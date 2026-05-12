import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/services/scheduling.dart';

void main() {
  group('durationFromDays', () {
    test('converts fractional days to duration', () {
      final d = durationFromDays(1.5);
      expect(d.inHours, 36);
    });
  });

  group('computeNextDueAt', () {
    test('uses completion time when anchored from completion', () {
      final due = computeNextDueAt(
        now: DateTime.utc(2026, 2, 20),
        interval: const Duration(days: 2),
        anchor: ScheduleAnchor.fromCompletion,
        lastCompletedAt: DateTime.utc(2026, 2, 10),
        previousDueAt: DateTime.utc(2026, 2, 11),
      );
      expect(due, DateTime.utc(2026, 2, 12));
    });

    test('uses previous due date when anchored from due date', () {
      final due = computeNextDueAt(
        now: DateTime.utc(2026, 2, 20),
        interval: const Duration(days: 2),
        anchor: ScheduleAnchor.fromDueDate,
        lastCompletedAt: DateTime.utc(2026, 2, 10),
        previousDueAt: DateTime.utc(2026, 2, 11),
      );
      expect(due, DateTime.utc(2026, 2, 13));
    });
  });

  group('DST-safe local scheduling', () {
    setUpAll(tz_data.initializeTimeZones);

    test('aligns to 9am local wall time after DST starts', () {
      final previousLocation = tz.local;
      tz.setLocalLocation(tz.getLocation('America/New_York'));
      addTearDown(() => tz.setLocalLocation(previousLocation));

      final aligned = alignToReminderTime(
        DateTime(2026, 3, 9, 12),
        ReminderTimePreference.morning,
      );

      expect(aligned.hour, 9);
      expect(aligned.minute, 0);
      expect(aligned.day, 9);
    });

    test('adds calendar days across DST without shifting wall-clock hour', () {
      final previousLocation = tz.local;
      tz.setLocalLocation(tz.getLocation('America/New_York'));
      addTearDown(() => tz.setLocalLocation(previousLocation));

      final next = addLocalCalendarDays(DateTime(2026, 3, 7, 9), 2);

      expect(next, DateTime(2026, 3, 9, 9));
    });
  });
}
