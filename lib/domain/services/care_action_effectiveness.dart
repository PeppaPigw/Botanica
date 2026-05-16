import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class ActionEffect {
  const ActionEffect({
    required this.taskType,
    required this.healthDelta,
    required this.occurrences,
    required this.effectivenessScore,
  });

  final TaskType taskType;
  final double healthDelta;
  final int occurrences;
  final double effectivenessScore;
}

class EffectivenessReport {
  const EffectivenessReport({
    required this.plantId,
    required this.effects,
    required this.bestAction,
    required this.worstAction,
    required this.overallScore,
  });

  final String plantId;
  final List<ActionEffect> effects;
  final TaskType? bestAction;
  final TaskType? worstAction;
  final double overallScore;
}

class CareActionEffectiveness {
  const CareActionEffectiveness._();

  static EffectivenessReport evaluate({
    required Plant plant,
    required List<CareLog> logs,
    required List<MapEntry<DateTime, double>> healthTimeline,
    required DateTime now,
  }) {
    final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
    if (plantLogs.isEmpty || healthTimeline.length < 2) {
      return EffectivenessReport(
        plantId: plant.id, effects: const [],
        bestAction: null, worstAction: null, overallScore: 0.5,
      );
    }

    final byType = <TaskType, List<CareLog>>{};
    for (final log in plantLogs) {
      byType.putIfAbsent(log.type, () => []).add(log);
    }

    final effects = <ActionEffect>[];
    for (final entry in byType.entries) {
      effects.add(_measureEffect(entry.key, entry.value, healthTimeline));
    }

    effects.sort((a, b) => b.effectivenessScore.compareTo(a.effectivenessScore));

    final best = effects.isNotEmpty ? effects.first.taskType : null;
    final worst = effects.length > 1 ? effects.last.taskType : null;
    final overall = effects.isEmpty ? 0.5
        : effects.map((e) => e.effectivenessScore).reduce((a, b) => a + b) / effects.length;

    return EffectivenessReport(
      plantId: plant.id, effects: effects,
      bestAction: best, worstAction: worst,
      overallScore: overall.clamp(0.0, 1.0),
    );
  }

  static ActionEffect _measureEffect(
      TaskType type, List<CareLog> logs, List<MapEntry<DateTime, double>> timeline) {
    double totalDelta = 0;
    int measured = 0;

    for (final log in logs) {
      final before = _nearestHealth(timeline, log.timestamp, lookBack: true);
      final after = _nearestHealth(timeline, log.timestamp, lookBack: false);
      if (before != null && after != null) {
        totalDelta += after - before;
        measured++;
      }
    }

    final avgDelta = measured > 0 ? totalDelta / measured : 0.0;
    final score = (avgDelta + 0.5).clamp(0.0, 1.0);

    return ActionEffect(
      taskType: type, healthDelta: avgDelta,
      occurrences: logs.length, effectivenessScore: score,
    );
  }

  static double? _nearestHealth(
      List<MapEntry<DateTime, double>> timeline, DateTime target,
      {required bool lookBack}) {
    MapEntry<DateTime, double>? best;
    for (final entry in timeline) {
      final diff = entry.key.difference(target).inDays;
      if (lookBack && diff <= 0 && diff >= -7) {
        if (best == null || entry.key.isAfter(best.key)) best = entry;
      }
      if (!lookBack && diff >= 1 && diff <= 7) {
        if (best == null || entry.key.isBefore(best.key)) best = entry;
      }
    }
    return best?.value;
  }
}
