import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_vital_signs_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant() => Plant(
      id: 'p1', nickname: 'Fern', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(int daysAgo, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_${type.name}_$daysAgo', plantId: 'p1', type: type,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('PlantVitalSignsEngine', () {
    test('computes dashboard with no logs', () {
      final result = PlantVitalSignsEngine.compute(
        plant: _plant(), logs: [], healthScore: 0.5, now: _now);
      expect(result.vitalSigns.length, 3);
      expect(result.nextAction, 'vitalActionWaterNow');
    });

    test('hydration is good after recent watering', () {
      final logs = [_log(1), _log(5), _log(10)];
      final result = PlantVitalSignsEngine.compute(
        plant: _plant(), logs: logs, healthScore: 0.8, now: _now,
        waterIntervalDays: 7);
      final hydration = result.vitalSigns.firstWhere((v) => v.name == 'hydration');
      expect(hydration.value, greaterThan(0.5));
      expect(hydration.status, 'vitalGood');
    });

    test('hydration drops when overdue', () {
      final logs = [_log(10)];
      final result = PlantVitalSignsEngine.compute(
        plant: _plant(), logs: logs, healthScore: 0.5, now: _now,
        waterIntervalDays: 7);
      final hydration = result.vitalSigns.firstWhere((v) => v.name == 'hydration');
      expect(hydration.value, lessThan(0.5));
    });

    test('overall status reflects health score', () {
      final logs = [_log(1)];
      final thriving = PlantVitalSignsEngine.compute(
        plant: _plant(), logs: logs, healthScore: 0.9, now: _now);
      expect(thriving.overallStatus, 'vitalStatusThriving');

      final critical = PlantVitalSignsEngine.compute(
        plant: _plant(), logs: [_log(20)], healthScore: 0.2, now: _now);
      expect(critical.overallStatus, 'vitalStatusCritical');
    });

    test('days until next care computed', () {
      final logs = [_log(3)];
      final result = PlantVitalSignsEngine.compute(
        plant: _plant(), logs: logs, healthScore: 0.7, now: _now,
        waterIntervalDays: 7);
      expect(result.daysUntilNextCare, 4);
    });

    test('care streak counts consecutive days', () {
      final logs = [_log(0), _log(1), _log(2)];
      final result = PlantVitalSignsEngine.compute(
        plant: _plant(), logs: logs, healthScore: 0.7, now: _now);
      expect(result.careStreak, greaterThanOrEqualTo(2));
    });
  });
}
