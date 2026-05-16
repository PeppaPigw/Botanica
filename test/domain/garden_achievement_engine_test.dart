import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_achievement_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

Plant _plant(String id) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room $id', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(int i, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_$i', plantId: 'p1', type: type,
      timestamp: _now.subtract(Duration(days: i)),
      note: null, linkedPhotoId: null,
    );

PhotoEntry _photo(int i) => PhotoEntry(
      id: 'photo_$i', plantId: 'p1', filePath: '/p$i.jpg',
      createdAt: _now.subtract(Duration(days: i)), note: null, hash: 'h$i',
    );

void main() {
  group('GardenAchievementEngine', () {
    test('empty garden has no unlocked achievements', () {
      final result = GardenAchievementEngine.compute(
        plants: [], logs: [], photos: [],
        streakDays: 0, longestStreak: 0, now: _now);
      expect(result.unlockedCount, 0);
      expect(result.totalAchievements, greaterThan(0));
    });

    test('first plant unlocks collection achievement', () {
      final result = GardenAchievementEngine.compute(
        plants: [_plant('p1')], logs: [], photos: [],
        streakDays: 0, longestStreak: 0, now: _now);
      final firstPlant = result.achievements.firstWhere((a) => a.id == 'firstPlant');
      expect(firstPlant.unlocked, isTrue);
    });

    test('water logs unlock care achievements', () {
      final logs = List.generate(100, (i) => _log(i));
      final result = GardenAchievementEngine.compute(
        plants: [_plant('p1')], logs: logs, photos: [],
        streakDays: 0, longestStreak: 0, now: _now);
      final hundredWaters = result.achievements.firstWhere((a) => a.id == 'hundredWaters');
      expect(hundredWaters.unlocked, isTrue);
    });

    test('streak achievements track longest streak', () {
      final result = GardenAchievementEngine.compute(
        plants: [_plant('p1')], logs: [], photos: [],
        streakDays: 10, longestStreak: 35, now: _now);
      final weekStreak = result.achievements.firstWhere((a) => a.id == 'weekStreak');
      final monthStreak = result.achievements.firstWhere((a) => a.id == 'monthStreak');
      expect(weekStreak.unlocked, isTrue);
      expect(monthStreak.unlocked, isTrue);
    });

    test('photo achievements track count', () {
      final photos = List.generate(25, (i) => _photo(i));
      final result = GardenAchievementEngine.compute(
        plants: [_plant('p1')], logs: [], photos: photos,
        streakDays: 0, longestStreak: 0, now: _now);
      final twentyPhotos = result.achievements.firstWhere((a) => a.id == 'twentyPhotos');
      expect(twentyPhotos.unlocked, isTrue);
    });

    test('near completion identifies close achievements', () {
      final logs = List.generate(90, (i) => _log(i));
      final result = GardenAchievementEngine.compute(
        plants: [_plant('p1')], logs: logs, photos: [],
        streakDays: 0, longestStreak: 0, now: _now);
      final hundredWaters = result.achievements.firstWhere((a) => a.id == 'hundredWaters');
      expect(hundredWaters.progressPercent, greaterThan(0.7));
    });

    test('progress percent is between 0 and 1', () {
      final result = GardenAchievementEngine.compute(
        plants: [_plant('p1')], logs: [_log(1)], photos: [],
        streakDays: 0, longestStreak: 0, now: _now);
      for (final a in result.achievements) {
        expect(a.progressPercent, greaterThanOrEqualTo(0.0));
        expect(a.progressPercent, lessThanOrEqualTo(1.0));
      }
    });

    test('diversity achievement with multiple rooms', () {
      final plants = List.generate(5, (i) => _plant('p$i'));
      final result = GardenAchievementEngine.compute(
        plants: plants, logs: [], photos: [],
        streakDays: 0, longestStreak: 0, now: _now);
      final fiveRooms = result.achievements.firstWhere((a) => a.id == 'fiveRooms');
      expect(fiveRooms.unlocked, isTrue);
    });
  });
}
