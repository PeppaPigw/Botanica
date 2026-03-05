import 'package:botanica/domain/models/daily_flower.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/services/ai/botanica_ai_prompts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BotanicaAiPrompts.languageNameForLocaleCode', () {
    test('maps common locales', () {
      expect(BotanicaAiPrompts.languageNameForLocaleCode('en'), 'English');
      expect(BotanicaAiPrompts.languageNameForLocaleCode('zh'),
          'Simplified Chinese');
      expect(BotanicaAiPrompts.languageNameForLocaleCode('es'), 'Spanish');
      expect(BotanicaAiPrompts.languageNameForLocaleCode('ar'), 'Arabic');
      expect(BotanicaAiPrompts.languageNameForLocaleCode('fr-FR'), 'French');
      expect(BotanicaAiPrompts.languageNameForLocaleCode('ja'), 'Japanese');
    });

    test('falls back to normalized language tag', () {
      expect(BotanicaAiPrompts.languageNameForLocaleCode('sv-SE'), 'sv');
      expect(BotanicaAiPrompts.languageNameForLocaleCode(''), 'English');
    });
  });

  group('BotanicaAiPrompts.dailyNote prompts', () {
    test('system prompt enforces language and style constraints', () {
      final prompt =
          BotanicaAiPrompts.dailyNoteSystemPrompt(languageName: 'Spanish');
      expect(prompt, contains('Respond ONLY in Spanish'));
      expect(prompt, contains('No emojis'));
      expect(prompt, contains('exactly 2 bullet lines'));
    });

    test('user prompt includes card fields', () {
      const content = DailyFlowerContent(
        key: 'lotus',
        name: 'Lotus',
        imagePath: null,
        meaningKeywords: ['clarity', 'calm'],
        symbolism: 'A symbol of renewal.',
        careBasics: {'Light': 'Bright indirect', 'Water': 'When dry'},
        appreciation: 'Observe the petals for 60 seconds.',
      );

      final prompt = BotanicaAiPrompts.dailyNoteUserPrompt(
        date: DateTime(2026, 2, 20),
        localeCode: 'es',
        beliefMode: BeliefMode.westernZodiac,
        variantLabel: 'Aries',
        content: content,
      );

      expect(prompt, contains('2026-02-20'));
      expect(prompt, contains('Personalization mode: western_zodiac'));
      expect(prompt, contains('Name: Lotus'));
      expect(prompt, contains('Symbolism: A symbol of renewal.'));
      expect(prompt, contains('Appreciation prompt: Observe the petals'));
    });
  });
}
