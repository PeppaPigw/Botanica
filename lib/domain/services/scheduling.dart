import 'package:timezone/timezone.dart' as tz;

import '../models/enums.dart';
import '../models/local_time.dart';

enum ScheduleAnchor {
  fromCompletion,
  fromDueDate,
}

Duration durationFromDays(double days) {
  final hours = (days * 24).round();
  return Duration(hours: hours);
}

DateTime alignToReminderTime(DateTime date, ReminderTimePreference pref) {
  return switch (pref) {
    ReminderTimePreference.morning => localWallClockDateTime(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: 9,
      ),
    ReminderTimePreference.evening =>
      localWallClockDateTime(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: 19,
      ),
  };
}

DateTime alignToLocalTime(DateTime date, LocalTime time) {
  return localWallClockDateTime(
    year: date.year,
    month: date.month,
    day: date.day,
    hour: time.hour,
    minute: time.minute,
  );
}

DateTime alignToPreferredReminderTime({
  required DateTime date,
  required ReminderTimePreference preference,
  LocalTime? override,
}) {
  final localOverride = override;
  if (localOverride != null) {
    return alignToLocalTime(date, localOverride);
  }
  return alignToReminderTime(date, preference);
}

DateTime addLocalCalendarDays(DateTime date, int days) {
  if (date.isUtc) {
    return DateTime.utc(
      date.year,
      date.month,
      date.day + days,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
  return localWallClockDateTime(
    year: date.year,
    month: date.month,
    day: date.day + days,
    hour: date.hour,
    minute: date.minute,
    second: date.second,
    millisecond: date.millisecond,
    microsecond: date.microsecond,
  );
}

DateTime localWallClockDateTime({
  required int year,
  required int month,
  required int day,
  int hour = 0,
  int minute = 0,
  int second = 0,
  int millisecond = 0,
  int microsecond = 0,
}) {
  final zoned = tz.TZDateTime(
    tz.local,
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
    microsecond,
  );
  return DateTime(
    zoned.year,
    zoned.month,
    zoned.day,
    zoned.hour,
    zoned.minute,
    zoned.second,
    zoned.millisecond,
    zoned.microsecond,
  );
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
  if (interval.inMicroseconds % Duration.microsecondsPerDay == 0) {
    return addLocalCalendarDays(base, interval.inDays);
  }
  return base.add(interval);
}
