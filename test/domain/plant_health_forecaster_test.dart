import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_health_forecaster.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';

Plant _plant({String id = 'p1', bool isArchived = false}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: isArchived,
    );

CareLog _log(
  DateTime ts, {
  String plantId = 'p1',
  TaskType type = TaskType.water,
}) =>
    CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}_$plantId',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task({
  String plantId = 'p1',
  required DateTime dueAt,
  TaskStatus status = TaskStatus.pending,
  DateTime? completedAt,
}) =>
    TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}_$plantId',
      plantId: plantId,
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 1)),
      completedAt: completedAt,
      adjustmentReasonIds: const [],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PlantHealthForecaster.forecast', () {
    test('returns null for archived plants', () {
      final plant = _plant(isArchived: true);
      final logs = List.generate(
          10, (i) => _log(now.subtract(Duration(days: i))));
      final result = PlantHealthForecaster.forecast(
        plant: plant, logs: logs, tasks: [], now: now);
      expect(result, isNull);
    });

    test('returns null with fewer than 5 logs', () {
      final logs = List.generate(
          4, (i) => _log(now.subtract(Duration(days: i))));
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNull);
    });

    test('returns stable when care is consistent across both periods', () {
      // Even distribution: 3 logs in recent 14 days, 3 in older 14-28 days
      final logs = [
        _log(now.subtract(const Duration(days: 3))),
        _log(now.subtract(const Duration(days: 7))),
        _log(now.subtract(const Duration(days: 11))),
        _log(now.subtract(const Duration(days: 17))),
        _log(now.subtract(const Duration(days: 21))),
        _log(now.subtract(const Duration(days: 25))),
      ];
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.forecast, HealthForecast.stable);
      expect(result.primaryFactor, 'consistentCare');
      expect(result.confidence, 0.6);
      expect(result.daysUntilChange, 14);
    });

    test('detects improving when recent care frequency exceeds older by 1.3x', () {
      // 8 logs in recent 14 days, 2 in older 14-28 days
      final logs = [
        ...List.generate(8, (i) => _log(now.subtract(Duration(days: i + 1)))),
        _log(now.subtract(const Duration(days: 18))),
        _log(now.subtract(const Duration(days: 22))),
      ];
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.forecast, HealthForecast.improving);
      expect(result.primaryFactor, 'increasedCare');
      expect(result.daysUntilChange, 14);
    });

    test('detects declining when recent care frequency drops below older * 0.6', () {
      // 1 log in recent 14 days, 8 in older 14-28 days
      final logs = [
        _log(now.subtract(const Duration(days: 5))),
        ...List.generate(8, (i) => _log(now.subtract(Duration(days: 15 + i)))),
      ];
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.forecast, HealthForecast.declining);
      expect(result.primaryFactor, 'decreasedCare');
      expect(result.daysUntilChange, 7);
    });

    test('detects atRisk with 3+ overdue tasks', () {
      final logs = List.generate(
          6, (i) => _log(now.subtract(Duration(days: i + 1))));
      final tasks = [
        _task(dueAt: now.subtract(const Duration(days: 1))),
        _task(dueAt: now.subtract(const Duration(days: 2))),
        _task(dueAt: now.subtract(const Duration(days: 3))),
      ];
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      expect(result!.forecast, HealthForecast.atRisk);
      expect(result.primaryFactor, 'manyOverdue');
      expect(result.daysUntilChange, 3);
    });

    test('detects declining with 1-2 overdue tasks', () {
      // Consistent care so only overdue signal fires
      final logs = [
        ...List.generate(3, (i) => _log(now.subtract(Duration(days: i + 1)))),
        ...List.generate(3, (i) => _log(now.subtract(Duration(days: 15 + i)))),
      ];
      final tasks = [
        _task(dueAt: now.subtract(const Duration(days: 1))),
      ];
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      expect(result!.forecast, HealthForecast.declining);
      expect(result.primaryFactor, 'overdueTask');
    });

    test('detects atRisk with care gap > 14 days', () {
      // All logs older than 14 days
      final logs = List.generate(
          6, (i) => _log(now.subtract(Duration(days: 16 + i))));
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.forecast, HealthForecast.atRisk);
      expect(result.primaryFactor, 'longGap');
      expect(result.daysUntilChange, 3);
    });

    test('detects declining with care gap 8-14 days', () {
      // Last care was 10 days ago; equal frequency in both periods so only gap fires
      final logs = [
        _log(now.subtract(const Duration(days: 10))),
        _log(now.subtract(const Duration(days: 11))),
        _log(now.subtract(const Duration(days: 12))),
        _log(now.subtract(const Duration(days: 18))),
        _log(now.subtract(const Duration(days: 20))),
        _log(now.subtract(const Duration(days: 22))),
      ];
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.primaryFactor, 'careGap');
      expect(result.forecast, HealthForecast.declining);
    });

    test('detects improving with diverse care types', () {
      // 3+ different care types in recent 14 days, consistent frequency
      final logs = [
        _log(now.subtract(const Duration(days: 1)), type: TaskType.water),
        _log(now.subtract(const Duration(days: 2)), type: TaskType.fertilize),
        _log(now.subtract(const Duration(days: 3)), type: TaskType.mist),
        _log(now.subtract(const Duration(days: 15)), type: TaskType.water),
        _log(now.subtract(const Duration(days: 17)), type: TaskType.water),
        _log(now.subtract(const Duration(days: 19)), type: TaskType.water),
      ];
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.forecast, HealthForecast.improving);
      expect(result.primaryFactor, contains('Care'));
    });

    test('confidence is clamped between 0.3 and 0.95', () {
      // Many signals to push confidence high
      final logs = List.generate(
          6, (i) => _log(now.subtract(Duration(days: 16 + i))));
      final tasks = [
        _task(dueAt: now.subtract(const Duration(days: 1))),
        _task(dueAt: now.subtract(const Duration(days: 2))),
        _task(dueAt: now.subtract(const Duration(days: 3))),
      ];
      final result = PlantHealthForecaster.forecast(
        plant: _plant(), logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      expect(result!.confidence, greaterThanOrEqualTo(0.3));
      expect(result.confidence, lessThanOrEqualTo(0.95));
    });

    test('only considers logs for the given plant', () {
      // 5 logs for p2, only 3 for p1 — should return null for p1
      final logs = [
        ...List.generate(3, (i) => _log(now.subtract(Duration(days: i + 1)),
            plantId: 'p1')),
        ...List.generate(5, (i) => _log(now.subtract(Duration(days: i + 1)),
            plantId: 'p2')),
      ];
      final result = PlantHealthForecaster.forecast(
        plant: _plant(id: 'p1'), logs: logs, tasks: [], now: now);
      expect(result, isNull);
    });
  });

  group('PlantHealthForecaster.forecastAll', () {
    test('excludes archived plants', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2', isArchived: true)];
      final logs = [
        ...List.generate(6, (i) => _log(now.subtract(Duration(days: i + 1)),
            plantId: 'p1')),
        ...List.generate(3, (i) => _log(now.subtract(Duration(days: 15 + i)),
            plantId: 'p1')),
        ...List.generate(6, (i) => _log(now.subtract(Duration(days: i + 1)),
            plantId: 'p2')),
      ];
      final results = PlantHealthForecaster.forecastAll(
        plants: plants, logs: logs, tasks: [], now: now);
      expect(results.every((r) => r.plantId != 'p2'), isTrue);
    });

    test('returns empty when no plants have enough logs', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2')];
      final logs = [
        _log(now.subtract(const Duration(days: 1)), plantId: 'p1'),
        _log(now.subtract(const Duration(days: 2)), plantId: 'p2'),
      ];
      final results = PlantHealthForecaster.forecastAll(
        plants: plants, logs: logs, tasks: [], now: now);
      expect(results, isEmpty);
    });

    test('sorts results by forecast index', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2')];
      final logs = [
        // p1: consistent care → stable
        ...List.generate(3, (i) => _log(now.subtract(Duration(days: i + 1)),
            plantId: 'p1')),
        ...List.generate(3, (i) => _log(now.subtract(Duration(days: 15 + i)),
            plantId: 'p1')),
        // p2: all old logs → atRisk (long gap)
        ...List.generate(6, (i) => _log(now.subtract(Duration(days: 16 + i)),
            plantId: 'p2')),
      ];
      final results = PlantHealthForecaster.forecastAll(
        plants: plants, logs: logs, tasks: [], now: now);
      if (results.length >= 2) {
        for (int i = 0; i < results.length - 1; i++) {
          expect(results[i].forecast.index,
              lessThanOrEqualTo(results[i + 1].forecast.index));
        }
      }
    });
  });
}
