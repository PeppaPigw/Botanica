import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/daily_fact_engine.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/enums.dart';

Plant _plant({String id = 'p1', String speciesId = 'sp1'}) => Plant(
      id: id,
      nickname: 'Monstera',
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
  String light = 'bright indirect',
  int waterDays = 7,
  bool petSafe = true,
  SpeciesOrigin? origin,
  SpeciesGrowth? growth,
  SpeciesMatureSize? matureSize,
}) =>
    Species(
      id: id,
      scientificName: 'Monstera deliciosa',
      commonNamesByLocale: const {'en': ['Swiss Cheese Plant']},
      difficulty: 'easy',
      petSafe: petSafe,
      light: light,
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: waterDays,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
      origin: origin,
      growth: growth,
      matureSize: matureSize,
    );

void main() {
  group('DailyFactEngine', () {
    test('returns null with no plants', () {
      final result = DailyFactEngine.generate(
        plants: [],
        speciesMap: {},
        now: DateTime(2026, 5, 16),
      );
      expect(result, isNull);
    });

    test('returns null when species not found', () {
      final result = DailyFactEngine.generate(
        plants: [_plant(speciesId: 'unknown')],
        speciesMap: {},
        now: DateTime(2026, 5, 16),
      );
      expect(result, isNull);
    });

    test('returns a fact for valid plant and species', () {
      final result = DailyFactEngine.generate(
        plants: [_plant()],
        speciesMap: {'sp1': _species()},
        now: DateTime(2026, 5, 16),
      );
      expect(result, isNotNull);
      expect(result!.plantId, 'p1');
      expect(result.factKey, isNotEmpty);
    });

    test('fact rotates by day', () {
      final facts = <String>{};
      for (int day = 0; day < 10; day++) {
        final result = DailyFactEngine.generate(
          plants: [_plant()],
          speciesMap: {'sp1': _species()},
          now: DateTime(2026, 5, 10 + day),
        );
        if (result != null) facts.add(result.factKey);
      }
      expect(facts.length, greaterThan(1));
    });

    test('same day returns same fact', () {
      final now = DateTime(2026, 5, 16, 8, 0);
      final r1 = DailyFactEngine.generate(
        plants: [_plant()],
        speciesMap: {'sp1': _species()},
        now: now,
      );
      final r2 = DailyFactEngine.generate(
        plants: [_plant()],
        speciesMap: {'sp1': _species()},
        now: now.add(const Duration(hours: 5)),
      );
      expect(r1!.factKey, r2!.factKey);
    });

    test('includes origin fact when available', () {
      const origin = SpeciesOrigin(
        nativeRangeByLocale: {'en': 'Central America'},
      );
      final facts = <String>{};
      for (int day = 0; day < 20; day++) {
        final result = DailyFactEngine.generate(
          plants: [_plant()],
          speciesMap: {'sp1': _species(origin: origin)},
          now: DateTime(2026, 5, day + 1),
        );
        if (result != null) facts.add(result.factKey);
      }
      expect(facts, contains('factOrigin'));
    });

    test('includes growth rate fact when available', () {
      const growth = SpeciesGrowth(rate: 'fast', form: 'climbing');
      final facts = <String>{};
      for (int day = 0; day < 20; day++) {
        final result = DailyFactEngine.generate(
          plants: [_plant()],
          speciesMap: {'sp1': _species(growth: growth)},
          now: DateTime(2026, 5, day + 1),
        );
        if (result != null) facts.add(result.factKey);
      }
      expect(facts, contains('factGrowthRate'));
    });

    test('includes pet safety fact', () {
      final facts = <String>{};
      for (int day = 0; day < 20; day++) {
        final result = DailyFactEngine.generate(
          plants: [_plant()],
          speciesMap: {'sp1': _species(petSafe: true)},
          now: DateTime(2026, 5, day + 1),
        );
        if (result != null) facts.add(result.factKey);
      }
      expect(facts, contains('factPetSafe'));
    });

    test('rotates between plants on different days', () {
      final plantIds = <String>{};
      for (int day = 0; day < 10; day++) {
        final result = DailyFactEngine.generate(
          plants: [
            _plant(id: 'p1', speciesId: 'sp1'),
            _plant(id: 'p2', speciesId: 'sp1'),
            _plant(id: 'p3', speciesId: 'sp1'),
          ],
          speciesMap: {'sp1': _species()},
          now: DateTime(2026, 5, 10 + day),
        );
        if (result != null) plantIds.add(result.plantId);
      }
      expect(plantIds.length, greaterThan(1));
    });

    test('excludes archived plants', () {
      final archived = Plant(
        id: 'archived',
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

      final result = DailyFactEngine.generate(
        plants: [archived],
        speciesMap: {'sp1': _species()},
        now: DateTime(2026, 5, 16),
      );
      expect(result, isNull);
    });
  });
}
