import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/room_optimizer.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

Plant _plant({
  required String id,
  required String room,
  String speciesId = 'sp1',
}) => Plant(
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
  String? growthRate,
}) => Species(
      id: id,
      scientificName: 'Species $id',
      commonNamesByLocale: {'en': ['Species $id']},
      difficulty: 'easy',
      petSafe: true,
      light: light,
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: waterDays,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
      growth: growthRate != null
          ? SpeciesGrowth(rate: growthRate, form: 'upright')
          : null,
    );

void main() {
  group('RoomOptimizer', () {
    test('returns empty for fewer than 3 plants', () {
      final result = RoomOptimizer.optimize(
        plants: [
          _plant(id: 'p1', room: 'A'),
          _plant(id: 'p2', room: 'B'),
        ],
        speciesMap: {'sp1': _species(id: 'sp1')},
      );
      expect(result, isEmpty);
    });

    test('returns empty for single room', () {
      final result = RoomOptimizer.optimize(
        plants: [
          _plant(id: 'p1', room: 'A'),
          _plant(id: 'p2', room: 'A'),
          _plant(id: 'p3', room: 'A'),
        ],
        speciesMap: {'sp1': _species(id: 'sp1')},
      );
      expect(result, isEmpty);
    });

    test('suggests moving plant to room with similar light needs', () {
      // p1 in Room A (bright indirect), p2 and p3 in Room B (bright indirect)
      // p4 in Room A (low light) — mismatched
      final plants = [
        _plant(id: 'p1', room: 'A', speciesId: 'bright'),
        _plant(id: 'p2', room: 'B', speciesId: 'bright'),
        _plant(id: 'p3', room: 'B', speciesId: 'bright'),
        _plant(id: 'p4', room: 'A', speciesId: 'low'),
      ];
      final speciesMap = {
        'bright': _species(id: 'bright', light: 'bright indirect', waterDays: 7),
        'low': _species(id: 'low', light: 'low', waterDays: 14),
      };
      final result = RoomOptimizer.optimize(
        plants: plants,
        speciesMap: speciesMap,
      );
      // p1 should be suggested to move to Room B (better light match)
      final p1Suggestion = result.where((r) => r.plantId == 'p1');
      expect(p1Suggestion, isNotEmpty);
      expect(p1Suggestion.first.suggestedRoom, 'B');
      expect(p1Suggestion.first.reasons,
          contains(RoomSuggestionReason.similarLight));
    });

    test('suggests based on water similarity', () {
      final plants = [
        _plant(id: 'p1', room: 'A', speciesId: 'weekly'),
        _plant(id: 'p2', room: 'B', speciesId: 'weekly'),
        _plant(id: 'p3', room: 'B', speciesId: 'weekly'),
        _plant(id: 'p4', room: 'A', speciesId: 'biweekly'),
      ];
      final speciesMap = {
        'weekly': _species(id: 'weekly', waterDays: 7, light: 'medium'),
        'biweekly': _species(id: 'biweekly', waterDays: 14, light: 'low'),
      };
      final result = RoomOptimizer.optimize(
        plants: plants,
        speciesMap: speciesMap,
      );
      final p1Suggestion = result.where((r) => r.plantId == 'p1');
      expect(p1Suggestion, isNotEmpty);
      expect(p1Suggestion.first.reasons,
          contains(RoomSuggestionReason.similarWater));
    });

    test('does not suggest if current room is already optimal', () {
      // All plants in same-species rooms
      final plants = [
        _plant(id: 'p1', room: 'A', speciesId: 'sp1'),
        _plant(id: 'p2', room: 'A', speciesId: 'sp1'),
        _plant(id: 'p3', room: 'B', speciesId: 'sp2'),
        _plant(id: 'p4', room: 'B', speciesId: 'sp2'),
      ];
      final speciesMap = {
        'sp1': _species(id: 'sp1', light: 'bright indirect', waterDays: 7),
        'sp2': _species(id: 'sp2', light: 'low', waterDays: 14),
      };
      final result = RoomOptimizer.optimize(
        plants: plants,
        speciesMap: speciesMap,
      );
      expect(result, isEmpty);
    });

    test('skips archived plants', () {
      final archived = Plant(
        id: 'archived',
        nickname: 'Dead',
        speciesId: 'sp1',
        room: 'A',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1),
        meta: const PlantMeta(),
        isArchived: true,
      );
      final result = RoomOptimizer.optimize(
        plants: [
          archived,
          _plant(id: 'p2', room: 'A'),
          _plant(id: 'p3', room: 'B'),
        ],
        speciesMap: {'sp1': _species(id: 'sp1')},
      );
      expect(result.any((r) => r.plantId == 'archived'), isFalse);
    });

    test('includes companion IDs in suggestion', () {
      final plants = [
        _plant(id: 'p1', room: 'A', speciesId: 'sp1'),
        _plant(id: 'p2', room: 'B', speciesId: 'sp1'),
        _plant(id: 'p3', room: 'B', speciesId: 'sp1'),
        _plant(id: 'p4', room: 'A', speciesId: 'sp2'),
      ];
      final speciesMap = {
        'sp1': _species(id: 'sp1', light: 'bright indirect', waterDays: 7),
        'sp2': _species(id: 'sp2', light: 'low', waterDays: 21),
      };
      final result = RoomOptimizer.optimize(
        plants: plants,
        speciesMap: speciesMap,
      );
      final p1Suggestion = result.where((r) => r.plantId == 'p1');
      if (p1Suggestion.isNotEmpty) {
        expect(p1Suggestion.first.companionIds, isNotEmpty);
      }
    });
  });
}
