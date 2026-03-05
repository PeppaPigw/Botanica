import 'package:flutter_test/flutter_test.dart';

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
}
