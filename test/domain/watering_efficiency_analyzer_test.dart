import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/watering_efficiency_analyzer.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant() => Plant(
      id: 'p1', nickname: 'Fern', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

Species _species({int waterDays = 7}) => Species(
      id: 'sp1', scientificName: 'Test', commonNamesByLocale: const {'en': ['Test']},
      difficulty: '2', petSafe: true, light: 'indirect',
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: waterDays, fertilizeBaseDays: 30,
        mistBaseDays: 3, rotateBaseDays: 14, pruneBaseDays: 90,
      ),
    );

CareLog _waterLog(int daysAgo) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('WateringEfficiencyAnalyzer', () {
    test('returns empty with insufficient data', () {
      final result = WateringEfficiencyAnalyzer.analyze(
        plants: [_plant()], species: [_species()],
        logs: [_waterLog(1), _waterLog(5)], now: _now);
      expect(result, isEmpty);
    });

    test('detects optimal watering', () {
      final logs = List.generate(8, (i) => _waterLog(i * 7));
      final result = WateringEfficiencyAnalyzer.analyze(
        plants: [_plant()], species: [_species(waterDays: 7)],
        logs: logs, now: _now);
      expect(result, isNotEmpty);
      expect(result.first.efficiency, WateringEfficiency.optimal);
    });

    test('detects overwatering', () {
      final logs = List.generate(10, (i) => _waterLog(i * 3));
      final result = WateringEfficiencyAnalyzer.analyze(
        plants: [_plant()], species: [_species(waterDays: 7)],
        logs: logs, now: _now);
      expect(result, isNotEmpty);
      expect(result.first.efficiency, WateringEfficiency.overwatering);
    });

    test('detects underwatering', () {
      final logs = List.generate(5, (i) => _waterLog(i * 12));
      final result = WateringEfficiencyAnalyzer.analyze(
        plants: [_plant()], species: [_species(waterDays: 5)],
        logs: logs, now: _now);
      expect(result, isNotEmpty);
      expect(result.first.efficiency, WateringEfficiency.underwatering);
    });

    test('consistency score between 0 and 1', () {
      final logs = List.generate(8, (i) => _waterLog(i * 7));
      final result = WateringEfficiencyAnalyzer.analyze(
        plants: [_plant()], species: [_species()], logs: logs, now: _now);
      expect(result.first.consistencyScore, greaterThanOrEqualTo(0.0));
      expect(result.first.consistencyScore, lessThanOrEqualTo(1.0));
    });

    test('recommendation matches efficiency', () {
      final logs = List.generate(10, (i) => _waterLog(i * 3));
      final result = WateringEfficiencyAnalyzer.analyze(
        plants: [_plant()], species: [_species(waterDays: 7)],
        logs: logs, now: _now);
      expect(result.first.recommendation, 'waterEfficiencyReduceFrequency');
    });
  });
}
