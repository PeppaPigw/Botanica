import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/weekly_report_engine.dart';
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

CareLog _log(DateTime ts, {
  String plantId = 'p1',
  TaskType type = TaskType.water,
}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}_$plantId',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task({
  required DateTime dueAt,
  DateTime? completedAt,
}) => TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}',
      plantId: 'p1',
      type: TaskType.water,
      dueAt: dueAt,
      status: TaskStatus.done,
      createdAt: dueAt.subtract(const Duration(days: 7)),
      completedAt: completedAt ?? dueAt,
      adjustmentReasonIds: const [],
    );

UserSettings _settings({int streak = 0}) => UserSettings(
      hasCompletedOnboarding: true,
      temperatureUnit: TemperatureUnit.celsius,
      beliefMode: BeliefMode.unselected,
      reminderTimePreference: ReminderTimePreference.morning,
      hemisphere: Hemisphere.northern,
      localeCode: 'en',
      enableDynamicColor: true,
      enableAiInsights: true,
      aiPreferredEndpointIndex: 0,
      careStreakDays: streak,
      longestStreak: streak,
      lastCareDate: DateTime(2026, 5, 15),
      lastMilestoneCelebrated: 0,
    );

void main() {
  // May 16, 2026 is a Saturday. Week starts Monday May 11.
  final now = DateTime(2026, 5, 16, 10, 0);

  group('WeeklyReportEngine', () {
    test('generates report with zero logs', () {
      final report = WeeklyReportEngine.generate(
        plants: [_plant()],
        logs: [],
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(report.totalActions, 0);
      expect(report.plantsCaresFor, 0);
      expect(report.highlights.any(
          (h) => h.type == WeeklyHighlightType.quietWeek), isTrue);
    });

    test('counts this week actions correctly', () {
      final logs = [
        _log(DateTime(2026, 5, 12, 10, 0)), // Monday this week
        _log(DateTime(2026, 5, 14, 10, 0)), // Wednesday
        _log(DateTime(2026, 5, 16, 8, 0)),  // Saturday (today)
        _log(DateTime(2026, 5, 4, 10, 0)),  // Last week - should not count
      ];
      final report = WeeklyReportEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(report.totalActions, 3);
    });

    test('compares to last week', () {
      final thisWeekLogs = List.generate(5, (i) =>
          _log(DateTime(2026, 5, 12 + i, 10, 0)));
      final lastWeekLogs = List.generate(3, (i) =>
          _log(DateTime(2026, 5, 5 + i, 10, 0)));
      final report = WeeklyReportEngine.generate(
        plants: [_plant()],
        logs: [...thisWeekLogs, ...lastWeekLogs],
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(report.comparedToLastWeek, 2); // 5 - 3
    });

    test('identifies top plant', () {
      final logs = [
        _log(DateTime(2026, 5, 12, 10, 0), plantId: 'p1'),
        _log(DateTime(2026, 5, 13, 10, 0), plantId: 'p1'),
        _log(DateTime(2026, 5, 14, 10, 0), plantId: 'p1'),
        _log(DateTime(2026, 5, 12, 11, 0), plantId: 'p2'),
      ];
      final report = WeeklyReportEngine.generate(
        plants: [_plant(id: 'p1'), _plant(id: 'p2')],
        logs: logs,
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(report.topPlantId, 'p1');
      expect(report.topPlantName, 'Plant p1');
    });

    test('highlights streak growth', () {
      final logs = [_log(DateTime(2026, 5, 12, 10, 0))];
      final report = WeeklyReportEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        settings: _settings(streak: 14),
        now: now,
      );
      expect(report.highlights.any(
          (h) => h.type == WeeklyHighlightType.streakGrowth), isTrue);
    });

    test('highlights diverse care', () {
      final logs = [
        _log(DateTime(2026, 5, 12, 10, 0), type: TaskType.water),
        _log(DateTime(2026, 5, 13, 10, 0), type: TaskType.fertilize),
        _log(DateTime(2026, 5, 14, 10, 0), type: TaskType.mist),
        _log(DateTime(2026, 5, 15, 10, 0), type: TaskType.rotate),
      ];
      final report = WeeklyReportEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(report.highlights.any(
          (h) => h.type == WeeklyHighlightType.diverseCare), isTrue);
    });

    test('highlights perfect week when all tasks on time', () {
      final tasks = List.generate(4, (i) {
        final due = DateTime(2026, 5, 12 + i, 9, 0);
        return _task(dueAt: due, completedAt: due.add(const Duration(hours: 2)));
      });
      final logs = [_log(DateTime(2026, 5, 12, 10, 0))];
      final report = WeeklyReportEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: tasks,
        settings: _settings(),
        now: now,
      );
      expect(report.highlights.any(
          (h) => h.type == WeeklyHighlightType.perfectWeek), isTrue);
    });

    test('highlights comeback week', () {
      final thisWeekLogs = List.generate(6, (i) =>
          _log(DateTime(2026, 5, 11 + i, 10, 0)));
      final lastWeekLogs = [
        _log(DateTime(2026, 5, 5, 10, 0)),
      ];
      final report = WeeklyReportEngine.generate(
        plants: [_plant()],
        logs: [...thisWeekLogs, ...lastWeekLogs],
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(report.highlights.any(
          (h) => h.type == WeeklyHighlightType.comebackWeek), isTrue);
    });

    test('limits highlights to 3', () {
      final logs = List.generate(12, (i) =>
          _log(DateTime(2026, 5, 11 + (i % 6), 10 + i, 0),
              type: TaskType.values[i % 5]));
      final report = WeeklyReportEngine.generate(
        plants: List.generate(5, (i) => _plant(id: 'p$i')),
        logs: logs,
        tasks: [],
        settings: _settings(streak: 14),
        now: now,
      );
      expect(report.highlights.length, lessThanOrEqualTo(3));
    });
  });
}
