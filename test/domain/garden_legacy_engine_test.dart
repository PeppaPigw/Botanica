import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_legacy_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {int daysAgo = 180}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: _now.subtract(Duration(days: daysAgo)),
      meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(String plantId, int daysAgo) => CareLog(
      id: 'log_${plantId}_$daysAgo', plantId: plantId, type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('GardenLegacyEngine', () {
    test('empty garden returns zero', () {
      final report = GardenLegacyEngine.compute(
        plants: [], logs: [], now: _now,
      );
      expect(report.overallScore, 0.0);
      expect(report.statusKey, 'legacyEmpty');
    });

    test('scores based on age and care', () {
      final logs = List.generate(30, (i) => _log('p1', i * 5));
      final report = GardenLegacyEngine.compute(
        plants: [_plant('p1', daysAgo: 365)], logs: logs, now: _now,
      );
      expect(report.overallScore, greaterThan(0.3));
      expect(report.longestSurvivor, 'p1');
    });

    test('identifies longest survivor', () {
      final report = GardenLegacyEngine.compute(
        plants: [_plant('p1', daysAgo: 400), _plant('p2', daysAgo: 100)],
        logs: [], now: _now,
      );
      expect(report.longestSurvivor, 'p1');
    });

    test('higher care frequency improves score', () {
      final lowCare = GardenLegacyEngine.compute(
        plants: [_plant('p1')],
        logs: List.generate(5, (i) => _log('p1', i * 30)),
        now: _now,
      );
      final highCare = GardenLegacyEngine.compute(
        plants: [_plant('p1')],
        logs: List.generate(50, (i) => _log('p1', i * 3)),
        now: _now,
      );
      expect(highCare.overallScore, greaterThan(lowCare.overallScore));
    });

    test('status reflects score level', () {
      final report = GardenLegacyEngine.compute(
        plants: [_plant('p1', daysAgo: 30)], logs: [], now: _now,
      );
      expect(report.statusKey, isNotEmpty);
    });
  });
}
