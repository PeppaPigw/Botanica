enum BeliefMode {
  justFlower,
  westernZodiac,
  tarot,
  almanac,
  omikuji,
  runes,
  ogham,
}

extension BeliefModeJson on BeliefMode {
  String get jsonKey => switch (this) {
        BeliefMode.justFlower => 'just_flower',
        BeliefMode.westernZodiac => 'western_zodiac',
        BeliefMode.tarot => 'tarot',
        BeliefMode.almanac => 'almanac',
        BeliefMode.omikuji => 'omikuji',
        BeliefMode.runes => 'runes',
        BeliefMode.ogham => 'ogham',
      };
}

BeliefMode beliefModeFromJsonKey(String jsonKey) => switch (jsonKey) {
      // Migration: "neutral" was renamed to "just_flower".
      'neutral' => BeliefMode.justFlower,
      'just_flower' => BeliefMode.justFlower,
      'western_zodiac' => BeliefMode.westernZodiac,
      // Migration: Chinese zodiac was replaced by Almanac.
      'chinese_zodiac' => BeliefMode.almanac,
      'tarot' => BeliefMode.tarot,
      // Migration: local traditions collapsed into a neutral mode.
      'local' => BeliefMode.justFlower,
      'almanac' => BeliefMode.almanac,
      'omikuji' => BeliefMode.omikuji,
      'runes' => BeliefMode.runes,
      'ogham' => BeliefMode.ogham,
      _ => throw FormatException('Unknown belief mode: $jsonKey'),
    };
