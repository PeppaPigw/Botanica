import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/photo_entry.dart';
import '../models/plant.dart';
import '../models/species.dart';

enum GrowthPhase { dormant, slowGrowth, activeGrowth, rapidGrowth }

class GrowthEstimate {
  const GrowthEstimate({
    required this.plantId,
    required this.phase,
    required this.confidence,
    required this.careIntensity,
    required this.daysSinceLastPhoto,
    required this.suggestPhoto,
  });

  final String plantId;
  final GrowthPhase phase;
  final double confidence;
  final double careIntensity;
  final int daysSinceLastPhoto;
  final bool suggestPhoto;
}

class PlantGrowthTracker {
  const PlantGrowthTracker._();

  static GrowthEstimate? estimate({
    required Plant plant,
    required Species species,
    required List<CareLog> logs,
    required List<PhotoEntry> photos,
    required DateTime now,
    required int currentMonth,
  }) {
    if (plant.isArchived) return null;

    final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
    if (plantLogs.length < 3) return null;

    final recentLogs = plantLogs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();

    final careIntensity = recentLogs.length / 30.0;

    final waterLogs = recentLogs.where((l) => l.type == TaskType.water).length;
    final fertLogs =
        recentLogs.where((l) => l.type == TaskType.fertilize).length;

    final phase = _estimatePhase(
      careIntensity: careIntensity,
      waterFrequency: waterLogs,
      fertFrequency: fertLogs,
      month: currentMonth,
      growthRate: species.growth?.rate,
    );

    final plantPhotos = photos.where((p) => p.plantId == plant.id).toList();
    final daysSincePhoto = plantPhotos.isEmpty
        ? 999
        : now.difference(plantPhotos.last.createdAt).inDays;

    final suggestPhoto =
        phase == GrowthPhase.rapidGrowth && daysSincePhoto > 7 ||
            phase == GrowthPhase.activeGrowth && daysSincePhoto > 14;

    final confidence = _computeConfidence(recentLogs.length, plantLogs.length);

    return GrowthEstimate(
      plantId: plant.id,
      phase: phase,
      confidence: confidence,
      careIntensity: careIntensity,
      daysSinceLastPhoto: daysSincePhoto,
      suggestPhoto: suggestPhoto,
    );
  }

  static GrowthPhase _estimatePhase({
    required double careIntensity,
    required int waterFrequency,
    required int fertFrequency,
    required int month,
    String? growthRate,
  }) {
    final isGrowingSeason = month >= 3 && month <= 9;
    final isFastGrower = growthRate == 'fast';

    if (!isGrowingSeason && careIntensity < 0.1) {
      return GrowthPhase.dormant;
    }

    if (isGrowingSeason && isFastGrower && careIntensity > 0.3) {
      return GrowthPhase.rapidGrowth;
    }

    if (isGrowingSeason && careIntensity > 0.2 && waterFrequency >= 4) {
      return GrowthPhase.activeGrowth;
    }

    if (careIntensity > 0.1 || waterFrequency >= 2) {
      return GrowthPhase.slowGrowth;
    }

    return GrowthPhase.dormant;
  }

  static double _computeConfidence(int recentCount, int totalCount) {
    final recency = (recentCount / 10.0).clamp(0.0, 1.0);
    final history = (totalCount / 20.0).clamp(0.0, 1.0);
    return (recency * 0.7 + history * 0.3).clamp(0.0, 1.0);
  }
}
