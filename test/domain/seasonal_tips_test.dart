import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/services/seasonal_tips.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeasonalTipsEngine.currentSeason', () {
    test('northern hemisphere spring in March', () {
      expect(
        SeasonalTipsEngine.currentSeason(Hemisphere.northern, now: DateTime(2025, 3, 15)),
        Season.spring,
      );
    });

    test('northern hemisphere summer in July', () {
      expect(
        SeasonalTipsEngine.currentSeason(Hemisphere.northern, now: DateTime(2025, 7, 1)),
        Season.summer,
      );
    });

    test('northern hemisphere autumn in October', () {
      expect(
        SeasonalTipsEngine.currentSeason(Hemisphere.northern, now: DateTime(2025, 10, 1)),
        Season.autumn,
      );
    });

    test('northern hemisphere winter in January', () {
      expect(
        SeasonalTipsEngine.currentSeason(Hemisphere.northern, now: DateTime(2025, 1, 15)),
        Season.winter,
      );
    });

    test('southern hemisphere is opposite', () {
      expect(
        SeasonalTipsEngine.currentSeason(Hemisphere.southern, now: DateTime(2025, 7, 1)),
        Season.winter,
      );
      expect(
        SeasonalTipsEngine.currentSeason(Hemisphere.southern, now: DateTime(2025, 1, 15)),
        Season.summer,
      );
    });
  });

  group('SeasonalTipsEngine.tipsForSeason', () {
    test('each season has 5 tips', () {
      for (final season in Season.values) {
        expect(SeasonalTipsEngine.tipsForSeason(season).length, 5);
      }
    });

    test('all tips have non-empty fields', () {
      for (final season in Season.values) {
        for (final tip in SeasonalTipsEngine.tipsForSeason(season)) {
          expect(tip.id, isNotEmpty);
          expect(tip.titleKey, isNotEmpty);
          expect(tip.bodyKey, isNotEmpty);
          expect(tip.icon, isNotEmpty);
        }
      }
    });
  });

  group('SeasonalTipsEngine.tipOfTheDay', () {
    test('returns a tip deterministically for same day', () {
      final tip1 = SeasonalTipsEngine.tipOfTheDay(
        Hemisphere.northern,
        now: DateTime(2025, 5, 10),
      );
      final tip2 = SeasonalTipsEngine.tipOfTheDay(
        Hemisphere.northern,
        now: DateTime(2025, 5, 10),
      );
      expect(tip1.id, tip2.id);
    });

    test('returns different tips on different days', () {
      final tip1 = SeasonalTipsEngine.tipOfTheDay(
        Hemisphere.northern,
        now: DateTime(2025, 5, 10),
      );
      final tip2 = SeasonalTipsEngine.tipOfTheDay(
        Hemisphere.northern,
        now: DateTime(2025, 5, 11),
      );
      expect(tip1.id, isNot(tip2.id));
    });
  });
}
