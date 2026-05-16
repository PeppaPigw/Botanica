import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Care forecast day bucketing', () {
    TaskInstance makeTask(TaskType type, DateTime dueAt) => TaskInstance(
          id: 'task-${dueAt.toIso8601String()}-${type.id}',
          plantId: 'plant-1',
          type: type,
          dueAt: dueAt,
          status: TaskStatus.pending,
          createdAt: DateTime(2026, 1, 1),
          completedAt: null,
          adjustmentReasonIds: const [],
        );

    List<int> computeForecast(List<TaskInstance> tasks, DateTime today) {
      final dayCounts = List<int>.filled(7, 0);
      for (final t in tasks) {
        if (t.isDismissed || t.status == TaskStatus.snoozed) continue;
        final due = DateTime(t.dueAt.year, t.dueAt.month, t.dueAt.day);
        final diff = due.difference(today).inDays;
        if (diff >= 0 && diff < 7) {
          dayCounts[diff]++;
        }
      }
      return dayCounts;
    }

    test('tasks are bucketed into correct day slots', () {
      final today = DateTime(2026, 5, 15);
      final tasks = [
        makeTask(TaskType.water, DateTime(2026, 5, 15, 9, 0)),
        makeTask(TaskType.fertilize, DateTime(2026, 5, 15, 14, 0)),
        makeTask(TaskType.water, DateTime(2026, 5, 17, 9, 0)),
        makeTask(TaskType.mist, DateTime(2026, 5, 21, 9, 0)),
      ];
      final counts = computeForecast(tasks, today);
      expect(counts[0], 2); // today
      expect(counts[1], 0); // tomorrow
      expect(counts[2], 1); // day after
      expect(counts[6], 1); // 6 days out
    });

    test('dismissed and snoozed tasks are excluded', () {
      final today = DateTime(2026, 5, 15);
      final tasks = [
        makeTask(TaskType.water, DateTime(2026, 5, 15, 9, 0)),
        TaskInstance(
          id: 'done-task',
          plantId: 'plant-1',
          type: TaskType.water,
          dueAt: DateTime(2026, 5, 15, 10, 0),
          status: TaskStatus.done,
          createdAt: DateTime(2026, 1, 1),
          completedAt: DateTime(2026, 5, 15, 10, 0),
          adjustmentReasonIds: const [],
        ),
        TaskInstance(
          id: 'snoozed-task',
          plantId: 'plant-1',
          type: TaskType.mist,
          dueAt: DateTime(2026, 5, 16, 9, 0),
          status: TaskStatus.snoozed,
          createdAt: DateTime(2026, 1, 1),
          completedAt: null,
          adjustmentReasonIds: const [],
        ),
      ];
      final counts = computeForecast(tasks, today);
      expect(counts[0], 1);
      expect(counts[1], 0);
    });

    test('tasks beyond 7 days are excluded', () {
      final today = DateTime(2026, 5, 15);
      final tasks = [
        makeTask(TaskType.water, DateTime(2026, 5, 22, 9, 0)),
        makeTask(TaskType.water, DateTime(2026, 5, 30, 9, 0)),
      ];
      final counts = computeForecast(tasks, today);
      expect(counts.every((c) => c == 0), true);
    });

    test('overdue tasks (before today) are excluded from forecast', () {
      final today = DateTime(2026, 5, 15);
      final tasks = [
        makeTask(TaskType.water, DateTime(2026, 5, 14, 9, 0)),
        makeTask(TaskType.water, DateTime(2026, 5, 10, 9, 0)),
      ];
      final counts = computeForecast(tasks, today);
      expect(counts.every((c) => c == 0), true);
    });

    test('busiest day is correctly identified', () {
      final today = DateTime(2026, 5, 15);
      final tasks = [
        makeTask(TaskType.water, DateTime(2026, 5, 15, 9, 0)),
        makeTask(TaskType.water, DateTime(2026, 5, 18, 9, 0)),
        makeTask(TaskType.fertilize, DateTime(2026, 5, 18, 10, 0)),
        makeTask(TaskType.mist, DateTime(2026, 5, 18, 11, 0)),
      ];
      final counts = computeForecast(tasks, today);
      int busiestIdx = 0;
      for (int i = 1; i < 7; i++) {
        if (counts[i] > counts[busiestIdx]) busiestIdx = i;
      }
      expect(busiestIdx, 3); // day index 3 = May 18
      expect(counts[busiestIdx], 3);
    });
  });
}
