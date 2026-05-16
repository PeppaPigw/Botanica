import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/next_action_recommender.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';

Plant _plant({String id = 'p1', DateTime? createdAt, bool archived = false}) =>
    Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: archived,
    );

TaskInstance _task({
  String plantId = 'p1',
  TaskType type = TaskType.water,
  required DateTime dueAt,
  TaskStatus status = TaskStatus.pending,
}) =>
    TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}_${type.name}',
      plantId: plantId,
      type: type,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 7)),
      completedAt: null,
      adjustmentReasonIds: const [],
    );

CareLog _log(DateTime ts, {String plantId = 'p1', String? photoId}) =>
    CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      timestamp: ts,
      note: null,
      linkedPhotoId: photoId,
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
  final now = DateTime(2026, 5, 16, 10, 0);

  group('NextActionRecommender', () {
    test('returns explore when no active plants', () {
      final result = NextActionRecommender.recommend(
        plants: [],
        tasks: [],
        logs: [],
        settings: _settings(),
        now: now,
      );
      expect(result.type, ActionType.explore);
      expect(result.messageKey, 'actionExplore');
    });

    test('returns explore when all plants archived', () {
      final result = NextActionRecommender.recommend(
        plants: [_plant(archived: true)],
        tasks: [],
        logs: [],
        settings: _settings(),
        now: now,
      );
      expect(result.type, ActionType.explore);
    });

    test('returns waterOverdue for overdue water task', () {
      final result = NextActionRecommender.recommend(
        plants: [_plant()],
        tasks: [_task(dueAt: now.subtract(const Duration(hours: 2)))],
        logs: [],
        settings: _settings(),
        now: now,
      );
      expect(result.type, ActionType.waterOverdue);
      expect(result.plantId, 'p1');
      expect(result.plantNickname, 'Plant p1');
      expect(result.priority, 10);
    });

    test('returns waterToday for same-day water task', () {
      final result = NextActionRecommender.recommend(
        plants: [_plant()],
        tasks: [_task(dueAt: DateTime(2026, 5, 16, 18, 0))],
        logs: [],
        settings: _settings(),
        now: now,
      );
      expect(result.type, ActionType.waterToday);
      expect(result.priority, 8);
    });

    test('waterOverdue takes priority over waterToday', () {
      final result = NextActionRecommender.recommend(
        plants: [_plant(), _plant(id: 'p2')],
        tasks: [
          _task(plantId: 'p2', dueAt: DateTime(2026, 5, 16, 18, 0)),
          _task(dueAt: now.subtract(const Duration(hours: 1))),
        ],
        logs: [],
        settings: _settings(),
        now: now,
      );
      expect(result.type, ActionType.waterOverdue);
    });

    test('returns checkNewPlant for recent plant with few logs', () {
      final newPlant = _plant(createdAt: now.subtract(const Duration(days: 3)));
      final result = NextActionRecommender.recommend(
        plants: [newPlant],
        tasks: [],
        logs: [_log(now.subtract(const Duration(days: 1)))],
        settings: _settings(),
        now: now,
      );
      expect(result.type, ActionType.checkNewPlant);
      expect(result.plantId, 'p1');
      expect(result.priority, 6);
    });

    test('does not recommend checkNewPlant if plant has 2+ logs', () {
      final newPlant = _plant(createdAt: now.subtract(const Duration(days: 3)));
      final result = NextActionRecommender.recommend(
        plants: [newPlant],
        tasks: [],
        logs: [
          _log(now.subtract(const Duration(days: 1))),
          _log(now.subtract(const Duration(days: 2))),
        ],
        settings: _settings(),
        now: now,
      );
      expect(result.type, isNot(ActionType.checkNewPlant));
    });

    test('returns fertilize for upcoming fertilize task', () {
      final result = NextActionRecommender.recommend(
        plants: [_plant()],
        tasks: [
          _task(
            type: TaskType.fertilize,
            dueAt: now.add(const Duration(days: 2)),
          ),
        ],
        logs: List.generate(
            3, (i) => _log(now.subtract(Duration(days: i)))),
        settings: _settings(),
        now: now,
      );
      expect(result.type, ActionType.fertilize);
      expect(result.priority, 5);
    });

    test('returns takePhoto for plant without recent photo', () {
      final oldPlant = _plant(createdAt: DateTime(2025, 1, 1));
      final result = NextActionRecommender.recommend(
        plants: [oldPlant],
        tasks: [],
        logs: [_log(now.subtract(const Duration(days: 20)))],
        settings: _settings(),
        now: now,
      );
      expect(result.type, ActionType.takePhoto);
      expect(result.priority, 3);
    });

    test('does not recommend takePhoto if recent photo exists', () {
      final oldPlant = _plant(createdAt: DateTime(2025, 1, 1));
      final result = NextActionRecommender.recommend(
        plants: [oldPlant],
        tasks: [],
        logs: [
          _log(now.subtract(const Duration(days: 5)), photoId: 'photo1'),
        ],
        settings: _settings(),
        now: now,
      );
      expect(result.type, isNot(ActionType.takePhoto));
    });

    test('returns celebrate at 7-day streak milestone', () {
      final result = NextActionRecommender.recommend(
        plants: [_plant()],
        tasks: [],
        logs: [
          _log(now.subtract(const Duration(days: 5)), photoId: 'photo1'),
        ],
        settings: _settings(streak: 14),
        now: now,
      );
      expect(result.type, ActionType.celebrate);
      expect(result.priority, 2);
    });

    test('returns rest when nothing else applies', () {
      final oldPlant = _plant(createdAt: DateTime(2025, 1, 1));
      final result = NextActionRecommender.recommend(
        plants: [oldPlant],
        tasks: [],
        logs: [
          _log(now.subtract(const Duration(days: 5)), photoId: 'photo1'),
        ],
        settings: _settings(streak: 3),
        now: now,
      );
      expect(result.type, ActionType.rest);
      expect(result.priority, 0);
    });

    test('handles plant not found for task gracefully', () {
      final result = NextActionRecommender.recommend(
        plants: [_plant(id: 'other')],
        tasks: [_task(plantId: 'missing', dueAt: now.subtract(const Duration(hours: 1)))],
        logs: [],
        settings: _settings(),
        now: now,
      );
      expect(result.type, ActionType.waterOverdue);
      expect(result.plantNickname, '');
    });
  });
}
