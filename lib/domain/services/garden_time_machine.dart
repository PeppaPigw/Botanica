import '../models/care_log.dart';
import '../models/plant.dart';

class GardenSnapshot {
  const GardenSnapshot({
    required this.date,
    required this.plantCount,
    required this.plantIds,
    required this.recentCareCount,
    required this.healthEstimate,
  });

  final DateTime date;
  final int plantCount;
  final List<String> plantIds;
  final int recentCareCount;
  final double healthEstimate;
}

class TimeMachineResult {
  const TimeMachineResult({
    required this.snapshots,
    required this.growthTimeline,
    required this.peakMonth,
    required this.totalPlantsEver,
  });

  final List<GardenSnapshot> snapshots;
  final List<MapEntry<DateTime, int>> growthTimeline;
  final int peakMonth;
  final int totalPlantsEver;
}

class GardenTimeMachine {
  const GardenTimeMachine._();

  static TimeMachineResult reconstruct({
    required List<Plant> allPlants,
    required List<CareLog> logs,
    required DateTime now,
    required int monthsBack,
  }) {
    final snapshots = <GardenSnapshot>[];
    final growthTimeline = <MapEntry<DateTime, int>>[];
    int peakCount = 0;
    int peakMonth = 0;

    for (int m = monthsBack; m >= 0; m--) {
      final snapshotDate = DateTime(now.year, now.month - m, 1);
      final plantsAtTime = allPlants.where((p) =>
          p.createdAt.isBefore(snapshotDate) ||
          p.createdAt.isAtSameMomentAs(snapshotDate)).toList();

      final activePlants = plantsAtTime.where((p) => !p.isArchived).toList();
      final monthLogs = logs.where((l) {
        final d = snapshotDate.difference(l.timestamp).inDays;
        return d >= 0 && d <= 30;
      }).length;

      final healthEstimate = _estimateHealth(monthLogs, activePlants.length);

      snapshots.add(GardenSnapshot(
        date: snapshotDate,
        plantCount: activePlants.length,
        plantIds: activePlants.map((p) => p.id).toList(),
        recentCareCount: monthLogs,
        healthEstimate: healthEstimate,
      ));

      growthTimeline.add(MapEntry(snapshotDate, activePlants.length));

      if (activePlants.length > peakCount) {
        peakCount = activePlants.length;
        peakMonth = monthsBack - m;
      }
    }

    return TimeMachineResult(
      snapshots: snapshots,
      growthTimeline: growthTimeline,
      peakMonth: peakMonth,
      totalPlantsEver: allPlants.length,
    );
  }

  static double _estimateHealth(int careActions, int plantCount) {
    if (plantCount == 0) return 0.0;
    final ratio = careActions / (plantCount * 4.0);
    return ratio.clamp(0.0, 1.0);
  }
}
