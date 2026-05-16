import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/services/plant_health_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2025, 5, 15);

  TaskInstance makeTask({
    required TaskStatus status,
    required DateTime dueAt,
    DateTime? completedAt,
    String plantId = 'plant-1',
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

  CareLog makeLog({
    required DateTime timestamp,
    String plantId = 'plant-1',
  }) =>
      CareLog(
        id: 'log-${timestamp.hashCode}-$plantId',
        plantId: plantId,
        type: TaskType.water,
        timestamp: timestamp,
        note: null,
        linkedPhotoId: null,
      );

  group('Garden-level health score (average across plants)', () {
    test('single plant with perfect care scores 100', () {
      final tasks = List.generate(5, (i) {
        final due = now.subtract(Duration(days: (i + 1) * 3));
        return makeTask(status: TaskStatus.done, dueAt: due, completedAt: due);
      });
      final logs = [makeLog(timestamp: now.subtract(const Duration(days: 1)))];

      final score = PlantHealthScore.compute(
        allTasks: tasks,
        recentLogs: logs,
        now: now,
      );
      expect(score, equals(100));
    });

    test('plant with overdue task scores less than 100', () {
      final tasks = [
        makeTask(
          status: TaskStatus.pending,
          dueAt: now.subtract(const Duration(days: 5)),
        ),
      ];
      final logs = [makeLog(timestamp: now.subtract(const Duration(days: 10)))];

      final score = PlantHealthScore.compute(
        allTasks: tasks,
        recentLogs: logs,
        now: now,
      );
      expect(score, lessThan(100));
    });

    test('average of two plants computes correctly', () {
      final plant1Tasks = List.generate(5, (i) {
        final due = now.subtract(Duration(days: (i + 1) * 3));
        return makeTask(
          status: TaskStatus.done,
          dueAt: due,
          completedAt: due,
          plantId: 'plant-1',
        );
      });
      final plant1Logs = [
        makeLog(
          timestamp: now.subtract(const Duration(days: 1)),
          plantId: 'plant-1',
        ),
      ];

      final plant2Tasks = [
        makeTask(
          status: TaskStatus.pending,
          dueAt: now.subtract(const Duration(days: 7)),
          plantId: 'plant-2',
        ),
      ];
      final plant2Logs = [
        makeLog(
          timestamp: now.subtract(const Duration(days: 20)),
          plantId: 'plant-2',
        ),
      ];

      final score1 = PlantHealthScore.compute(
        allTasks: plant1Tasks,
        recentLogs: plant1Logs,
        now: now,
      );
      final score2 = PlantHealthScore.compute(
        allTasks: plant2Tasks,
        recentLogs: plant2Logs,
        now: now,
      );

      final average = ((score1 + score2) / 2).round();
      expect(average, greaterThan(score2));
      expect(average, lessThan(score1));
    });

    test('plant with no tasks and recent log scores 100', () {
      final logs = [makeLog(timestamp: now.subtract(const Duration(days: 1)))];

      final score = PlantHealthScore.compute(
        allTasks: const [],
        recentLogs: logs,
        now: now,
      );
      expect(score, equals(100));
    });
  });
}
