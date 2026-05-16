import '../models/care_log.dart';
import '../models/photo_entry.dart';
import '../models/plant.dart';

class PlantMemory {
  const PlantMemory({
    required this.type,
    required this.titleKey,
    required this.date,
    required this.plantId,
    required this.plantNickname,
    this.photoId,
    this.metric,
  });

  final String type;
  final String titleKey;
  final DateTime date;
  final String plantId;
  final String plantNickname;
  final String? photoId;
  final double? metric;
}

class MemoryLaneResult {
  const MemoryLaneResult({
    required this.onThisDay,
    required this.milestoneMemories,
    required this.firstCareMemories,
    required this.seasonalMemories,
  });

  final List<PlantMemory> onThisDay;
  final List<PlantMemory> milestoneMemories;
  final List<PlantMemory> firstCareMemories;
  final List<PlantMemory> seasonalMemories;

  List<PlantMemory> get all => [
        ...onThisDay,
        ...milestoneMemories,
        ...firstCareMemories,
        ...seasonalMemories,
      ]..sort((a, b) => b.date.compareTo(a.date));
}

class PlantMemoryLaneEngine {
  const PlantMemoryLaneEngine._();

  static MemoryLaneResult generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<PhotoEntry> photos,
    required DateTime now,
  }) {
    final onThisDay = _findOnThisDay(plants, logs, photos, now);
    final milestones = _findMilestones(plants, logs, now);
    final firstCare = _findFirstCare(plants, logs, now);
    final seasonal = _findSeasonalMemories(plants, logs, now);

    return MemoryLaneResult(
      onThisDay: onThisDay,
      milestoneMemories: milestones,
      firstCareMemories: firstCare,
      seasonalMemories: seasonal,
    );
  }

  static List<PlantMemory> _findOnThisDay(
      List<Plant> plants, List<CareLog> logs, List<PhotoEntry> photos, DateTime now) {
    final memories = <PlantMemory>[];

    for (final photo in photos) {
      if (photo.createdAt.month == now.month &&
          photo.createdAt.day == now.day &&
          photo.createdAt.year < now.year) {
        final plant = plants.where((p) => p.id == photo.plantId).firstOrNull;
        if (plant == null) continue;
        memories.add(PlantMemory(
          type: 'onThisDayPhoto',
          titleKey: 'memoryOnThisDayPhoto',
          date: photo.createdAt,
          plantId: plant.id,
          plantNickname: plant.nickname,
          photoId: photo.id,
        ));
      }
    }

    return memories.take(5).toList();
  }

  static List<PlantMemory> _findMilestones(
      List<Plant> plants, List<CareLog> logs, DateTime now) {
    final memories = <PlantMemory>[];

    for (final plant in plants.where((p) => !p.isArchived)) {
      final daysOwned = now.difference(plant.createdAt).inDays;

      for (final milestone in [30, 90, 180, 365, 730]) {
        final diff = (daysOwned - milestone).abs();
        if (diff <= 3 && daysOwned >= milestone) {
          memories.add(PlantMemory(
            type: 'milestone',
            titleKey: 'memoryMilestone${milestone}Days',
            date: plant.createdAt.add(Duration(days: milestone)),
            plantId: plant.id,
            plantNickname: plant.nickname,
            metric: milestone.toDouble(),
          ));
        }
      }
    }

    return memories.take(3).toList();
  }

  static List<PlantMemory> _findFirstCare(
      List<Plant> plants, List<CareLog> logs, DateTime now) {
    final memories = <PlantMemory>[];

    for (final plant in plants.where((p) => !p.isArchived)) {
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      if (plantLogs.isEmpty) continue;

      final firstLog = plantLogs.reduce((a, b) =>
          a.timestamp.isBefore(b.timestamp) ? a : b);

      final daysSinceFirst = now.difference(firstLog.timestamp).inDays;
      if (daysSinceFirst > 0 &&
          daysSinceFirst % 365 <= 3 &&
          daysSinceFirst >= 365) {
        memories.add(PlantMemory(
          type: 'firstCareAnniversary',
          titleKey: 'memoryFirstCareAnniversary',
          date: firstLog.timestamp,
          plantId: plant.id,
          plantNickname: plant.nickname,
          metric: (daysSinceFirst / 365).floorToDouble(),
        ));
      }
    }

    return memories.take(3).toList();
  }

  static List<PlantMemory> _findSeasonalMemories(
      List<Plant> plants, List<CareLog> logs, DateTime now) {
    final memories = <PlantMemory>[];

    final lastYearMonth = DateTime(now.year - 1, now.month);
    final lastYearLogs = logs.where((l) =>
        l.timestamp.year == lastYearMonth.year &&
        l.timestamp.month == lastYearMonth.month).toList();

    if (lastYearLogs.length > 10) {
      final plantIds = lastYearLogs.map((l) => l.plantId).toSet();
      final plant = plants.where((p) => plantIds.contains(p.id)).firstOrNull;
      if (plant != null) {
        memories.add(PlantMemory(
          type: 'seasonalReflection',
          titleKey: 'memorySeasonalReflection',
          date: lastYearMonth,
          plantId: plant.id,
          plantNickname: plant.nickname,
          metric: lastYearLogs.length.toDouble(),
        ));
      }
    }

    return memories;
  }
}
