import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class ConfidenceDimension {
  const ConfidenceDimension({
    required this.name,
    required this.score,
    required this.evidence,
  });

  final String name;
  final double score;
  final String evidence;
}

class CareConfidenceReport {
  const CareConfidenceReport({
    required this.overallConfidence,
    required this.dimensions,
    required this.level,
    required this.nextMilestone,
  });

  final double overallConfidence;
  final List<ConfidenceDimension> dimensions;
  final String level;
  final String nextMilestone;
}

class CareConfidenceEngine {
  const CareConfidenceEngine._();

  static CareConfidenceReport assess({
    required List<Plant> plants,
    required List<CareLog> logs,
    required Map<String, double> healthScores,
    required int streakDays,
    required int totalDaysActive,
    required DateTime now,
  }) {
    final active = plants.where((p) => !p.isArchived).toList();
    final dimensions = <ConfidenceDimension>[];

    final consistency = _consistencyScore(logs, now);
    dimensions.add(ConfidenceDimension(
      name: 'confidenceConsistency', score: consistency,
      evidence: 'confidenceEvidenceStreak',
    ));

    final diversity = _diversityScore(active);
    dimensions.add(ConfidenceDimension(
      name: 'confidenceDiversity', score: diversity,
      evidence: 'confidenceEvidenceSpecies',
    ));

    final health = _healthScore(healthScores);
    dimensions.add(ConfidenceDimension(
      name: 'confidenceHealth', score: health,
      evidence: 'confidenceEvidenceHealth',
    ));

    final experience = _experienceScore(totalDaysActive, active.length);
    dimensions.add(ConfidenceDimension(
      name: 'confidenceExperience', score: experience,
      evidence: 'confidenceEvidenceTime',
    ));

    final variety = _careVarietyScore(logs);
    dimensions.add(ConfidenceDimension(
      name: 'confidenceVariety', score: variety,
      evidence: 'confidenceEvidenceCareTypes',
    ));

    final overall = dimensions.map((d) => d.score).reduce((a, b) => a + b)
        / dimensions.length;

    final level = _level(overall);
    final next = _nextMilestone(overall);

    return CareConfidenceReport(
      overallConfidence: overall.clamp(0.0, 1.0),
      dimensions: dimensions,
      level: level,
      nextMilestone: next,
    );
  }

  static double _consistencyScore(List<CareLog> logs, DateTime now) {
    final recent = logs.where((l) => now.difference(l.timestamp).inDays <= 30).length;
    return (recent / 30.0).clamp(0.0, 1.0);
  }

  static double _diversityScore(List<Plant> plants) {
    if (plants.isEmpty) return 0.0;
    final species = plants.map((p) => p.speciesId).toSet().length;
    return (species / 5.0).clamp(0.0, 1.0);
  }

  static double _healthScore(Map<String, double> scores) {
    if (scores.isEmpty) return 0.5;
    final avg = scores.values.reduce((a, b) => a + b) / scores.length;
    return avg.clamp(0.0, 1.0);
  }

  static double _experienceScore(int daysActive, int plantCount) {
    final timeScore = (daysActive / 180.0).clamp(0.0, 1.0);
    final sizeScore = (plantCount / 10.0).clamp(0.0, 1.0);
    return (timeScore * 0.6 + sizeScore * 0.4);
  }

  static double _careVarietyScore(List<CareLog> logs) {
    if (logs.isEmpty) return 0.0;
    final types = logs.map((l) => l.type).toSet().length;
    return (types / TaskType.values.length).clamp(0.0, 1.0);
  }

  static String _level(double score) {
    if (score >= 0.8) return 'confidenceMaster';
    if (score >= 0.6) return 'confidenceConfident';
    if (score >= 0.4) return 'confidenceLearning';
    return 'confidenceNovice';
  }

  static String _nextMilestone(double score) {
    if (score >= 0.8) return 'confidenceMilestoneKeepGoing';
    if (score >= 0.6) return 'confidenceMilestoneMaster';
    if (score >= 0.4) return 'confidenceMilestoneConfident';
    return 'confidenceMilestoneLearning';
  }
}
