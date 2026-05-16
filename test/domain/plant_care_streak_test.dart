import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/services/plant_care_streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CareLog makeLog(DateTime timestamp) => CareLog(
        id: timestamp.toIso8601String(),
        plantId: 'plant-1',
        type: TaskType.water,
        timestamp: timestamp,
        note: null,
        linkedPhotoId: null,
      );

  DateTime daysAgo(int daysAgo) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(
      Duration(days: daysAgo),
    );
  }

  group('PlantCareStreak.compute', () {
    test('returns 0 for empty logs', () {
      expect(PlantCareStreak.compute([]), 0);
    });

    test('returns 1 for a single log today', () {
      expect(PlantCareStreak.compute([makeLog(daysAgo(0))]), 1);
    });

    test('returns 1 for a single log yesterday', () {
      expect(PlantCareStreak.compute([makeLog(daysAgo(1))]), 1);
    });

    test('returns 0 if most recent log is 2+ days ago', () {
      expect(PlantCareStreak.compute([makeLog(daysAgo(2))]), 0);
    });

    test('counts consecutive days', () {
      final logs = [
        makeLog(daysAgo(0)),
        makeLog(daysAgo(1)),
        makeLog(daysAgo(2)),
        makeLog(daysAgo(3)),
      ];
      expect(PlantCareStreak.compute(logs), 4);
    });

    test('breaks on gap', () {
      final logs = [
        makeLog(daysAgo(0)),
        makeLog(daysAgo(1)),
        // gap at day 2
        makeLog(daysAgo(3)),
        makeLog(daysAgo(4)),
      ];
      expect(PlantCareStreak.compute(logs), 2);
    });

    test('deduplicates multiple logs on same day', () {
      final logs = [
        makeLog(daysAgo(0).add(const Duration(hours: 8))),
        makeLog(daysAgo(0).add(const Duration(hours: 14))),
        makeLog(daysAgo(1)),
        makeLog(daysAgo(2)),
      ];
      expect(PlantCareStreak.compute(logs), 3);
    });

    test('handles unordered input', () {
      final logs = [
        makeLog(daysAgo(2)),
        makeLog(daysAgo(0)),
        makeLog(daysAgo(1)),
      ];
      expect(PlantCareStreak.compute(logs), 3);
    });

    test('streak starting from yesterday counts correctly', () {
      final logs = [
        makeLog(daysAgo(1)),
        makeLog(daysAgo(2)),
        makeLog(daysAgo(3)),
      ];
      expect(PlantCareStreak.compute(logs), 3);
    });
  });
}
