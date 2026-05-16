import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_compatibility.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/enums.dart';

Plant _plant({
  required String id,
  String room = 'Living Room',
  String speciesId = 'sp1',
}) =>
    Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: speciesId,
      room: room,
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

Species _species({
  required String id,
  String light = 'bright indirect',
  int waterDays = 7,
  String difficulty = 'easy',
}) =>
    Species(
      id: id,
      scientificName: 'Species $id',
      commonNamesByLocale: const {'en': ['Test Plant']},
      difficulty: difficulty,
      petSafe: true,
      light: light,
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: waterDays,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
    );

void main() {
  group('PlantCompatibilityEngine', () {
    test('returns null for room with fewer than 2 plants', () {
      final result = PlantCompatibilityEngine.analyzeRoom(
        room: 'Room',
        plants: [_plant(id: 'p1', room: 'Room')],
        speciesMap: {'sp1': _species(id: 'sp1')},
      );
      expect(result, isNull);
    });

    test('returns null when species data is missing', () {
      final result = PlantCompatibilityEngine.analyzeRoom(
        room: 'Room',
        plants: [
          _plant(id: 'p1', room: 'Room', speciesId: 'unknown1'),
          _plant(id: 'p2', room: 'Room', speciesId: 'unknown2'),
        ],
        speciesMap: {},
      );
      expect(result, isNull);
    });

    test('great compatibility for identical needs', () {
      final plants = [
        _plant(id: 'p1', room: 'Room', speciesId: 'sp1'),
        _plant(id: 'p2', room: 'Room', speciesId: 'sp2'),
      ];
      final speciesMap = {
        'sp1': _species(id: 'sp1', light: 'bright indirect', waterDays: 7),
        'sp2': _species(id: 'sp2', light: 'bright indirect', waterDays: 7),
      };

      final result = PlantCompatibilityEngine.analyzeRoom(
        room: 'Room',
        plants: plants,
        speciesMap: speciesMap,
      );

      expect(result, isNotNull);
      expect(result!.pairings.length, 1);
      expect(result.pairings.first.level, CompatibilityLevel.great);
    });

    test('poor compatibility for conflicting needs', () {
      final plants = [
        _plant(id: 'p1', room: 'Room', speciesId: 'sp1'),
        _plant(id: 'p2', room: 'Room', speciesId: 'sp2'),
      ];
      final speciesMap = {
        'sp1': _species(id: 'sp1', light: 'low light', waterDays: 3, difficulty: 'easy'),
        'sp2': _species(id: 'sp2', light: 'full direct sun', waterDays: 14, difficulty: 'expert'),
      };

      final result = PlantCompatibilityEngine.analyzeRoom(
        room: 'Room',
        plants: plants,
        speciesMap: speciesMap,
      );

      expect(result, isNotNull);
      expect(result!.pairings.first.level, CompatibilityLevel.poor);
    });

    test('reasons include light conflict', () {
      final plants = [
        _plant(id: 'p1', room: 'Room', speciesId: 'sp1'),
        _plant(id: 'p2', room: 'Room', speciesId: 'sp2'),
      ];
      final speciesMap = {
        'sp1': _species(id: 'sp1', light: 'low shade'),
        'sp2': _species(id: 'sp2', light: 'full direct sun'),
      };

      final result = PlantCompatibilityEngine.analyzeRoom(
        room: 'Room',
        plants: plants,
        speciesMap: speciesMap,
      );

      expect(result!.pairings.first.reasons, contains('compatConflictLight'));
    });

    test('reasons include water conflict', () {
      final plants = [
        _plant(id: 'p1', room: 'Room', speciesId: 'sp1'),
        _plant(id: 'p2', room: 'Room', speciesId: 'sp2'),
      ];
      final speciesMap = {
        'sp1': _species(id: 'sp1', waterDays: 3),
        'sp2': _species(id: 'sp2', waterDays: 14),
      };

      final result = PlantCompatibilityEngine.analyzeRoom(
        room: 'Room',
        plants: plants,
        speciesMap: speciesMap,
      );

      expect(result!.pairings.first.reasons, contains('compatConflictWater'));
    });

    test('analyzeAllRooms groups by room', () {
      final plants = [
        _plant(id: 'p1', room: 'Living Room', speciesId: 'sp1'),
        _plant(id: 'p2', room: 'Living Room', speciesId: 'sp2'),
        _plant(id: 'p3', room: 'Bedroom', speciesId: 'sp1'),
        _plant(id: 'p4', room: 'Bedroom', speciesId: 'sp2'),
      ];
      final speciesMap = {
        'sp1': _species(id: 'sp1', light: 'bright indirect', waterDays: 7),
        'sp2': _species(id: 'sp2', light: 'bright indirect', waterDays: 7),
      };

      final results = PlantCompatibilityEngine.analyzeAllRooms(
        plants: plants,
        speciesMap: speciesMap,
      );

      expect(results.length, 2);
    });

    test('excludes archived plants', () {
      final plants = [
        _plant(id: 'p1', room: 'Room', speciesId: 'sp1'),
        Plant(
          id: 'p2',
          nickname: 'Archived',
          speciesId: 'sp2',
          room: 'Room',
          environmentMode: EnvironmentMode.indoor,
          coverAsset: null,
          coverPhotoPath: null,
          createdAt: DateTime(2025, 1, 1),
          meta: const PlantMeta(),
          isArchived: true,
        ),
      ];
      final speciesMap = {
        'sp1': _species(id: 'sp1'),
        'sp2': _species(id: 'sp2'),
      };

      final result = PlantCompatibilityEngine.analyzeRoom(
        room: 'Room',
        plants: plants,
        speciesMap: speciesMap,
      );

      expect(result, isNull);
    });

    test('overallScore reflects pairing quality', () {
      final plants = [
        _plant(id: 'p1', room: 'Room', speciesId: 'sp1'),
        _plant(id: 'p2', room: 'Room', speciesId: 'sp2'),
        _plant(id: 'p3', room: 'Room', speciesId: 'sp3'),
      ];
      final speciesMap = {
        'sp1': _species(id: 'sp1', light: 'bright indirect', waterDays: 7),
        'sp2': _species(id: 'sp2', light: 'bright indirect', waterDays: 7),
        'sp3': _species(id: 'sp3', light: 'low shade', waterDays: 21, difficulty: 'expert'),
      };

      final result = PlantCompatibilityEngine.analyzeRoom(
        room: 'Room',
        plants: plants,
        speciesMap: speciesMap,
      );

      expect(result, isNotNull);
      expect(result!.pairings.length, 3);
      expect(result.overallScore, greaterThan(0));
      expect(result.overallScore, lessThan(1));
    });
  });
}
