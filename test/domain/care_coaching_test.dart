import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/domain/services/care_coaching.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2025, 5, 15, 20, 0);
  final settings = UserSettings.defaults().copyWith(
    careStreakDays: 5,
    lastCareDate: DateTime(2025, 5, 14),
  );

  TaskInstance makeTask({
    required TaskStatus status,
    required DateTime dueAt,
    DateTime? completedAt,
    String plantId = 'p1',
    TaskType type = TaskType.water,
  }) =>
      TaskInstance(
        id: 'task-${dueAt.hashCode}-${type.id}',
        plantId: plantId,
        type: type,
        dueAt: dueAt,
        status: status,
        createdAt: dueAt.subtract(const Duration(days: 7)),
        completedAt: completedAt,
        adjustmentReasonIds: const [],
      );

  CareLog makeLog({
    required DateTime timestamp,
    TaskType type = TaskType.water,
    String plantId = 'p1',
  }) =>
      CareLog(
        id: 'log-${timestamp.hashCode}',
        plantId: plantId,
        type: type,
        timestamp: timestamp,
        note: null,
        linkedPhotoId: null,
      );

  group('CareCoachingEngine', () {
    test('detects late watering pattern', () {
      final tasks = List.generate(6, (i) {
        final due = now.subtract(Duration(days: (i + 1) * 5));
        return makeTask(
          status: TaskStatus.done,
          dueAt: due,
          completedAt: due.add(const Duration(days: 2)),
        );
      });
      final logs = [makeLog(timestamp: now.subtract(const Duration(days: 1)))];

      final insights = CareCoachingEngine.generateInsights(
        allTasks: tasks,
        allLogs: logs,
        settings: settings,
        now: now,
      );

      expect(
        insights.any((i) => i.type == CoachingInsightType.lateWaterer),
        isTrue,
      );
    });

    test('detects streak at risk in evening', () {
      final settingsAtRisk = settings.copyWith(
        careStreakDays: 7,
        lastCareDate: DateTime(2025, 5, 14),
      );
      final eveningNow = DateTime(2025, 5, 15, 19, 0);

      final insights = CareCoachingEngine.generateInsights(
        allTasks: const [],
        allLogs: const [],
        settings: settingsAtRisk,
        now: eveningNow,
      );

      expect(
        insights.any((i) => i.type == CoachingInsightType.streakAtRisk),
        isTrue,
      );
    });

    test('does not flag streak at risk during daytime', () {
      final settingsAtRisk = settings.copyWith(
        careStreakDays: 7,
        lastCareDate: DateTime(2025, 5, 14),
      );
      final morningNow = DateTime(2025, 5, 15, 10, 0);

      final insights = CareCoachingEngine.generateInsights(
        allTasks: const [],
        allLogs: const [],
        settings: settingsAtRisk,
        now: morningNow,
      );

      expect(
        insights.any((i) => i.type == CoachingInsightType.streakAtRisk),
        isFalse,
      );
    });

    test('detects neglected plant', () {
      final tasks = [
        makeTask(
          status: TaskStatus.pending,
          dueAt: now.subtract(const Duration(days: 10)),
          plantId: 'neglected',
        ),
      ];
      final logs = [
        makeLog(
          timestamp: now.subtract(const Duration(days: 25)),
          plantId: 'neglected',
        ),
      ];

      final insights = CareCoachingEngine.generateInsights(
        allTasks: tasks,
        allLogs: logs,
        settings: settings,
        now: now,
      );

      expect(
        insights.any((i) => i.type == CoachingInsightType.neglectedPlant),
        isTrue,
      );
    });

    test('detects improving habit', () {
      final logs = [
        ...List.generate(5, (i) => makeLog(
              timestamp: now.subtract(Duration(days: i)),
            )),
        ...List.generate(2, (i) => makeLog(
              timestamp: now.subtract(Duration(days: 8 + i)),
            )),
      ];

      final insights = CareCoachingEngine.generateInsights(
        allTasks: const [],
        allLogs: logs,
        settings: settings,
        now: now,
      );

      expect(
        insights.any((i) => i.type == CoachingInsightType.improvingHabit),
        isTrue,
      );
    });

    test('detects diversify care need', () {
      final logs = List.generate(
        8,
        (i) => makeLog(timestamp: now.subtract(Duration(days: i * 3))),
      );

      final insights = CareCoachingEngine.generateInsights(
        allTasks: const [],
        allLogs: logs,
        settings: settings,
        now: now,
      );

      expect(
        insights.any((i) => i.type == CoachingInsightType.diversifyCare),
        isTrue,
      );
    });

    test('detects consistent carer', () {
      final tasks = List.generate(12, (i) {
        final due = now.subtract(Duration(days: (i + 1) * 3));
        return makeTask(
          status: TaskStatus.done,
          dueAt: due,
          completedAt: due,
        );
      });
      final logs = [makeLog(timestamp: now.subtract(const Duration(days: 1)))];

      final insights = CareCoachingEngine.generateInsights(
        allTasks: tasks,
        allLogs: logs,
        settings: settings,
        now: now,
      );

      expect(
        insights.any((i) => i.type == CoachingInsightType.consistentCarer),
        isTrue,
      );
    });

    test('returns at most 3 insights', () {
      final tasks = List.generate(12, (i) {
        final due = now.subtract(Duration(days: (i + 1) * 3));
        return makeTask(
          status: TaskStatus.done,
          dueAt: due,
          completedAt: due.add(const Duration(days: 2)),
        );
      });
      final logs = List.generate(
        10,
        (i) => makeLog(timestamp: now.subtract(Duration(days: i * 2))),
      );

      final insights = CareCoachingEngine.generateInsights(
        allTasks: tasks,
        allLogs: logs,
        settings: settings.copyWith(
          careStreakDays: 7,
          lastCareDate: DateTime(2025, 5, 14),
        ),
        now: now,
      );

      expect(insights.length, lessThanOrEqualTo(3));
    });

    test('returns empty list when no patterns detected', () {
      final insights = CareCoachingEngine.generateInsights(
        allTasks: const [],
        allLogs: const [],
        settings: UserSettings.defaults(),
        now: now,
      );

      expect(insights, isEmpty);
    });
  });
}
