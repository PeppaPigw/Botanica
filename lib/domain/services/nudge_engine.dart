import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';

enum NudgeType {
  forgottenRotation,
  longSinceFertilize,
  seasonalWaterReduction,
  newPlantCheckUp,
  dustyLeaves,
  growthSpurt,
}

enum NudgePriority { low, medium, high }

class CareNudge {
  const CareNudge({
    required this.type,
    required this.plantId,
    required this.plantNickname,
    required this.priority,
    required this.messageKey,
    required this.args,
  });

  final NudgeType type;
  final String plantId;
  final String plantNickname;
  final NudgePriority priority;
  final String messageKey;
  final Map<String, String> args;
}

class NudgeEngine {
  const NudgeEngine._();

  static List<CareNudge> generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
    required bool isWinter,
    int maxNudges = 2,
  }) {
    final nudges = <CareNudge>[];

    for (final plant in plants) {
      if (plant.isArchived) continue;

      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();

      final rotation = _checkRotation(plant, plantLogs, now);
      if (rotation != null) nudges.add(rotation);

      final fertilize = _checkFertilize(plant, plantLogs, now, isWinter);
      if (fertilize != null) nudges.add(fertilize);

      final newPlant = _checkNewPlant(plant, plantLogs, now);
      if (newPlant != null) nudges.add(newPlant);

      final dusty = _checkDustyLeaves(plant, plantLogs, now);
      if (dusty != null) nudges.add(dusty);

      if (!isWinter) {
        final growth = _checkGrowthSpurt(plant, plantLogs, now);
        if (growth != null) nudges.add(growth);
      }
    }

    nudges.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return nudges.take(maxNudges).toList();
  }

  static CareNudge? _checkRotation(
      Plant plant, List<CareLog> logs, DateTime now) {
    final lastRotate = _lastLogOfType(logs, TaskType.rotate);
    if (lastRotate == null) return null;

    final daysSince = now.difference(lastRotate.timestamp).inDays;
    if (daysSince < 21) return null;

    return CareNudge(
      type: NudgeType.forgottenRotation,
      plantId: plant.id,
      plantNickname: plant.nickname,
      priority: NudgePriority.low,
      messageKey: 'nudgeRotation',
      args: {'plant': plant.nickname, 'days': daysSince.toString()},
    );
  }

  static CareNudge? _checkFertilize(
      Plant plant, List<CareLog> logs, DateTime now, bool isWinter) {
    if (isWinter) return null;

    final lastFert = _lastLogOfType(logs, TaskType.fertilize);
    final daysSince = lastFert == null
        ? now.difference(plant.createdAt).inDays
        : now.difference(lastFert.timestamp).inDays;

    if (daysSince < 35) return null;

    return CareNudge(
      type: NudgeType.longSinceFertilize,
      plantId: plant.id,
      plantNickname: plant.nickname,
      priority: NudgePriority.medium,
      messageKey: 'nudgeFertilize',
      args: {'plant': plant.nickname, 'days': daysSince.toString()},
    );
  }

  static CareNudge? _checkNewPlant(
      Plant plant, List<CareLog> logs, DateTime now) {
    final age = now.difference(plant.createdAt).inDays;
    if (age < 7 || age > 14) return null;

    final logCount = logs.length;
    if (logCount >= 3) return null;

    return CareNudge(
      type: NudgeType.newPlantCheckUp,
      plantId: plant.id,
      plantNickname: plant.nickname,
      priority: NudgePriority.medium,
      messageKey: 'nudgeNewPlant',
      args: {'plant': plant.nickname},
    );
  }

  static CareNudge? _checkDustyLeaves(
      Plant plant, List<CareLog> logs, DateTime now) {
    final lastWipe = _lastLogOfType(logs, TaskType.wipeLeaves);
    if (lastWipe == null) {
      final age = now.difference(plant.createdAt).inDays;
      if (age < 30) return null;
    } else {
      final daysSince = now.difference(lastWipe.timestamp).inDays;
      if (daysSince < 21) return null;
    }

    return CareNudge(
      type: NudgeType.dustyLeaves,
      plantId: plant.id,
      plantNickname: plant.nickname,
      priority: NudgePriority.low,
      messageKey: 'nudgeDustyLeaves',
      args: {'plant': plant.nickname},
    );
  }

  static CareNudge? _checkGrowthSpurt(
      Plant plant, List<CareLog> logs, DateTime now) {
    final recentWater = logs
        .where((l) =>
            l.type == TaskType.water &&
            now.difference(l.timestamp).inDays <= 14)
        .length;
    final olderWater = logs
        .where((l) =>
            l.type == TaskType.water &&
            now.difference(l.timestamp).inDays > 14 &&
            now.difference(l.timestamp).inDays <= 28)
        .length;

    if (olderWater == 0 || recentWater <= olderWater) return null;
    final ratio = recentWater / olderWater;
    if (ratio < 1.5) return null;

    return CareNudge(
      type: NudgeType.growthSpurt,
      plantId: plant.id,
      plantNickname: plant.nickname,
      priority: NudgePriority.low,
      messageKey: 'nudgeGrowthSpurt',
      args: {'plant': plant.nickname},
    );
  }

  static CareLog? _lastLogOfType(List<CareLog> logs, TaskType type) {
    final filtered = logs.where((l) => l.type == type).toList();
    if (filtered.isEmpty) return null;
    return filtered.reduce(
        (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }
}
