import '../models/enums.dart';
import '../models/plant.dart';

class PlantRecommendation {
  const PlantRecommendation({
    required this.speciesId,
    required this.reason,
    required this.matchScore,
    required this.difficulty,
    required this.lightNeeds,
  });

  final String speciesId;
  final String reason;
  final double matchScore;
  final String difficulty;
  final String lightNeeds;
}

class RecommendationResult {
  const RecommendationResult({
    required this.recommendations,
    required this.userProfile,
    required this.gardenGaps,
  });

  final List<PlantRecommendation> recommendations;
  final String userProfile;
  final List<String> gardenGaps;
}

class PlantRecommendationEngine {
  const PlantRecommendationEngine._();

  static RecommendationResult suggest({
    required List<Plant> currentPlants,
    required Map<String, String> speciesLight,
    required Map<String, String> speciesDifficulty,
    required Map<String, int> speciesWaterDays,
    required List<String> availableSpeciesIds,
    required int userLevel,
  }) {
    final active = currentPlants.where((p) => !p.isArchived).toList();
    final ownedSpecies = active.map((p) => p.speciesId).toSet();
    final userProfile = _profileUser(active, speciesDifficulty);
    final gaps = _findGaps(active, speciesLight, speciesDifficulty);

    final candidates = availableSpeciesIds
        .where((id) => !ownedSpecies.contains(id))
        .toList();

    final recommendations = <PlantRecommendation>[];
    for (final id in candidates) {
      final score = _scoreCandidate(
        id, active, speciesLight, speciesDifficulty, speciesWaterDays, userLevel,
      );
      final reason = _reason(id, gaps, speciesLight, speciesDifficulty);
      recommendations.add(PlantRecommendation(
        speciesId: id,
        reason: reason,
        matchScore: score,
        difficulty: speciesDifficulty[id] ?? 'medium',
        lightNeeds: speciesLight[id] ?? 'medium',
      ));
    }

    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return RecommendationResult(
      recommendations: recommendations.take(5).toList(),
      userProfile: userProfile,
      gardenGaps: gaps,
    );
  }

  static String _profileUser(List<Plant> plants, Map<String, String> difficulty) {
    if (plants.isEmpty) return 'profileBeginner';
    final diffs = plants.map((p) => difficulty[p.speciesId] ?? 'medium').toList();
    final hardCount = diffs.where((d) => d == 'hard').length;
    if (hardCount > plants.length / 2) return 'profileExpert';
    if (plants.length > 10) return 'profileCollector';
    return 'profileIntermediate';
  }

  static List<String> _findGaps(List<Plant> plants,
      Map<String, String> light, Map<String, String> difficulty) {
    final gaps = <String>[];
    final lights = plants.map((p) => light[p.speciesId] ?? 'medium').toSet();
    if (!lights.contains('low')) gaps.add('gapLowLight');
    if (!lights.contains('direct')) gaps.add('gapDirectLight');

    final diffs = plants.map((p) => difficulty[p.speciesId] ?? 'medium').toSet();
    if (!diffs.contains('hard') && plants.length > 5) gaps.add('gapChallenge');

    final envs = plants.map((p) => p.environmentMode).toSet();
    if (!envs.contains(EnvironmentMode.outdoor)) gaps.add('gapOutdoor');

    return gaps;
  }

  static double _scoreCandidate(String id, List<Plant> owned,
      Map<String, String> light, Map<String, String> difficulty,
      Map<String, int> water, int level) {
    double score = 0.5;

    final diff = difficulty[id] ?? 'medium';
    if (level < 5 && diff == 'easy') score += 0.2;
    if (level >= 10 && diff == 'hard') score += 0.15;

    final candidateLight = light[id] ?? 'medium';
    final ownedLights = owned.map((p) => light[p.speciesId] ?? 'medium').toSet();
    if (!ownedLights.contains(candidateLight)) score += 0.2;

    final waterDays = water[id] ?? 7;
    final ownedWater = owned.map((p) => water[p.speciesId] ?? 7).toList();
    if (ownedWater.isNotEmpty) {
      final avgWater = ownedWater.reduce((a, b) => a + b) / ownedWater.length;
      if ((waterDays - avgWater).abs() < 2) score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  static String _reason(String id, List<String> gaps,
      Map<String, String> light, Map<String, String> difficulty) {
    final l = light[id] ?? 'medium';
    if (gaps.contains('gapLowLight') && l == 'low') return 'recommendFillsLowLight';
    if (gaps.contains('gapDirectLight') && l == 'direct') return 'recommendFillsDirectLight';
    if (gaps.contains('gapChallenge') && difficulty[id] == 'hard') return 'recommendNewChallenge';
    return 'recommendGoodMatch';
  }
}
