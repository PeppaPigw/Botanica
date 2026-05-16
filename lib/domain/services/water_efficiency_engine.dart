import 'dart:math' as math;

import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/species.dart';

enum WaterEfficiency { overwatering, optimal, underwatering, insufficient }

class WaterEfficiencyResult {
  const WaterEfficiencyResult({
    required this.efficiency,
    required this.score,
    required this.actualIntervalDays,
    required this.recommendedIntervalDays,
    required this.deviation,
  });

  final WaterEfficiency efficiency;
  final double score;
  final double actualIntervalDays;
  final int recommendedIntervalDays;
  final double deviation;
}

class WaterEfficiencyEngine {
  const WaterEfficiencyEngine._();

  static WaterEfficiencyResult? analyze({
    required Plant plant,
    required Species species,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final waterLogs = logs
        .where((l) => l.plantId == plant.id && l.type == TaskType.water)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (waterLogs.length < 3) return null;

    final intervals = <double>[];
    final count = math.min(waterLogs.length - 1, 8);
    for (int i = 0; i < count; i++) {
      final diff = waterLogs[i].timestamp
          .difference(waterLogs[i + 1].timestamp)
          .inHours / 24.0;
      if (diff > 0 && diff < 60) {
        intervals.add(diff);
      }
    }

    if (intervals.length < 2) return null;

    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    final recommended = species.careDefaults.waterBaseDays;

    final ratio = avgInterval / recommended;
    final deviation = (ratio - 1.0).abs();

    final WaterEfficiency efficiency;
    if (ratio < 0.7) {
      efficiency = WaterEfficiency.overwatering;
    } else if (ratio > 1.4) {
      efficiency = WaterEfficiency.underwatering;
    } else {
      efficiency = WaterEfficiency.optimal;
    }

    final score = (1.0 - deviation).clamp(0.0, 1.0);

    return WaterEfficiencyResult(
      efficiency: efficiency,
      score: score,
      actualIntervalDays: avgInterval,
      recommendedIntervalDays: recommended,
      deviation: deviation,
    );
  }

  static Map<String, WaterEfficiencyResult> analyzeAll({
    required List<Plant> plants,
    required Map<String, Species> speciesMap,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final results = <String, WaterEfficiencyResult>{};
    for (final plant in plants) {
      if (plant.isArchived) continue;
      final species = speciesMap[plant.speciesId];
      if (species == null) continue;

      final result = analyze(
        plant: plant,
        species: species,
        logs: logs,
        now: now,
      );
      if (result != null) {
        results[plant.id] = result;
      }
    }
    return results;
  }

  static double gardenEfficiencyScore(
      Map<String, WaterEfficiencyResult> results) {
    if (results.isEmpty) return 1.0;
    final total = results.values.fold<double>(0, (s, r) => s + r.score);
    return total / results.length;
  }
}
