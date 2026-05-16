import 'package:botanica/domain/models/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the streak-at-risk detection logic used in the Tasks screen.
///
/// The banner shows when:
/// - careStreakDays >= 3
/// - lastCareDate is exactly 1 day ago (no care today)
/// - current hour >= 16 (4 PM)
void main() {
  bool isStreakAtRisk(UserSettings settings, DateTime now) {
    if (settings.careStreakDays < 3) return false;
    if (settings.lastCareDate == null) return false;
    final daysSinceCare = now
        .difference(DateTime(
          settings.lastCareDate!.year,
          settings.lastCareDate!.month,
          settings.lastCareDate!.day,
        ))
        .inDays;
    return daysSinceCare == 1 && now.hour >= 16;
  }

  group('Streak at risk detection', () {
    test('triggers when streak >= 3, no care today, and hour >= 16', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 5,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 18, 30);

      expect(isStreakAtRisk(settings, now), isTrue);
    });

    test('does not trigger before 4 PM', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 5,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 14, 0);

      expect(isStreakAtRisk(settings, now), isFalse);
    });

    test('does not trigger with streak < 3', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 2,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 19, 0);

      expect(isStreakAtRisk(settings, now), isFalse);
    });

    test('does not trigger if care was done today', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 10,
        lastCareDate: DateTime(2025, 6, 11),
      );
      final now = DateTime(2025, 6, 11, 20, 0);

      expect(isStreakAtRisk(settings, now), isFalse);
    });

    test('does not trigger if no lastCareDate', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 5,
      );
      final now = DateTime(2025, 6, 11, 19, 0);

      expect(isStreakAtRisk(settings, now), isFalse);
    });

    test('does not trigger if care was 2+ days ago (streak already broken)', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 5,
        lastCareDate: DateTime(2025, 6, 9),
      );
      final now = DateTime(2025, 6, 11, 19, 0);

      expect(isStreakAtRisk(settings, now), isFalse);
    });

    test('triggers at exactly 4 PM boundary', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 3,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 16, 0);

      expect(isStreakAtRisk(settings, now), isTrue);
    });

    test('does not trigger at 3:59 PM (one minute before threshold)', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 7,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 15, 59);

      expect(isStreakAtRisk(settings, now), isFalse);
    });

    test('triggers at 11:59 PM (late evening)', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 14,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 23, 59);

      expect(isStreakAtRisk(settings, now), isTrue);
    });

    test('triggers with minimum streak of exactly 3', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 3,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 17, 0);

      expect(isStreakAtRisk(settings, now), isTrue);
    });

    test('does not trigger with streak of exactly 2 (below threshold)', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 2,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 17, 0);

      expect(isStreakAtRisk(settings, now), isFalse);
    });

    test('handles month boundary correctly', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 5,
        lastCareDate: DateTime(2025, 5, 31),
      );
      final now = DateTime(2025, 6, 1, 20, 0);

      expect(isStreakAtRisk(settings, now), isTrue);
    });

    test('handles year boundary correctly', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 10,
        lastCareDate: DateTime(2025, 12, 31),
      );
      final now = DateTime(2026, 1, 1, 18, 0);

      expect(isStreakAtRisk(settings, now), isTrue);
    });

    test('does not trigger with very high streak but care done today', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 100,
        lastCareDate: DateTime(2025, 6, 11),
      );
      final now = DateTime(2025, 6, 11, 22, 0);

      expect(isStreakAtRisk(settings, now), isFalse);
    });

    test('does not trigger early morning after care yesterday', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 5,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 6, 0);

      expect(isStreakAtRisk(settings, now), isFalse);
    });

    test('does not trigger if streak is 0 even with other conditions met', () {
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 0,
        lastCareDate: DateTime(2025, 6, 10),
      );
      final now = DateTime(2025, 6, 11, 18, 0);

      expect(isStreakAtRisk(settings, now), isFalse);
    });
  });
}
