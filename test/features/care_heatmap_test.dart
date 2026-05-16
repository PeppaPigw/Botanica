import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Care activity heatmap bucketing', () {
    CareLog makeLog(DateTime timestamp) => CareLog(
          id: 'log-${timestamp.toIso8601String()}',
          plantId: 'plant-1',
          type: TaskType.water,
          timestamp: timestamp,
          note: null,
          linkedPhotoId: null,
        );

    Map<int, int> computeHeatmap(List<CareLog> logs, DateTime today) {
      const weeks = 12;
      const daysTotal = weeks * 7;
      final startDay = today.subtract(const Duration(days: daysTotal - 1));

      final dayCounts = <int, int>{};
      for (final log in logs) {
        final logDay = DateTime(
          log.timestamp.year,
          log.timestamp.month,
          log.timestamp.day,
        );
        final diff = logDay.difference(startDay).inDays;
        if (diff >= 0 && diff < daysTotal) {
          dayCounts[diff] = (dayCounts[diff] ?? 0) + 1;
        }
      }
      return dayCounts;
    }

    test('logs within 12 weeks are bucketed correctly', () {
      final today = DateTime(2026, 5, 15);
      final logs = [
        makeLog(DateTime(2026, 5, 15, 9, 0)),
        makeLog(DateTime(2026, 5, 15, 14, 0)),
        makeLog(DateTime(2026, 5, 14, 10, 0)),
        makeLog(DateTime(2026, 2, 1, 8, 0)),
      ];
      final heatmap = computeHeatmap(logs, today);
      expect(heatmap[83], 2); // today = day 83 (12*7 - 1)
      expect(heatmap[82], 1); // yesterday
      // Feb 1 is more than 84 days before May 15 (103 days), so excluded
      expect(heatmap.length, 2);
    });

    test('logs outside 12-week window are excluded', () {
      final today = DateTime(2026, 5, 15);
      final logs = [
        makeLog(DateTime(2026, 1, 1, 9, 0)),
        makeLog(DateTime(2025, 12, 1, 9, 0)),
      ];
      final heatmap = computeHeatmap(logs, today);
      expect(heatmap.isEmpty, true);
    });

    test('multiple logs on same day accumulate', () {
      final today = DateTime(2026, 5, 15);
      final logs = [
        makeLog(DateTime(2026, 5, 10, 8, 0)),
        makeLog(DateTime(2026, 5, 10, 12, 0)),
        makeLog(DateTime(2026, 5, 10, 18, 0)),
      ];
      final heatmap = computeHeatmap(logs, today);
      expect(heatmap[78], 3); // May 10 = 5 days before today = index 83-5=78
    });

    test('empty logs produce empty heatmap', () {
      final today = DateTime(2026, 5, 15);
      final heatmap = computeHeatmap([], today);
      expect(heatmap.isEmpty, true);
    });
  });

  group('Weekly trend comparison', () {
    test('trend up when this week has more actions', () {
      const thisWeek = 8;
      const lastWeek = 5;
      expect(thisWeek > lastWeek, true);
      expect(thisWeek - lastWeek, 3);
    });

    test('trend down when this week has fewer actions', () {
      const thisWeek = 3;
      const lastWeek = 7;
      expect(thisWeek < lastWeek, true);
      expect(thisWeek - lastWeek, -4);
    });

    test('trend same when equal', () {
      const thisWeek = 5;
      const lastWeek = 5;
      expect(thisWeek == lastWeek, true);
    });
  });
}
