import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_diversity_engine.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant(String id, {String speciesId = 'sp1', EnvironmentMode env = EnvironmentMode.indoor}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: speciesId,
      room: 'Room', environmentMode: env,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('GardenDiversityEngine', () {
    test('empty garden returns zero index', () {
      final metrics = GardenDiversityEngine.compute(
        plants: [], speciesLight: {}, speciesDifficulty: {},
      );
      expect(metrics.overallIndex, 0.0);
      expect(metrics.statusKey, 'diversityEmpty');
    });

    test('single species has low diversity', () {
      final plants = List.generate(5, (i) => _plant('p$i'));
      final metrics = GardenDiversityEngine.compute(
        plants: plants,
        speciesLight: {'sp1': 'medium'},
        speciesDifficulty: {'sp1': 'easy'},
      );
      expect(metrics.uniqueSpeciesRatio, closeTo(0.2, 0.01));
      expect(metrics.statusKey, isNot('diversityExcellent'));
    });

    test('diverse garden scores high', () {
      final plants = [
        _plant('p1', speciesId: 'fern', env: EnvironmentMode.indoor),
        _plant('p2', speciesId: 'cactus', env: EnvironmentMode.outdoor),
        _plant('p3', speciesId: 'orchid', env: EnvironmentMode.balcony),
      ];
      final metrics = GardenDiversityEngine.compute(
        plants: plants,
        speciesLight: {'fern': 'low', 'cactus': 'direct', 'orchid': 'bright'},
        speciesDifficulty: {'fern': 'easy', 'cactus': 'easy', 'orchid': 'hard'},
      );
      expect(metrics.overallIndex, greaterThan(0.6));
      expect(metrics.speciesCount, 3);
    });

    test('suggests improvements for low diversity', () {
      final metrics = GardenDiversityEngine.compute(
        plants: List.generate(5, (i) => _plant('p$i')),
        speciesLight: {'sp1': 'medium'},
        speciesDifficulty: {'sp1': 'easy'},
      );
      expect(metrics.suggestions, isNotEmpty);
    });

    test('skips archived plants', () {
      final archived = Plant(
        id: 'pa', nickname: 'Archived', speciesId: 'rare',
        room: 'Room', environmentMode: EnvironmentMode.outdoor,
        coverAsset: null, coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: true,
      );
      final metrics = GardenDiversityEngine.compute(
        plants: [archived],
        speciesLight: {'rare': 'direct'},
        speciesDifficulty: {'rare': 'hard'},
      );
      expect(metrics.speciesCount, 0);
    });
  });
}
