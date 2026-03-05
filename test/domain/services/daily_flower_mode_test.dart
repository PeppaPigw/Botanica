import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/domain/services/daily_flower_mode.dart';

void main() {
  group('DailyFlowerMode', () {
    test('variant key respects manual western zodiac sign', () {
      final settings = UserSettings.defaults().copyWith(
        westernZodiacSignId: 'leo',
      );

      final key = DailyFlowerMode.variantKey(
        beliefMode: BeliefMode.westernZodiac,
        settings: settings,
        now: DateTime(2026, 2, 20),
        tarotCardId: null,
      );

      expect(key, 'leo');
    });

    test('needsProfile is true when western zodiac data is missing', () {
      final settings = UserSettings.defaults();

      final key = DailyFlowerMode.variantKey(
        beliefMode: BeliefMode.westernZodiac,
        settings: settings,
        now: DateTime(2026, 2, 20),
        tarotCardId: null,
      );

      expect(key, isNull);
      expect(
        DailyFlowerMode.needsPersonalInfo(
          beliefMode: BeliefMode.westernZodiac,
          settings: settings,
        ),
        isTrue,
      );
    });

    test('needsPersonalInfo gates all modes when key missing', () {
      final settings = UserSettings.defaults();

      for (final mode in <BeliefMode>[
        BeliefMode.westernZodiac,
        BeliefMode.almanac,
        BeliefMode.omikuji,
        BeliefMode.runes,
        BeliefMode.ogham,
        BeliefMode.justFlower,
      ]) {
        expect(
          DailyFlowerMode.needsPersonalInfo(
            beliefMode: mode,
            settings: settings,
          ),
          isTrue,
          reason: 'Expected $mode to require personal info when missing.',
        );
      }

      expect(
        DailyFlowerMode.needsPersonalInfo(
          beliefMode: BeliefMode.tarot,
          settings: settings,
        ),
        isFalse,
        reason: 'Tarot is personalized via the daily draw, not profile fields.',
      );
    });

    test('needsPersonalInfo is false when birthDate is set', () {
      final settings = UserSettings.defaults().copyWith(
        birthDate: DateTime(1998, 7, 14),
      );

      for (final mode in <BeliefMode>[
        BeliefMode.westernZodiac,
        BeliefMode.tarot,
        BeliefMode.almanac,
        BeliefMode.omikuji,
        BeliefMode.runes,
        BeliefMode.ogham,
        BeliefMode.justFlower,
      ]) {
        expect(
          DailyFlowerMode.needsPersonalInfo(
            beliefMode: mode,
            settings: settings,
          ),
          isFalse,
          reason: 'Expected $mode to not require personal info when set.',
        );
      }
    });

    test('dailySeed satisfies personal info for non-zodiac modes', () {
      final settings = UserSettings.defaults().copyWith(dailySeed: 'Aster');

      for (final mode in <BeliefMode>[
        BeliefMode.almanac,
        BeliefMode.omikuji,
        BeliefMode.runes,
        BeliefMode.ogham,
        BeliefMode.justFlower,
      ]) {
        expect(
          DailyFlowerMode.needsPersonalInfo(
            beliefMode: mode,
            settings: settings,
          ),
          isFalse,
          reason: 'Expected $mode to accept dailySeed as personal info.',
        );
      }

      expect(
        DailyFlowerMode.needsPersonalInfo(
          beliefMode: BeliefMode.westernZodiac,
          settings: settings,
        ),
        isTrue,
        reason: 'Western zodiac still requires birth date or a selected sign.',
      );
    });

    test('manual western sign does not satisfy auto-mode key gating', () {
      final settings = UserSettings.defaults().copyWith(
        westernZodiacSignId: 'leo',
      );

      expect(
        DailyFlowerMode.needsPersonalInfo(
          beliefMode: BeliefMode.westernZodiac,
          settings: settings,
        ),
        isFalse,
        reason: 'Western zodiac mode can be configured with a manual sign.',
      );

      for (final mode in <BeliefMode>[
        BeliefMode.almanac,
        BeliefMode.omikuji,
        BeliefMode.runes,
        BeliefMode.ogham,
        BeliefMode.justFlower,
      ]) {
        expect(
          DailyFlowerMode.needsPersonalInfo(
            beliefMode: mode,
            settings: settings,
          ),
          isTrue,
          reason:
              'Expected $mode to require a personal key (seed phrase or birth date).',
        );
      }
    });

    test('needsTarotDraw toggles based on stored card', () {
      expect(
        DailyFlowerMode.needsTarotDraw(
          beliefMode: BeliefMode.tarot,
          tarotCardId: null,
        ),
        isTrue,
      );

      expect(
        DailyFlowerMode.needsTarotDraw(
          beliefMode: BeliefMode.tarot,
          tarotCardId: 'the_fool',
        ),
        isFalse,
      );
    });

    test('canShowEntry blocks when mode unselected even if no needs', () {
      expect(
        DailyFlowerMode.canShowEntry(
          beliefMode: BeliefMode.unselected,
          needsPersonalInfo: false,
          needsTarotDraw: false,
        ),
        isFalse,
      );

      expect(
        DailyFlowerMode.canShowEntry(
          beliefMode: BeliefMode.tarot,
          needsPersonalInfo: false,
          needsTarotDraw: false,
        ),
        isTrue,
      );
    });

    test('canShowEntry blocks when personal info is missing', () {
      expect(
        DailyFlowerMode.canShowEntry(
          beliefMode: BeliefMode.runes,
          needsPersonalInfo: true,
          needsTarotDraw: false,
        ),
        isFalse,
      );
    });
  });
}
