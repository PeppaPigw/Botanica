import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/task_instance.dart';
import '../models/user_settings.dart';

enum WhispererTier {
  seedling,
  sprout,
  gardener,
  botanist,
  whisperer;

  static WhispererTier fromXp(int xp) {
    if (xp >= 1000) return WhispererTier.whisperer;
    if (xp >= 500) return WhispererTier.botanist;
    if (xp >= 200) return WhispererTier.gardener;
    if (xp >= 50) return WhispererTier.sprout;
    return WhispererTier.seedling;
  }

  int get xpThreshold => switch (this) {
        WhispererTier.seedling => 0,
        WhispererTier.sprout => 50,
        WhispererTier.gardener => 200,
        WhispererTier.botanist => 500,
        WhispererTier.whisperer => 1000,
      };

  WhispererTier? get next => switch (this) {
        WhispererTier.seedling => WhispererTier.sprout,
        WhispererTier.sprout => WhispererTier.gardener,
        WhispererTier.gardener => WhispererTier.botanist,
        WhispererTier.botanist => WhispererTier.whisperer,
        WhispererTier.whisperer => null,
      };
}

class WhispererScore {
  const WhispererScore({
    required this.xp,
    required this.tier,
    required this.progressToNext,
    required this.breakdown,
  });

  final int xp;
  final WhispererTier tier;
  final double progressToNext;
  final WhispererBreakdown breakdown;
}

class WhispererBreakdown {
  const WhispererBreakdown({
    required this.streakXp,
    required this.punctualityXp,
    required this.diversityXp,
    required this.volumeXp,
    required this.consistencyXp,
  });

  final int streakXp;
  final int punctualityXp;
  final int diversityXp;
  final int volumeXp;
  final int consistencyXp;
}

class PlantWhispererScore {
  const PlantWhispererScore._();

  static WhispererScore compute({
    required UserSettings settings,
    required List<CareLog> allLogs,
    required List<TaskInstance> allTasks,
    required int plantCount,
    required DateTime now,
  }) {
    final streakXp = _streakXp(settings.careStreakDays);
    final punctualityXp = _punctualityXp(allTasks, now);
    final diversityXp = _diversityXp(allLogs);
    final volumeXp = _volumeXp(allLogs.length, plantCount);
    final consistencyXp = _consistencyXp(allLogs, now);

    final breakdown = WhispererBreakdown(
      streakXp: streakXp,
      punctualityXp: punctualityXp,
      diversityXp: diversityXp,
      volumeXp: volumeXp,
      consistencyXp: consistencyXp,
    );

    final totalXp =
        streakXp + punctualityXp + diversityXp + volumeXp + consistencyXp;
    final tier = WhispererTier.fromXp(totalXp);
    final nextTier = tier.next;
    final progress = nextTier == null
        ? 1.0
        : (totalXp - tier.xpThreshold) /
            (nextTier.xpThreshold - tier.xpThreshold);

    return WhispererScore(
      xp: totalXp,
      tier: tier,
      progressToNext: progress.clamp(0.0, 1.0),
      breakdown: breakdown,
    );
  }

  // Streak: 2 XP per day, capped at 200
  static int _streakXp(int streakDays) => (streakDays * 2).clamp(0, 200);

  // Punctuality: % of tasks completed on time in last 30 days → up to 250 XP
  static int _punctualityXp(List<TaskInstance> tasks, DateTime now) {
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recent = tasks.where(
      (t) => t.dueAt.isAfter(thirtyDaysAgo) && t.dueAt.isBefore(now),
    );
    if (recent.isEmpty) return 0;

    final onTime = recent.where((t) {
      if (t.status != TaskStatus.done || t.completedAt == null) return false;
      final dueDay = DateTime(t.dueAt.year, t.dueAt.month, t.dueAt.day);
      final doneDay = DateTime(
        t.completedAt!.year,
        t.completedAt!.month,
        t.completedAt!.day,
      );
      return !doneDay.isAfter(dueDay);
    }).length;

    return (onTime / recent.length * 250).round();
  }

  // Diversity: unique care types performed → up to 150 XP
  static int _diversityXp(List<CareLog> logs) {
    final types = logs.map((l) => l.type).toSet();
    // 9 possible task types, each worth ~17 XP
    return (types.length * 150 / 9).round().clamp(0, 150);
  }

  // Volume: total care actions scaled by plant count → up to 200 XP
  static int _volumeXp(int logCount, int plantCount) {
    if (plantCount == 0) return 0;
    final actionsPerPlant = logCount / plantCount;
    // 20+ actions per plant = max XP
    return (actionsPerPlant / 20 * 200).round().clamp(0, 200);
  }

  // Consistency: active days in last 14 days → up to 200 XP
  static int _consistencyXp(List<CareLog> logs, DateTime now) {
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final recentLogs = logs.where((l) => l.timestamp.isAfter(twoWeeksAgo));
    final activeDays = <int>{};
    for (final log in recentLogs) {
      final dayIndex = now.difference(log.timestamp).inDays;
      activeDays.add(dayIndex);
    }
    // 14 active days = max XP
    return (activeDays.length / 14 * 200).round().clamp(0, 200);
  }
}
