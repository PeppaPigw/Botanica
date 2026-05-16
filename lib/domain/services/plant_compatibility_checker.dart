import '../models/enums.dart';
import '../models/plant.dart';

class CompatibilityResult {
  const CompatibilityResult({
    required this.plantIdA,
    required this.plantIdB,
    required this.overallScore,
    required this.lightMatch,
    required this.waterMatch,
    required this.humidityMatch,
    required this.verdict,
    required this.tips,
  });

  final String plantIdA;
  final String plantIdB;
  final double overallScore;
  final double lightMatch;
  final double waterMatch;
  final double humidityMatch;
  final String verdict;
  final List<String> tips;
}

class RoomCompatibilityReport {
  const RoomCompatibilityReport({
    required this.room,
    required this.pairs,
    required this.avgCompatibility,
    required this.conflicts,
  });

  final String room;
  final List<CompatibilityResult> pairs;
  final double avgCompatibility;
  final List<String> conflicts;
}

class PlantCompatibilityChecker {
  const PlantCompatibilityChecker._();

  static CompatibilityResult check({
    required Plant plantA,
    required Plant plantB,
    required Map<String, String> speciesLight,
    required Map<String, int> speciesWaterDays,
  }) {
    final lightA = speciesLight[plantA.speciesId] ?? 'medium';
    final lightB = speciesLight[plantB.speciesId] ?? 'medium';
    final waterA = speciesWaterDays[plantA.speciesId] ?? 7;
    final waterB = speciesWaterDays[plantB.speciesId] ?? 7;

    final lightMatch = _lightCompatibility(lightA, lightB);
    final waterMatch = _waterCompatibility(waterA, waterB);
    final humidityMatch = _environmentMatch(plantA.environmentMode, plantB.environmentMode);

    final overall = (lightMatch * 0.4 + waterMatch * 0.35 + humidityMatch * 0.25)
        .clamp(0.0, 1.0);

    final verdict = _verdict(overall);
    final tips = _generateTips(lightA, lightB, waterA, waterB, plantA, plantB);

    return CompatibilityResult(
      plantIdA: plantA.id,
      plantIdB: plantB.id,
      overallScore: overall,
      lightMatch: lightMatch,
      waterMatch: waterMatch,
      humidityMatch: humidityMatch,
      verdict: verdict,
      tips: tips,
    );
  }

  static RoomCompatibilityReport analyzeRoom({
    required String room,
    required List<Plant> plantsInRoom,
    required Map<String, String> speciesLight,
    required Map<String, int> speciesWaterDays,
  }) {
    final pairs = <CompatibilityResult>[];
    final conflicts = <String>[];

    for (int i = 0; i < plantsInRoom.length; i++) {
      for (int j = i + 1; j < plantsInRoom.length; j++) {
        final result = check(
          plantA: plantsInRoom[i],
          plantB: plantsInRoom[j],
          speciesLight: speciesLight,
          speciesWaterDays: speciesWaterDays,
        );
        pairs.add(result);
        if (result.overallScore < 0.4) {
          conflicts.add('compatibilityConflict');
        }
      }
    }

    final avg = pairs.isEmpty
        ? 1.0
        : pairs.map((p) => p.overallScore).reduce((a, b) => a + b) / pairs.length;

    return RoomCompatibilityReport(
      room: room,
      pairs: pairs,
      avgCompatibility: avg,
      conflicts: conflicts,
    );
  }

  static double _lightCompatibility(String a, String b) {
    const levels = {'low': 0, 'medium': 1, 'bright': 2, 'direct': 3};
    final la = levels[a] ?? 1;
    final lb = levels[b] ?? 1;
    final diff = (la - lb).abs();
    if (diff == 0) return 1.0;
    if (diff == 1) return 0.7;
    if (diff == 2) return 0.4;
    return 0.2;
  }

  static double _waterCompatibility(int daysA, int daysB) {
    final diff = (daysA - daysB).abs();
    if (diff <= 1) return 1.0;
    if (diff <= 3) return 0.8;
    if (diff <= 7) return 0.5;
    return 0.3;
  }

  static double _environmentMatch(EnvironmentMode a, EnvironmentMode b) {
    if (a == b) return 1.0;
    return 0.5;
  }

  static String _verdict(double score) {
    if (score >= 0.8) return 'compatibilityGreat';
    if (score >= 0.6) return 'compatibilityGood';
    if (score >= 0.4) return 'compatibilityFair';
    return 'compatibilityPoor';
  }

  static List<String> _generateTips(
      String lightA, String lightB, int waterA, int waterB,
      Plant plantA, Plant plantB) {
    final tips = <String>[];
    if (lightA != lightB) tips.add('compatibilityTipLight');
    if ((waterA - waterB).abs() > 3) tips.add('compatibilityTipWater');
    if (plantA.environmentMode != plantB.environmentMode) {
      tips.add('compatibilityTipEnvironment');
    }
    return tips;
  }
}
