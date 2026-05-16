import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/companion_plant_analyzer.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

Plant _plant({
  String id = 'p1',
  String speciesId = 'sp1',
  String room = 'Living Room',
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
  String id = 'sp1',
  String light = 'bright indirect',
  int waterBaseDays = 7,
  String growthRate = 'moderate',
  bool petSafe = true,
}) =>
    Species(
      id: id,
      scientificName: 'Testus $id',
      commonNamesByLocale: const {'en': ['Test']},
      difficulty: '3',
      petSafe: petSafe,
      light: light,
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: waterBaseDays,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
      origin: null,
      growth: SpeciesGrowth(rate: growthRate, form: 'upright'),
      matureSize: null,
    );

void main() {
  group('CompanionPlantAnalyzer', () {
    test('analyzeByRoom returns empty with fewer than 2 plants per room', () {
      final plants = [_plant(id: 'p1', room: 'A'), _plant(id: 'p2', room: 'B')];
      final species = [_species()];
      final result = CompanionPlantAnalyzer.analyzeByRoom(
        plants: plants, species: species);
      expect(result, isEmpty);
    });

    test('analyzeByRoom detects excellent compatibility for same-needs plants', () {
      final plants = [
        _plant(id: 'p1', speciesId: 'sp1', room: 'Room'),
        _plant(id: 'p2', speciesId: 'sp2', room: 'Room'),
      ];
      final species = [
        _species(id: 'sp1', light: 'bright indirect', waterBaseDays: 7),
        _species(id: 'sp2', light: 'bright indirect', waterBaseDays: 7),
      ];
      final result = CompanionPlantAnalyzer.analyzeByRoom(
        plants: plants, species: species);
      expect(result, hasLength(1));
      expect(result.first.pairings.first.compatibility,
          CompatibilityLevel.excellent);
    });

    test('analyzeByRoom detects poor compatibility for conflicting needs', () {
      final plants = [
        _plant(id: 'p1', speciesId: 'sp1', room: 'Room'),
        _plant(id: 'p2', speciesId: 'sp2', room: 'Room'),
      ];
      final species = [
        _species(id: 'sp1', light: 'full direct sun', waterBaseDays: 3,
            growthRate: 'fast'),
        _species(id: 'sp2', light: 'low light shade', waterBaseDays: 14,
            growthRate: 'slow'),
      ];
      final result = CompanionPlantAnalyzer.analyzeByRoom(
        plants: plants, species: species);
      expect(result, hasLength(1));
      expect(result.first.pairings.first.compatibility,
          CompatibilityLevel.poor);
    });

    test('findBestCompanions returns only excellent pairings', () {
      final plants = [
        _plant(id: 'p1', speciesId: 'sp1'),
        _plant(id: 'p2', speciesId: 'sp2'),
        _plant(id: 'p3', speciesId: 'sp3'),
      ];
      final species = [
        _species(id: 'sp1', light: 'bright indirect', waterBaseDays: 7),
        _species(id: 'sp2', light: 'bright indirect', waterBaseDays: 7),
        _species(id: 'sp3', light: 'low shade', waterBaseDays: 14,
            growthRate: 'slow'),
      ];
      final result = CompanionPlantAnalyzer.findBestCompanions(
        plants: plants, species: species);
      for (final pairing in result) {
        expect(pairing.compatibility, CompatibilityLevel.excellent);
      }
    });

    test('findConflicts only returns poor pairings in same room', () {
      final plants = [
        _plant(id: 'p1', speciesId: 'sp1', room: 'Room'),
        _plant(id: 'p2', speciesId: 'sp2', room: 'Room'),
        _plant(id: 'p3', speciesId: 'sp3', room: 'Other'),
      ];
      final species = [
        _species(id: 'sp1', light: 'full direct', waterBaseDays: 2,
            growthRate: 'fast'),
        _species(id: 'sp2', light: 'low shade', waterBaseDays: 14,
            growthRate: 'slow'),
        _species(id: 'sp3', light: 'low shade', waterBaseDays: 14,
            growthRate: 'slow'),
      ];
      final result = CompanionPlantAnalyzer.findConflicts(
        plants: plants, species: species);
      for (final pairing in result) {
        expect(pairing.compatibility, CompatibilityLevel.poor);
        expect(pairing.room, isNotEmpty);
      }
    });

    test('overallScore is between 0 and 1', () {
      final plants = [
        _plant(id: 'p1', speciesId: 'sp1', room: 'Room'),
        _plant(id: 'p2', speciesId: 'sp2', room: 'Room'),
      ];
      final species = [
        _species(id: 'sp1'),
        _species(id: 'sp2'),
      ];
      final result = CompanionPlantAnalyzer.analyzeByRoom(
        plants: plants, species: species);
      for (final report in result) {
        expect(report.overallScore, greaterThanOrEqualTo(0.0));
        expect(report.overallScore, lessThanOrEqualTo(1.0));
      }
    });
  });
}
