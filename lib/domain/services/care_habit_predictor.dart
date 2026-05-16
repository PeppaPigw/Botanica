import '../models/care_log.dart';
import '../models/task_instance.dart';

class HabitPrediction {
  const HabitPrediction({
    required this.dayOfWeek,
    required this.missRisk,
    required this.avgCompletionRate,
    required this.peakCareHour,
    required this.insight,
  });

  final int dayOfWeek;
  final double missRisk;
  final double avgCompletionRate;
  final int peakCareHour;
  final String insight;
}

class WeeklyHabitProfile {
  const WeeklyHabitProfile({
    required this.predictions,
    required this.bestDay,
    required this.worstDay,
    required this.preferredTimeSlot,
    required this.weekendVsWeekday,
  });

  final List<HabitPrediction> predictions;
  final int bestDay;
  final int worstDay;
  final String preferredTimeSlot;
  final double weekendVsWeekday;
}

class CareHabitPredictor {
  const CareHabitPredictor._();

  static WeeklyHabitProfile predict({
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
  }) {
    final recentLogs = logs.where((l) => now.difference(l.timestamp).inDays <= 60).toList();
    final recentTasks = tasks.where((t) => now.difference(t.dueAt).inDays <= 60).toList();

    final predictions = <HabitPrediction>[];

    for (int day = 1; day <= 7; day++) {
      final dayLogs = recentLogs.where((l) => l.timestamp.weekday == day).toList();
      final dayTasks = recentTasks.where((t) => t.dueAt.weekday == day).toList();

      final completed = dayTasks.where((t) => t.isDone).length;
      final total = dayTasks.length;
      final completionRate = total > 0 ? completed / total : 0.5;
      final missRisk = 1.0 - completionRate;

      final hours = dayLogs.map((l) => l.timestamp.hour).toList();
      final peakHour = hours.isEmpty ? 9 : _mode(hours);

      final insight = _insightForDay(day, missRisk, dayLogs.length);

      predictions.add(HabitPrediction(
        dayOfWeek: day,
        missRisk: missRisk,
        avgCompletionRate: completionRate,
        peakCareHour: peakHour,
        insight: insight,
      ));
    }

    final bestDay = predictions.reduce((a, b) =>
        a.avgCompletionRate > b.avgCompletionRate ? a : b).dayOfWeek;
    final worstDay = predictions.reduce((a, b) =>
        a.missRisk > b.missRisk ? a : b).dayOfWeek;

    final allHours = recentLogs.map((l) => l.timestamp.hour).toList();
    final preferredSlot = _timeSlot(allHours.isEmpty ? 9 : _mode(allHours));

    final weekdayLogs = recentLogs.where((l) => l.timestamp.weekday <= 5).length;
    final weekendLogs = recentLogs.where((l) => l.timestamp.weekday > 5).length;
    final weekendRatio = weekdayLogs > 0
        ? (weekendLogs / 2) / (weekdayLogs / 5)
        : 1.0;

    return WeeklyHabitProfile(
      predictions: predictions,
      bestDay: bestDay,
      worstDay: worstDay,
      preferredTimeSlot: preferredSlot,
      weekendVsWeekday: weekendRatio,
    );
  }

  static int _mode(List<int> values) {
    final counts = <int, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static String _timeSlot(int hour) {
    if (hour < 6) return 'habitSlotEarlyMorning';
    if (hour < 10) return 'habitSlotMorning';
    if (hour < 14) return 'habitSlotMidday';
    if (hour < 18) return 'habitSlotAfternoon';
    if (hour < 21) return 'habitSlotEvening';
    return 'habitSlotNight';
  }

  static String _insightForDay(int day, double missRisk, int logCount) {
    if (missRisk > 0.7) return 'habitHighRiskDay';
    if (missRisk < 0.2 && logCount > 5) return 'habitReliableDay';
    if (day >= 6) return 'habitWeekendPattern';
    return 'habitNormalDay';
  }
}
