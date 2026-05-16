import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class CareRoutine {
  const CareRoutine({
    required this.name,
    required this.plantIds,
    required this.taskTypes,
    required this.preferredTime,
    required this.frequency,
    required this.avgDuration,
    required this.consistency,
  });

  final String name;
  final List<String> plantIds;
  final List<TaskType> taskTypes;
  final int preferredTime;
  final String frequency;
  final int avgDuration;
  final double consistency;
}

class RoutineOptimization {
  const RoutineOptimization({
    required this.suggestion,
    required this.timeSaved,
    required this.affectedPlants,
  });

  final String suggestion;
  final int timeSaved;
  final List<String> affectedPlants;
}

class CareRoutineResult {
  const CareRoutineResult({
    required this.detectedRoutines,
    required this.optimizations,
    required this.totalWeeklyMinutes,
    required this.efficiencyScore,
  });

  final List<CareRoutine> detectedRoutines;
  final List<RoutineOptimization> optimizations;
  final int totalWeeklyMinutes;
  final double efficiencyScore;
}

class CareRoutineDetector {
  const CareRoutineDetector._();

  static CareRoutineResult analyze({
    required List<Plant> plants,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final recentLogs = logs.where((l) => now.difference(l.timestamp).inDays <= 30).toList();
    if (recentLogs.length < 10) {
      return const CareRoutineResult(
        detectedRoutines: [],
        optimizations: [],
        totalWeeklyMinutes: 0,
        efficiencyScore: 0.5,
      );
    }

    final routines = _detectRoutines(recentLogs, now);
    final optimizations = _suggestOptimizations(routines, plants);
    final weeklyMinutes = _estimateWeeklyTime(recentLogs);
    final efficiency = _computeEfficiency(routines, recentLogs);

    return CareRoutineResult(
      detectedRoutines: routines,
      optimizations: optimizations,
      totalWeeklyMinutes: weeklyMinutes,
      efficiencyScore: efficiency,
    );
  }

  static List<CareRoutine> _detectRoutines(List<CareLog> logs, DateTime now) {
    final routines = <CareRoutine>[];

    // Detect morning routine
    final morningLogs = logs.where((l) => l.timestamp.hour >= 6 && l.timestamp.hour < 10).toList();
    if (morningLogs.length >= 5) {
      final plantIds = morningLogs.map((l) => l.plantId).toSet().toList();
      final types = morningLogs.map((l) => l.type).toSet().toList();
      routines.add(CareRoutine(
        name: 'routineMorning',
        plantIds: plantIds,
        taskTypes: types,
        preferredTime: 8,
        frequency: 'daily',
        avgDuration: plantIds.length * 3,
        consistency: morningLogs.length / 30.0,
      ));
    }

    // Detect evening routine
    final eveningLogs = logs.where((l) => l.timestamp.hour >= 18 && l.timestamp.hour < 22).toList();
    if (eveningLogs.length >= 5) {
      final plantIds = eveningLogs.map((l) => l.plantId).toSet().toList();
      final types = eveningLogs.map((l) => l.type).toSet().toList();
      routines.add(CareRoutine(
        name: 'routineEvening',
        plantIds: plantIds,
        taskTypes: types,
        preferredTime: 19,
        frequency: 'daily',
        avgDuration: plantIds.length * 3,
        consistency: eveningLogs.length / 30.0,
      ));
    }

    // Detect weekend routine
    final weekendLogs = logs.where((l) =>
        l.timestamp.weekday >= 6).toList();
    if (weekendLogs.length >= 4) {
      final plantIds = weekendLogs.map((l) => l.plantId).toSet().toList();
      final types = weekendLogs.map((l) => l.type).toSet().toList();
      routines.add(CareRoutine(
        name: 'routineWeekend',
        plantIds: plantIds,
        taskTypes: types,
        preferredTime: 10,
        frequency: 'weekly',
        avgDuration: plantIds.length * 5,
        consistency: weekendLogs.length / 8.0,
      ));
    }

    return routines;
  }

  static List<RoutineOptimization> _suggestOptimizations(
      List<CareRoutine> routines, List<Plant> plants) {
    final optimizations = <RoutineOptimization>[];

    // Suggest batching by room
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final rooms = <String, List<String>>{};
    for (final p in activePlants) {
      rooms.putIfAbsent(p.room, () => []).add(p.id);
    }

    for (final entry in rooms.entries) {
      if (entry.value.length >= 3) {
        optimizations.add(RoutineOptimization(
          suggestion: 'optimizeBatchRoom',
          timeSaved: entry.value.length * 2,
          affectedPlants: entry.value,
        ));
      }
    }

    if (routines.isEmpty) {
      optimizations.add(RoutineOptimization(
        suggestion: 'optimizeCreateRoutine',
        timeSaved: 10,
        affectedPlants: activePlants.map((p) => p.id).take(5).toList(),
      ));
    }

    return optimizations;
  }

  static int _estimateWeeklyTime(List<CareLog> recentLogs) {
    final weeklyActions = recentLogs.length / 4.0;
    return (weeklyActions * 2.5).round();
  }

  static double _computeEfficiency(List<CareRoutine> routines, List<CareLog> logs) {
    if (routines.isEmpty) return 0.3;
    final avgConsistency = routines.map((r) => r.consistency).reduce((a, b) => a + b) / routines.length;
    return avgConsistency.clamp(0.0, 1.0);
  }
}
