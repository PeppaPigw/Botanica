import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_compatibility_checker.dart';
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
  group('PlantCompatibilityChecker', () {
    test('perfect match for identical species', () {
      final result = PlantCompatibilityChecker.check(
        plantA: _plant('p1'), plantB: _plant('p2'),
        speciesLight: {'sp1': 'medium'},
        speciesWaterDays: {'sp1': 7},
      );
      expect(result.overallScore, 1.0);
      expect(result.verdict, 'compatibilityGreat');
    });

    test('poor match for very different needs', () {
      final result = PlantCompatibilityChecker.check(
        plantA: _plant('p1', speciesId: 'cactus', env: EnvironmentMode.outdoor),
        plantB: _plant('p2', speciesId: 'fern', env: EnvironmentMode.indoor),
        speciesLight: {'cactus': 'direct', 'fern': 'low'},
        speciesWaterDays: {'cactus': 14, 'fern': 2},
      );
      expect(result.overallScore, lessThan(0.4));
      expect(result.verdict, 'compatibilityPoor');
      expect(result.tips, isNotEmpty);
    });

    test('environment mismatch reduces score', () {
      final result = PlantCompatibilityChecker.check(
        plantA: _plant('p1', env: EnvironmentMode.indoor),
        plantB: _plant('p2', env: EnvironmentMode.outdoor),
        speciesLight: {'sp1': 'medium'},
        speciesWaterDays: {'sp1': 7},
      );
      expect(result.humidityMatch, 0.5);
      expect(result.overallScore, lessThan(1.0));
    });

    test('room report detects conflicts', () {
      final plants = [
        _plant('p1', speciesId: 'cactus', env: EnvironmentMode.outdoor),
        _plant('p2', speciesId: 'fern', env: EnvironmentMode.indoor),
      ];
      final report = PlantCompatibilityChecker.analyzeRoom(
        room: 'Living Room', plantsInRoom: plants,
        speciesLight: {'cactus': 'direct', 'fern': 'low'},
        speciesWaterDays: {'cactus': 14, 'fern': 2},
      );
      expect(report.conflicts, isNotEmpty);
      expect(report.avgCompatibility, lessThan(0.4));
    });

    test('room report with single plant has no pairs', () {
      final report = PlantCompatibilityChecker.analyzeRoom(
        room: 'Bedroom', plantsInRoom: [_plant('p1')],
        speciesLight: {'sp1': 'medium'},
        speciesWaterDays: {'sp1': 7},
      );
      expect(report.pairs, isEmpty);
      expect(report.avgCompatibility, 1.0);
    });

    test('generates tips for mismatches', () {
      final result = PlantCompatibilityChecker.check(
        plantA: _plant('p1', speciesId: 'a', env: EnvironmentMode.indoor),
        plantB: _plant('p2', speciesId: 'b', env: EnvironmentMode.outdoor),
        speciesLight: {'a': 'low', 'b': 'bright'},
        speciesWaterDays: {'a': 3, 'b': 14},
      );
      expect(result.tips, contains('compatibilityTipLight'));
      expect(result.tips, contains('compatibilityTipWater'));
      expect(result.tips, contains('compatibilityTipEnvironment'));
    });
  });
}
