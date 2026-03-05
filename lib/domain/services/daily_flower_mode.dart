import '../models/enums.dart';
import '../models/user_settings.dart';
import 'daily_rituals.dart';
import 'zodiac.dart';

class DailyFlowerMode {
  const DailyFlowerMode._();

  static String? personalizationKey(UserSettings settings) {
    final seed = settings.dailySeed;
    if (seed != null) {
      final normalized = seed.trim().replaceAll('|', ' ');
      if (normalized.isNotEmpty) {
        return 'seed:${normalized.toLowerCase()}';
      }
    }

    final birthDate = settings.birthDate;
    if (birthDate != null) {
      final y = birthDate.year.toString().padLeft(4, '0');
      final m = birthDate.month.toString().padLeft(2, '0');
      final d = birthDate.day.toString().padLeft(2, '0');
      return 'birth:$y-$m-$d';
    }

    return null;
  }

  static bool needsPersonalInfo({
    required BeliefMode beliefMode,
    required UserSettings settings,
  }) {
    if (beliefMode == BeliefMode.unselected) return false;
    if (beliefMode == BeliefMode.tarot) return false;
    if (beliefMode == BeliefMode.westernZodiac) {
      return _westernZodiacVariantKey(settings) == null;
    }
    return personalizationKey(settings) == null;
  }

  static String? variantKey({
    required BeliefMode beliefMode,
    required UserSettings settings,
    required DateTime now,
    required String? tarotCardId,
  }) {
    return switch (beliefMode) {
      BeliefMode.unselected => null,
      BeliefMode.westernZodiac => _westernZodiacVariantKey(settings),
      BeliefMode.tarot => tarotCardId,
      BeliefMode.almanac => DailyRituals.almanacGanzhiForDate(now).id,
      BeliefMode.omikuji => DailyRituals.omikujiIdForDate(now),
      BeliefMode.runes => DailyRituals.runeIdForDate(now),
      BeliefMode.ogham => DailyRituals.oghamIdForDate(now),
      BeliefMode.justFlower => null,
    };
  }

  static bool needsTarotDraw({
    required BeliefMode beliefMode,
    required String? tarotCardId,
  }) {
    if (beliefMode != BeliefMode.tarot) return false;
    return tarotCardId == null || tarotCardId.trim().isEmpty;
  }

  static bool canShowEntry({
    required BeliefMode beliefMode,
    required bool needsPersonalInfo,
    required bool needsTarotDraw,
  }) {
    if (beliefMode == BeliefMode.unselected) return false;
    return !needsPersonalInfo && !needsTarotDraw;
  }

  static String? _westernZodiacVariantKey(UserSettings settings) {
    final manual = settings.westernZodiacSignId;
    if (manual != null && manual.trim().isNotEmpty) return manual.trim();
    final birthDate = settings.birthDate;
    if (birthDate == null) return null;
    return westernZodiacIdForDate(birthDate);
  }
}
