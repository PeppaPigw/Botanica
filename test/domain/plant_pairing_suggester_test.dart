import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_pairing_suggester.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

Plant _plant({String id = 'p1', String speciesId = 'sp1'}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: speciesId,
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

Species _species({
  String id = 'sp1',
  String name = 'Monstera deliciosa',
  int waterDays = 7,
  String light = 'bright indirect',
  String difficulty = 'easy',
}) =>
    Species(
      id: id,
      scientificName: name,
      commonNamesByLocale: {'en': [name.split(' ').first]},
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
  group('PlantPairingSuggester', () {
    test('returns empty for no active plants', () {
      final result = PlantPairingSuggester.suggest(
        plants: [],
        speciesMap: {},
        candidateSpecies: [_species(id: 'sp2', name: 'Pothos aureus')],
      );
      expect(result, isEmpty);
    });

    test('returns empty for no candidates', () {
      final result = PlantPairingSuggester.suggest(
        plants: [_plant()],
        speciesMap: {'sp1': _species()},
        candidateSpecies: [],
      );
      expect(result, isEmpty);
    });

    test('excludes already-owned species', () {
      final result = PlantPairingSuggester.suggest(
        plants: [_plant()],
        speciesMap: {'sp1': _species()},
        candidateSpecies: [_species()],
      );
      expect(result, isEmpty);
    });

    test('suggests species with similar watering schedule', () {
      final owned = _species(id: 'sp1', waterDays: 7);
      final candidate = _species(
        id: 'sp2',
        name: 'Pothos aureus',
        waterDays: 7,
      );
      final result = PlantPairingSuggester.suggest(
        plants: [_plant()],
        speciesMap: {'sp1': owned},
        candidateSpecies: [candidate],
      );
      expect(result, isNotEmpty);
      expect(result.first.suggestedSpeciesId, 'sp2');
      expect(
        result.first.reasons.contains(PairingReason.similarCareSchedule),
        isTrue,
      );
    });

    test('suggests easy companions', () {
      final owned = _species(id: 'sp1', difficulty: 'hard');
      final candidate = _species(
        id: 'sp2',
        name: 'Pothos aureus',
        difficulty: 'easy',
        waterDays: 14,
      );
      final result = PlantPairingSuggester.suggest(
        plants: [_plant()],
        speciesMap: {'sp1': owned},
        candidateSpecies: [candidate],
      );
      expect(result, isNotEmpty);
      expect(
        result.first.reasons.contains(PairingReason.easyCompanion),
        isTrue,
      );
    });

    test('diversifies collection with different genus', () {
      final owned = _species(id: 'sp1', name: 'Monstera deliciosa');
      final candidate = _species(
        id: 'sp2',
        name: 'Ficus lyrata',
        waterDays: 7,
      );
      final result = PlantPairingSuggester.suggest(
        plants: [_plant()],
        speciesMap: {'sp1': owned},
        candidateSpecies: [candidate],
      );
      expect(result, isNotEmpty);
      expect(
        result.first.reasons.contains(PairingReason.diversifiesCollection),
        isTrue,
      );
    });

    test('limits suggestions to maxSuggestions', () {
      final owned = _species(id: 'sp1');
      final candidates = List.generate(
        10,
        (i) => _species(
          id: 'sp${i + 2}',
          name: 'Genus$i species$i',
          waterDays: 7,
        ),
      );
      final result = PlantPairingSuggester.suggest(
        plants: [_plant()],
        speciesMap: {'sp1': owned},
        candidateSpecies: candidates,
        maxSuggestions: 3,
      );
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('results sorted by compatibility score descending', () {
      final owned = _species(id: 'sp1', waterDays: 7, light: 'bright indirect');
      final candidates = [
        _species(id: 'sp2', name: 'Ficus lyrata', waterDays: 7, light: 'medium'),
        _species(id: 'sp3', name: 'Cactus spiny', waterDays: 21, light: 'direct', difficulty: 'hard'),
      ];
      final result = PlantPairingSuggester.suggest(
        plants: [_plant()],
        speciesMap: {'sp1': owned},
        candidateSpecies: candidates,
      );
      if (result.length >= 2) {
        expect(result[0].compatibilityScore,
            greaterThanOrEqualTo(result[1].compatibilityScore));
      }
    });

    test('skips archived plants', () {
      final archived = Plant(
        id: 'p1',
        nickname: 'Dead',
        speciesId: 'sp1',
        room: 'Room',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1),
        meta: const PlantMeta(),
        isArchived: true,
      );
      final result = PlantPairingSuggester.suggest(
        plants: [archived],
        speciesMap: {'sp1': _species()},
        candidateSpecies: [_species(id: 'sp2', name: 'Pothos aureus')],
      );
      expect(result, isEmpty);
    });
  });
}
