import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class DelegationTask {
  const DelegationTask({
    required this.plantId,
    required this.plantNickname,
    required this.taskType,
    required this.frequencyDays,
    required this.instructions,
    required this.priority,
  });

  final String plantId;
  final String plantNickname;
  final TaskType taskType;
  final int frequencyDays;
  final String instructions;
  final int priority;
}

class CareDelegationPlan {
  const CareDelegationPlan({
    required this.startDate,
    required this.endDate,
    required this.tasks,
    required this.totalTaskCount,
    required this.criticalPlants,
    required this.summaryKey,
  });

  final DateTime startDate;
  final DateTime endDate;
  final List<DelegationTask> tasks;
  final int totalTaskCount;
  final List<String> criticalPlants;
  final String summaryKey;
}

class CareDelegationEngine {
  const CareDelegationEngine._();

  static CareDelegationPlan generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required Map<String, int> speciesWaterDays,
    required DateTime startDate,
    required DateTime endDate,
    required Season currentSeason,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final durationDays = endDate.difference(startDate).inDays;
    final tasks = <DelegationTask>[];
    final criticalPlants = <String>[];

    for (final plant in activePlants) {
      final waterDays = speciesWaterDays[plant.speciesId] ?? 7;
      final adjustedDays = _seasonAdjust(waterDays, currentSeason);

      if (durationDays >= adjustedDays) {
        final priority = _priority(adjustedDays, durationDays);
        if (priority >= 8) criticalPlants.add(plant.id);

        tasks.add(DelegationTask(
          plantId: plant.id,
          plantNickname: plant.nickname,
          taskType: TaskType.water,
          frequencyDays: adjustedDays,
          instructions: 'delegationWaterInstructions',
          priority: priority,
        ));
      }

      if (durationDays >= 14) {
        tasks.add(DelegationTask(
          plantId: plant.id,
          plantNickname: plant.nickname,
          taskType: TaskType.mist,
          frequencyDays: 3,
          instructions: 'delegationMistInstructions',
          priority: 4,
        ));
      }
    }

    tasks.sort((a, b) => b.priority.compareTo(a.priority));

    final totalCount = tasks.fold<int>(0, (sum, t) =>
        sum + (durationDays / t.frequencyDays).ceil());

    final summaryKey = durationDays <= 3
        ? 'delegationShortTrip'
        : durationDays <= 7
            ? 'delegationWeekAway'
            : 'delegationExtendedAbsence';

    return CareDelegationPlan(
      startDate: startDate,
      endDate: endDate,
      tasks: tasks,
      totalTaskCount: totalCount,
      criticalPlants: criticalPlants,
      summaryKey: summaryKey,
    );
  }

  static int _seasonAdjust(int baseDays, Season season) {
    switch (season) {
      case Season.summer: return (baseDays * 0.7).round().clamp(1, 30);
      case Season.winter: return (baseDays * 1.4).round().clamp(1, 30);
      default: return baseDays;
    }
  }

  static int _priority(int waterDays, int durationDays) {
    final ratio = durationDays / waterDays;
    if (ratio >= 4) return 10;
    if (ratio >= 2) return 8;
    if (ratio >= 1) return 6;
    return 4;
  }
}
