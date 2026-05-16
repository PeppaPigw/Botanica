import '../models/care_log.dart';
import '../models/task_instance.dart';

class WeeklyRhythm {
  const WeeklyRhythm({
    required this.weekStart,
    required this.score,
    required this.tasksCompleted,
    required this.tasksMissed,
    required this.onTimeRate,
    required this.varietyScore,
    required this.consistencyTrend,
  });

  final DateTime weekStart;
  final double score;
  final int tasksCompleted;
  final int tasksMissed;
  final double onTimeRate;
  final double varietyScore;
  final double consistencyTrend;
}

class RhythmInsight {
  const RhythmInsight({
    required this.type,
    required this.message,
    required this.metric,
  });

  final String type;
  final String message;
  final double metric;
}

class GardenRhythmResult {
  const GardenRhythmResult({
    required this.currentScore,
    required this.weeklyHistory,
    required this.bestWeekScore,
    required this.averageScore,
    required this.insights,
    required this.trend,
  });

  final double currentScore;
  final List<WeeklyRhythm> weeklyHistory;
  final double bestWeekScore;
  final double averageScore;
  final List<RhythmInsight> insights;
  final double trend;

  String get rhythmGrade {
    if (currentScore >= 0.9) return 'A+';
    if (currentScore >= 0.8) return 'A';
    if (currentScore >= 0.7) return 'B';
    if (currentScore >= 0.6) return 'C';
    if (currentScore >= 0.4) return 'D';
    return 'F';
  }
}

class GardenRhythmScore {
  const GardenRhythmScore._();

  static GardenRhythmResult compute({
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
    int weeksToAnalyze = 8,
  }) {
    final weeks = <WeeklyRhythm>[];

    for (int w = 0; w < weeksToAnalyze; w++) {
      final weekEnd = _startOfWeek(now).subtract(Duration(days: 7 * w));
      final weekStart = weekEnd.subtract(const Duration(days: 7));

      final weekTasks = tasks.where((t) =>
          t.dueAt.isAfter(weekStart) && t.dueAt.isBefore(weekEnd)).toList();
      final weekLogs = logs.where((l) =>
          l.timestamp.isAfter(weekStart) && l.timestamp.isBefore(weekEnd)).toList();

      final completed = weekTasks.where((t) => t.isDone).length;
      final missed = weekTasks.where((t) =>
          !t.isDone && !t.isDismissed && t.dueAt.isBefore(now)).length;
      final total = completed + missed;

      final onTimeRate = total > 0 ? completed / total : 1.0;

      final taskTypes = weekLogs.map((l) => l.type).toSet();
      final varietyScore = taskTypes.length >= 4
          ? 1.0
          : taskTypes.length >= 2
              ? 0.7
              : taskTypes.isNotEmpty
                  ? 0.4
                  : 0.0;

      final activeDays = weekLogs.map((l) =>
          DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day))
          .toSet()
          .length;
      final consistencyScore = (activeDays / 7.0).clamp(0.0, 1.0);

      final score = (onTimeRate * 0.5 + varietyScore * 0.2 + consistencyScore * 0.3)
          .clamp(0.0, 1.0);

      weeks.add(WeeklyRhythm(
        weekStart: weekStart,
        score: score,
        tasksCompleted: completed,
        tasksMissed: missed,
        onTimeRate: onTimeRate,
        varietyScore: varietyScore,
        consistencyTrend: consistencyScore,
      ));
    }

    final currentScore = weeks.isNotEmpty ? weeks.first.score : 0.0;
    final bestWeek = weeks.isEmpty
        ? 0.0
        : weeks.map((w) => w.score).reduce((a, b) => a > b ? a : b);
    final avgScore = weeks.isEmpty
        ? 0.0
        : weeks.map((w) => w.score).reduce((a, b) => a + b) / weeks.length;

    final trend = weeks.length >= 2
        ? weeks.first.score - weeks[1].score
        : 0.0;

    final insights = _generateInsights(weeks, logs, now);

    return GardenRhythmResult(
      currentScore: currentScore,
      weeklyHistory: weeks,
      bestWeekScore: bestWeek,
      averageScore: avgScore,
      insights: insights,
      trend: trend,
    );
  }

  static DateTime _startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  static List<RhythmInsight> _generateInsights(
      List<WeeklyRhythm> weeks, List<CareLog> logs, DateTime now) {
    final insights = <RhythmInsight>[];

    if (weeks.length >= 3) {
      final recentAvg = weeks.take(3).map((w) => w.score).reduce((a, b) => a + b) / 3;
      final olderAvg = weeks.skip(3).take(3).map((w) => w.score).fold(0.0, (a, b) => a + b);
      final olderCount = weeks.skip(3).take(3).length;
      if (olderCount > 0 && recentAvg > olderAvg / olderCount + 0.1) {
        insights.add(RhythmInsight(
          type: 'improving',
          message: 'rhythmImproving',
          metric: recentAvg - olderAvg / olderCount,
        ));
      }
    }

    if (weeks.isNotEmpty && weeks.first.onTimeRate < 0.5) {
      insights.add(RhythmInsight(
        type: 'missedTasks',
        message: 'rhythmManyMissed',
        metric: weeks.first.onTimeRate,
      ));
    }

    final weekendLogs = logs.where((l) =>
        now.difference(l.timestamp).inDays <= 28 &&
        (l.timestamp.weekday == 6 || l.timestamp.weekday == 7)).length;
    final weekdayLogs = logs.where((l) =>
        now.difference(l.timestamp).inDays <= 28 &&
        l.timestamp.weekday < 6).length;
    if (weekendLogs > weekdayLogs * 0.8 && weekendLogs > 5) {
      insights.add(const RhythmInsight(
        type: 'weekendWarrior',
        message: 'rhythmWeekendWarrior',
        metric: 0.0,
      ));
    }

    if (weeks.isNotEmpty && weeks.first.varietyScore >= 1.0) {
      insights.add(const RhythmInsight(
        type: 'diverseCare',
        message: 'rhythmDiverseCare',
        metric: 1.0,
      ));
    }

    return insights;
  }
}
