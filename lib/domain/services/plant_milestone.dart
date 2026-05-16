import '../models/plant.dart';

enum PlantMilestoneType { oneMonth, threeMonths, sixMonths, oneYear, twoYears }

class PlantMilestone {
  const PlantMilestone({
    required this.plant,
    required this.type,
    required this.daysOwned,
  });

  final Plant plant;
  final PlantMilestoneType type;
  final int daysOwned;
}

class PlantMilestoneEngine {
  const PlantMilestoneEngine._();

  static const _milestones = <PlantMilestoneType, int>{
    PlantMilestoneType.oneMonth: 30,
    PlantMilestoneType.threeMonths: 90,
    PlantMilestoneType.sixMonths: 180,
    PlantMilestoneType.oneYear: 365,
    PlantMilestoneType.twoYears: 730,
  };

  static PlantMilestone? todaysMilestone(Plant plant, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final daysOwned = today.difference(plant.createdAt).inDays;

    for (final entry in _milestones.entries.toList().reversed) {
      final threshold = entry.value;
      if (daysOwned >= threshold && daysOwned < threshold + 1) {
        return PlantMilestone(
          plant: plant,
          type: entry.key,
          daysOwned: daysOwned,
        );
      }
    }
    return null;
  }

  static PlantMilestoneType? currentTier(Plant plant, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final daysOwned = today.difference(plant.createdAt).inDays;

    PlantMilestoneType? tier;
    for (final entry in _milestones.entries) {
      if (daysOwned >= entry.value) {
        tier = entry.key;
      }
    }
    return tier;
  }

  static List<PlantMilestone> todaysMilestones(
    List<Plant> plants, {
    DateTime? now,
  }) {
    final results = <PlantMilestone>[];
    for (final plant in plants) {
      if (plant.isArchived) continue;
      final milestone = todaysMilestone(plant, now: now);
      if (milestone != null) results.add(milestone);
    }
    return results;
  }
}
