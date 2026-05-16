import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_health_timeline.dart';
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

CareLog _log(DateTime ts, {String plantId = 'p1', TaskType type = TaskType.water}) =>
    CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}_$plantId',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task({
  required DateTime dueAt,
  String plantId = 'p1',
  TaskStatus status = TaskStatus.done,
}) =>
    TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}_$plantId',
      plantId: plantId,
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 1)),
      completedAt: status == TaskStatus.done ? dueAt : null,
      adjustmentReasonIds: const [],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PlantHealthTimeline', () {
    test('returns null for archived plants', () {
      final result = PlantHealthTimeline.generate(
        plant: _plant(isArchived: true), logs: [], tasks: [], now: now);
      expect(result, isNull);
    });

    test('returns null with fewer than 4 logs', () {
      final logs = List.generate(3, (i) =>
          _log(now.subtract(Duration(days: i * 7))));
      final result = PlantHealthTimeline.generate(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNull);
    });

    test('returns null when span is less than 2 weeks', () {
      final logs = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: i))));
      final result = PlantHealthTimeline.generate(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNull);
    });

    test('generates timeline with sufficient data', () {
      final logs = List.generate(20, (i) =>
          _log(now.subtract(Duration(days: i * 3))));
      final tasks = List.generate(10, (i) =>
          _task(dueAt: now.subtract(Duration(days: i * 5))));
      final result = PlantHealthTimeline.generate(
        plant: _plant(), logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      expect(result!.snapshots, isNotEmpty);
      expect(result.plantId, 'p1');
    });

    test('snapshots have scores between 0 and 1', () {
      final logs = List.generate(30, (i) =>
          _log(now.subtract(Duration(days: i * 2))));
      final tasks = List.generate(15, (i) =>
          _task(dueAt: now.subtract(Duration(days: i * 4))));
      final result = PlantHealthTimeline.generate(
        plant: _plant(), logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      for (final snapshot in result!.snapshots) {
        expect(snapshot.score, greaterThanOrEqualTo(0.0));
        expect(snapshot.score, lessThanOrEqualTo(1.0));
      }
    });

    test('trend is positive when recent care improves', () {
      // Sparse old care, dense recent care
      final logs = [
        // Old: 1 log per week for weeks 8-5
        ...List.generate(4, (i) =>
            _log(now.subtract(Duration(days: 35 + i * 7)))),
        // Recent: 3 logs per week for weeks 4-1
        ...List.generate(12, (i) =>
            _log(now.subtract(Duration(days: i * 2)))),
      ];
      final result = PlantHealthTimeline.generate(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.trend, greaterThan(0));
    });

    test('bestWeek and worstWeek are populated', () {
      final logs = List.generate(20, (i) =>
          _log(now.subtract(Duration(days: i * 3))));
      final result = PlantHealthTimeline.generate(
        plant: _plant(), logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.bestWeek, isNotNull);
      expect(result.worstWeek, isNotNull);
    });

    test('only considers logs for the given plant', () {
      final logs = [
        ...List.generate(3, (i) =>
            _log(now.subtract(Duration(days: i * 7)), plantId: 'p1')),
        ...List.generate(20, (i) =>
            _log(now.subtract(Duration(days: i * 3)), plantId: 'p2')),
      ];
      final result = PlantHealthTimeline.generate(
        plant: _plant(id: 'p1'), logs: logs, tasks: [], now: now);
      // Only 3 logs for p1, needs 4 minimum
      expect(result, isNull);
    });
  });
}
