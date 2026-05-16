import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';
import '../models/user_settings.dart';

enum SmartNotificationType {
  rhythmChange,
  streakEncouragement,
  neglectWarning,
  seasonalReminder,
  milestoneApproaching,
  batchOpportunity,
  comebackWelcome,
  perfectWeekCelebration,
}

class SmartNotification {
  const SmartNotification({
    required this.type,
    required this.titleKey,
    required this.bodyKey,
    required this.args,
    required this.priority,
    this.plantId,
  });

  final SmartNotificationType type;
  final String titleKey;
  final String bodyKey;
  final Map<String, String> args;
  final int priority;
  final String? plantId;
}

class SmartNotificationEngine {
  const SmartNotificationEngine._();

  static List<SmartNotification> generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required UserSettings settings,
    required DateTime now,
  }) {
    final notifications = <SmartNotification>[];

    _checkStreakEncouragement(settings, notifications);
    _checkNeglectWarning(plants, logs, notifications, now);
    _checkBatchOpportunity(tasks, notifications, now);
    _checkComebackWelcome(settings, logs, notifications, now);
    _checkPerfectWeek(tasks, notifications, now);
    _checkMilestoneApproaching(settings, notifications);
    _checkRhythmChange(plants, logs, notifications, now);

    notifications.sort((a, b) => b.priority.compareTo(a.priority));
    return notifications.take(3).toList();
  }

  static void _checkStreakEncouragement(
      UserSettings settings, List<SmartNotification> out) {
    final streak = settings.careStreakDays;
    if (streak >= 5 && streak < 7) {
      out.add(SmartNotification(
        type: SmartNotificationType.streakEncouragement,
        titleKey: 'smartNotifStreakTitle',
        bodyKey: 'smartNotifStreakAlmostWeek',
        args: {'days': streak.toString()},
        priority: 8,
      ));
    } else if (streak >= 25 && streak < 30) {
      out.add(SmartNotification(
        type: SmartNotificationType.streakEncouragement,
        titleKey: 'smartNotifStreakTitle',
        bodyKey: 'smartNotifStreakAlmostMonth',
        args: {'days': streak.toString()},
        priority: 9,
      ));
    }
  }

  static void _checkNeglectWarning(
    List<Plant> plants,
    List<CareLog> logs,
    List<SmartNotification> out,
    DateTime now,
  ) {
    for (final plant in plants.where((p) => !p.isArchived)) {
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      if (plantLogs.isEmpty) continue;

      final lastCare = plantLogs
          .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
      final daysSince = now.difference(lastCare.timestamp).inDays;

      if (daysSince >= 10 && daysSince < 14) {
        out.add(SmartNotification(
          type: SmartNotificationType.neglectWarning,
          titleKey: 'smartNotifNeglectTitle',
          bodyKey: 'smartNotifNeglectBody',
          args: {'plant': plant.nickname, 'days': daysSince.toString()},
          priority: 7,
          plantId: plant.id,
        ));
        return;
      }
    }
  }

  static void _checkBatchOpportunity(
    List<TaskInstance> tasks,
    List<SmartNotification> out,
    DateTime now,
  ) {
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dayAfter = tomorrow.add(const Duration(days: 1));

    final tomorrowTasks = tasks.where((t) =>
        !t.isDismissed &&
        t.status == TaskStatus.pending &&
        t.dueAt.isAfter(tomorrow) &&
        t.dueAt.isBefore(dayAfter)).toList();

    if (tomorrowTasks.length >= 4) {
      out.add(SmartNotification(
        type: SmartNotificationType.batchOpportunity,
        titleKey: 'smartNotifBatchTitle',
        bodyKey: 'smartNotifBatchBody',
        args: {'count': tomorrowTasks.length.toString()},
        priority: 5,
      ));
    }
  }

  static void _checkComebackWelcome(
    UserSettings settings,
    List<CareLog> logs,
    List<SmartNotification> out,
    DateTime now,
  ) {
    if (logs.isEmpty) return;

    final lastLog = logs.reduce(
        (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
    final daysSince = now.difference(lastLog.timestamp).inDays;

    if (daysSince >= 5 && daysSince <= 14) {
      out.add(SmartNotification(
        type: SmartNotificationType.comebackWelcome,
        titleKey: 'smartNotifComebackTitle',
        bodyKey: 'smartNotifComebackBody',
        args: {'days': daysSince.toString()},
        priority: 6,
      ));
    }
  }

  static void _checkPerfectWeek(
    List<TaskInstance> tasks,
    List<SmartNotification> out,
    DateTime now,
  ) {
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekTasks = tasks.where((t) =>
        t.dueAt.isAfter(weekStart) &&
        t.dueAt.isBefore(now)).toList();

    if (weekTasks.isEmpty) return;

    final allDone = weekTasks.every((t) => t.isDone);
    if (allDone && weekTasks.length >= 5) {
      out.add(SmartNotification(
        type: SmartNotificationType.perfectWeekCelebration,
        titleKey: 'smartNotifPerfectWeekTitle',
        bodyKey: 'smartNotifPerfectWeekBody',
        args: {'count': weekTasks.length.toString()},
        priority: 9,
      ));
    }
  }

  static void _checkMilestoneApproaching(
      UserSettings settings, List<SmartNotification> out) {
    final streak = settings.careStreakDays;
    final milestones = [7, 30, 90, 365];

    for (final milestone in milestones) {
      final remaining = milestone - streak;
      if (remaining > 0 && remaining <= 3 && remaining > 0) {
        out.add(SmartNotification(
          type: SmartNotificationType.milestoneApproaching,
          titleKey: 'smartNotifMilestoneTitle',
          bodyKey: 'smartNotifMilestoneBody',
          args: {
            'milestone': milestone.toString(),
            'remaining': remaining.toString(),
          },
          priority: 7,
        ));
        return;
      }
    }
  }

  static void _checkRhythmChange(
    List<Plant> plants,
    List<CareLog> logs,
    List<SmartNotification> out,
    DateTime now,
  ) {
    for (final plant in plants.where((p) => !p.isArchived)) {
      final waterLogs = logs
          .where((l) => l.plantId == plant.id && l.type == TaskType.water)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (waterLogs.length < 6) continue;

      final recentStart = now.subtract(const Duration(days: 14));
      final olderStart = now.subtract(const Duration(days: 28));

      final recent = waterLogs.where((l) => l.timestamp.isAfter(recentStart)).length;
      final older = waterLogs.where((l) =>
          l.timestamp.isAfter(olderStart) &&
          !l.timestamp.isAfter(recentStart)).length;

      if (older > 0 && recent > older * 1.5) {
        out.add(SmartNotification(
          type: SmartNotificationType.rhythmChange,
          titleKey: 'smartNotifRhythmTitle',
          bodyKey: 'smartNotifRhythmIncreased',
          args: {'plant': plant.nickname},
          priority: 6,
          plantId: plant.id,
        ));
        return;
      }
    }
  }
}
