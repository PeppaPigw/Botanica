import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_recommendation_engine.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant(String id, {String speciesId = 'sp1'}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: speciesId,
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('PlantRecommendationEngine', () {
    test('suggests new species not already owned', () {
      final result = PlantRecommendationEngine.suggest(
        currentPlants: [_plant('p1', speciesId: 'fern')],
        speciesLight: {'fern': 'low', 'cactus': 'direct', 'pothos': 'medium'},
        speciesDifficulty: {'fern': 'easy', 'cactus': 'easy', 'pothos': 'easy'},
        speciesWaterDays: {'fern': 3, 'cactus': 14, 'pothos': 7},
        availableSpeciesIds: ['fern', 'cactus', 'pothos'],
        userLevel: 5,
      );
      expect(result.recommendations, isNotEmpty);
      expect(result.recommendations.every((r) => r.speciesId != 'fern'), isTrue);
    });

    test('limits to 5 recommendations', () {
      final available = List.generate(20, (i) => 'sp$i');
      final result = PlantRecommendationEngine.suggest(
        currentPlants: [_plant('p1', speciesId: 'owned')],
        speciesLight: {for (final id in available) id: 'medium'},
        speciesDifficulty: {for (final id in available) id: 'easy'},
        speciesWaterDays: {for (final id in available) id: 7},
        availableSpeciesIds: available,
        userLevel: 5,
      );
      expect(result.recommendations.length, lessThanOrEqualTo(5));
    });

    test('identifies garden gaps', () {
      final result = PlantRecommendationEngine.suggest(
        currentPlants: [_plant('p1')],
        speciesLight: {'sp1': 'medium'},
        speciesDifficulty: {'sp1': 'easy'},
        speciesWaterDays: {'sp1': 7},
        availableSpeciesIds: ['sp1'],
        userLevel: 5,
      );
      expect(result.gardenGaps, isNotEmpty);
    });

    test('profiles user based on collection', () {
      final plants = List.generate(12, (i) => _plant('p$i'));
      final result = PlantRecommendationEngine.suggest(
        currentPlants: plants,
        speciesLight: {'sp1': 'medium'},
        speciesDifficulty: {'sp1': 'easy'},
        speciesWaterDays: {'sp1': 7},
        availableSpeciesIds: ['new1'],
        userLevel: 10,
      );
      expect(result.userProfile, 'profileCollector');
    });

    test('scores sorted descending', () {
      final result = PlantRecommendationEngine.suggest(
        currentPlants: [_plant('p1', speciesId: 'fern')],
        speciesLight: {'fern': 'low', 'a': 'direct', 'b': 'medium'},
        speciesDifficulty: {'fern': 'easy', 'a': 'hard', 'b': 'easy'},
        speciesWaterDays: {'fern': 3, 'a': 14, 'b': 7},
        availableSpeciesIds: ['a', 'b'],
        userLevel: 15,
      );
      if (result.recommendations.length >= 2) {
        expect(result.recommendations[0].matchScore,
            greaterThanOrEqualTo(result.recommendations[1].matchScore));
      }
    });
  });
}
