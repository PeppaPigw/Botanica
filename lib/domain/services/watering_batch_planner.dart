import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class BatchSlot {
  const BatchSlot({
    required this.dayOfWeek,
    required this.plantIds,
    required this.estimatedMinutes,
  });

  final int dayOfWeek;
  final List<String> plantIds;
  final int estimatedMinutes;
}

class WateringBatchPlan {
  const WateringBatchPlan({
    required this.slots,
    required this.totalPlantsPerWeek,
    required this.batchEfficiency,
    required this.suggestedDays,
  });

  final List<BatchSlot> slots;
  final int totalPlantsPerWeek;
  final double batchEfficiency;
  final int suggestedDays;
}

class WateringBatchPlanner {
  const WateringBatchPlanner._();

  static WateringBatchPlan plan({
    required List<Plant> plants,
    required Map<String, int> speciesWaterDays,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.isEmpty) {
      return const WateringBatchPlan(
        slots: [], totalPlantsPerWeek: 0, batchEfficiency: 1.0, suggestedDays: 0,
      );
    }

    final preferredDays = _detectPreferredDays(logs, now);
    final slots = _buildSlots(activePlants, speciesWaterDays, preferredDays);
    final totalPerWeek = slots.fold<int>(0, (s, slot) => s + slot.plantIds.length);
    final efficiency = _computeEfficiency(slots, activePlants.length);

    return WateringBatchPlan(
      slots: slots,
      totalPlantsPerWeek: totalPerWeek,
      batchEfficiency: efficiency,
      suggestedDays: slots.length,
    );
  }

  static List<int> _detectPreferredDays(List<CareLog> logs, DateTime now) {
    final recentWater = logs.where((l) =>
        l.type == TaskType.water &&
        now.difference(l.timestamp).inDays <= 30).toList();

    final dayCounts = <int, int>{};
    for (final log in recentWater) {
      dayCounts[log.timestamp.weekday] =
          (dayCounts[log.timestamp.weekday] ?? 0) + 1;
    }

    final sorted = dayCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  static List<BatchSlot> _buildSlots(
      List<Plant> plants, Map<String, int> frequencies, List<int> preferred) {
    final dayBuckets = <int, List<String>>{};

    for (final plant in plants) {
      final targetDay = preferred.isNotEmpty
          ? preferred[plants.indexOf(plant) % preferred.length]
          : (plants.indexOf(plant) % 7) + 1;
      dayBuckets.putIfAbsent(targetDay, () => []).add(plant.id);
    }

    return dayBuckets.entries.map((e) => BatchSlot(
      dayOfWeek: e.key,
      plantIds: e.value,
      estimatedMinutes: e.value.length * 2,
    )).toList()..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
  }

  static double _computeEfficiency(List<BatchSlot> slots, int totalPlants) {
    if (slots.isEmpty || totalPlants == 0) return 1.0;
    final maxPerSlot = slots.map((s) => s.plantIds.length)
        .reduce((a, b) => a > b ? a : b);
    return (maxPerSlot / totalPlants).clamp(0.0, 1.0);
  }
}
