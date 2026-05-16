import 'package:botanica/domain/models/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSettings dismissedCoachingDate', () {
    test('defaults to null', () {
      final settings = UserSettings.defaults();
      expect(settings.dismissedCoachingDate, isNull);
    });

    test('copyWith sets dismissedCoachingDate', () {
      final settings = UserSettings.defaults();
      final now = DateTime(2025, 5, 15);
      final updated = settings.copyWith(dismissedCoachingDate: now);
      expect(updated.dismissedCoachingDate, equals(now));
    });

    test('copyWith can clear dismissedCoachingDate', () {
      final settings = UserSettings.defaults().copyWith(
        dismissedCoachingDate: DateTime(2025, 5, 15),
      );
      final cleared = settings.copyWith(dismissedCoachingDate: null);
      expect(cleared.dismissedCoachingDate, isNull);
    });

    test('toJson and fromJson round-trip', () {
      final settings = UserSettings.defaults().copyWith(
        dismissedCoachingDate: DateTime(2025, 5, 15),
      );
      final json = settings.toJson();
      final restored = UserSettings.fromJson(json);
      expect(
        restored.dismissedCoachingDate,
        equals(DateTime(2025, 5, 15)),
      );
    });

    test('toJson with null dismissedCoachingDate', () {
      final settings = UserSettings.defaults();
      final json = settings.toJson();
      expect(json['dismissedCoachingDate'], isNull);
      final restored = UserSettings.fromJson(json);
      expect(restored.dismissedCoachingDate, isNull);
    });

    test('equality includes dismissedCoachingDate', () {
      final a = UserSettings.defaults().copyWith(
        dismissedCoachingDate: DateTime(2025, 5, 15),
      );
      final b = UserSettings.defaults().copyWith(
        dismissedCoachingDate: DateTime(2025, 5, 15),
      );
      final c = UserSettings.defaults().copyWith(
        dismissedCoachingDate: DateTime(2025, 5, 16),
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
