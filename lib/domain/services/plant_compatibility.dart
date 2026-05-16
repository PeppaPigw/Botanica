import '../models/plant.dart';
import '../models/species.dart';

enum CompatibilityLevel { great, good, fair, poor }

class PlantPairing {
  const PlantPairing({
    required this.plantA,
    required this.plantB,
    required this.level,
    required this.reasons,
  });

  final Plant plantA;
  final Plant plantB;
  final CompatibilityLevel level;
  final List<String> reasons;
}

class RoomCompatibility {
  const RoomCompatibility({
    required this.room,
    required this.plants,
    required this.pairings,
    required this.overallScore,
  });

  final String room;
  final List<Plant> plants;
  final List<PlantPairing> pairings;
  final double overallScore;
}

class PlantCompatibilityEngine {
  const PlantCompatibilityEngine._();

  static RoomCompatibility? analyzeRoom({
    required String room,
    required List<Plant> plants,
    required Map<String, Species> speciesMap,
  }) {
    final roomPlants = plants
        .where((p) => p.room == room && !p.isArchived)
        .toList();

    if (roomPlants.length < 2) return null;

    final pairings = <PlantPairing>[];
    for (int i = 0; i < roomPlants.length; i++) {
      for (int j = i + 1; j < roomPlants.length; j++) {
        final pairing = _analyzePair(
          roomPlants[i],
          roomPlants[j],
          speciesMap,
        );
        if (pairing != null) pairings.add(pairing);
      }
    }

    if (pairings.isEmpty) return null;

    final avgScore = pairings.fold<double>(0, (sum, p) {
          return sum + _levelToScore(p.level);
        }) /
        pairings.length;

    return RoomCompatibility(
      room: room,
      plants: roomPlants,
      pairings: pairings,
      overallScore: avgScore,
    );
  }

  static List<RoomCompatibility> analyzeAllRooms({
    required List<Plant> plants,
    required Map<String, Species> speciesMap,
  }) {
    final rooms = plants
        .where((p) => !p.isArchived)
        .map((p) => p.room)
        .toSet();

    final results = <RoomCompatibility>[];
    for (final room in rooms) {
      final result = analyzeRoom(
        room: room,
        plants: plants,
        speciesMap: speciesMap,
      );
      if (result != null) results.add(result);
    }
    results.sort((a, b) => a.overallScore.compareTo(b.overallScore));
    return results;
  }

  static PlantPairing? _analyzePair(
    Plant a,
    Plant b,
    Map<String, Species> speciesMap,
  ) {
    final specA = speciesMap[a.speciesId];
    final specB = speciesMap[b.speciesId];

    if (specA == null || specB == null) return null;

    final reasons = <String>[];
    int score = 0;

    final lightScore = _compareLightNeeds(specA.light, specB.light);
    score += lightScore;
    if (lightScore == 2) {
      reasons.add('compatSameLight');
    } else if (lightScore == 0) {
      reasons.add('compatConflictLight');
    }

    final waterScore = _compareWaterNeeds(
      specA.careDefaults.waterBaseDays,
      specB.careDefaults.waterBaseDays,
    );
    score += waterScore;
    if (waterScore == 2) {
      reasons.add('compatSameWater');
    } else if (waterScore == 0) {
      reasons.add('compatConflictWater');
    }

    final difficultyScore = _compareDifficulty(specA.difficulty, specB.difficulty);
    score += difficultyScore;

    final level = switch (score) {
      >= 5 => CompatibilityLevel.great,
      >= 4 => CompatibilityLevel.good,
      >= 2 => CompatibilityLevel.fair,
      _ => CompatibilityLevel.poor,
    };

    return PlantPairing(
      plantA: a,
      plantB: b,
      level: level,
      reasons: reasons,
    );
  }

  static int _compareLightNeeds(String lightA, String lightB) {
    final tierA = _lightTier(lightA);
    final tierB = _lightTier(lightB);
    final diff = (tierA - tierB).abs();
    if (diff == 0) return 2;
    if (diff == 1) return 1;
    return 0;
  }

  static int _lightTier(String light) {
    final lower = light.toLowerCase();
    if (lower.contains('low') || lower.contains('shade')) return 0;
    if (lower.contains('medium') || lower.contains('partial')) return 1;
    if (lower.contains('indirect')) return 2;
    if (lower.contains('direct') || lower.contains('full')) return 3;
    return 1;
  }

  static int _compareWaterNeeds(int daysA, int daysB) {
    final ratio = daysA > daysB ? daysA / daysB : daysB / daysA;
    if (ratio <= 1.3) return 2;
    if (ratio <= 2.0) return 1;
    return 0;
  }

  static int _compareDifficulty(String diffA, String diffB) {
    final tierA = _difficultyTier(diffA);
    final tierB = _difficultyTier(diffB);
    final diff = (tierA - tierB).abs();
    if (diff == 0) return 2;
    if (diff == 1) return 1;
    return 0;
  }

  static int _difficultyTier(String difficulty) {
    final lower = difficulty.toLowerCase();
    if (lower.contains('easy') || lower.contains('beginner')) return 0;
    if (lower.contains('moderate') || lower.contains('medium')) return 1;
    if (lower.contains('hard') || lower.contains('expert')) return 2;
    return 1;
  }

  static double _levelToScore(CompatibilityLevel level) {
    return switch (level) {
      CompatibilityLevel.great => 1.0,
      CompatibilityLevel.good => 0.75,
      CompatibilityLevel.fair => 0.5,
      CompatibilityLevel.poor => 0.25,
    };
  }
}
