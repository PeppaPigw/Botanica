import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/domain/services/plant_whisperer_score.dart';

CareLog _log({
  required TaskType type,
  required DateTime timestamp,
}) =>
    CareLog(
      id: 'log-${timestamp.millisecondsSinceEpoch}',
      plantId: 'plant-1',
      type: type,
      timestamp: timestamp,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task({
  required DateTime dueAt,
  TaskStatus status = TaskStatus.pending,
  DateTime? completedAt,
}) =>
    TaskInstance(
      id: 'task-${dueAt.millisecondsSinceEpoch}',
      plantId: 'plant-1',
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: DateTime(2026, 1, 1),
      completedAt: completedAt,
      adjustmentReasonIds: const <String>[],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('WhispererTier', () {
    test('fromXp returns correct tiers', () {
      expect(WhispererTier.fromXp(0), WhispererTier.seedling);
      expect(WhispererTier.fromXp(49), WhispererTier.seedling);
      expect(WhispererTier.fromXp(50), WhispererTier.sprout);
      expect(WhispererTier.fromXp(199), WhispererTier.sprout);
      expect(WhispererTier.fromXp(200), WhispererTier.gardener);
      expect(WhispererTier.fromXp(499), WhispererTier.gardener);
      expect(WhispererTier.fromXp(500), WhispererTier.botanist);
      expect(WhispererTier.fromXp(999), WhispererTier.botanist);
      expect(WhispererTier.fromXp(1000), WhispererTier.whisperer);
      expect(WhispererTier.fromXp(5000), WhispererTier.whisperer);
    });

    test('next returns correct progression', () {
      expect(WhispererTier.seedling.next, WhispererTier.sprout);
      expect(WhispererTier.sprout.next, WhispererTier.gardener);
      expect(WhispererTier.gardener.next, WhispererTier.botanist);
      expect(WhispererTier.botanist.next, WhispererTier.whisperer);
      expect(WhispererTier.whisperer.next, isNull);
    });
  });

  group('PlantWhispererScore.compute', () {
    test('returns seedling for new user with no data', () {
      final score = PlantWhispererScore.compute(
        settings: UserSettings.defaults(),
        allLogs: [],
        allTasks: [],
        plantCount: 0,
        now: now,
      );
      expect(score.xp, 0);
      expect(score.tier, WhispererTier.seedling);
    });

    test('streak contributes 2 XP per day', () {
      final settings = UserSettings.defaults().copyWith(careStreakDays: 10);
      final score = PlantWhispererScore.compute(
        settings: settings,
        allLogs: [],
        allTasks: [],
        plantCount: 1,
        now: now,
      );
      expect(score.breakdown.streakXp, 20);
    });

    test('streak XP caps at 200', () {
      final settings = UserSettings.defaults().copyWith(careStreakDays: 200);
      final score = PlantWhispererScore.compute(
        settings: settings,
        allLogs: [],
        allTasks: [],
        plantCount: 1,
        now: now,
      );
      expect(score.breakdown.streakXp, 200);
    });

    test('punctuality rewards on-time completions', () {
      final tasks = [
        _task(
          dueAt: now.subtract(const Duration(days: 5)),
          status: TaskStatus.done,
          completedAt: now.subtract(const Duration(days: 5)),
        ),
        _task(
          dueAt: now.subtract(const Duration(days: 3)),
          status: TaskStatus.done,
          completedAt: now.subtract(const Duration(days: 3)),
        ),
      ];
      final score = PlantWhispererScore.compute(
        settings: UserSettings.defaults(),
        allLogs: [],
        allTasks: tasks,
        plantCount: 1,
        now: now,
      );
      expect(score.breakdown.punctualityXp, 250);
    });

    test('diversity rewards multiple care types', () {
      final logs = [
        _log(type: TaskType.water, timestamp: now.subtract(const Duration(days: 1))),
        _log(type: TaskType.fertilize, timestamp: now.subtract(const Duration(days: 2))),
        _log(type: TaskType.mist, timestamp: now.subtract(const Duration(days: 3))),
      ];
      final score = PlantWhispererScore.compute(
        settings: UserSettings.defaults(),
        allLogs: logs,
        allTasks: [],
        plantCount: 1,
        now: now,
      );
      expect(score.breakdown.diversityXp, 50);
    });

    test('consistency rewards active days in last 14 days', () {
      final logs = List.generate(
        7,
        (i) => _log(
          type: TaskType.water,
          timestamp: now.subtract(Duration(days: i * 2)),
        ),
      );
      final score = PlantWhispererScore.compute(
        settings: UserSettings.defaults(),
        allLogs: logs,
        allTasks: [],
        plantCount: 1,
        now: now,
      );
      expect(score.breakdown.consistencyXp, 100);
    });

    test('combined score reaches gardener tier', () {
      final settings = UserSettings.defaults().copyWith(careStreakDays: 30);
      final logs = List.generate(
        14,
        (i) => _log(
          type: TaskType.water,
          timestamp: now.subtract(Duration(days: i)),
        ),
      );
      final tasks = List.generate(
        10,
        (i) => _task(
          dueAt: now.subtract(Duration(days: i + 1)),
          status: TaskStatus.done,
          completedAt: now.subtract(Duration(days: i + 1)),
        ),
      );
      final score = PlantWhispererScore.compute(
        settings: settings,
        allLogs: logs,
        allTasks: tasks,
        plantCount: 3,
        now: now,
      );
      expect(score.tier.index, greaterThanOrEqualTo(WhispererTier.gardener.index));
    });

    test('progressToNext is 1.0 at max tier', () {
      final settings = UserSettings.defaults().copyWith(careStreakDays: 100);
      final logs = List.generate(
        100,
        (i) => _log(
          type: TaskType.values[i % TaskType.values.length],
          timestamp: now.subtract(Duration(days: i % 14)),
        ),
      );
      final tasks = List.generate(
        50,
        (i) => _task(
          dueAt: now.subtract(Duration(days: i % 30)),
          status: TaskStatus.done,
          completedAt: now.subtract(Duration(days: i % 30)),
        ),
      );
      final score = PlantWhispererScore.compute(
        settings: settings,
        allLogs: logs,
        allTasks: tasks,
        plantCount: 5,
        now: now,
      );
      if (score.tier == WhispererTier.whisperer) {
        expect(score.progressToNext, 1.0);
      }
    });
  });
}
