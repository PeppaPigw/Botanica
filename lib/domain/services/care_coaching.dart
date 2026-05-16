import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/task_instance.dart';
import '../models/user_settings.dart';

enum CoachingInsightType {
  lateWaterer,
  consistentCarer,
  neglectedPlant,
  improvingHabit,
  streakAtRisk,
  diversifyCare,
}

class CoachingInsight {
  const CoachingInsight({
    required this.type,
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    this.plantId,
    this.priority = 0,
  });

  final CoachingInsightType type;
  final String titleKey;
  final String bodyKey;
  final String icon;
  final String? plantId;
  final int priority;
}

class CareCoachingEngine {
  const CareCoachingEngine._();

  static List<CoachingInsight> generateInsights({
    required List<TaskInstance> allTasks,
    required List<CareLog> allLogs,
    required UserSettings settings,
    required DateTime now,
  }) {
    final insights = <CoachingInsight>[];

    _checkLateWatering(allTasks, insights, now);
    _checkStreakAtRisk(settings, insights, now);
    _checkNeglectedPlants(allTasks, allLogs, insights, now);
    _checkImprovingHabit(allLogs, insights, now);
    _checkDiversifyCare(allLogs, insights, now);
    _checkConsistentCarer(allTasks, insights);

    insights.sort((a, b) => b.priority.compareTo(a.priority));
    return insights.take(3).toList();
  }

  static void _checkLateWatering(
    List<TaskInstance> tasks,
    List<CoachingInsight> insights,
    DateTime now,
  ) {
    final completedWater = tasks
        .where((t) =>
            t.type == TaskType.water &&
            t.isDone &&
            t.completedAt != null)
        .toList();

    if (completedWater.length < 5) return;

    final recent = completedWater
        .where((t) => now.difference(t.completedAt!).inDays <= 30)
        .toList();

    if (recent.length < 3) return;

    int lateCount = 0;
    for (final t in recent) {
      if (t.completedAt!.isAfter(t.dueAt.add(const Duration(days: 1)))) {
        lateCount++;
      }
    }

    if (lateCount > recent.length * 0.5) {
      insights.add(const CoachingInsight(
        type: CoachingInsightType.lateWaterer,
        titleKey: 'coachingLateWatererTitle',
        bodyKey: 'coachingLateWatererBody',
        icon: 'schedule',
        priority: 8,
      ));
    }
  }

  static void _checkStreakAtRisk(
    UserSettings settings,
    List<CoachingInsight> insights,
    DateTime now,
  ) {
    if (settings.careStreakDays < 3) return;
    if (settings.lastCareDate == null) return;

    final daysSinceCare = now
        .difference(DateTime(
          settings.lastCareDate!.year,
          settings.lastCareDate!.month,
          settings.lastCareDate!.day,
        ))
        .inDays;

    if (daysSinceCare == 1 && now.hour >= 18) {
      insights.add(const CoachingInsight(
        type: CoachingInsightType.streakAtRisk,
        titleKey: 'coachingStreakAtRiskTitle',
        bodyKey: 'coachingStreakAtRiskBody',
        icon: 'fire',
        priority: 9,
      ));
    }
  }

  static void _checkNeglectedPlants(
    List<TaskInstance> tasks,
    List<CareLog> logs,
    List<CoachingInsight> insights,
    DateTime now,
  ) {
    final plantIds = tasks.map((t) => t.plantId).toSet();

    for (final plantId in plantIds) {
      final plantLogs = logs.where((l) => l.plantId == plantId).toList();
      if (plantLogs.isEmpty) continue;

      final lastLog = plantLogs.reduce(
        (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
      );

      if (now.difference(lastLog.timestamp).inDays > 21) {
        insights.add(CoachingInsight(
          type: CoachingInsightType.neglectedPlant,
          titleKey: 'coachingNeglectedPlantTitle',
          bodyKey: 'coachingNeglectedPlantBody',
          icon: 'alert',
          plantId: plantId,
          priority: 7,
        ));
        break;
      }
    }
  }

  static void _checkImprovingHabit(
    List<CareLog> logs,
    List<CoachingInsight> insights,
    DateTime now,
  ) {
    final thisWeek = logs
        .where((l) => now.difference(l.timestamp).inDays <= 7)
        .length;
    final lastWeek = logs
        .where((l) {
          final days = now.difference(l.timestamp).inDays;
          return days > 7 && days <= 14;
        })
        .length;

    if (thisWeek > lastWeek && lastWeek > 0 && thisWeek >= 3) {
      insights.add(const CoachingInsight(
        type: CoachingInsightType.improvingHabit,
        titleKey: 'coachingImprovingTitle',
        bodyKey: 'coachingImprovingBody',
        icon: 'trending_up',
        priority: 5,
      ));
    }
  }

  static void _checkDiversifyCare(
    List<CareLog> logs,
    List<CoachingInsight> insights,
    DateTime now,
  ) {
    final recentLogs =
        logs.where((l) => now.difference(l.timestamp).inDays <= 30).toList();

    if (recentLogs.length < 5) return;

    final types = recentLogs.map((l) => l.type).toSet();
    if (types.length == 1 && types.first == TaskType.water) {
      insights.add(const CoachingInsight(
        type: CoachingInsightType.diversifyCare,
        titleKey: 'coachingDiversifyTitle',
        bodyKey: 'coachingDiversifyBody',
        icon: 'category',
        priority: 4,
      ));
    }
  }

  static void _checkConsistentCarer(
    List<TaskInstance> tasks,
    List<CoachingInsight> insights,
  ) {
    final completed = tasks.where((t) => t.isDone && t.completedAt != null);
    if (completed.length < 10) return;

    final recent = completed.toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    final last10 = recent.take(10).toList();

    int onTime = 0;
    for (final t in last10) {
      if (!t.completedAt!.isAfter(t.dueAt.add(const Duration(days: 1)))) {
        onTime++;
      }
    }

    if (onTime >= 9) {
      insights.add(const CoachingInsight(
        type: CoachingInsightType.consistentCarer,
        titleKey: 'coachingConsistentTitle',
        bodyKey: 'coachingConsistentBody',
        icon: 'star',
        priority: 6,
      ));
    }
  }
}
