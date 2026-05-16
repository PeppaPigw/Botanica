import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/species.dart';

class ScheduleAdjustment {
  const ScheduleAdjustment({
    required this.plantId,
    required this.plantNickname,
    required this.taskType,
    required this.currentIntervalDays,
    required this.suggestedIntervalDays,
    required this.confidence,
    required this.reason,
  });

  final String plantId;
  final String plantNickname;
  final TaskType taskType;
  final int currentIntervalDays;
  final int suggestedIntervalDays;
  final double confidence;
  final String reason;

  int get daysDifference => suggestedIntervalDays - currentIntervalDays;
  bool get suggestsMoreFrequent => suggestedIntervalDays < currentIntervalDays;
}

class AdaptiveCareScheduler {
  const AdaptiveCareScheduler._();

  static List<ScheduleAdjustment> analyze({
    required List<Plant> plants,
    required List<Species> species,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final adjustments = <ScheduleAdjustment>[];

    for (final plant in plants.where((p) => !p.isArchived)) {
      final spec = species.where((s) => s.id == plant.speciesId).firstOrNull;
      if (spec == null) continue;

      _analyzeWatering(plant, spec, logs, adjustments, now);
      _analyzeFertilizing(plant, spec, logs, adjustments, now);
    }

    adjustments.sort((a, b) => b.confidence.compareTo(a.confidence));
    return adjustments.take(5).toList();
  }

  static void _analyzeWatering(
    Plant plant,
    Species spec,
    List<CareLog> logs,
    List<ScheduleAdjustment> out,
    DateTime now,
  ) {
    final waterLogs = logs
        .where((l) => l.plantId == plant.id && l.type == TaskType.water)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (waterLogs.length < 5) return;

    final recentLogs = waterLogs
        .where((l) => now.difference(l.timestamp).inDays <= 60)
        .toList();
    if (recentLogs.length < 4) return;

    final intervals = <int>[];
    for (int i = 1; i < recentLogs.length; i++) {
      final gap = recentLogs[i].timestamp
          .difference(recentLogs[i - 1].timestamp)
          .inDays;
      if (gap > 0 && gap <= 30) intervals.add(gap);
    }

    if (intervals.length < 3) return;

    intervals.sort();
    final median = intervals[intervals.length ~/ 2];
    final currentInterval = spec.careDefaults.waterBaseDays;

    final diff = (median - currentInterval).abs();
    if (diff < 2) return;

    final variance = _variance(intervals);
    final confidence = variance < 4.0 ? 0.85 : (variance < 9.0 ? 0.65 : 0.45);

    if (confidence < 0.5) return;

    final reason = median < currentInterval
        ? 'adjustNeedsMoreWater'
        : 'adjustNeedsLessWater';

    out.add(ScheduleAdjustment(
      plantId: plant.id,
      plantNickname: plant.nickname,
      taskType: TaskType.water,
      currentIntervalDays: currentInterval,
      suggestedIntervalDays: median,
      confidence: confidence,
      reason: reason,
    ));
  }

  static void _analyzeFertilizing(
    Plant plant,
    Species spec,
    List<CareLog> logs,
    List<ScheduleAdjustment> out,
    DateTime now,
  ) {
    final fertLogs = logs
        .where((l) => l.plantId == plant.id && l.type == TaskType.fertilize)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (fertLogs.length < 3) return;

    final recentLogs = fertLogs
        .where((l) => now.difference(l.timestamp).inDays <= 120)
        .toList();
    if (recentLogs.length < 3) return;

    final intervals = <int>[];
    for (int i = 1; i < recentLogs.length; i++) {
      final gap = recentLogs[i].timestamp
          .difference(recentLogs[i - 1].timestamp)
          .inDays;
      if (gap > 0 && gap <= 90) intervals.add(gap);
    }

    if (intervals.length < 2) return;

    intervals.sort();
    final median = intervals[intervals.length ~/ 2];
    final currentInterval = spec.careDefaults.fertilizeBaseDays;

    final diff = (median - currentInterval).abs();
    if (diff < 5) return;

    final variance = _variance(intervals);
    final confidence = variance < 25.0 ? 0.75 : 0.5;

    if (confidence < 0.5) return;

    out.add(ScheduleAdjustment(
      plantId: plant.id,
      plantNickname: plant.nickname,
      taskType: TaskType.fertilize,
      currentIntervalDays: currentInterval,
      suggestedIntervalDays: median,
      confidence: confidence,
      reason: median < currentInterval
          ? 'adjustFertilizeMore'
          : 'adjustFertilizeLess',
    ));
  }

  static double _variance(List<int> values) {
    if (values.isEmpty) return 0;
    final mean = values.fold<int>(0, (s, v) => s + v) / values.length;
    final sumSquares = values.fold<double>(
        0, (s, v) => s + (v - mean) * (v - mean));
    return sumSquares / values.length;
  }
}
