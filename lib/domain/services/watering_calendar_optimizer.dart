import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';

class WateringDay {
  const WateringDay({
    required this.weekday,
    required this.plantIds,
    required this.plantNicknames,
  });

  final int weekday;
  final List<String> plantIds;
  final List<String> plantNicknames;
}

class WateringScheduleOptimization {
  const WateringScheduleOptimization({
    required this.optimizedDays,
    required this.currentActiveDays,
    required this.optimizedActiveDays,
    required this.daysSaved,
  });

  final List<WateringDay> optimizedDays;
  final int currentActiveDays;
  final int optimizedActiveDays;
  final int daysSaved;
}

class WateringCalendarOptimizer {
  const WateringCalendarOptimizer._();

  static WateringScheduleOptimization? optimize({
    required List<Plant> plants,
    required List<TaskInstance> tasks,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 3) return null;

    final intervals = <String, int>{};
    for (final plant in activePlants) {
      final waterTasks = tasks
          .where((t) => t.plantId == plant.id && t.type == TaskType.water)
          .toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

      if (waterTasks.length >= 2) {
        final gaps = <int>[];
        for (int i = 1; i < waterTasks.length; i++) {
          gaps.add(waterTasks[i].dueAt.difference(waterTasks[i - 1].dueAt).inDays);
        }
        final avg = gaps.fold<int>(0, (s, g) => s + g) ~/ gaps.length;
        if (avg > 0 && avg <= 14) {
          intervals[plant.id] = avg;
        }
      }
    }

    if (intervals.length < 3) return null;

    final groups = _groupByInterval(intervals, activePlants);
    final optimized = _assignDays(groups, now);

    final currentDays = _countCurrentActiveDays(tasks, activePlants, now);

    if (optimized.length >= currentDays) return null;

    return WateringScheduleOptimization(
      optimizedDays: optimized,
      currentActiveDays: currentDays,
      optimizedActiveDays: optimized.length,
      daysSaved: currentDays - optimized.length,
    );
  }

  static Map<int, List<Plant>> _groupByInterval(
      Map<String, int> intervals, List<Plant> plants) {
    final groups = <int, List<Plant>>{};

    for (final entry in intervals.entries) {
      final plant = plants.where((p) => p.id == entry.key).firstOrNull;
      if (plant == null) continue;

      final interval = entry.value;
      final bucket = _bucketInterval(interval);
      groups.putIfAbsent(bucket, () => []).add(plant);
    }

    return groups;
  }

  static int _bucketInterval(int interval) {
    if (interval <= 2) return 2;
    if (interval <= 4) return 3;
    if (interval <= 7) return 7;
    return 14;
  }

  static List<WateringDay> _assignDays(
      Map<int, List<Plant>> groups, DateTime now) {
    final dayAssignments = <int, List<Plant>>{};
    final startWeekday = now.weekday;

    final sortedBuckets = groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    int nextDay = startWeekday;
    for (final entry in sortedBuckets) {
      final bucket = entry.key;
      final plantsInGroup = entry.value;

      if (bucket <= 3) {
        dayAssignments.putIfAbsent(1, () => []).addAll(plantsInGroup);
        dayAssignments.putIfAbsent(4, () => []).addAll(plantsInGroup);
        if (bucket <= 2) {
          dayAssignments.putIfAbsent(6, () => []).addAll(plantsInGroup);
        }
      } else if (bucket <= 7) {
        dayAssignments.putIfAbsent(nextDay, () => []).addAll(plantsInGroup);
        nextDay = (nextDay % 7) + 1;
      } else {
        final biweeklyDay = (nextDay + 2) % 7 + 1;
        dayAssignments.putIfAbsent(biweeklyDay, () => []).addAll(plantsInGroup);
      }
    }

    return dayAssignments.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => WateringDay(
              weekday: e.key,
              plantIds: e.value.map((p) => p.id).toList(),
              plantNicknames: e.value.map((p) => p.nickname).toList(),
            ))
        .toList()
      ..sort((a, b) => a.weekday.compareTo(b.weekday));
  }

  static int _countCurrentActiveDays(
      List<TaskInstance> tasks, List<Plant> plants, DateTime now) {
    final plantIds = plants.map((p) => p.id).toSet();
    final upcoming = tasks.where((t) =>
        plantIds.contains(t.plantId) &&
        t.type == TaskType.water &&
        !t.isDismissed &&
        t.dueAt.isAfter(now) &&
        t.dueAt.isBefore(now.add(const Duration(days: 14))));

    final days = upcoming.map((t) => t.dueAt.weekday).toSet();
    return days.length.clamp(1, 7);
  }
}
