import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_maturity_estimator.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

Plant _plant({
  String id = 'p1',
  String speciesId = 'sp1',
  DateTime? createdAt,
}) =>
    Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: speciesId,
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

Species _species({
  String id = 'sp1',
  String growthRate = 'moderate',
}) =>
    Species(
      id: id,
      scientificName: 'Testus plantus',
      commonNamesByLocale: const {'en': ['Test Plant']},
      difficulty: '3',
      petSafe: true,
      light: 'bright indirect',
      careDefaults: const SpeciesCareDefaults(
        waterBaseDays: 7,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
      origin: null,
      growth: SpeciesGrowth(rate: growthRate, form: 'upright'),
      matureSize: null,
    );

CareLog _log(DateTime ts, {String plantId = 'p1', TaskType type = TaskType.water}) =>
    CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_$plantId',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PlantMaturityEstimator', () {
    test('returns empty with no active plants', () {
      final result = PlantMaturityEstimator.estimateAll(
        plants: [], species: [], logs: [], now: now);
      expect(result, isEmpty);
    });

    test('skips plants without matching species', () {
      final plants = [_plant(speciesId: 'unknown')];
      final result = PlantMaturityEstimator.estimateAll(
        plants: plants, species: [_species(id: 'sp1')], logs: [], now: now);
      expect(result, isEmpty);
    });

    test('estimates seedling stage for very new plant', () {
      final plants = [_plant(createdAt: now.subtract(const Duration(days: 30)))];
      final result = PlantMaturityEstimator.estimateAll(
        plants: plants, species: [_species()], logs: [], now: now);
      expect(result, hasLength(1));
      expect(result.first.stage, MaturityStage.seedling);
      expect(result.first.progressPercent, lessThan(15));
    });

    test('estimates juvenile stage for young plant', () {
      // 6 months old with moderate growth (24 month maturity)
      final plants = [_plant(createdAt: now.subtract(const Duration(days: 180)))];
      final result = PlantMaturityEstimator.estimateAll(
        plants: plants, species: [_species()], logs: [], now: now);
      expect(result, hasLength(1));
      // 180/30 = 6 months, 6/24 = 25% → juvenile
      expect(result.first.stage, MaturityStage.juvenile);
    });

    test('fast growth rate reaches maturity sooner', () {
      // 8 months old
      final plants = [_plant(createdAt: now.subtract(const Duration(days: 240)))];
      final fastSpecies = _species(growthRate: 'fast');
      final result = PlantMaturityEstimator.estimateAll(
        plants: plants, species: [fastSpecies], logs: [], now: now);
      expect(result, hasLength(1));
      // 240/30 = 8 months, 8/12 = 66% → mature
      expect(result.first.stage, MaturityStage.mature);
    });

    test('slow growth rate delays maturity', () {
      // 12 months old
      final plants = [_plant(createdAt: now.subtract(const Duration(days: 365)))];
      final slowSpecies = _species(growthRate: 'slow');
      final result = PlantMaturityEstimator.estimateAll(
        plants: plants, species: [slowSpecies], logs: [], now: now);
      expect(result, hasLength(1));
      // 365/30 ≈ 12 months, 12/48 = 25% → juvenile
      expect(result.first.stage, MaturityStage.juvenile);
    });

    test('care bonus accelerates growth', () {
      // 10 months old, moderate growth
      final plants = [_plant(createdAt: now.subtract(const Duration(days: 300)))];
      // Recent fertilizing + consistent watering
      final logs = [
        _log(now.subtract(const Duration(days: 5)), type: TaskType.fertilize),
        ...List.generate(5, (i) => _log(now.subtract(Duration(days: i * 3)))),
      ];
      final result = PlantMaturityEstimator.estimateAll(
        plants: plants, species: [_species()], logs: logs, now: now);
      expect(result, hasLength(1));
      // Base: 10/24 ≈ 41.7%, with 20% bonus → ~50% → adolescent
      expect(result.first.stage, MaturityStage.adolescent);
    });

    test('full grown plant has null months to mature', () {
      // 3 years old with moderate growth (24 month maturity)
      final plants = [_plant(createdAt: now.subtract(const Duration(days: 1095)))];
      final result = PlantMaturityEstimator.estimateAll(
        plants: plants, species: [_species()], logs: [], now: now);
      expect(result, hasLength(1));
      expect(result.first.stage, MaturityStage.fullGrown);
      expect(result.first.estimatedMonthsToMature, isNull);
      expect(result.first.progressPercent, 100.0);
    });

    test('results sorted by progress descending', () {
      final plants = [
        _plant(id: 'p1', createdAt: now.subtract(const Duration(days: 30))),
        _plant(id: 'p2', createdAt: now.subtract(const Duration(days: 365))),
      ];
      final result = PlantMaturityEstimator.estimateAll(
        plants: plants, species: [_species()], logs: [], now: now);
      expect(result.length, 2);
      expect(result.first.progressPercent,
          greaterThanOrEqualTo(result.last.progressPercent));
    });
  });
}
