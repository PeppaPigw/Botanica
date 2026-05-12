import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/services/garden_wellness_priorities.dart';
import 'package:botanica/domain/services/garden_wellness_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GardenWellnessPriorities.build', () {
    test('returns personalized urgent priorities for an at-risk garden', () {
      final summary = GardenWellnessSummary.compute(
        plants: <Plant>[
          _plant('p1', 'Monstera', 'Living room'),
          _plant('p2', 'Fern', 'Bathroom'),
        ],
        tasks: <TaskInstance>[
          _task(id: 't1', plantId: 'p2', dueAt: DateTime(2026, 3, 5, 7)),
          _task(id: 't2', plantId: 'p2', dueAt: DateTime(2026, 3, 6, 7)),
          _task(id: 't3', plantId: 'p1', dueAt: DateTime(2026, 3, 7, 18)),
        ],
        logs: <CareLog>[
          _log('l1', 'p1', DateTime(2026, 3, 6, 8)),
          _log('l2', 'p2', DateTime(2026, 2, 10, 8)),
        ],
        now: DateTime(2026, 3, 7, 9),
      );

      final priorities = GardenWellnessPriorities.build(summary: summary);

      expect(priorities, hasLength(3));
      expect(priorities.first.title, 'Check on Fern');
      expect(priorities.first.body, '2 overdue tasks and no recent log.');
      expect(priorities[1].title, 'Keep today on track');
      expect(priorities[1].body, '1 task is due today.');
      expect(priorities[2].title, 'Refresh care history');
      expect(priorities[2].body, '1 plant is missing a recent log.');
    });

    test('returns a calm fallback when nothing is urgent', () {
      final summary = GardenWellnessSummary.compute(
        plants: <Plant>[
          _plant('p1', 'Monstera', 'Living room'),
        ],
        tasks: <TaskInstance>[
          _task(id: 't1', plantId: 'p1', dueAt: DateTime(2026, 3, 12, 18)),
        ],
        logs: <CareLog>[
          _log('l1', 'p1', DateTime(2026, 3, 6, 8)),
        ],
        now: DateTime(2026, 3, 7, 9),
      );

      final priorities = GardenWellnessPriorities.build(summary: summary);

      expect(priorities, hasLength(1));
      expect(priorities.first.title, 'Enjoy the calm');
      expect(
        priorities.first.body,
        'No urgent issues today — your garden looks steady.',
      );
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
