import 'garden_wellness_summary.dart';

enum GardenWellnessPriorityKind {
  attention,
  dueToday,
  refreshHistory,
  calm,
}

class GardenWellnessPriority {
  const GardenWellnessPriority({
    required this.kind,
    required this.title,
    required this.body,
  });

  final GardenWellnessPriorityKind kind;
  final String title;
  final String body;
}

class GardenWellnessPriorities {
  const GardenWellnessPriorities._();

  static List<GardenWellnessPriority> build({
    required GardenWellnessSummary summary,
  }) {
    final priorities = <GardenWellnessPriority>[];
    final focus =
        summary.focusPlants.isEmpty ? null : summary.focusPlants.first;

    if (focus != null &&
        (focus.score < 80 || focus.overdueTasks > 0 || !focus.hasRecentLog)) {
      priorities.add(
        GardenWellnessPriority(
          kind: GardenWellnessPriorityKind.attention,
          title: 'Check on ${focus.plant.nickname}',
          body: _attentionBody(focus),
        ),
      );
    }

    if (summary.dueTodayTasks > 0) {
      priorities.add(
        GardenWellnessPriority(
          kind: GardenWellnessPriorityKind.dueToday,
          title: 'Keep today on track',
          body: _dueTodayBody(summary.dueTodayTasks),
        ),
      );
    }

    final missingLogCount = summary.focusPlants
        .where((focusPlant) => !focusPlant.hasRecentLog)
        .length;
    if (missingLogCount > 0) {
      priorities.add(
        GardenWellnessPriority(
          kind: GardenWellnessPriorityKind.refreshHistory,
          title: 'Refresh care history',
          body: _refreshHistoryBody(missingLogCount),
        ),
      );
    }

    if (priorities.isEmpty) {
      priorities.add(
        const GardenWellnessPriority(
          kind: GardenWellnessPriorityKind.calm,
          title: 'Enjoy the calm',
          body: 'No urgent issues today — your garden looks steady.',
        ),
      );
    }

    return priorities.take(3).toList(growable: false);
  }
}

String _attentionBody(GardenFocusPlant focus) {
  if (focus.overdueTasks > 0 && !focus.hasRecentLog) {
    return '${focus.overdueTasks} overdue ${_taskWord(focus.overdueTasks)} '
        'and no recent log.';
  }
  if (focus.overdueTasks > 0) {
    final verb = focus.overdueTasks == 1 ? 'needs' : 'need';
    return '${focus.overdueTasks} overdue ${_taskWord(focus.overdueTasks)} '
        '$verb attention.';
  }
  if (!focus.hasRecentLog) {
    return 'No recent log in the last 14 days.';
  }
  return 'This plant needs a quick check-in.';
}

String _dueTodayBody(int count) {
  if (count == 1) {
    return '1 task is due today.';
  }
  return '$count tasks are due today.';
}

String _refreshHistoryBody(int count) {
  if (count == 1) {
    return '1 plant is missing a recent log.';
  }
  return '$count plants are missing a recent log.';
}

String _taskWord(int count) => count == 1 ? 'task' : 'tasks';
