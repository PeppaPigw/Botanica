import '../models/care_log.dart';
import '../models/plant.dart';

class SurvivalPrediction {
  const SurvivalPrediction({
    required this.plantId,
    required this.plantNickname,
    required this.survivalProbability,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.projectedMonths,
    required this.recommendation,
  });

  final String plantId;
  final String plantNickname;
  final double survivalProbability;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final int projectedMonths;
  final String recommendation;

  bool get atRisk => survivalProbability < 0.6;
}

class PlantSurvivalPredictor {
  const PlantSurvivalPredictor._();

  static List<SurvivalPrediction> predict({
    required List<Plant> plants,
    required List<CareLog> logs,
    required Map<String, double> healthScores,
    required DateTime now,
  }) {
    final predictions = <SurvivalPrediction>[];

    for (final plant in plants.where((p) => !p.isArchived)) {
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      final health = healthScores[plant.id] ?? 0.5;
      final prediction = _predictSingle(plant, plantLogs, health, now);
      predictions.add(prediction);
    }

    predictions.sort((a, b) => a.survivalProbability.compareTo(b.survivalProbability));
    return predictions;
  }

  static SurvivalPrediction _predictSingle(
      Plant plant, List<CareLog> logs, double health, DateTime now) {
    final risks = <String>[];
    final protective = <String>[];
    double score = 0.5;

    // Health factor
    if (health > 0.7) {
      score += 0.2;
      protective.add('survivalGoodHealth');
    } else if (health < 0.4) {
      score -= 0.2;
      risks.add('survivalPoorHealth');
    }

    // Care frequency
    final recentLogs = logs.where((l) => now.difference(l.timestamp).inDays <= 30).toList();
    if (recentLogs.length >= 10) {
      score += 0.15;
      protective.add('survivalActiveCare');
    } else if (recentLogs.isEmpty) {
      score -= 0.25;
      risks.add('survivalNoCare');
    }

    // Care consistency
    final last60 = logs.where((l) => now.difference(l.timestamp).inDays <= 60).toList();
    if (last60.length >= 5) {
      final days = last60.map((l) =>
          DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day)).toSet();
      final consistency = days.length / 60.0;
      if (consistency > 0.3) {
        score += 0.1;
        protective.add('survivalConsistentCare');
      }
    }

    // Age factor
    final daysOwned = now.difference(plant.createdAt).inDays;
    if (daysOwned > 365) {
      score += 0.1;
      protective.add('survivalEstablished');
    } else if (daysOwned < 30) {
      score -= 0.05;
      risks.add('survivalNewPlant');
    }

    // Care diversity
    final types = logs.map((l) => l.type).toSet();
    if (types.length >= 3) {
      score += 0.05;
      protective.add('survivalDiverseCare');
    }

    // Last care gap
    if (logs.isNotEmpty) {
      final lastCare = logs.map((l) => l.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);
      final gap = now.difference(lastCare).inDays;
      if (gap > 14) {
        score -= 0.15;
        risks.add('survivalLongGap');
      }
    }

    final probability = score.clamp(0.05, 0.99);
    final projectedMonths = (probability * 24).round().clamp(1, 24);
    final recommendation = _recommend(probability, risks);

    return SurvivalPrediction(
      plantId: plant.id,
      plantNickname: plant.nickname,
      survivalProbability: probability,
      riskFactors: risks,
      protectiveFactors: protective,
      projectedMonths: projectedMonths,
      recommendation: recommendation,
    );
  }

  static String _recommend(double probability, List<String> risks) {
    if (probability > 0.8) return 'survivalKeepItUp';
    if (risks.contains('survivalNoCare')) return 'survivalStartCaring';
    if (risks.contains('survivalLongGap')) return 'survivalResumeCare';
    if (risks.contains('survivalPoorHealth')) return 'survivalRescueMode';
    return 'survivalImproveConsistency';
  }
}
