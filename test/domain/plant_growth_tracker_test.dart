import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_growth_tracker.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

Plant _plant({String id = 'p1'}) => Plant(
      id: id,
      nickname: 'Monstera',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

Species _species({String? growthRate}) => Species(
      id: 'sp1',
      scientificName: 'Test',
      commonNamesByLocale: const {'en': ['Test']},
      difficulty: 'easy',
      petSafe: true,
      light: 'bright indirect',
      careDefaults: const SpeciesCareDefaults(
        waterBaseDays: 7,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
      growth: growthRate != null
          ? SpeciesGrowth(rate: growthRate, form: 'climbing')
          : null,
    );

CareLog _log(DateTime ts, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}',
      plantId: 'p1',
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

PhotoEntry _photo(DateTime ts) => PhotoEntry(
      id: 'photo_${ts.millisecondsSinceEpoch}',
      plantId: 'p1',
      filePath: '/photos/test.jpg',
      createdAt: ts,
      note: null,
      hash: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PlantGrowthTracker', () {
    test('returns null for archived plant', () {
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
      expect(
        PlantGrowthTracker.estimate(
          plant: archived,
          species: _species(),
          logs: List.generate(5, (i) => _log(now.subtract(Duration(days: i)))),
          photos: [],
          now: now,
          currentMonth: 5,
        ),
        isNull,
      );
    });

    test('returns null with fewer than 3 logs', () {
      expect(
        PlantGrowthTracker.estimate(
          plant: _plant(),
          species: _species(),
          logs: [_log(now.subtract(const Duration(days: 1)))],
          photos: [],
          now: now,
          currentMonth: 5,
        ),
        isNull,
      );
    });

    test('detects dormant phase in winter with low care', () {
      final logs = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: 60 + i * 10))));
      final result = PlantGrowthTracker.estimate(
        plant: _plant(),
        species: _species(),
        logs: logs,
        photos: [],
        now: now,
        currentMonth: 12,
      );
      expect(result, isNotNull);
      expect(result!.phase, GrowthPhase.dormant);
    });

    test('detects rapid growth for fast grower in growing season', () {
      final logs = List.generate(15, (i) =>
          _log(now.subtract(Duration(days: i * 2))));
      final result = PlantGrowthTracker.estimate(
        plant: _plant(),
        species: _species(growthRate: 'fast'),
        logs: logs,
        photos: [],
        now: now,
        currentMonth: 6,
      );
      expect(result, isNotNull);
      expect(result!.phase, GrowthPhase.rapidGrowth);
    });

    test('detects active growth with frequent watering in season', () {
      final logs = List.generate(10, (i) =>
          _log(now.subtract(Duration(days: i * 3))));
      final result = PlantGrowthTracker.estimate(
        plant: _plant(),
        species: _species(),
        logs: logs,
        photos: [],
        now: now,
        currentMonth: 5,
      );
      expect(result, isNotNull);
      expect(result!.phase, GrowthPhase.activeGrowth);
    });

    test('suggests photo when rapid growth and no recent photo', () {
      final logs = List.generate(15, (i) =>
          _log(now.subtract(Duration(days: i * 2))));
      final result = PlantGrowthTracker.estimate(
        plant: _plant(),
        species: _species(growthRate: 'fast'),
        logs: logs,
        photos: [_photo(now.subtract(const Duration(days: 20)))],
        now: now,
        currentMonth: 6,
      );
      expect(result!.suggestPhoto, isTrue);
    });

    test('does not suggest photo when recent photo exists', () {
      final logs = List.generate(15, (i) =>
          _log(now.subtract(Duration(days: i * 2))));
      final result = PlantGrowthTracker.estimate(
        plant: _plant(),
        species: _species(growthRate: 'fast'),
        logs: logs,
        photos: [_photo(now.subtract(const Duration(days: 3)))],
        now: now,
        currentMonth: 6,
      );
      expect(result!.suggestPhoto, isFalse);
    });

    test('confidence increases with more logs', () {
      final fewLogs = List.generate(4, (i) =>
          _log(now.subtract(Duration(days: i * 5))));
      final manyLogs = List.generate(20, (i) =>
          _log(now.subtract(Duration(days: i * 2))));

      final resultFew = PlantGrowthTracker.estimate(
        plant: _plant(),
        species: _species(),
        logs: fewLogs,
        photos: [],
        now: now,
        currentMonth: 5,
      );
      final resultMany = PlantGrowthTracker.estimate(
        plant: _plant(),
        species: _species(),
        logs: manyLogs,
        photos: [],
        now: now,
        currentMonth: 5,
      );

      expect(resultMany!.confidence, greaterThan(resultFew!.confidence));
    });

    test('daysSinceLastPhoto is 999 when no photos', () {
      final logs = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: i * 3))));
      final result = PlantGrowthTracker.estimate(
        plant: _plant(),
        species: _species(),
        logs: logs,
        photos: [],
        now: now,
        currentMonth: 5,
      );
      expect(result!.daysSinceLastPhoto, 999);
    });
  });
}
