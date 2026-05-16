import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';

class HealthSnapshot {
  const HealthSnapshot({
    required this.date,
    required this.score,
    required this.factors,
  });

  final DateTime date;
  final double score;
  final List<String> factors;
}

class HealthTimeline {
  const HealthTimeline({
    required this.plantId,
    required this.plantNickname,
    required this.snapshots,
    required this.trend,
    required this.bestWeek,
    required this.worstWeek,
  });

  final String plantId;
  final String plantNickname;
  final List<HealthSnapshot> snapshots;
  final double trend;
  final DateTime? bestWeek;
  final DateTime? worstWeek;
}

class PlantHealthTimeline {
  const PlantHealthTimeline._();

  static HealthTimeline? generate({
    required Plant plant,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
  }) {
    if (plant.isArchived) return null;

    final plantLogs = logs.where((l) => l.plantId == plant.id).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final plantTasks = tasks.where((t) => t.plantId == plant.id).toList();

    if (plantLogs.length < 4) return null;

    final firstLog = plantLogs.first.timestamp;
    final weeksAvailable = now.difference(firstLog).inDays ~/ 7;
    if (weeksAvailable < 2) return null;

    final snapshots = <HealthSnapshot>[];
    final weeksToAnalyze = weeksAvailable.clamp(2, 12);

    for (int w = weeksToAnalyze - 1; w >= 0; w--) {
      final weekEnd = now.subtract(Duration(days: w * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 7));

      final weekLogs = plantLogs.where((l) =>
          l.timestamp.isAfter(weekStart) &&
          !l.timestamp.isAfter(weekEnd)).toList();

      final weekTasks = plantTasks.where((t) =>
          t.dueAt.isAfter(weekStart) && t.dueAt.isBefore(weekEnd)).toList();

      final score = _weekScore(weekLogs, weekTasks, weekEnd);
      final factors = _weekFactors(weekLogs, weekTasks);

      snapshots.add(HealthSnapshot(
        date: weekEnd,
        score: score,
        factors: factors,
      ));
    }

    if (snapshots.length < 2) return null;

    final trend = _calculateTrend(snapshots);
    final bestWeek = _findBestWeek(snapshots);
    final worstWeek = _findWorstWeek(snapshots);

    return HealthTimeline(
      plantId: plant.id,
      plantNickname: plant.nickname,
      snapshots: snapshots,
      trend: trend,
      bestWeek: bestWeek,
      worstWeek: worstWeek,
    );
  }

  static double _weekScore(
    List<CareLog> logs,
    List<TaskInstance> tasks,
    DateTime weekEnd,
  ) {
    double score = 0.5;

    final careCount = logs.length;
    if (careCount >= 3) {
      score += 0.2;
    } else if (careCount >= 1) {
      score += 0.1;
    } else {
      score -= 0.2;
    }

    final careTypes = logs.map((l) => l.type).toSet().length;
    if (careTypes >= 3) score += 0.1;

    final completedTasks = tasks.where((t) => t.isDone).length;
    final totalTasks = tasks.length;
    if (totalTasks > 0) {
      final completionRate = completedTasks / totalTasks;
      score += (completionRate - 0.5) * 0.3;
    }

    final overdue = tasks.where((t) =>
        t.status == TaskStatus.pending &&
        t.dueAt.isBefore(weekEnd)).length;
    score -= overdue * 0.1;

    return score.clamp(0.0, 1.0);
  }

  static List<String> _weekFactors(
      List<CareLog> logs, List<TaskInstance> tasks) {
    final factors = <String>[];

    if (logs.isEmpty) {
      factors.add('noCare');
    } else if (logs.length >= 3) {
      factors.add('activeCare');
    }

    final types = logs.map((l) => l.type).toSet();
    if (types.length >= 3) factors.add('diverseCare');

    final overdue = tasks.where((t) => t.status == TaskStatus.pending).length;
    if (overdue >= 2) factors.add('overdueTasks');

    final allDone = tasks.isNotEmpty && tasks.every((t) => t.isDone);
    if (allDone && tasks.length >= 2) factors.add('allTasksDone');

    return factors;
  }

  static double _calculateTrend(List<HealthSnapshot> snapshots) {
    if (snapshots.length < 3) {
      return snapshots.last.score - snapshots.first.score;
    }

    final halfPoint = snapshots.length ~/ 2;
    final firstHalf = snapshots.sublist(0, halfPoint);
    final secondHalf = snapshots.sublist(halfPoint);

    final firstAvg =
        firstHalf.fold<double>(0, (s, h) => s + h.score) / firstHalf.length;
    final secondAvg =
        secondHalf.fold<double>(0, (s, h) => s + h.score) / secondHalf.length;

    return secondAvg - firstAvg;
  }

  static DateTime? _findBestWeek(List<HealthSnapshot> snapshots) {
    if (snapshots.isEmpty) return null;
    final best = snapshots.reduce((a, b) => a.score >= b.score ? a : b);
    return best.date;
  }

  static DateTime? _findWorstWeek(List<HealthSnapshot> snapshots) {
    if (snapshots.isEmpty) return null;
    final worst = snapshots.reduce((a, b) => a.score <= b.score ? a : b);
    return worst.date;
  }
}
