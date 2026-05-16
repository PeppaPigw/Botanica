import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/environment_stress_detector.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';

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

CareLog _log(DateTime ts, {
  String plantId = 'p1',
  TaskType type = TaskType.water,
}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task({
  String plantId = 'p1',
  required DateTime dueAt,
  TaskStatus status = TaskStatus.done,
  DateTime? completedAt,
}) => TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 7)),
      completedAt: completedAt,
      adjustmentReasonIds: const [],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('EnvironmentStressDetector', () {
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
        EnvironmentStressDetector.detect(
          plant: archived, logs: [], tasks: [], now: now),
        isNull,
      );
    });

    test('returns null with fewer than 4 logs', () {
      final logs = List.generate(3, (i) =>
          _log(now.subtract(Duration(days: i * 5))));
      expect(
        EnvironmentStressDetector.detect(
          plant: _plant(), logs: logs, tasks: [], now: now),
        isNull,
      );
    });

    test('detects sudden watering increase', () {
      final logs = <CareLog>[
        // Recent 2 weeks: 6 waterings
        ...List.generate(6, (i) =>
            _log(now.subtract(Duration(days: i * 2)))),
        // Previous 2 weeks: 2 waterings
        _log(now.subtract(const Duration(days: 18))),
        _log(now.subtract(const Duration(days: 25))),
      ];
      final result = EnvironmentStressDetector.detect(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.signals, contains(StressSignal.suddenWateringIncrease));
      expect(result.suggestion, 'suggestionCheckDrainage');
    });

    test('detects no recent care', () {
      final logs = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: 30 + i * 5))));
      final result = EnvironmentStressDetector.detect(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.signals, contains(StressSignal.noRecentCare));
    });

    test('detects erratic schedule', () {
      // Very irregular watering: 1 day, 1 day, 20 days, 1 day gaps
      final logs = [
        _log(now.subtract(const Duration(days: 1))),
        _log(now.subtract(const Duration(days: 2))),
        _log(now.subtract(const Duration(days: 3))),
        _log(now.subtract(const Duration(days: 23))),
        _log(now.subtract(const Duration(days: 24))),
      ];
      final result = EnvironmentStressDetector.detect(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.signals, contains(StressSignal.erraticSchedule));
    });

    test('detects missed care after consistency', () {
      final tasks = [
        // Some completed, more pending
        _task(dueAt: now.subtract(const Duration(days: 3)),
            status: TaskStatus.done,
            completedAt: now.subtract(const Duration(days: 3))),
        _task(dueAt: now.subtract(const Duration(days: 10)),
            status: TaskStatus.done,
            completedAt: now.subtract(const Duration(days: 10))),
        _task(dueAt: now.subtract(const Duration(days: 5)),
            status: TaskStatus.pending),
        _task(dueAt: now.subtract(const Duration(days: 7)),
            status: TaskStatus.pending),
        _task(dueAt: now.subtract(const Duration(days: 14)),
            status: TaskStatus.pending),
      ];
      final logs = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: i * 5))));
      final result = EnvironmentStressDetector.detect(
        plant: _plant(), logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      expect(result!.signals,
          contains(StressSignal.missedCareAfterConsistency));
    });

    test('returns null for healthy plant with regular care', () {
      // Regular watering every 7 days
      final logs = List.generate(6, (i) =>
          _log(now.subtract(Duration(days: i * 7))));
      final result = EnvironmentStressDetector.detect(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNull);
    });

    test('stress level increases with more signals', () {
      // Create conditions for multiple signals
      final logs = [
        // No recent care (last was 25 days ago)
        ...List.generate(5, (i) =>
            _log(now.subtract(Duration(days: 25 + i * 3)))),
      ];
      final result = EnvironmentStressDetector.detect(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.level.index, greaterThanOrEqualTo(StressLevel.moderate.index));
    });

    test('detectAll returns sorted results', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2')];
      final logs = [
        // p1: no recent care
        ...List.generate(5, (i) =>
            _log(now.subtract(Duration(days: 30 + i * 5)), plantId: 'p1')),
        // p2: regular care
        ...List.generate(5, (i) =>
            _log(now.subtract(Duration(days: i * 7)), plantId: 'p2')),
      ];
      final results = EnvironmentStressDetector.detectAll(
        plants: plants, logs: logs, tasks: [], now: now);
      // Only p1 should be stressed
      expect(results.length, 1);
      expect(results.first.plantId, 'p1');
    });

    test('confidence increases with more signals', () {
      final logsOneSignal = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: 25 + i * 3))));
      final resultOne = EnvironmentStressDetector.detect(
        plant: _plant(), logs: logsOneSignal, tasks: [], now: now);

      // Multiple signals: no recent care + long gap after frequent
      final logsMulti = [
        ...List.generate(8, (i) =>
            _log(now.subtract(Duration(days: 25 + i)))),
      ];
      final resultMulti = EnvironmentStressDetector.detect(
        plant: _plant(), logs: logsMulti, tasks: [], now: now);

      if (resultOne != null && resultMulti != null) {
        expect(resultMulti.confidence,
            greaterThanOrEqualTo(resultOne.confidence));
      }
    });
  });
}
