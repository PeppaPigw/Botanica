import '../models/care_log.dart';
import '../models/task_instance.dart';

class HealthFactor {
  const HealthFactor({
    required this.id,
    required this.points,
    required this.maxPoints,
  });

  final String id;
  final int points;
  final int maxPoints;

  bool get isPerfect => points == maxPoints;
}

class HealthBreakdown {
  const HealthBreakdown({
    required this.totalScore,
    required this.factors,
  });

  final int totalScore;
  final List<HealthFactor> factors;
}

class PlantHealthScore {
  const PlantHealthScore._();

  static const int _maxOverduePenalty = 50;
  static const int _maxInactivityPenalty = 10;
  static const int _maxVarietyBonus = 10;
  static const int _maxConsistencyBonus = 15;

  static int compute({
    required List<TaskInstance> allTasks,
    required List<CareLog> recentLogs,
    required DateTime now,
  }) {
    var score = 100;

    final overdueCount = allTasks.where((t) => t.isOverdueAt(now)).length;
    score -= (overdueCount * 10).clamp(0, _maxOverduePenalty);

    final hasRecentLog = recentLogs.any(
      (l) => now.difference(l.timestamp).inDays <= 14,
    );
    if (!hasRecentLog) score -= _maxInactivityPenalty;

    return score.clamp(0, 100);
  }

  static HealthBreakdown breakdown({
    required List<TaskInstance> allTasks,
    required List<CareLog> recentLogs,
    required DateTime now,
  }) {
    final factors = <HealthFactor>[];

    final overdueCount = allTasks.where((t) => t.isOverdueAt(now)).length;
    final overduePenalty = (overdueCount * 10).clamp(0, _maxOverduePenalty);
    factors.add(HealthFactor(
      id: 'overdue',
      points: _maxOverduePenalty - overduePenalty,
      maxPoints: _maxOverduePenalty,
    ));

    final hasRecentLog = recentLogs.any(
      (l) => now.difference(l.timestamp).inDays <= 14,
    );
    factors.add(HealthFactor(
      id: 'activity',
      points: hasRecentLog ? _maxInactivityPenalty : 0,
      maxPoints: _maxInactivityPenalty,
    ));

    final recentTypes = recentLogs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .map((l) => l.type)
        .toSet();
    final varietyScore =
        (recentTypes.length * 3).clamp(0, _maxVarietyBonus);
    factors.add(HealthFactor(
      id: 'variety',
      points: varietyScore,
      maxPoints: _maxVarietyBonus,
    ));

    final completedTasks =
        allTasks.where((t) => t.isDone && t.completedAt != null).toList();
    int onTimeCount = 0;
    for (final t in completedTasks) {
      final diff = t.completedAt!.difference(t.dueAt).inDays;
      if (diff <= 1) onTimeCount++;
    }
    final consistencyRate = completedTasks.isEmpty
        ? 1.0
        : onTimeCount / completedTasks.length;
    final consistencyScore =
        (consistencyRate * _maxConsistencyBonus).round();
    factors.add(HealthFactor(
      id: 'consistency',
      points: consistencyScore,
      maxPoints: _maxConsistencyBonus,
    ));

    final totalScore = compute(allTasks: allTasks, recentLogs: recentLogs, now: now);

    return HealthBreakdown(totalScore: totalScore, factors: factors);
  }
}
