import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/domain/services/achievements.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  UserSettings baseSettings() => UserSettings.defaults().copyWith(
        careStreakDays: 0,
        longestStreak: 0,
        lastMilestoneCelebrated: 0,
      );

  Plant makePlant(String id, {String room = 'Living Room', bool archived = false}) => Plant(
        id: id,
        nickname: 'Plant $id',
        speciesId: 'species-1',
        room: room,
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: DateTime(2025, 1, 1),
        meta: const PlantMeta(),
        isArchived: archived,
      );

  TaskInstance makeTask(String id, {TaskStatus status = TaskStatus.done}) =>
      TaskInstance(
        id: id,
        plantId: 'p1',
        type: TaskType.water,
        dueAt: DateTime(2025, 5, 1),
        status: status,
        createdAt: DateTime(2025, 4, 28),
        completedAt: status == TaskStatus.done ? DateTime(2025, 5, 1) : null,
        adjustmentReasonIds: const [],
      );

  CareLog makeLog(String id, {TaskType type = TaskType.water}) => CareLog(
        id: id,
        plantId: 'p1',
        type: type,
        timestamp: DateTime(2025, 5, 1),
        note: null,
        linkedPhotoId: null,
      );

  PhotoEntry makePhoto(String id) => PhotoEntry(
        id: id,
        plantId: 'p1',
        filePath: '/photos/$id.jpg',
        createdAt: DateTime(2025, 5, 1),
        note: null,
        hash: null,
      );

  group('AchievementsEngine', () {
    test('firstPlant unlocks with 1 plant', () {
      final achievements = AchievementsEngine.compute(
        plants: [makePlant('p1')],
        tasks: const [],
        logs: const [],
        photos: const [],
        settings: baseSettings(),
      );

      final first = achievements.firstWhere((a) => a.id == 'firstPlant');
      expect(first.unlocked, isTrue);
    });

    test('fivePlants requires 5 non-archived plants', () {
      final achievements = AchievementsEngine.compute(
        plants: [
          for (int i = 0; i < 4; i++) makePlant('p$i'),
          makePlant('p4', archived: true),
        ],
        tasks: const [],
        logs: const [],
        photos: const [],
        settings: baseSettings(),
      );

      final five = achievements.firstWhere((a) => a.id == 'fivePlants');
      expect(five.unlocked, isFalse);
      expect(five.progress, 4);
    });

    test('streak achievements use longestStreak', () {
      final achievements = AchievementsEngine.compute(
        plants: const [],
        tasks: const [],
        logs: const [],
        photos: const [],
        settings: baseSettings().copyWith(longestStreak: 8),
      );

      final week = achievements.firstWhere((a) => a.id == 'weekStreak');
      final month = achievements.firstWhere((a) => a.id == 'monthStreak');
      expect(week.unlocked, isTrue);
      expect(month.unlocked, isFalse);
      expect(month.progress, 8);
    });

    test('diverseCarer requires 5 unique care types', () {
      final achievements = AchievementsEngine.compute(
        plants: const [],
        tasks: const [],
        logs: [
          makeLog('l1', type: TaskType.water),
          makeLog('l2', type: TaskType.fertilize),
          makeLog('l3', type: TaskType.mist),
          makeLog('l4', type: TaskType.rotate),
          makeLog('l5', type: TaskType.prune),
        ],
        photos: const [],
        settings: baseSettings(),
      );

      final diverse = achievements.firstWhere((a) => a.id == 'diverseCarer');
      expect(diverse.unlocked, isTrue);
    });

    test('photo achievements count PhotoEntry items', () {
      final achievements = AchievementsEngine.compute(
        plants: const [],
        tasks: const [],
        logs: const [],
        photos: [for (int i = 0; i < 10; i++) makePhoto('ph$i')],
        settings: baseSettings(),
      );

      final first = achievements.firstWhere((a) => a.id == 'firstPhoto');
      final ten = achievements.firstWhere((a) => a.id == 'tenPhotos');
      final fifty = achievements.firstWhere((a) => a.id == 'fiftyPhotos');
      expect(first.unlocked, isTrue);
      expect(ten.unlocked, isTrue);
      expect(fifty.unlocked, isFalse);
      expect(fifty.progress, 10);
    });

    test('room achievements count unique rooms', () {
      final achievements = AchievementsEngine.compute(
        plants: [
          makePlant('p1', room: 'Living Room'),
          makePlant('p2', room: 'Bedroom'),
          makePlant('p3', room: 'Kitchen'),
        ],
        tasks: const [],
        logs: const [],
        photos: const [],
        settings: baseSettings(),
      );

      final three = achievements.firstWhere((a) => a.id == 'threeRooms');
      expect(three.unlocked, isTrue);
    });

    test('progressFraction is correct for partial progress', () {
      final achievements = AchievementsEngine.compute(
        plants: [makePlant('p1'), makePlant('p2'), makePlant('p3')],
        tasks: const [],
        logs: const [],
        photos: const [],
        settings: baseSettings(),
      );

      final five = achievements.firstWhere((a) => a.id == 'fivePlants');
      expect(five.progressFraction, closeTo(0.6, 0.01));
    });

    test('unlockedCount returns correct count', () {
      final count = AchievementsEngine.unlockedCount(
        plants: [makePlant('p1')],
        tasks: [makeTask('t1')],
        logs: [makeLog('l1')],
        photos: [makePhoto('ph1')],
        settings: baseSettings().copyWith(longestStreak: 7),
      );

      // firstPlant, firstCare, weekStreak, firstPhoto = 4
      expect(count, 4);
    });
  });
}
