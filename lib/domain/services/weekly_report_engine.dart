import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';
import '../models/user_settings.dart';

class WeeklyHighlight {
  const WeeklyHighlight({
    required this.type,
    required this.messageKey,
    required this.args,
  });

  final WeeklyHighlightType type;
  final String messageKey;
  final Map<String, String> args;
}

enum WeeklyHighlightType {
  streakGrowth,
  mostCaredPlant,
  newPersonalBest,
  consistentCarer,
  diverseCare,
  quietWeek,
  comebackWeek,
  perfectWeek,
}

class WeeklyReport {
  const WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.totalActions,
    required this.plantsCaresFor,
    required this.highlights,
    required this.comparedToLastWeek,
    required this.topPlantId,
    required this.topPlantName,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalActions;
  final int plantsCaresFor;
  final List<WeeklyHighlight> highlights;
  final int comparedToLastWeek;
  final String? topPlantId;
  final String topPlantName;
}

class WeeklyReportEngine {
  const WeeklyReportEngine._();

  static WeeklyReport generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required UserSettings settings,
    required DateTime now,
  }) {
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEnd = weekStartDate.add(const Duration(days: 6));

    final thisWeekLogs = logs.where((l) =>
        !l.timestamp.isBefore(weekStartDate) &&
        l.timestamp.isBefore(weekEnd.add(const Duration(days: 1)))).toList();

    final lastWeekStart = weekStartDate.subtract(const Duration(days: 7));
    final lastWeekLogs = logs.where((l) =>
        !l.timestamp.isBefore(lastWeekStart) &&
        l.timestamp.isBefore(weekStartDate)).toList();

    final activePlants = plants.where((p) => !p.isArchived).toList();
    final plantsCaredFor = thisWeekLogs.map((l) => l.plantId).toSet().length;

    final topPlant = _topPlant(thisWeekLogs, activePlants);
    final highlights = _generateHighlights(
      thisWeekLogs: thisWeekLogs,
      lastWeekLogs: lastWeekLogs,
      tasks: tasks,
      settings: settings,
      activePlants: activePlants,
      weekStartDate: weekStartDate,
      weekEnd: weekEnd,
    );

    return WeeklyReport(
      weekStart: weekStartDate,
      weekEnd: weekEnd,
      totalActions: thisWeekLogs.length,
      plantsCaresFor: plantsCaredFor,
      highlights: highlights,
      comparedToLastWeek: thisWeekLogs.length - lastWeekLogs.length,
      topPlantId: topPlant?.id,
      topPlantName: topPlant?.nickname ?? '',
    );
  }

  static Plant? _topPlant(List<CareLog> logs, List<Plant> plants) {
    if (logs.isEmpty) return null;
    final counts = <String, int>{};
    for (final log in logs) {
      counts[log.plantId] = (counts[log.plantId] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    final topId = counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    return plants.where((p) => p.id == topId).fold<Plant?>(null, (_, p) => p);
  }

  static List<WeeklyHighlight> _generateHighlights({
    required List<CareLog> thisWeekLogs,
    required List<CareLog> lastWeekLogs,
    required List<TaskInstance> tasks,
    required UserSettings settings,
    required List<Plant> activePlants,
    required DateTime weekStartDate,
    required DateTime weekEnd,
  }) {
    final highlights = <WeeklyHighlight>[];

    if (settings.careStreakDays >= 7) {
      highlights.add(WeeklyHighlight(
        type: WeeklyHighlightType.streakGrowth,
        messageKey: 'weeklyStreakGrowth',
        args: {'days': settings.careStreakDays.toString()},
      ));
    }

    final thisWeekTypes = thisWeekLogs.map((l) => l.type).toSet();
    if (thisWeekTypes.length >= 4) {
      highlights.add(WeeklyHighlight(
        type: WeeklyHighlightType.diverseCare,
        messageKey: 'weeklyDiverseCare',
        args: {'types': thisWeekTypes.length.toString()},
      ));
    }

    if (thisWeekLogs.length > lastWeekLogs.length * 2 &&
        lastWeekLogs.length < 3 &&
        thisWeekLogs.length >= 5) {
      highlights.add(const WeeklyHighlight(
        type: WeeklyHighlightType.comebackWeek,
        messageKey: 'weeklyComebackWeek',
        args: {},
      ));
    }

    if (thisWeekLogs.length > lastWeekLogs.length &&
        thisWeekLogs.length >= 10) {
      highlights.add(WeeklyHighlight(
        type: WeeklyHighlightType.newPersonalBest,
        messageKey: 'weeklyNewBest',
        args: {'count': thisWeekLogs.length.toString()},
      ));
    }

    final weekTasks = tasks.where((t) =>
        t.status == TaskStatus.done &&
        t.completedAt != null &&
        !t.dueAt.isBefore(weekStartDate) &&
        t.dueAt.isBefore(weekEnd.add(const Duration(days: 1)))).toList();
    final allOnTime = weekTasks.isNotEmpty &&
        weekTasks.every((t) =>
            t.completedAt!.difference(t.dueAt).inHours <= 24);
    if (allOnTime && weekTasks.length >= 3) {
      highlights.add(const WeeklyHighlight(
        type: WeeklyHighlightType.perfectWeek,
        messageKey: 'weeklyPerfectWeek',
        args: {},
      ));
    }

    if (thisWeekLogs.isEmpty) {
      highlights.add(const WeeklyHighlight(
        type: WeeklyHighlightType.quietWeek,
        messageKey: 'weeklyQuietWeek',
        args: {},
      ));
    }

    final plantsCared = thisWeekLogs.map((l) => l.plantId).toSet();
    if (plantsCared.length == activePlants.length && activePlants.length >= 3) {
      highlights.add(const WeeklyHighlight(
        type: WeeklyHighlightType.consistentCarer,
        messageKey: 'weeklyConsistentCarer',
        args: {},
      ));
    }

    return highlights.take(3).toList();
  }
}
