import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/services/garden_wellness_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GardenWellnessSummary.compute', () {
    test('orders focus plants by lowest health and reports garden totals', () {
      final now = DateTime(2026, 3, 7, 9);
      final plants = <Plant>[
        _plant('p1', 'Monstera', 'Living room'),
        _plant('p2', 'Fern', 'Bathroom'),
        _plant('p3', 'ZZ Plant', 'Bedroom'),
      ];
      final tasks = <TaskInstance>[
        _task(
          id: 't1',
          plantId: 'p1',
          dueAt: DateTime(2026, 3, 7, 18),
        ),
        _task(
          id: 't2',
          plantId: 'p2',
          dueAt: DateTime(2026, 3, 6, 7),
        ),
        _task(
          id: 't3',
          plantId: 'p2',
          dueAt: DateTime(2026, 3, 5, 7),
        ),
        _task(
          id: 't4',
          plantId: 'p3',
          dueAt: DateTime(2026, 3, 9, 10),
        ),
      ];
      final logs = <CareLog>[
        _log('l1', 'p1', DateTime(2026, 3, 5, 8)),
        _log('l2', 'p2', DateTime(2026, 2, 10, 8)),
        _log('l3', 'p3', DateTime(2026, 3, 6, 8)),
      ];

      final summary = GardenWellnessSummary.compute(
        plants: plants,
        tasks: tasks,
        logs: logs,
        now: now,
      );

      expect(summary.plantCount, 3);
      expect(summary.overallScore, 90);
      expect(summary.overdueTasks, 2);
      expect(summary.dueTodayTasks, 1);
      expect(summary.recentlyCaredPlants, 2);
      expect(summary.atRiskPlants, 1);
      expect(summary.focusPlants, hasLength(3));

      final first = summary.focusPlants.first;
      expect(first.plant.nickname, 'Fern');
      expect(first.score, 70);
      expect(first.overdueTasks, 2);
      expect(first.hasRecentLog, isFalse);
    });

    test('returns an empty summary when there are no plants', () {
      final summary = GardenWellnessSummary.compute(
        plants: const <Plant>[],
        tasks: const <TaskInstance>[],
        logs: const <CareLog>[],
        now: DateTime(2026, 3, 7, 9),
      );

      expect(summary.plantCount, 0);
      expect(summary.overallScore, 0);
      expect(summary.overdueTasks, 0);
      expect(summary.dueTodayTasks, 0);
      expect(summary.recentlyCaredPlants, 0);
      expect(summary.atRiskPlants, 0);
      expect(summary.focusPlants, isEmpty);
    });
  });
}

Plant _plant(String id, String nickname, String room) {
  return Plant(
    id: id,
    nickname: nickname,
    speciesId: 'unknown',
    room: room,
    environmentMode: EnvironmentMode.indoor,
    coverAsset: 'assets/placeholders/species/unknown.png',
    createdAt: DateTime(2026, 1, 1),
    meta: const PlantMeta(),
  );
}

TaskInstance _task({
  required String id,
  required String plantId,
  required DateTime dueAt,
}) {
  return TaskInstance(
    id: id,
    plantId: plantId,
    type: TaskType.water,
    dueAt: dueAt,
    status: TaskStatus.pending,
    createdAt: DateTime(2026, 3, 1),
    completedAt: null,
    adjustmentReasonIds: const <String>[],
  );
}

CareLog _log(String id, String plantId, DateTime timestamp) {
  return CareLog(
    id: id,
    plantId: plantId,
    type: TaskType.water,
    timestamp: timestamp,
    note: null,
    linkedPhotoId: null,
  );
}
