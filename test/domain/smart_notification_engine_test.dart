import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/smart_notification_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';

Plant _plant({String id = 'p1'}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(DateTime ts, {String plantId = 'p1'}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_$plantId',
      plantId: plantId,
      type: TaskType.water,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task({
  required DateTime dueAt,
  TaskStatus status = TaskStatus.pending,
}) =>
    TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}',
      plantId: 'p1',
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 1)),
      completedAt: status == TaskStatus.done ? dueAt : null,
      adjustmentReasonIds: const [],
    );

UserSettings _settings({int streak = 3}) => UserSettings(
      hasCompletedOnboarding: true,
      temperatureUnit: TemperatureUnit.celsius,
      beliefMode: BeliefMode.unselected,
      reminderTimePreference: ReminderTimePreference.morning,
      hemisphere: Hemisphere.northern,
      localeCode: 'en',
      enableDynamicColor: false,
      enableAiInsights: true,
      aiPreferredEndpointIndex: 0,
      careStreakDays: streak,
      longestStreak: streak,
      lastCareDate: DateTime(2026, 5, 15),
      lastMilestoneCelebrated: 0,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('SmartNotificationEngine', () {
    test('returns at most 3 notifications', () {
      final plants = [_plant()];
      final logs = [_log(now.subtract(const Duration(days: 12)))];
      final tasks = List.generate(6, (i) =>
          _task(dueAt: DateTime(now.year, now.month, now.day + 1, i)));
      final result = SmartNotificationEngine.generate(
        plants: plants, logs: logs, tasks: tasks,
        settings: _settings(streak: 6), now: now);
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('detects streak encouragement near 7 days', () {
      final result = SmartNotificationEngine.generate(
        plants: [_plant()],
        logs: [_log(now.subtract(const Duration(days: 1)))],
        tasks: [],
        settings: _settings(streak: 6),
        now: now,
      );
      expect(
        result.any((n) => n.type == SmartNotificationType.streakEncouragement),
        isTrue,
      );
    });

    test('detects neglect warning for plant not cared for 10+ days', () {
      final result = SmartNotificationEngine.generate(
        plants: [_plant()],
        logs: [_log(now.subtract(const Duration(days: 11)))],
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(
        result.any((n) => n.type == SmartNotificationType.neglectWarning),
        isTrue,
      );
    });

    test('detects batch opportunity with 4+ tasks tomorrow', () {
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 10);
      final tasks = List.generate(5, (i) =>
          _task(dueAt: tomorrow.add(Duration(hours: i))));
      final result = SmartNotificationEngine.generate(
        plants: [_plant()],
        logs: [_log(now.subtract(const Duration(days: 1)))],
        tasks: tasks,
        settings: _settings(),
        now: now,
      );
      expect(
        result.any((n) => n.type == SmartNotificationType.batchOpportunity),
        isTrue,
      );
    });

    test('detects perfect week celebration', () {
      // Use a Friday so weekStart is Monday (4 days back), giving room for 5 tasks
      final friday = DateTime(2026, 5, 15, 18, 0);
      // weekStart = Friday - 4 days = Monday May 11
      // Tasks on Tue-Fri (all after Monday, all before Friday 18:00)
      final tasks = [
        _task(dueAt: DateTime(2026, 5, 12, 9, 0), status: TaskStatus.done),
        _task(dueAt: DateTime(2026, 5, 12, 15, 0), status: TaskStatus.done),
        _task(dueAt: DateTime(2026, 5, 13, 9, 0), status: TaskStatus.done),
        _task(dueAt: DateTime(2026, 5, 14, 9, 0), status: TaskStatus.done),
        _task(dueAt: DateTime(2026, 5, 15, 9, 0), status: TaskStatus.done),
      ];
      final result = SmartNotificationEngine.generate(
        plants: [_plant()],
        logs: [_log(friday.subtract(const Duration(days: 1)))],
        tasks: tasks,
        settings: _settings(),
        now: friday,
      );
      expect(
        result.any((n) => n.type == SmartNotificationType.perfectWeekCelebration),
        isTrue,
      );
    });

    test('notifications are sorted by priority', () {
      final result = SmartNotificationEngine.generate(
        plants: [_plant()],
        logs: [_log(now.subtract(const Duration(days: 11)))],
        tasks: [],
        settings: _settings(streak: 6),
        now: now,
      );
      for (int i = 0; i < result.length - 1; i++) {
        expect(result[i].priority, greaterThanOrEqualTo(result[i + 1].priority));
      }
    });
  });
}
