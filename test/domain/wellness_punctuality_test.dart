import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/services/garden_wellness_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2025, 5, 15);

  Plant makePlant(String id) => Plant(
        id: id,
        nickname: 'Plant $id',
        speciesId: 'species-1',
        room: 'Living Room',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: now.subtract(const Duration(days: 60)),
        meta: const PlantMeta(),
        isArchived: false,
      );

  TaskInstance makeTask({
    required String plantId,
    required DateTime dueAt,
    required TaskStatus status,
    DateTime? completedAt,
  }) =>
      TaskInstance(
        id: 'task-${dueAt.hashCode}-$plantId',
        plantId: plantId,
        type: TaskType.water,
        dueAt: dueAt,
        status: status,
        createdAt: dueAt.subtract(const Duration(days: 7)),
        completedAt: completedAt,
        adjustmentReasonIds: const [],
      );

  CareLog makeLog(String plantId, DateTime timestamp) => CareLog(
        id: 'log-${timestamp.hashCode}-$plantId',
        plantId: plantId,
        type: TaskType.water,
        timestamp: timestamp,
        note: null,
        linkedPhotoId: null,
      );

  group('GardenWellnessSummary punctualityPercent', () {
    test('100% when all tasks completed on time', () {
      final plants = [makePlant('p1')];
      final tasks = List.generate(5, (i) {
        final due = now.subtract(Duration(days: (i + 1) * 3));
        return makeTask(
          plantId: 'p1',
          dueAt: due,
          status: TaskStatus.done,
          completedAt: due,
        );
      });
      final logs = [makeLog('p1', now.subtract(const Duration(days: 1)))];

      final summary = GardenWellnessSummary.compute(
        plants: plants,
        tasks: tasks,
        logs: logs,
        now: now,
      );

      expect(summary.punctualityPercent, equals(100));
    });

    test('0% when all tasks completed late', () {
      final plants = [makePlant('p1')];
      final tasks = List.generate(5, (i) {
        final due = now.subtract(Duration(days: (i + 1) * 3));
        return makeTask(
          plantId: 'p1',
          dueAt: due,
          status: TaskStatus.done,
          completedAt: due.add(const Duration(days: 3)),
        );
      });
      final logs = [makeLog('p1', now.subtract(const Duration(days: 1)))];

      final summary = GardenWellnessSummary.compute(
        plants: plants,
        tasks: tasks,
        logs: logs,
        now: now,
      );

      expect(summary.punctualityPercent, equals(0));
    });

    test('50% when half on time half late', () {
      final plants = [makePlant('p1')];
      final tasks = [
        makeTask(
          plantId: 'p1',
          dueAt: now.subtract(const Duration(days: 6)),
          status: TaskStatus.done,
          completedAt: now.subtract(const Duration(days: 6)),
        ),
        makeTask(
          plantId: 'p1',
          dueAt: now.subtract(const Duration(days: 3)),
          status: TaskStatus.done,
          completedAt: now,
        ),
      ];
      final logs = [makeLog('p1', now.subtract(const Duration(days: 1)))];

      final summary = GardenWellnessSummary.compute(
        plants: plants,
        tasks: tasks,
        logs: logs,
        now: now,
      );

      expect(summary.punctualityPercent, equals(50));
    });

    test('100% when no completed tasks', () {
      final plants = [makePlant('p1')];
      final tasks = [
        makeTask(
          plantId: 'p1',
          dueAt: now.add(const Duration(days: 3)),
          status: TaskStatus.pending,
        ),
      ];
      final logs = [makeLog('p1', now.subtract(const Duration(days: 1)))];

      final summary = GardenWellnessSummary.compute(
        plants: plants,
        tasks: tasks,
        logs: logs,
        now: now,
      );

      expect(summary.punctualityPercent, equals(100));
    });

    test('empty garden returns 100', () {
      final summary = GardenWellnessSummary.compute(
        plants: const [],
        tasks: const [],
        logs: const [],
        now: now,
      );

      expect(summary.punctualityPercent, equals(100));
    });
  });
}
