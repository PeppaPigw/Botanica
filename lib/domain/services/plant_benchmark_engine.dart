import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class PlantBenchmark {
  const PlantBenchmark({
    required this.speciesId,
    required this.plantId,
    required this.plantNickname,
    required this.userCareFrequency,
    required this.communityAvgFrequency,
    required this.userHealthScore,
    required this.communityAvgHealth,
    required this.percentile,
    required this.insight,
  });

  final String speciesId;
  final String plantId;
  final String plantNickname;
  final double userCareFrequency;
  final double communityAvgFrequency;
  final double userHealthScore;
  final double communityAvgHealth;
  final int percentile;
  final String insight;

  bool get aboveAverage => percentile >= 50;
}

class CommunityStats {
  const CommunityStats({
    required this.speciesId,
    required this.avgWaterIntervalDays,
    required this.avgFertilizeIntervalDays,
    required this.avgHealthScore,
    required this.avgSurvivalMonths,
    required this.sampleSize,
  });

  final String speciesId;
  final double avgWaterIntervalDays;
  final double avgFertilizeIntervalDays;
  final double avgHealthScore;
  final double avgSurvivalMonths;
  final int sampleSize;
}

class PlantBenchmarkEngine {
  const PlantBenchmarkEngine._();

  static List<PlantBenchmark> compare({
    required List<Plant> plants,
    required List<CareLog> logs,
    required Map<String, double> healthScores,
    required Map<String, CommunityStats> communityData,
    required DateTime now,
  }) {
    final benchmarks = <PlantBenchmark>[];

    for (final plant in plants.where((p) => !p.isArchived)) {
      final community = communityData[plant.speciesId];
      if (community == null) continue;

      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      final waterLogs = plantLogs.where((l) => l.type == TaskType.water).toList();

      if (waterLogs.length < 3) continue;

      final recentWater = waterLogs
          .where((l) => now.difference(l.timestamp).inDays <= 60)
          .toList();
      final userFreq = recentWater.isEmpty
          ? 0.0
          : 60.0 / recentWater.length;

      final userHealth = healthScores[plant.id] ?? 0.5;
      final percentile = _calculatePercentile(
          userFreq, community.avgWaterIntervalDays, userHealth, community.avgHealthScore);

      final insight = _generateInsight(
          userFreq, community.avgWaterIntervalDays, userHealth, community.avgHealthScore);

      benchmarks.add(PlantBenchmark(
        speciesId: plant.speciesId,
        plantId: plant.id,
        plantNickname: plant.nickname,
        userCareFrequency: userFreq,
        communityAvgFrequency: community.avgWaterIntervalDays,
        userHealthScore: userHealth,
        communityAvgHealth: community.avgHealthScore,
        percentile: percentile,
        insight: insight,
      ));
    }

    benchmarks.sort((a, b) => b.percentile.compareTo(a.percentile));
    return benchmarks;
  }

  static int _calculatePercentile(
      double userFreq, double communityFreq, double userHealth, double communityHealth) {
    final freqRatio = communityFreq > 0
        ? (1.0 - (userFreq - communityFreq).abs() / communityFreq).clamp(0.0, 1.0)
        : 0.5;
    final healthRatio = communityHealth > 0
        ? (userHealth / communityHealth).clamp(0.0, 2.0) / 2.0
        : 0.5;
    return ((freqRatio * 0.4 + healthRatio * 0.6) * 100).round().clamp(0, 99);
  }

  static String _generateInsight(
      double userFreq, double communityFreq, double userHealth, double communityHealth) {
    if (userHealth > communityHealth * 1.2) return 'benchmarkAboveAvgHealth';
    if (userHealth < communityHealth * 0.8) return 'benchmarkBelowAvgHealth';
    if ((userFreq - communityFreq).abs() < 1.0) return 'benchmarkOnTrack';
    if (userFreq < communityFreq) return 'benchmarkMoreFrequent';
    return 'benchmarkLessFrequent';
  }
}
