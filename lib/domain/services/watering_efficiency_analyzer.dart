import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/species.dart';

enum WateringEfficiency { optimal, overwatering, underwatering, erratic }

class WateringAnalysis {
  const WateringAnalysis({
    required this.plantId,
    required this.plantNickname,
    required this.efficiency,
    required this.avgIntervalDays,
    required this.idealIntervalDays,
    required this.deviationPercent,
    required this.consistencyScore,
    required this.recommendation,
  });

  final String plantId;
  final String plantNickname;
  final WateringEfficiency efficiency;
  final double avgIntervalDays;
  final int idealIntervalDays;
  final double deviationPercent;
  final double consistencyScore;
  final String recommendation;
}

class WateringEfficiencyAnalyzer {
  const WateringEfficiencyAnalyzer._();

  static List<WateringAnalysis> analyze({
    required List<Plant> plants,
    required List<Species> species,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final results = <WateringAnalysis>[];

    for (final plant in plants.where((p) => !p.isArchived)) {
      final spec = species.where((s) => s.id == plant.speciesId).firstOrNull;
      if (spec == null) continue;

      final waterLogs = logs
          .where((l) => l.plantId == plant.id && l.type == TaskType.water &&
              now.difference(l.timestamp).inDays <= 60)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (waterLogs.length < 4) continue;

      final intervals = <int>[];
      for (int i = 1; i < waterLogs.length; i++) {
        final gap = waterLogs[i].timestamp.difference(waterLogs[i - 1].timestamp).inDays;
        if (gap > 0) intervals.add(gap);
      }

      if (intervals.isEmpty) continue;

      final avg = intervals.reduce((a, b) => a + b) / intervals.length;
      final ideal = spec.careDefaults.waterBaseDays;
      final deviation = ideal > 0 ? ((avg - ideal) / ideal * 100) : 0.0;

      final mean = avg;
      final variance = intervals.fold<double>(0, (s, v) => s + (v - mean) * (v - mean)) / intervals.length;
      final stdDev = _sqrt(variance);
      final consistency = (1.0 - (stdDev / mean).clamp(0.0, 1.0)).clamp(0.0, 1.0);

      final efficiency = _classify(deviation, consistency);
      final recommendation = _recommend(efficiency, avg, ideal);

      results.add(WateringAnalysis(
        plantId: plant.id,
        plantNickname: plant.nickname,
        efficiency: efficiency,
        avgIntervalDays: avg,
        idealIntervalDays: ideal,
        deviationPercent: deviation,
        consistencyScore: consistency,
        recommendation: recommendation,
      ));
    }

    results.sort((a, b) => a.consistencyScore.compareTo(b.consistencyScore));
    return results;
  }

  static WateringEfficiency _classify(double deviation, double consistency) {
    if (consistency < 0.4) return WateringEfficiency.erratic;
    if (deviation < -20) return WateringEfficiency.overwatering;
    if (deviation > 25) return WateringEfficiency.underwatering;
    return WateringEfficiency.optimal;
  }

  static String _recommend(WateringEfficiency eff, double avg, int ideal) {
    switch (eff) {
      case WateringEfficiency.overwatering:
        return 'waterEfficiencyReduceFrequency';
      case WateringEfficiency.underwatering:
        return 'waterEfficiencyIncreaseFrequency';
      case WateringEfficiency.erratic:
        return 'waterEfficiencyBeConsistent';
      case WateringEfficiency.optimal:
        return 'waterEfficiencyKeepItUp';
    }
  }

  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double g = x / 2;
    for (int i = 0; i < 15; i++) { g = (g + x / g) / 2; }
    return g;
  }
}
