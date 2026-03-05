import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/services/care/care_actions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CareActions.updatedSettingsAfterCare', () {
    test('starts streak at 1 on first care action', () {
      final settings = UserSettings.defaults();
      final now = DateTime(2026, 2, 20, 9, 30);

      final next = CareActions.updatedSettingsAfterCare(
        settings: settings,
        now: now,
      );

      expect(next.careStreakDays, 1);
      expect(next.lastCareDate, DateTime(2026, 2, 20));
    });

    test('increments streak on consecutive days', () {
      final day1 = DateTime(2026, 2, 20, 8);
      final day2 = DateTime(2026, 2, 21, 18);

      final s1 = CareActions.updatedSettingsAfterCare(
        settings: UserSettings.defaults(),
        now: day1,
      );
      final s2 = CareActions.updatedSettingsAfterCare(settings: s1, now: day2);

      expect(s2.careStreakDays, 2);
      expect(s2.lastCareDate, DateTime(2026, 2, 21));
    });

    test('does not increment when called twice on the same day', () {
      final morning = DateTime(2026, 2, 20, 9);
      final evening = DateTime(2026, 2, 20, 19);

      final s1 = CareActions.updatedSettingsAfterCare(
        settings: UserSettings.defaults(),
        now: morning,
      );
      final s2 =
          CareActions.updatedSettingsAfterCare(settings: s1, now: evening);

      expect(s2.careStreakDays, 1);
      expect(s2.lastCareDate, DateTime(2026, 2, 20));
    });

    test('resets to 1 when the gap is more than one day', () {
      final day1 = DateTime(2026, 2, 20, 9);
      final day4 = DateTime(2026, 2, 23, 9);

      final s1 = CareActions.updatedSettingsAfterCare(
        settings: UserSettings.defaults(),
        now: day1,
      );
      final s2 = CareActions.updatedSettingsAfterCare(settings: s1, now: day4);

      expect(s2.careStreakDays, 1);
      expect(s2.lastCareDate, DateTime(2026, 2, 23));
    });

    test('treats inconsistent stored streak as at least 1', () {
      final yesterday = DateTime(2026, 2, 20);
      final settings = UserSettings.defaults().copyWith(
        careStreakDays: 0,
        lastCareDate: yesterday,
      );

      final next = CareActions.updatedSettingsAfterCare(
        settings: settings,
        now: DateTime(2026, 2, 21, 9),
      );

      expect(next.careStreakDays, 2);
    });
  });
}
