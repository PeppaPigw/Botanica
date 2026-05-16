import '../models/care_log.dart';
import '../models/photo_entry.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';
import '../models/user_settings.dart';

enum AchievementTier { bronze, silver, gold }

class Achievement {
  const Achievement({
    required this.id,
    required this.tier,
    required this.unlocked,
    this.progress,
    this.target,
  });

  final String id;
  final AchievementTier tier;
  final bool unlocked;
  final int? progress;
  final int? target;

  double get progressFraction {
    if (target == null || target == 0) return unlocked ? 1.0 : 0.0;
    return (progress ?? 0).clamp(0, target!).toDouble() / target!;
  }
}

class AchievementsEngine {
  const AchievementsEngine._();

  static List<Achievement> compute({
    required List<Plant> plants,
    required List<TaskInstance> tasks,
    required List<CareLog> logs,
    required List<PhotoEntry> photos,
    required UserSettings settings,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).length;
    final totalPlants = plants.length;
    final completedTasks = tasks.where((t) => t.isDone).length;
    final photoCount = photos.length;
    final longestStreak = settings.longestStreak;
    final uniqueRooms = plants.map((p) => p.room).where((r) => r.isNotEmpty).toSet();
    final uniqueCareTypes = logs.map((l) => l.type).toSet();

    return [
      Achievement(
        id: 'firstPlant',
        tier: AchievementTier.bronze,
        unlocked: totalPlants >= 1,
        progress: totalPlants.clamp(0, 1),
        target: 1,
      ),
      Achievement(
        id: 'fivePlants',
        tier: AchievementTier.bronze,
        unlocked: activePlants >= 5,
        progress: activePlants.clamp(0, 5),
        target: 5,
      ),
      Achievement(
        id: 'tenPlants',
        tier: AchievementTier.silver,
        unlocked: activePlants >= 10,
        progress: activePlants.clamp(0, 10),
        target: 10,
      ),
      Achievement(
        id: 'twentyPlants',
        tier: AchievementTier.gold,
        unlocked: activePlants >= 20,
        progress: activePlants.clamp(0, 20),
        target: 20,
      ),
      Achievement(
        id: 'firstCare',
        tier: AchievementTier.bronze,
        unlocked: completedTasks >= 1,
        progress: completedTasks.clamp(0, 1),
        target: 1,
      ),
      Achievement(
        id: 'fiftyCares',
        tier: AchievementTier.bronze,
        unlocked: completedTasks >= 50,
        progress: completedTasks.clamp(0, 50),
        target: 50,
      ),
      Achievement(
        id: 'hundredCares',
        tier: AchievementTier.silver,
        unlocked: completedTasks >= 100,
        progress: completedTasks.clamp(0, 100),
        target: 100,
      ),
      Achievement(
        id: 'fiveHundredCares',
        tier: AchievementTier.gold,
        unlocked: completedTasks >= 500,
        progress: completedTasks.clamp(0, 500),
        target: 500,
      ),
      Achievement(
        id: 'weekStreak',
        tier: AchievementTier.bronze,
        unlocked: longestStreak >= 7,
        progress: longestStreak.clamp(0, 7),
        target: 7,
      ),
      Achievement(
        id: 'monthStreak',
        tier: AchievementTier.silver,
        unlocked: longestStreak >= 30,
        progress: longestStreak.clamp(0, 30),
        target: 30,
      ),
      Achievement(
        id: 'yearStreak',
        tier: AchievementTier.gold,
        unlocked: longestStreak >= 365,
        progress: longestStreak.clamp(0, 365),
        target: 365,
      ),
      Achievement(
        id: 'firstPhoto',
        tier: AchievementTier.bronze,
        unlocked: photoCount >= 1,
        progress: photoCount.clamp(0, 1),
        target: 1,
      ),
      Achievement(
        id: 'tenPhotos',
        tier: AchievementTier.silver,
        unlocked: photoCount >= 10,
        progress: photoCount.clamp(0, 10),
        target: 10,
      ),
      Achievement(
        id: 'fiftyPhotos',
        tier: AchievementTier.gold,
        unlocked: photoCount >= 50,
        progress: photoCount.clamp(0, 50),
        target: 50,
      ),
      Achievement(
        id: 'threeRooms',
        tier: AchievementTier.bronze,
        unlocked: uniqueRooms.length >= 3,
        progress: uniqueRooms.length.clamp(0, 3),
        target: 3,
      ),
      Achievement(
        id: 'fiveRooms',
        tier: AchievementTier.silver,
        unlocked: uniqueRooms.length >= 5,
        progress: uniqueRooms.length.clamp(0, 5),
        target: 5,
      ),
      Achievement(
        id: 'diverseCarer',
        tier: AchievementTier.silver,
        unlocked: uniqueCareTypes.length >= 5,
        progress: uniqueCareTypes.length.clamp(0, 5),
        target: 5,
      ),
    ];
  }

  static int unlockedCount({
    required List<Plant> plants,
    required List<TaskInstance> tasks,
    required List<CareLog> logs,
    required List<PhotoEntry> photos,
    required UserSettings settings,
  }) {
    return compute(
      plants: plants,
      tasks: tasks,
      logs: logs,
      photos: photos,
      settings: settings,
    ).where((a) => a.unlocked).length;
  }
}
