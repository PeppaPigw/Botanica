import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/services/plant_health_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlantHealthScore.compute', () {
    test('is 100 when no overdue tasks and recent log exists', () {
      final now = DateTime(2026, 2, 23, 12);

      final tasks = <TaskInstance>[
        TaskInstance(
          id: 't1',
          plantId: 'p1',
          type: TaskType.water,
          dueAt: now.add(const Duration(days: 2)),
          status: TaskStatus.pending,
          createdAt: now,
          completedAt: null,
          adjustmentReasonIds: const [],
        ),
      ];

      final logs = <CareLog>[
        CareLog(
          id: 'l1',
          plantId: 'p1',
          type: TaskType.water,
          timestamp: now.subtract(const Duration(days: 1)),
          note: null,
          linkedPhotoId: null,
        ),
      ];

      expect(
        PlantHealthScore.compute(allTasks: tasks, recentLogs: logs, now: now),
        100,
      );
    });

    test('decreases by 10 per overdue task capped at 50', () {
      final now = DateTime(2026, 2, 23, 12);

      TaskInstance overdue(String id) => TaskInstance(
            id: id,
            plantId: 'p1',
            type: TaskType.water,
            dueAt: now.subtract(const Duration(days: 1)),
            status: TaskStatus.pending,
            createdAt: now,
            completedAt: null,
            adjustmentReasonIds: const [],
          );

      final tasks = <TaskInstance>[
        overdue('t1'),
        overdue('t2'),
        overdue('t3'),
        overdue('t4'),
        overdue('t5'),
        overdue('t6'),
      ];

      final logs = <CareLog>[
        CareLog(
          id: 'l1',
          plantId: 'p1',
          type: TaskType.water,
          timestamp: now.subtract(const Duration(days: 2)),
          note: null,
          linkedPhotoId: null,
        ),
      ];

      // 6 overdue tasks would be -60, but capped at -50.
      expect(
        PlantHealthScore.compute(allTasks: tasks, recentLogs: logs, now: now),
        50,
      );
    });

    test('decreases by 10 when there is no log in the last 14 days', () {
      final now = DateTime(2026, 2, 23, 12);

      final tasks = <TaskInstance>[
        TaskInstance(
          id: 't1',
          plantId: 'p1',
          type: TaskType.water,
          dueAt: now.add(const Duration(days: 5)),
          status: TaskStatus.pending,
          createdAt: now,
          completedAt: null,
          adjustmentReasonIds: const [],
        ),
      ];

      final logs = <CareLog>[
        CareLog(
          id: 'l1',
          plantId: 'p1',
          type: TaskType.water,
          timestamp: now.subtract(const Duration(days: 20)),
          note: null,
          linkedPhotoId: null,
        ),
      ];

      expect(
        PlantHealthScore.compute(allTasks: tasks, recentLogs: logs, now: now),
        90,
      );
    });

    test('never goes below 0', () {
      final now = DateTime(2026, 2, 23, 12);

      final tasks = List.generate(
        12,
        (i) => TaskInstance(
          id: 't$i',
          plantId: 'p1',
          type: TaskType.water,
          dueAt: now.subtract(const Duration(days: 1)),
          status: TaskStatus.pending,
          createdAt: now,
          completedAt: null,
          adjustmentReasonIds: const [],
        ),
      );

      const logs = <CareLog>[];

      expect(
        PlantHealthScore.compute(allTasks: tasks, recentLogs: logs, now: now),
        40,
        reason:
            'Overdue penalty capped at 50, plus 10 for missing recent log → 40',
      );
    });
  });
}
