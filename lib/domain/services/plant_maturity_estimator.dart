import '../models/care_log.dart';
import '../models/plant.dart';
import '../models/species.dart';

enum MaturityStage { seedling, juvenile, adolescent, mature, fullGrown }

class MaturityEstimate {
  const MaturityEstimate({
    required this.plantId,
    required this.plantNickname,
    required this.stage,
    required this.progressPercent,
    required this.estimatedMonthsToMature,
    required this.growthRate,
  });

  final String plantId;
  final String plantNickname;
  final MaturityStage stage;
  final double progressPercent;
  final int? estimatedMonthsToMature;
  final String growthRate;
}

class PlantMaturityEstimator {
  const PlantMaturityEstimator._();

  static List<MaturityEstimate> estimateAll({
    required List<Plant> plants,
    required List<Species> species,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final results = <MaturityEstimate>[];

    for (final plant in plants.where((p) => !p.isArchived)) {
      final sp = species.where((s) => s.id == plant.speciesId).firstOrNull;
      if (sp == null) continue;

      final estimate = _estimateSingle(plant, sp, logs, now);
      if (estimate != null) results.add(estimate);
    }

    results.sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
    return results;
  }

  static MaturityEstimate? _estimateSingle(
    Plant plant,
    Species species,
    List<CareLog> logs,
    DateTime now,
  ) {
    final ageDays = now.difference(plant.createdAt).inDays;
    if (ageDays < 1) return null;

    final growthRate = species.growth?.rate ?? 'moderate';
    final maturityMonths = _maturityMonthsForRate(growthRate);

    final ageMonths = ageDays / 30.0;
    final careBonus = _careBonus(plant.id, logs, now);

    final effectiveProgress =
        ((ageMonths / maturityMonths) * (1.0 + careBonus)).clamp(0.0, 1.0);

    final stage = _stageFromProgress(effectiveProgress);
    final remainingMonths = effectiveProgress >= 1.0
        ? null
        : ((1.0 - effectiveProgress) * maturityMonths).round();

    return MaturityEstimate(
      plantId: plant.id,
      plantNickname: plant.nickname,
      stage: stage,
      progressPercent: effectiveProgress * 100,
      estimatedMonthsToMature: remainingMonths,
      growthRate: growthRate,
    );
  }

  static int _maturityMonthsForRate(String rate) {
    return switch (rate.toLowerCase()) {
      'fast' => 12,
      'moderate' => 24,
      'slow' => 48,
      _ => 24,
    };
  }

  static double _careBonus(String plantId, List<CareLog> logs, DateTime now) {
    final plantLogs =
        logs.where((l) => l.plantId == plantId).toList();
    if (plantLogs.isEmpty) return 0;

    final recentLogs = plantLogs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();

    final hasFertilizer = recentLogs.any((l) => l.type.name == 'fertilize');
    final hasConsistentWatering = recentLogs.length >= 4;

    double bonus = 0;
    if (hasFertilizer) bonus += 0.1;
    if (hasConsistentWatering) bonus += 0.1;
    return bonus;
  }

  static MaturityStage _stageFromProgress(double progress) {
    if (progress >= 0.9) return MaturityStage.fullGrown;
    if (progress >= 0.65) return MaturityStage.mature;
    if (progress >= 0.4) return MaturityStage.adolescent;
    if (progress >= 0.15) return MaturityStage.juvenile;
    return MaturityStage.seedling;
  }
}
