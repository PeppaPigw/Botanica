import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_harmony_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';

Plant _plant({String id = 'p1', String room = 'Room', String speciesId = 'sp1'}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: speciesId,
      room: room,
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
  String plantId = 'p1',
  required DateTime dueAt,
  TaskStatus status = TaskStatus.done,
  DateTime? completedAt,
}) => TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}_$plantId',
      plantId: plantId,
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 7)),
      completedAt: completedAt,
      adjustmentReasonIds: const [],
    );

UserSettings _settings({int streak = 7}) => UserSettings(
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
  final now = DateTime(2026, 5, 16, 10, 0);

  group('GardenHarmonyEngine', () {
    test('thriving garden with consistent care', () {
      final plants = [
        _plant(id: 'p1', room: 'Living Room', speciesId: 'sp1'),
        _plant(id: 'p2', room: 'Bedroom', speciesId: 'sp2'),
        _plant(id: 'p3', room: 'Kitchen', speciesId: 'sp3'),
      ];
      final logs = <CareLog>[];
      for (int i = 0; i < 12; i++) {
        logs.add(_log(now.subtract(Duration(days: i)),
            type: TaskType.values[i % 4]));
      }
      final tasks = List.generate(8, (i) {
        final due = now.subtract(Duration(days: i * 3));
        return _task(dueAt: due, completedAt: due);
      });
      final result = GardenHarmonyEngine.compute(
        plants: plants,
        logs: logs,
        tasks: tasks,
        settings: _settings(streak: 12),
        now: now,
      );
      expect(result.level, HarmonyLevel.thriving);
      expect(result.overallScore, greaterThan(0.8));
    });

    test('needs attention with overdue tasks and no recent care', () {
      final plants = [_plant()];
      final tasks = [
        _task(
          dueAt: now.subtract(const Duration(days: 5)),
          status: TaskStatus.pending,
          completedAt: null,
        ),
      ];
      final result = GardenHarmonyEngine.compute(
        plants: plants,
        logs: [],
        tasks: tasks,
        settings: _settings(streak: 0),
        now: now,
      );
      expect(result.level, HarmonyLevel.needsAttention);
      expect(result.overallScore, lessThan(0.4));
    });

    test('health score reflects overdue tasks', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2')];
      final tasks = [
        _task(
          plantId: 'p1',
          dueAt: now.subtract(const Duration(days: 5)),
          status: TaskStatus.pending,
          completedAt: null,
        ),
      ];
      final result = GardenHarmonyEngine.compute(
        plants: plants,
        logs: [],
        tasks: tasks,
        settings: _settings(),
        now: now,
      );
      expect(result.healthScore, 0.5); // 1 of 2 healthy
    });

    test('consistency score reflects on-time completion', () {
      final tasks = List.generate(6, (i) {
        final due = now.subtract(Duration(days: i * 4));
        return _task(dueAt: due, completedAt: due);
      });
      final result = GardenHarmonyEngine.compute(
        plants: [_plant()],
        logs: [],
        tasks: tasks,
        settings: _settings(),
        now: now,
      );
      expect(result.consistencyScore, 1.0);
    });

    test('diversity score increases with rooms and species', () {
      final singlePlant = GardenHarmonyEngine.compute(
        plants: [_plant()],
        logs: [_log(now.subtract(const Duration(days: 1)))],
        tasks: [],
        settings: _settings(),
        now: now,
      );
      final diversePlants = GardenHarmonyEngine.compute(
        plants: [
          _plant(id: 'p1', room: 'Room A', speciesId: 'sp1'),
          _plant(id: 'p2', room: 'Room B', speciesId: 'sp2'),
          _plant(id: 'p3', room: 'Room C', speciesId: 'sp3'),
        ],
        logs: [
          _log(now.subtract(const Duration(days: 1)), type: TaskType.water),
          _log(now.subtract(const Duration(days: 2)), type: TaskType.fertilize),
          _log(now.subtract(const Duration(days: 3)), type: TaskType.mist),
          _log(now.subtract(const Duration(days: 4)), type: TaskType.rotate),
        ],
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(diversePlants.diversityScore,
          greaterThan(singlePlant.diversityScore));
    });

    test('engagement score reflects recent activity and streak', () {
      final activeLogs = List.generate(10, (i) =>
          _log(now.subtract(Duration(days: i))));
      final result = GardenHarmonyEngine.compute(
        plants: [_plant()],
        logs: activeLogs,
        tasks: [],
        settings: _settings(streak: 14),
        now: now,
      );
      expect(result.engagementScore, greaterThan(0.8));
    });

    test('detects improving trend', () {
      final logs = [
        // Recent week: 6 logs
        ...List.generate(6, (i) =>
            _log(now.subtract(Duration(days: i)))),
        // Previous week: 1 log
        _log(now.subtract(const Duration(days: 10))),
      ];
      final result = GardenHarmonyEngine.compute(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(result.trend, HarmonyTrend.improving);
    });

    test('detects declining trend', () {
      final logs = [
        // Recent week: 1 log
        _log(now.subtract(const Duration(days: 2))),
        // Previous week: 6 logs
        ...List.generate(6, (i) =>
            _log(now.subtract(Duration(days: 8 + i)))),
      ];
      final result = GardenHarmonyEngine.compute(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        settings: _settings(),
        now: now,
      );
      expect(result.trend, HarmonyTrend.declining);
    });

    test('overall score is clamped 0-1', () {
      final result = GardenHarmonyEngine.compute(
        plants: [],
        logs: [],
        tasks: [],
        settings: _settings(streak: 0),
        now: now,
      );
      expect(result.overallScore, greaterThanOrEqualTo(0.0));
      expect(result.overallScore, lessThanOrEqualTo(1.0));
    });
  });
}
