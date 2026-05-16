import 'dart:math';

import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';

enum ConsistencyGrade { excellent, good, fair, inconsistent }

class CareConsistencyResult {
  const CareConsistencyResult({
    required this.plantId,
    required this.grade,
    required this.score,
    required this.averageDelayHours,
    required this.onTimePercentage,
    required this.improvingTrend,
  });

  final String plantId;
  final ConsistencyGrade grade;
  final double score;
  final double averageDelayHours;
  final double onTimePercentage;
  final bool improvingTrend;
}

class CareConsistencyScorer {
  const CareConsistencyScorer._();

  static CareConsistencyResult? score({
    required Plant plant,
    required List<TaskInstance> tasks,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    if (plant.isArchived) return null;

    final completedTasks = tasks
        .where((t) =>
            t.plantId == plant.id &&
            t.status == TaskStatus.done &&
            t.completedAt != null)
        .toList();

    if (completedTasks.length < 5) return null;

    completedTasks.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    final delays = <double>[];
    int onTimeCount = 0;

    for (final task in completedTasks) {
      final delayHours =
          task.completedAt!.difference(task.dueAt).inMinutes / 60.0;
      delays.add(delayHours);
      if (delayHours <= 24) onTimeCount++;
    }

    final averageDelay =
        delays.reduce((a, b) => a + b) / delays.length;
    final onTimePercentage = onTimeCount / completedTasks.length;

    final recentHalf = delays.sublist(delays.length ~/ 2);
    final olderHalf = delays.sublist(0, delays.length ~/ 2);
    final recentAvg = recentHalf.reduce((a, b) => a + b) / recentHalf.length;
    final olderAvg = olderHalf.reduce((a, b) => a + b) / olderHalf.length;
    final improving = recentAvg < olderAvg;

    final variance = _computeVariance(delays);
    final consistencyScore = _computeScore(
      onTimePercentage: onTimePercentage,
      averageDelay: averageDelay,
      variance: variance,
    );

    final grade = _gradeFromScore(consistencyScore);

    return CareConsistencyResult(
      plantId: plant.id,
      grade: grade,
      score: consistencyScore,
      averageDelayHours: averageDelay,
      onTimePercentage: onTimePercentage,
      improvingTrend: improving,
    );
  }

  static Map<String, CareConsistencyResult> scoreAll({
    required List<Plant> plants,
    required List<TaskInstance> tasks,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final results = <String, CareConsistencyResult>{};
    for (final plant in plants) {
      final result = score(plant: plant, tasks: tasks, logs: logs, now: now);
      if (result != null) {
        results[plant.id] = result;
      }
    }
    return results;
  }

  static double gardenConsistencyScore(
      Map<String, CareConsistencyResult> results) {
    if (results.isEmpty) return 0;
    final total = results.values.map((r) => r.score).reduce((a, b) => a + b);
    return total / results.length;
  }

  static double _computeVariance(List<double> values) {
    if (values.length < 2) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumSquares =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b);
    return sumSquares / values.length;
  }

  static double _computeScore({
    required double onTimePercentage,
    required double averageDelay,
    required double variance,
  }) {
    final timingScore = onTimePercentage;
    final delayPenalty = (1.0 - (averageDelay.abs() / 72.0)).clamp(0.0, 1.0);
    final variancePenalty =
        (1.0 - (sqrt(variance) / 48.0)).clamp(0.0, 1.0);

    return (timingScore * 0.5 + delayPenalty * 0.3 + variancePenalty * 0.2)
        .clamp(0.0, 1.0);
  }

  static ConsistencyGrade _gradeFromScore(double score) {
    if (score >= 0.85) return ConsistencyGrade.excellent;
    if (score >= 0.65) return ConsistencyGrade.good;
    if (score >= 0.45) return ConsistencyGrade.fair;
    return ConsistencyGrade.inconsistent;
  }
}
