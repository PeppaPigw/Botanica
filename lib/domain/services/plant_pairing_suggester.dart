import '../models/plant.dart';
import '../models/species.dart';

enum PairingReason {
  similarCareSchedule,
  complementaryLight,
  sameRoom,
  diversifiesCollection,
  easyCompanion,
}

class PlantPairingSuggestion {
  const PlantPairingSuggestion({
    required this.suggestedSpeciesId,
    required this.reasons,
    required this.compatibilityScore,
    required this.basedOnPlantId,
  });

  final String suggestedSpeciesId;
  final List<PairingReason> reasons;
  final double compatibilityScore;
  final String basedOnPlantId;
}

class PlantPairingSuggester {
  const PlantPairingSuggester._();

  static List<PlantPairingSuggestion> suggest({
    required List<Plant> plants,
    required Map<String, Species> speciesMap,
    required List<Species> candidateSpecies,
    int maxSuggestions = 3,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.isEmpty || candidateSpecies.isEmpty) return [];

    final ownedSpeciesIds = activePlants.map((p) => p.speciesId).toSet();
    final candidates =
        candidateSpecies.where((s) => !ownedSpeciesIds.contains(s.id)).toList();

    if (candidates.isEmpty) return [];

    final suggestions = <PlantPairingSuggestion>[];

    for (final candidate in candidates) {
      double bestScore = 0;
      String bestPlantId = activePlants.first.id;
      final reasons = <PairingReason>{};

      for (final plant in activePlants) {
        final owned = speciesMap[plant.speciesId];
        if (owned == null) continue;

        double score = 0;
        final pairReasons = <PairingReason>[];

        final waterSimilarity = _waterSimilarity(owned, candidate);
        if (waterSimilarity > 0.7) {
          score += 0.3;
          pairReasons.add(PairingReason.similarCareSchedule);
        }

        if (_isComplementaryLight(owned, candidate)) {
          score += 0.2;
          pairReasons.add(PairingReason.complementaryLight);
        }

        if (candidate.difficulty == 'easy' || candidate.difficulty == 'medium') {
          score += 0.15;
          pairReasons.add(PairingReason.easyCompanion);
        }

        if (!_sameFamily(owned, candidate)) {
          score += 0.2;
          pairReasons.add(PairingReason.diversifiesCollection);
        }

        if (score > bestScore) {
          bestScore = score;
          bestPlantId = plant.id;
          reasons.clear();
          reasons.addAll(pairReasons);
        }
      }

      if (bestScore > 0.2) {
        suggestions.add(PlantPairingSuggestion(
          suggestedSpeciesId: candidate.id,
          reasons: reasons.toList(),
          compatibilityScore: bestScore.clamp(0.0, 1.0),
          basedOnPlantId: bestPlantId,
        ));
      }
    }

    suggestions.sort(
        (a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
    return suggestions.take(maxSuggestions).toList();
  }

  static double _waterSimilarity(Species a, Species b) {
    final aWater = a.careDefaults.waterBaseDays;
    final bWater = b.careDefaults.waterBaseDays;
    if (aWater == 0 || bWater == 0) return 0;
    final ratio = aWater < bWater ? aWater / bWater : bWater / aWater;
    return ratio;
  }

  static bool _isComplementaryLight(Species owned, Species candidate) {
    final ownedLight = owned.light.toLowerCase();
    final candidateLight = candidate.light.toLowerCase();
    if (ownedLight == candidateLight) return false;
    final lightLevels = ['low', 'medium', 'bright indirect', 'direct'];
    final ownedIdx = lightLevels.indexOf(ownedLight);
    final candidateIdx = lightLevels.indexOf(candidateLight);
    if (ownedIdx < 0 || candidateIdx < 0) return false;
    return (ownedIdx - candidateIdx).abs() == 1;
  }

  static bool _sameFamily(Species a, Species b) {
    final aGenus = a.scientificName.split(' ').first.toLowerCase();
    final bGenus = b.scientificName.split(' ').first.toLowerCase();
    return aGenus == bGenus;
  }
}
