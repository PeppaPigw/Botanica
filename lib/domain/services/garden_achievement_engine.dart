import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/photo_entry.dart';
import '../models/plant.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.iconName,
    required this.category,
    required this.tier,
    required this.unlocked,
    this.unlockedAt,
    this.progress,
    this.target,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String iconName;
  final String category;
  final int tier;
  final bool unlocked;
  final DateTime? unlockedAt;
  final int? progress;
  final int? target;

  double get progressPercent =>
      (progress != null && target != null && target! > 0)
          ? (progress! / target!).clamp(0.0, 1.0)
          : unlocked ? 1.0 : 0.0;
}

class AchievementSummary {
  const AchievementSummary({
    required this.totalAchievements,
    required this.unlockedCount,
    required this.recentUnlocks,
    required this.nearCompletion,
    required this.achievements,
  });

  final int totalAchievements;
  final int unlockedCount;
  final List<Achievement> recentUnlocks;
  final List<Achievement> nearCompletion;
  final List<Achievement> achievements;

  double get completionRate =>
      totalAchievements > 0 ? unlockedCount / totalAchievements : 0;
}

class GardenAchievementEngine {
  const GardenAchievementEngine._();

  static AchievementSummary compute({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<PhotoEntry> photos,
    required int streakDays,
    required int longestStreak,
    required DateTime now,
  }) {
    final achievements = <Achievement>[];
    final activePlants = plants.where((p) => !p.isArchived).toList();

    // Collection achievements
    achievements.add(_collectionAchievement('firstPlant', activePlants.length, 1, 1));
    achievements.add(_collectionAchievement('fivePlants', activePlants.length, 5, 2));
    achievements.add(_collectionAchievement('tenPlants', activePlants.length, 10, 3));
    achievements.add(_collectionAchievement('twentyPlants', activePlants.length, 20, 4));

    // Care achievements
    achievements.add(_careAchievement('firstWater', logs, TaskType.water, 1, 1));
    achievements.add(_careAchievement('hundredWaters', logs, TaskType.water, 100, 3));
    achievements.add(_careAchievement('firstPrune', logs, TaskType.prune, 1, 1));
    achievements.add(_careAchievement('tenPrunes', logs, TaskType.prune, 10, 2));
    achievements.add(_careAchievement('firstFertilize', logs, TaskType.fertilize, 1, 1));
    achievements.add(_careAchievement('fiftyFertilize', logs, TaskType.fertilize, 50, 3));

    // Streak achievements
    achievements.add(_streakAchievement('weekStreak', longestStreak, 7, 1));
    achievements.add(_streakAchievement('monthStreak', longestStreak, 30, 2));
    achievements.add(_streakAchievement('quarterStreak', longestStreak, 90, 3));
    achievements.add(_streakAchievement('yearStreak', longestStreak, 365, 4));

    // Photo achievements
    achievements.add(_photoAchievement('firstPhoto', photos.length, 1, 1));
    achievements.add(_photoAchievement('twentyPhotos', photos.length, 20, 2));
    achievements.add(_photoAchievement('hundredPhotos', photos.length, 100, 3));

    // Diversity achievements
    final rooms = activePlants.map((p) => p.room).toSet().length;
    achievements.add(_diversityAchievement('threeRooms', rooms, 3, 2));
    achievements.add(_diversityAchievement('fiveRooms', rooms, 5, 3));

    // Time achievements
    final oldestDays = activePlants.isEmpty ? 0
        : activePlants.map((p) => now.difference(p.createdAt).inDays).reduce((a, b) => a > b ? a : b);
    achievements.add(_timeAchievement('sixMonths', oldestDays, 180, 2));
    achievements.add(_timeAchievement('oneYear', oldestDays, 365, 3));
    achievements.add(_timeAchievement('twoYears', oldestDays, 730, 4));

    final unlocked = achievements.where((a) => a.unlocked).toList();
    final nearComplete = achievements
        .where((a) => !a.unlocked && a.progressPercent >= 0.7)
        .toList()
      ..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));

    return AchievementSummary(
      totalAchievements: achievements.length,
      unlockedCount: unlocked.length,
      recentUnlocks: unlocked.take(5).toList(),
      nearCompletion: nearComplete.take(3).toList(),
      achievements: achievements,
    );
  }

  static Achievement _collectionAchievement(String id, int current, int target, int tier) =>
      Achievement(
        id: id, titleKey: 'achievement_$id', descriptionKey: 'achievementDesc_$id',
        iconName: 'plant', category: 'collection', tier: tier,
        unlocked: current >= target, progress: current, target: target,
      );

  static Achievement _careAchievement(
      String id, List<CareLog> logs, TaskType type, int target, int tier) {
    final count = logs.where((l) => l.type == type).length;
    return Achievement(
      id: id, titleKey: 'achievement_$id', descriptionKey: 'achievementDesc_$id',
      iconName: 'care', category: 'care', tier: tier,
      unlocked: count >= target, progress: count, target: target,
    );
  }

  static Achievement _streakAchievement(String id, int longest, int target, int tier) =>
      Achievement(
        id: id, titleKey: 'achievement_$id', descriptionKey: 'achievementDesc_$id',
        iconName: 'streak', category: 'streak', tier: tier,
        unlocked: longest >= target, progress: longest, target: target,
      );

  static Achievement _photoAchievement(String id, int count, int target, int tier) =>
      Achievement(
        id: id, titleKey: 'achievement_$id', descriptionKey: 'achievementDesc_$id',
        iconName: 'camera', category: 'photo', tier: tier,
        unlocked: count >= target, progress: count, target: target,
      );

  static Achievement _diversityAchievement(String id, int count, int target, int tier) =>
      Achievement(
        id: id, titleKey: 'achievement_$id', descriptionKey: 'achievementDesc_$id',
        iconName: 'diversity', category: 'diversity', tier: tier,
        unlocked: count >= target, progress: count, target: target,
      );

  static Achievement _timeAchievement(String id, int days, int target, int tier) =>
      Achievement(
        id: id, titleKey: 'achievement_$id', descriptionKey: 'achievementDesc_$id',
        iconName: 'time', category: 'time', tier: tier,
        unlocked: days >= target, progress: days, target: target,
      );
}
