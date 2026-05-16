import '../models/care_log.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';
import 'plant_health_score.dart';

enum CareMomentum { increasing, stable, decreasing }

class GardenWellnessSummary {
  const GardenWellnessSummary({
    required this.plantCount,
    required this.overallScore,
    required this.overdueTasks,
    required this.dueTodayTasks,
    required this.recentlyCaredPlants,
    required this.atRiskPlants,
    required this.focusPlants,
    required this.punctualityPercent,
    required this.weeklyActivePercent,
    required this.careMomentum,
  });

  final int plantCount;
  final int overallScore;
  final int overdueTasks;
  final int dueTodayTasks;
  final int recentlyCaredPlants;
  final int atRiskPlants;
  final List<GardenFocusPlant> focusPlants;
  final int punctualityPercent;
  final int weeklyActivePercent;
  final CareMomentum careMomentum;

  bool get isEmpty => plantCount == 0;

  static GardenWellnessSummary compute({
    required List<Plant> plants,
    required List<TaskInstance> tasks,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    if (plants.isEmpty) {
      return const GardenWellnessSummary(
        plantCount: 0,
        overallScore: 0,
        overdueTasks: 0,
        dueTodayTasks: 0,
        recentlyCaredPlants: 0,
        atRiskPlants: 0,
        focusPlants: <GardenFocusPlant>[],
        punctualityPercent: 100,
        weeklyActivePercent: 0,
        careMomentum: CareMomentum.stable,
      );
    }

    final focusPlants = plants.map((plant) {
      final plantTasks = tasks
          .where((task) => task.plantId == plant.id)
          .toList(growable: false);
      final plantLogs =
          logs.where((log) => log.plantId == plant.id).toList(growable: false);
      final score = PlantHealthScore.compute(
        allTasks: plantTasks,
        recentLogs: plantLogs,
        now: now,
      );
      final overdueTasks =
          plantTasks.where((task) => task.isOverdueAt(now)).length;
      final hasRecentLog = plantLogs.any(
        (log) => now.difference(log.timestamp).inDays <= 14,
      );

      return GardenFocusPlant(
        plant: plant,
        score: score,
        overdueTasks: overdueTasks,
        hasRecentLog: hasRecentLog,
      );
    }).toList(growable: false)
      ..sort(_compareFocusPlants);

    final overallScore =
        (focusPlants.fold<int>(0, (sum, plant) => sum + plant.score) /
                focusPlants.length)
            .round();

    final completedTasks =
        tasks.where((t) => t.isDone).toList(growable: false);
    final punctuality = completedTasks.isEmpty
        ? 100
        : ((completedTasks
                    .where((t) =>
                        t.completedAt != null &&
                        !t.completedAt!.isAfter(
                          t.dueAt.add(const Duration(days: 1)),
                        ))
                    .length /
                completedTasks.length) *
            100)
            .round();

    // Weekly active: % of last 8 weeks with at least one care log
    const weekCount = 8;
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: weekCount * 7));
    final recentLogs = logs.where((l) => l.timestamp.isAfter(weekStart));
    final activeWeeks = <int>{};
    for (final log in recentLogs) {
      final weekIndex = log.timestamp.difference(weekStart).inDays ~/ 7;
      activeWeeks.add(weekIndex);
    }
    final weeklyActive =
        ((activeWeeks.length / weekCount) * 100).round().clamp(0, 100);

    // Care momentum: compare this week's logs to last week's
    final thisWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final thisWeekLogs =
        logs.where((l) => l.timestamp.isAfter(thisWeekStart)).length;
    final lastWeekLogs = logs
        .where((l) =>
            l.timestamp.isAfter(lastWeekStart) &&
            !l.timestamp.isAfter(thisWeekStart))
        .length;
    final CareMomentum momentum;
    if (lastWeekLogs == 0 && thisWeekLogs == 0) {
      momentum = CareMomentum.stable;
    } else if (thisWeekLogs > lastWeekLogs) {
      momentum = CareMomentum.increasing;
    } else if (thisWeekLogs < lastWeekLogs && lastWeekLogs - thisWeekLogs >= 2) {
      momentum = CareMomentum.decreasing;
    } else {
      momentum = CareMomentum.stable;
    }

    return GardenWellnessSummary(
      plantCount: plants.length,
      overallScore: overallScore,
      overdueTasks: tasks.where((task) => task.isOverdueAt(now)).length,
      dueTodayTasks: tasks.where((task) => _isDueToday(task, now)).length,
      recentlyCaredPlants:
          focusPlants.where((plant) => plant.hasRecentLog).length,
      atRiskPlants: focusPlants.where((plant) => plant.score < 80).length,
      focusPlants: focusPlants,
      punctualityPercent: punctuality,
      weeklyActivePercent: weeklyActive,
      careMomentum: momentum,
    );
  }

  static int _compareFocusPlants(GardenFocusPlant a, GardenFocusPlant b) {
    final score = a.score.compareTo(b.score);
    if (score != 0) return score;

    final overdue = b.overdueTasks.compareTo(a.overdueTasks);
    if (overdue != 0) return overdue;

    final recent = (a.hasRecentLog ? 1 : 0).compareTo(b.hasRecentLog ? 1 : 0);
    if (recent != 0) return recent;

    return a.plant.nickname.compareTo(b.plant.nickname);
  }

  static bool _isDueToday(TaskInstance task, DateTime now) {
    if (task.isDismissed) return false;
    final dueAt = task.dueAt;
    return dueAt.year == now.year &&
        dueAt.month == now.month &&
        dueAt.day == now.day;
  }
}

class GardenFocusPlant {
  const GardenFocusPlant({
    required this.plant,
    required this.score,
    required this.overdueTasks,
    required this.hasRecentLog,
  });

  final Plant plant;
  final int score;
  final int overdueTasks;
  final bool hasRecentLog;
}
