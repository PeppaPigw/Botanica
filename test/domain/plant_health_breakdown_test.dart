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
  }) =>
      TaskInstance(
        id: 'task-${dueAt.hashCode}',
        plantId: 'plant-1',
        type: TaskType.water,
        dueAt: dueAt,
        status: status,
        createdAt: dueAt.subtract(const Duration(days: 7)),
        completedAt: completedAt,
        adjustmentReasonIds: const [],
      );

  CareLog makeLog({required DateTime timestamp, TaskType type = TaskType.water}) =>
      CareLog(
        id: 'log-${timestamp.hashCode}',
        plantId: 'plant-1',
        type: type,
        timestamp: timestamp,
        note: null,
        linkedPhotoId: null,
      );

  group('PlantHealthScore.breakdown', () {
    test('perfect score with no overdue, recent activity, variety, consistency',
        () {
      final tasks = [
        makeTask(
          status: TaskStatus.done,
          dueAt: now.subtract(const Duration(days: 3)),
          completedAt: now.subtract(const Duration(days: 3)),
        ),
        makeTask(
          status: TaskStatus.done,
          dueAt: now.subtract(const Duration(days: 10)),
          completedAt: now.subtract(const Duration(days: 10)),
        ),
      ];
      final logs = [
        makeLog(timestamp: now.subtract(const Duration(days: 1))),
        makeLog(
            timestamp: now.subtract(const Duration(days: 5)),
            type: TaskType.fertilize),
        makeLog(
            timestamp: now.subtract(const Duration(days: 8)),
            type: TaskType.mist),
        makeLog(
            timestamp: now.subtract(const Duration(days: 12)),
            type: TaskType.rotate),
      ];

      final result =
          PlantHealthScore.breakdown(allTasks: tasks, recentLogs: logs, now: now);

      expect(result.totalScore, 100);
      expect(result.factors.length, 4);
    });

    test('overdue tasks reduce score', () {
      final tasks = [
        makeTask(
          status: TaskStatus.pending,
          dueAt: now.subtract(const Duration(days: 2)),
        ),
        makeTask(
          status: TaskStatus.pending,
          dueAt: now.subtract(const Duration(days: 5)),
        ),
      ];
      final logs = [
        makeLog(timestamp: now.subtract(const Duration(days: 1))),
      ];

      final result =
          PlantHealthScore.breakdown(allTasks: tasks, recentLogs: logs, now: now);

      final overdueFactor =
          result.factors.firstWhere((f) => f.id == 'overdue');
      expect(overdueFactor.points, lessThan(overdueFactor.maxPoints));
    });

    test('no recent activity reduces score', () {
      final tasks = <TaskInstance>[];
      final logs = [
        makeLog(timestamp: now.subtract(const Duration(days: 30))),
      ];

      final result =
          PlantHealthScore.breakdown(allTasks: tasks, recentLogs: logs, now: now);

      final activityFactor =
          result.factors.firstWhere((f) => f.id == 'activity');
      expect(activityFactor.points, 0);
    });

    test('diverse care types increase variety score', () {
      final tasks = <TaskInstance>[];
      final logs = [
        makeLog(timestamp: now.subtract(const Duration(days: 1))),
        makeLog(
            timestamp: now.subtract(const Duration(days: 3)),
            type: TaskType.fertilize),
        makeLog(
            timestamp: now.subtract(const Duration(days: 5)),
            type: TaskType.mist),
      ];

      final result =
          PlantHealthScore.breakdown(allTasks: tasks, recentLogs: logs, now: now);

      final varietyFactor =
          result.factors.firstWhere((f) => f.id == 'variety');
      expect(varietyFactor.points, greaterThan(0));
    });

    test('on-time completions increase consistency score', () {
      final tasks = [
        makeTask(
          status: TaskStatus.done,
          dueAt: now.subtract(const Duration(days: 7)),
          completedAt: now.subtract(const Duration(days: 7)),
        ),
        makeTask(
          status: TaskStatus.done,
          dueAt: now.subtract(const Duration(days: 14)),
          completedAt: now.subtract(const Duration(days: 14)),
        ),
      ];
      final logs = [
        makeLog(timestamp: now.subtract(const Duration(days: 1))),
      ];

      final result =
          PlantHealthScore.breakdown(allTasks: tasks, recentLogs: logs, now: now);

      final consistencyFactor =
          result.factors.firstWhere((f) => f.id == 'consistency');
      expect(consistencyFactor.points, consistencyFactor.maxPoints);
    });

    test('compute returns same value as breakdown.totalScore', () {
      final tasks = [
        makeTask(
          status: TaskStatus.pending,
          dueAt: now.subtract(const Duration(days: 1)),
        ),
      ];
      final logs = [
        makeLog(timestamp: now.subtract(const Duration(days: 2))),
      ];

      final score =
          PlantHealthScore.compute(allTasks: tasks, recentLogs: logs, now: now);
      final breakdown =
          PlantHealthScore.breakdown(allTasks: tasks, recentLogs: logs, now: now);

      expect(score, breakdown.totalScore);
    });

    test('score is clamped between 0 and 100', () {
      // Many overdue tasks
      final tasks = List.generate(
        10,
        (i) => makeTask(
          status: TaskStatus.pending,
          dueAt: now.subtract(Duration(days: i + 1)),
        ),
      );
      final logs = <CareLog>[];

      final result =
          PlantHealthScore.breakdown(allTasks: tasks, recentLogs: logs, now: now);

      expect(result.totalScore, greaterThanOrEqualTo(0));
      expect(result.totalScore, lessThanOrEqualTo(100));
    });
  });
}
