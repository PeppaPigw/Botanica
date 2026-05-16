import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/water_efficiency_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

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

Species _species({String id = 'sp1', int waterDays = 7}) => Species(
      id: id,
      scientificName: 'Test',
      commonNamesByLocale: const {'en': ['Test']},
      difficulty: 'easy',
      petSafe: true,
      light: 'bright indirect',
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: waterDays,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
    );

CareLog _waterLog(DateTime ts, {String plantId = 'p1'}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('WaterEfficiencyEngine', () {
    test('returns null with fewer than 3 water logs', () {
      final logs = [
        _waterLog(now.subtract(const Duration(days: 7))),
        _waterLog(now.subtract(const Duration(days: 14))),
      ];
      expect(
        WaterEfficiencyEngine.analyze(
          plant: _plant(), species: _species(), logs: logs, now: now),
        isNull,
      );
    });

    test('optimal when matching recommended interval', () {
      final logs = List.generate(5, (i) =>
          _waterLog(now.subtract(Duration(days: i * 7))));
      final result = WaterEfficiencyEngine.analyze(
        plant: _plant(), species: _species(waterDays: 7), logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.efficiency, WaterEfficiency.optimal);
      expect(result.score, greaterThan(0.8));
    });

    test('overwatering when interval much shorter than recommended', () {
      // Watering every 3 days when recommended is 7
      final logs = List.generate(5, (i) =>
          _waterLog(now.subtract(Duration(days: i * 3))));
      final result = WaterEfficiencyEngine.analyze(
        plant: _plant(), species: _species(waterDays: 7), logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.efficiency, WaterEfficiency.overwatering);
    });

    test('underwatering when interval much longer than recommended', () {
      // Watering every 14 days when recommended is 7
      final logs = List.generate(4, (i) =>
          _waterLog(now.subtract(Duration(days: i * 14))));
      final result = WaterEfficiencyEngine.analyze(
        plant: _plant(), species: _species(waterDays: 7), logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.efficiency, WaterEfficiency.underwatering);
    });

    test('score is higher for closer to recommended', () {
      final optimalLogs = List.generate(5, (i) =>
          _waterLog(now.subtract(Duration(days: i * 7))));
      final offLogs = List.generate(5, (i) =>
          _waterLog(now.subtract(Duration(days: i * 4))));

      final optimal = WaterEfficiencyEngine.analyze(
        plant: _plant(), species: _species(waterDays: 7),
        logs: optimalLogs, now: now);
      final off = WaterEfficiencyEngine.analyze(
        plant: _plant(), species: _species(waterDays: 7),
        logs: offLogs, now: now);

      expect(optimal!.score, greaterThan(off!.score));
    });

    test('ignores non-water logs', () {
      final logs = [
        _waterLog(now.subtract(const Duration(days: 7))),
        _waterLog(now.subtract(const Duration(days: 14))),
        CareLog(
          id: 'fert1',
          plantId: 'p1',
          type: TaskType.fertilize,
          timestamp: now.subtract(const Duration(days: 10)),
          note: null,
          linkedPhotoId: null,
        ),
      ];
      expect(
        WaterEfficiencyEngine.analyze(
          plant: _plant(), species: _species(), logs: logs, now: now),
        isNull,
      );
    });

    test('analyzeAll returns results for multiple plants', () {
      final plants = [
        _plant(id: 'p1', speciesId: 'sp1'),
        _plant(id: 'p2', speciesId: 'sp1'),
      ];
      final logs = [
        ...List.generate(5, (i) =>
            _waterLog(now.subtract(Duration(days: i * 7)), plantId: 'p1')),
        ...List.generate(5, (i) =>
            _waterLog(now.subtract(Duration(days: i * 7)), plantId: 'p2')),
      ];
      final results = WaterEfficiencyEngine.analyzeAll(
        plants: plants,
        speciesMap: {'sp1': _species()},
        logs: logs,
        now: now,
      );
      expect(results.length, 2);
    });

    test('gardenEfficiencyScore averages all results', () {
      final results = {
        'p1': const WaterEfficiencyResult(
          efficiency: WaterEfficiency.optimal,
          score: 0.9,
          actualIntervalDays: 7.0,
          recommendedIntervalDays: 7,
          deviation: 0.1,
        ),
        'p2': const WaterEfficiencyResult(
          efficiency: WaterEfficiency.overwatering,
          score: 0.5,
          actualIntervalDays: 3.0,
          recommendedIntervalDays: 7,
          deviation: 0.5,
        ),
      };
      final score = WaterEfficiencyEngine.gardenEfficiencyScore(results);
      expect(score, closeTo(0.7, 0.01));
    });

    test('deviation reflects distance from recommended', () {
      final logs = List.generate(5, (i) =>
          _waterLog(now.subtract(Duration(days: i * 5))));
      final result = WaterEfficiencyEngine.analyze(
        plant: _plant(), species: _species(waterDays: 7), logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.deviation, greaterThan(0));
      expect(result.actualIntervalDays, closeTo(5.0, 0.5));
      expect(result.recommendedIntervalDays, 7);
    });
  });
}
