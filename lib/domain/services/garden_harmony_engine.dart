import 'dart:math';

import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';
import '../models/user_settings.dart';

enum HarmonyLevel { thriving, balanced, developing, needsAttention }

class GardenHarmonyResult {
  const GardenHarmonyResult({
    required this.overallScore,
    required this.level,
    required this.healthScore,
    required this.consistencyScore,
    required this.diversityScore,
    required this.engagementScore,
    required this.trend,
  });

  final double overallScore;
  final HarmonyLevel level;
  final double healthScore;
  final double consistencyScore;
  final double diversityScore;
  final double engagementScore;
  final HarmonyTrend trend;
}

enum HarmonyTrend { improving, stable, declining }

class GardenHarmonyEngine {
  const GardenHarmonyEngine._();

  static GardenHarmonyResult compute({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required UserSettings settings,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();

    final healthScore = _computeHealthScore(activePlants, tasks, now);
    final consistencyScore = _computeConsistencyScore(tasks, now);
    final diversityScore = _computeDiversityScore(activePlants, logs);
    final engagementScore = _computeEngagementScore(logs, settings, now);

    final overall = (healthScore * 0.35 +
            consistencyScore * 0.25 +
            diversityScore * 0.15 +
            engagementScore * 0.25)
        .clamp(0.0, 1.0);

    final level = _levelFromScore(overall);
    final trend = _computeTrend(logs, tasks, now);

    return GardenHarmonyResult(
      overallScore: overall,
      level: level,
      healthScore: healthScore,
      consistencyScore: consistencyScore,
      diversityScore: diversityScore,
      engagementScore: engagementScore,
      trend: trend,
    );
  }

  static double _computeHealthScore(
      List<Plant> plants, List<TaskInstance> tasks, DateTime now) {
    if (plants.isEmpty) return 0.5;

    int healthyCount = 0;
    for (final plant in plants) {
      final plantTasks = tasks.where((t) =>
          t.plantId == plant.id && t.status == TaskStatus.pending);
      final hasOverdue = plantTasks.any((t) =>
          t.dueAt.isBefore(now.subtract(const Duration(days: 2))));
      if (!hasOverdue) healthyCount++;
    }
    return healthyCount / plants.length;
  }

  static double _computeConsistencyScore(
      List<TaskInstance> tasks, DateTime now) {
    final recentCompleted = tasks.where((t) =>
        t.status == TaskStatus.done &&
        t.completedAt != null &&
        now.difference(t.dueAt).inDays <= 30).toList();

    if (recentCompleted.length < 3) return 0.5;

    int onTime = 0;
    for (final task in recentCompleted) {
      if (task.completedAt!.difference(task.dueAt).inHours <= 24) {
        onTime++;
      }
    }
    return onTime / recentCompleted.length;
  }

  static double _computeDiversityScore(
      List<Plant> plants, List<CareLog> logs) {
    if (plants.isEmpty) return 0;

    final roomCount = plants.map((p) => p.room).toSet().length;
    final speciesCount = plants.map((p) => p.speciesId).toSet().length;
    final careTypes = logs.map((l) => l.type).toSet().length;

    final roomScore = min(roomCount / 3.0, 1.0);
    final speciesScore = min(speciesCount / 5.0, 1.0);
    final careScore = min(careTypes / 4.0, 1.0);

    return (roomScore * 0.3 + speciesScore * 0.4 + careScore * 0.3)
        .clamp(0.0, 1.0);
  }

  static double _computeEngagementScore(
      List<CareLog> logs, UserSettings settings, DateTime now) {
    final recentLogs = logs.where((l) =>
        now.difference(l.timestamp).inDays <= 14).length;

    final recencyScore = min(recentLogs / 10.0, 1.0);
    final streakScore = min(settings.careStreakDays / 14.0, 1.0);

    return (recencyScore * 0.6 + streakScore * 0.4).clamp(0.0, 1.0);
  }

  static HarmonyLevel _levelFromScore(double score) {
    if (score >= 0.8) return HarmonyLevel.thriving;
    if (score >= 0.6) return HarmonyLevel.balanced;
    if (score >= 0.4) return HarmonyLevel.developing;
    return HarmonyLevel.needsAttention;
  }

  static HarmonyTrend _computeTrend(
      List<CareLog> logs, List<TaskInstance> tasks, DateTime now) {
    final recentLogs = logs.where((l) =>
        now.difference(l.timestamp).inDays <= 7).length;
    final olderLogs = logs.where((l) =>
        now.difference(l.timestamp).inDays > 7 &&
        now.difference(l.timestamp).inDays <= 14).length;

    if (recentLogs > olderLogs + 2) return HarmonyTrend.improving;
    if (olderLogs > recentLogs + 2) return HarmonyTrend.declining;
    return HarmonyTrend.stable;
  }
}
