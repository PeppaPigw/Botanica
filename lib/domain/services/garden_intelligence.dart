import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';
import '../models/user_settings.dart';
import 'environment_stress_detector.dart';
import 'seasonal_care_advisor.dart';

enum InsightCategory {
  rhythm,
  pattern,
  milestone,
  seasonal,
  behavioral,
}

class GardenInsight {
  const GardenInsight({
    required this.category,
    required this.messageKey,
    required this.args,
    this.plantId,
    this.priority = 0,
  });

  final InsightCategory category;
  final String messageKey;
  final Map<String, String> args;
  final String? plantId;
  final int priority;
}

class GardenIntelligence {
  const GardenIntelligence._();

  static GardenInsight? surfaceInsight({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required UserSettings settings,
    required DateTime now,
  }) {
    final candidates = <GardenInsight>[];

    _detectWateringRhythmShift(plants, logs, candidates, now);
    _detectFavoriteCareDay(logs, candidates, now);
    _detectMostActiveTime(logs, candidates, now);
    _detectPlantCareAffinity(plants, logs, candidates, now);
    _detectQuietPeriodEnding(tasks, candidates, now);
    _detectCareAcceleration(logs, candidates, now);
    _detectGardenGrowth(plants, candidates, now);
    _detectSeasonalShift(logs, candidates, now);
    _detectStressedPlants(plants, logs, tasks, candidates, now);
    _detectSeasonalCareReminder(plants, settings, candidates, now);

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => b.priority.compareTo(a.priority));

    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final index = dayOfYear % candidates.length;
    return candidates[index];
  }

  static void _detectWateringRhythmShift(
    List<Plant> plants,
    List<CareLog> logs,
    List<GardenInsight> out,
    DateTime now,
  ) {
    for (final plant in plants) {
      if (plant.isArchived) continue;
      final waterLogs = logs
          .where((l) => l.plantId == plant.id && l.type == TaskType.water)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (waterLogs.length < 6) continue;

      final recentStart = now.subtract(const Duration(days: 30));
      final olderStart = now.subtract(const Duration(days: 60));

      final recent =
          waterLogs.where((l) => l.timestamp.isAfter(recentStart)).toList();
      final older = waterLogs
          .where((l) =>
              l.timestamp.isAfter(olderStart) &&
              !l.timestamp.isAfter(recentStart))
          .toList();

      if (recent.length < 3 || older.length < 3) continue;

      final recentAvg = _averageInterval(recent);
      final olderAvg = _averageInterval(older);

      if (recentAvg == null || olderAvg == null) continue;

      final shift = recentAvg - olderAvg;
      if (shift.abs() >= 1.5) {
        final direction = shift > 0 ? 'longer' : 'shorter';
        out.add(GardenInsight(
          category: InsightCategory.rhythm,
          messageKey: 'insightRhythmShift',
          args: {
            'plant': plant.nickname,
            'direction': direction,
            'oldDays': olderAvg.round().toString(),
            'newDays': recentAvg.round().toString(),
          },
          plantId: plant.id,
          priority: 9,
        ));
        return;
      }
    }
  }

  static void _detectFavoriteCareDay(
    List<CareLog> logs,
    List<GardenInsight> out,
    DateTime now,
  ) {
    final recentLogs =
        logs.where((l) => now.difference(l.timestamp).inDays <= 60).toList();
    if (recentLogs.length < 10) return;

    final dayCounts = List<int>.filled(7, 0);
    for (final log in recentLogs) {
      dayCounts[log.timestamp.weekday - 1]++;
    }

    int maxIdx = 0;
    for (int i = 1; i < 7; i++) {
      if (dayCounts[i] > dayCounts[maxIdx]) maxIdx = i;
    }

    final total = dayCounts.fold<int>(0, (s, c) => s + c);
    final ratio = dayCounts[maxIdx] / total;

    if (ratio >= 0.25) {
      const dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      out.add(GardenInsight(
        category: InsightCategory.pattern,
        messageKey: 'insightFavoriteCareDay',
        args: {
          'day': dayNames[maxIdx],
          'percent': (ratio * 100).round().toString(),
        },
        priority: 6,
      ));
    }
  }

  static void _detectMostActiveTime(
    List<CareLog> logs,
    List<GardenInsight> out,
    DateTime now,
  ) {
    final recentLogs =
        logs.where((l) => now.difference(l.timestamp).inDays <= 30).toList();
    if (recentLogs.length < 8) return;

    int morningCount = 0;
    int afternoonCount = 0;
    int eveningCount = 0;

    for (final log in recentLogs) {
      final hour = log.timestamp.hour;
      if (hour >= 5 && hour < 12) {
        morningCount++;
      } else if (hour >= 12 && hour < 18) {
        afternoonCount++;
      } else {
        eveningCount++;
      }
    }

    final total = morningCount + afternoonCount + eveningCount;
    if (total == 0) return;

    String period;
    int count;
    if (morningCount >= afternoonCount && morningCount >= eveningCount) {
      period = 'morning';
      count = morningCount;
    } else if (afternoonCount >= eveningCount) {
      period = 'afternoon';
      count = afternoonCount;
    } else {
      period = 'evening';
      count = eveningCount;
    }

    final ratio = count / total;
    if (ratio >= 0.6) {
      out.add(GardenInsight(
        category: InsightCategory.behavioral,
        messageKey: 'insightActiveTime',
        args: {
          'period': period,
          'percent': (ratio * 100).round().toString(),
        },
        priority: 5,
      ));
    }
  }

  static void _detectPlantCareAffinity(
    List<Plant> plants,
    List<CareLog> logs,
    List<GardenInsight> out,
    DateTime now,
  ) {
    if (plants.length < 2) return;

    final recentLogs =
        logs.where((l) => now.difference(l.timestamp).inDays <= 30).toList();
    if (recentLogs.length < 5) return;

    final plantCounts = <String, int>{};
    for (final log in recentLogs) {
      plantCounts[log.plantId] = (plantCounts[log.plantId] ?? 0) + 1;
    }

    if (plantCounts.isEmpty) return;

    final sorted = plantCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topPlant = plants.where((p) => p.id == sorted.first.key).fold<Plant?>(null, (_, p) => p);
    if (topPlant == null || topPlant.isArchived) return;

    final totalActions = sorted.fold<int>(0, (s, e) => s + e.value);
    final topRatio = sorted.first.value / totalActions;

    if (topRatio >= 0.35 && plants.length >= 3) {
      out.add(GardenInsight(
        category: InsightCategory.behavioral,
        messageKey: 'insightMostLovedPlant',
        args: {
          'plant': topPlant.nickname,
          'actions': sorted.first.value.toString(),
        },
        plantId: topPlant.id,
        priority: 7,
      ));
    }
  }

  static void _detectQuietPeriodEnding(
    List<TaskInstance> tasks,
    List<GardenInsight> out,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = tasks
        .where((t) =>
            !t.isDismissed &&
            t.dueAt.isAfter(today) &&
            t.dueAt.isBefore(today.add(const Duration(days: 7))))
        .toList();

    if (upcoming.isEmpty) return;

    final todayTasks = tasks
        .where((t) {
          final due = DateTime(t.dueAt.year, t.dueAt.month, t.dueAt.day);
          return due == today && !t.isDismissed;
        })
        .toList();

    if (todayTasks.isEmpty && upcoming.length >= 3) {
      final nextDue = upcoming
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
      final daysUntil = DateTime(
        nextDue.first.dueAt.year,
        nextDue.first.dueAt.month,
        nextDue.first.dueAt.day,
      ).difference(today).inDays;

      if (daysUntil >= 2) {
        out.add(GardenInsight(
          category: InsightCategory.pattern,
          messageKey: 'insightQuietThenBusy',
          args: {
            'quietDays': daysUntil.toString(),
            'taskCount': upcoming.length.toString(),
          },
          priority: 4,
        ));
      }
    }
  }

  static void _detectCareAcceleration(
    List<CareLog> logs,
    List<GardenInsight> out,
    DateTime now,
  ) {
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final thisWeek = logs
        .where((l) => l.timestamp.isAfter(thisWeekStart))
        .length;
    final lastWeek = logs
        .where((l) =>
            l.timestamp.isAfter(lastWeekStart) &&
            !l.timestamp.isAfter(thisWeekStart))
        .length;

    if (lastWeek >= 3 && thisWeek > lastWeek * 1.5) {
      out.add(GardenInsight(
        category: InsightCategory.behavioral,
        messageKey: 'insightCareAcceleration',
        args: {
          'thisWeek': thisWeek.toString(),
          'lastWeek': lastWeek.toString(),
        },
        priority: 6,
      ));
    }
  }

  static void _detectGardenGrowth(
    List<Plant> plants,
    List<GardenInsight> out,
    DateTime now,
  ) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 2) return;

    final recentAdditions = activePlants
        .where((p) => now.difference(p.createdAt).inDays <= 14)
        .toList();

    if (recentAdditions.isNotEmpty && activePlants.length >= 5) {
      out.add(GardenInsight(
        category: InsightCategory.milestone,
        messageKey: 'insightGardenGrowing',
        args: {
          'total': activePlants.length.toString(),
          'recent': recentAdditions.length.toString(),
        },
        priority: 5,
      ));
    }
  }

  static void _detectSeasonalShift(
    List<CareLog> logs,
    List<GardenInsight> out,
    DateTime now,
  ) {
    if (logs.length < 20) return;

    final month = now.month;
    final isTransition = month == 3 || month == 6 || month == 9 || month == 12;
    if (!isTransition) return;

    final thisMonth = logs
        .where((l) =>
            l.timestamp.month == month && l.timestamp.year == now.year)
        .length;
    final lastMonth = logs
        .where((l) {
          final target = month == 1 ? 12 : month - 1;
          final targetYear = month == 1 ? now.year - 1 : now.year;
          return l.timestamp.month == target && l.timestamp.year == targetYear;
        })
        .length;

    if (lastMonth >= 5 && thisMonth != lastMonth) {
      final direction = thisMonth > lastMonth ? 'more' : 'less';
      out.add(GardenInsight(
        category: InsightCategory.seasonal,
        messageKey: 'insightSeasonalActivity',
        args: {
          'direction': direction,
          'thisMonth': thisMonth.toString(),
          'lastMonth': lastMonth.toString(),
        },
        priority: 7,
      ));
    }
  }

  static void _detectStressedPlants(
    List<Plant> plants,
    List<CareLog> logs,
    List<TaskInstance> tasks,
    List<GardenInsight> out,
    DateTime now,
  ) {
    final results = EnvironmentStressDetector.detectAll(
      plants: plants,
      logs: logs,
      tasks: tasks,
      now: now,
    );
    if (results.isEmpty) return;

    final top = results.first;
    if (top.level == StressLevel.high || top.level == StressLevel.moderate) {
      out.add(GardenInsight(
        category: InsightCategory.behavioral,
        messageKey: 'insightPlantStressed',
        args: {
          'plant': top.plantNickname,
          'signal': top.signals.first.name,
        },
        plantId: top.plantId,
        priority: top.level == StressLevel.high ? 10 : 8,
      ));
    }
  }

  static void _detectSeasonalCareReminder(
    List<Plant> plants,
    UserSettings settings,
    List<GardenInsight> out,
    DateTime now,
  ) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 3) return;

    final season = SeasonalCareAdvisor.currentSeason(now, settings.hemisphere);

    final month = now.month;
    final isTransitionMonth = month == 3 || month == 5 || month == 9 || month == 11;
    if (!isTransitionMonth) return;

    final messageKey = switch (season) {
      Season.spring => 'insightSpringCare',
      Season.summer => 'insightSummerCare',
      Season.autumn => 'insightAutumnCare',
      Season.winter => 'insightWinterCare',
    };

    out.add(GardenInsight(
      category: InsightCategory.seasonal,
      messageKey: messageKey,
      args: {'count': activePlants.length.toString()},
      priority: 6,
    ));
  }

  static double? _averageInterval(List<CareLog> sortedLogs) {
    if (sortedLogs.length < 2) return null;
    final intervals = <int>[];
    for (int i = 1; i < sortedLogs.length; i++) {
      intervals.add(
        sortedLogs[i]
            .timestamp
            .difference(sortedLogs[i - 1].timestamp)
            .inDays,
      );
    }
    if (intervals.isEmpty) return null;
    return intervals.fold<int>(0, (s, v) => s + v) / intervals.length;
  }
}
