import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/services/plant_anniversary.dart';

void main() {
  group('PlantAnniversary.checkMilestone', () {
    final now = DateTime(2026, 5, 16, 10, 0);

    test('returns null for plant younger than 30 days', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 15)),
        lastShown: null,
        now: now,
      );
      expect(result, isNull);
    });

    test('returns 30 for plant exactly 30 days old', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 30)),
        lastShown: null,
        now: now,
      );
      expect(result, 30);
    });

    test('returns 30 for plant 31 days old (within 1-day window)', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 31)),
        lastShown: null,
        now: now,
      );
      expect(result, 30);
    });

    test('returns null for plant 32 days old (outside window)', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 32)),
        lastShown: null,
        now: now,
      );
      expect(result, isNull);
    });

    test('returns 90 for plant exactly 90 days old', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 90)),
        lastShown: null,
        now: now,
      );
      expect(result, 90);
    });

    test('returns 180 for plant exactly 180 days old', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 180)),
        lastShown: null,
        now: now,
      );
      expect(result, 180);
    });

    test('returns 365 for plant exactly 365 days old', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 365)),
        lastShown: null,
        now: now,
      );
      expect(result, 365);
    });

    test('returns null if already shown today', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 90)),
        lastShown: DateTime(now.year, now.month, now.day, 8, 0),
        now: now,
      );
      expect(result, isNull);
    });

    test('returns null if shown within last 7 days', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 30)),
        lastShown: now.subtract(const Duration(days: 3)),
        now: now,
      );
      expect(result, isNull);
    });

    test('returns milestone if last shown more than 7 days ago', () {
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 90)),
        lastShown: now.subtract(const Duration(days: 60)),
        now: now,
      );
      expect(result, 90);
    });

    test('picks earliest matching milestone', () {
      // 30 days matches first in the loop
      final result = PlantAnniversary.checkMilestone(
        plantCreatedAt: now.subtract(const Duration(days: 30)),
        lastShown: null,
        now: now,
      );
      expect(result, 30);
    });
  });

  group('PlantAnniversary.milestoneLabel', () {
    test('returns correct labels', () {
      expect(PlantAnniversary.milestoneLabel(30), '1 month');
      expect(PlantAnniversary.milestoneLabel(90), '3 months');
      expect(PlantAnniversary.milestoneLabel(180), '6 months');
      expect(PlantAnniversary.milestoneLabel(365), '1 year');
    });
  });
}
