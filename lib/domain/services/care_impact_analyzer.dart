import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';

class CareImpactSummary {
  const CareImpactSummary({
    required this.totalCareActions,
    required this.totalWateringEvents,
    required this.plantsSavedFromDecline,
    required this.longestCaredPlantDays,
    required this.longestCaredPlantName,
    required this.uniqueCareTypes,
    required this.busiestMonth,
    required this.averageResponseTimeHours,
    required this.impactScore,
  });

  final int totalCareActions;
  final int totalWateringEvents;
  final int plantsSavedFromDecline;
  final int longestCaredPlantDays;
  final String longestCaredPlantName;
  final int uniqueCareTypes;
  final int? busiestMonth;
  final double? averageResponseTimeHours;
  final double impactScore;
}

class CareImpactAnalyzer {
  const CareImpactAnalyzer._();

  static CareImpactSummary? analyze({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
  }) {
    if (logs.isEmpty) return null;

    final activePlants = plants.where((p) => !p.isArchived).toList();

    final totalCare = logs.length;
    final totalWater = logs.where((l) => l.type == TaskType.water).length;
    final uniqueTypes = logs.map((l) => l.type).toSet().length;

    final savedCount = _plantsSavedFromDecline(activePlants, logs, tasks, now);

    String longestName = '';
    int longestDays = 0;
    for (final plant in activePlants) {
      final days = now.difference(plant.createdAt).inDays;
      final hasRecentCare = logs.any((l) =>
          l.plantId == plant.id &&
          now.difference(l.timestamp).inDays < 30);
      if (days > longestDays && hasRecentCare) {
        longestDays = days;
        longestName = plant.nickname;
      }
    }

    final busiestMonth = _busiestMonth(logs);
    final avgResponse = _averageResponseTime(tasks);

    final impactScore = _computeImpactScore(
      totalCare: totalCare,
      savedCount: savedCount,
      longestDays: longestDays,
      uniqueTypes: uniqueTypes,
      avgResponse: avgResponse,
    );

    return CareImpactSummary(
      totalCareActions: totalCare,
      totalWateringEvents: totalWater,
      plantsSavedFromDecline: savedCount,
      longestCaredPlantDays: longestDays,
      longestCaredPlantName: longestName,
      uniqueCareTypes: uniqueTypes,
      busiestMonth: busiestMonth,
      averageResponseTimeHours: avgResponse,
      impactScore: impactScore,
    );
  }

  static int _plantsSavedFromDecline(
    List<Plant> plants,
    List<CareLog> logs,
    List<TaskInstance> tasks,
    DateTime now,
  ) {
    int saved = 0;
    for (final plant in plants) {
      final overdueTasks = tasks.where((t) =>
          t.plantId == plant.id &&
          t.status == TaskStatus.done &&
          t.completedAt != null &&
          t.completedAt!.difference(t.dueAt).inHours > 48);
      if (overdueTasks.length >= 2) {
        final recentCare = logs.any((l) =>
            l.plantId == plant.id &&
            now.difference(l.timestamp).inDays < 14);
        if (recentCare) saved++;
      }
    }
    return saved;
  }

  static int? _busiestMonth(List<CareLog> logs) {
    if (logs.length < 10) return null;
    final monthCounts = List.filled(12, 0);
    for (final log in logs) {
      monthCounts[log.timestamp.month - 1]++;
    }
    int maxCount = 0;
    int? maxMonth;
    for (int m = 0; m < 12; m++) {
      if (monthCounts[m] > maxCount) {
        maxCount = monthCounts[m];
        maxMonth = m + 1;
      }
    }
    return maxMonth;
  }

  static double? _averageResponseTime(List<TaskInstance> tasks) {
    final completed = tasks.where((t) =>
        t.status == TaskStatus.done && t.completedAt != null).toList();
    if (completed.length < 3) return null;
    double totalHours = 0;
    for (final task in completed) {
      totalHours +=
          task.completedAt!.difference(task.dueAt).inMinutes / 60.0;
    }
    return totalHours / completed.length;
  }

  static double _computeImpactScore({
    required int totalCare,
    required int savedCount,
    required int longestDays,
    required int uniqueTypes,
    required double? avgResponse,
  }) {
    double score = 0;
    score += (totalCare / 100.0).clamp(0.0, 0.3);
    score += (savedCount * 0.1).clamp(0.0, 0.2);
    score += (longestDays / 365.0).clamp(0.0, 0.2);
    score += (uniqueTypes / 6.0).clamp(0.0, 0.15);
    if (avgResponse != null && avgResponse < 24) {
      score += 0.15;
    }
    return score.clamp(0.0, 1.0);
  }
}
