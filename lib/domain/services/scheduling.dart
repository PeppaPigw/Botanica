import '../models/enums.dart';

enum ScheduleAnchor {
  fromCompletion,
  fromDueDate,
}

Duration durationFromDays(double days) {
  final hours = (days * 24).round();
  return Duration(hours: hours);
}

DateTime alignToReminderTime(DateTime date, ReminderTimePreference pref) {
  final day = DateTime(date.year, date.month, date.day);
  return switch (pref) {
    ReminderTimePreference.morning => DateTime(day.year, day.month, day.day, 9),
    ReminderTimePreference.evening =>
      DateTime(day.year, day.month, day.day, 19),
  };
}

DateTime computeNextDueAt({
  required DateTime now,
  required Duration interval,
  required ScheduleAnchor anchor,
  required DateTime? lastCompletedAt,
  required DateTime? previousDueAt,
}) {
  final base = switch (anchor) {
    ScheduleAnchor.fromCompletion => lastCompletedAt ?? now,
    ScheduleAnchor.fromDueDate => previousDueAt ?? now,
  };
  return base.add(interval);
}
