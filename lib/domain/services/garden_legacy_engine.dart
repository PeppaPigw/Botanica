import '../models/care_log.dart';
import '../models/plant.dart';

class LegacyPlantScore {
  const LegacyPlantScore({
    required this.plantId,
    required this.score,
    required this.ageDays,
    required this.totalCareActions,
    required this.carePerMonth,
  });

  final String plantId;
  final double score;
  final int ageDays;
  final int totalCareActions;
  final double carePerMonth;
}

class GardenLegacyReport {
  const GardenLegacyReport({
    required this.overallScore,
    required this.plantScores,
    required this.longestSurvivor,
    required this.totalCareActions,
    required this.statusKey,
  });

  final double overallScore;
  final List<LegacyPlantScore> plantScores;
  final String? longestSurvivor;
  final int totalCareActions;
  final String statusKey;
}

class GardenLegacyEngine {
  const GardenLegacyEngine._();

  static GardenLegacyReport compute({
    required List<Plant> plants,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final active = plants.where((p) => !p.isArchived).toList();
    if (active.isEmpty) {
      return const GardenLegacyReport(
        overallScore: 0.0, plantScores: [], longestSurvivor: null,
        totalCareActions: 0, statusKey: 'legacyEmpty',
      );
    }

    final plantScores = <LegacyPlantScore>[];
    for (final plant in active) {
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      final ageDays = now.difference(plant.createdAt).inDays;
      final months = ageDays / 30.0;
      final carePerMonth = months > 0 ? plantLogs.length / months : 0.0;

      final score = _plantLegacyScore(ageDays, plantLogs.length, carePerMonth);
      plantScores.add(LegacyPlantScore(
        plantId: plant.id, score: score, ageDays: ageDays,
        totalCareActions: plantLogs.length, carePerMonth: carePerMonth,
      ));
    }

    plantScores.sort((a, b) => b.score.compareTo(a.score));

    final overall = plantScores.map((s) => s.score).reduce((a, b) => a + b)
        / plantScores.length;

    final longest = plantScores.reduce((a, b) => a.ageDays > b.ageDays ? a : b);
    final statusKey = _status(overall);

    return GardenLegacyReport(
      overallScore: overall.clamp(0.0, 1.0),
      plantScores: plantScores,
      longestSurvivor: longest.plantId,
      totalCareActions: logs.length,
      statusKey: statusKey,
    );
  }

  static double _plantLegacyScore(int ageDays, int careCount, double carePerMonth) {
    final ageScore = (ageDays / 365.0).clamp(0.0, 1.0);
    final careScore = (carePerMonth / 8.0).clamp(0.0, 1.0);
    return (ageScore * 0.4 + careScore * 0.6).clamp(0.0, 1.0);
  }

  static String _status(double score) {
    if (score >= 0.8) return 'legacyLegendary';
    if (score >= 0.6) return 'legacyEstablished';
    if (score >= 0.4) return 'legacyGrowing';
    return 'legacyBudding';
  }
}
