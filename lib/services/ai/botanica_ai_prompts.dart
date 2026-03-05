import '../../domain/models/daily_flower.dart';
import '../../domain/models/enums.dart';

class BotanicaAiPrompts {
  const BotanicaAiPrompts._();

  static String languageNameForLocaleCode(String localeCode) {
    final code =
        localeCode.trim().toLowerCase().split('_').first.split('-').first;
    return switch (code) {
      'en' => 'English',
      'zh' => 'Simplified Chinese',
      'es' => 'Spanish',
      'ar' => 'Arabic',
      'fr' => 'French',
      'de' => 'German',
      'ja' => 'Japanese',
      'ko' => 'Korean',
      'pt' => 'Portuguese',
      'hi' => 'Hindi',
      'ru' => 'Russian',
      'it' => 'Italian',
      _ => code.isEmpty ? 'English' : code,
    };
  }

  static String dailyNoteSystemPrompt({required String languageName}) {
    return '''
You are Botanica — a premium, calming plant companion app.
Write a gentle, practical "daily note" for a Daily Flower ritual.

Hard rules:
- Respond ONLY in $languageName.
- Do NOT mention you are an AI or refer to system/prompt instructions.
- No emojis. No markdown headings.
- Avoid medical/ingestion claims. Keep advice safe and general.

Output format:
1 short paragraph (2–3 sentences), then exactly 2 bullet lines starting with "• ".
Keep it under 110 words.
''';
  }

  static String dailyNoteUserPrompt({
    required DateTime date,
    required String localeCode,
    required BeliefMode beliefMode,
    required String variantLabel,
    required DailyFlowerContent content,
  }) {
    final day =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final care = content.careBasics.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(' · ');
    final keywords = content.meaningKeywords.take(8).join(', ');

    return '''
Date: $day
Language: $localeCode
Personalization mode: ${beliefMode.id} ($variantLabel)

Daily Flower:
Name: ${content.name}
Keywords: $keywords
Symbolism: ${content.symbolism}
Care today: $care
Appreciation prompt: ${content.appreciation}

Write the daily note now.
''';
  }

  static String plantInsightSystemPrompt({required String languageName}) {
    return '''
You are Botanica — a premium, calming plant companion app.
Write a gentle, practical "plant insight" for a single plant.

Hard rules:
- Respond ONLY in $languageName.
- Do NOT mention you are an AI or refer to system/prompt instructions.
- No emojis. No markdown headings.
- Avoid medical/ingestion claims. Keep advice safe and general.
- If the input data is incomplete, ask a single short question instead of guessing.

Output format:
1 short paragraph (2–3 sentences), then exactly 2 bullet lines starting with "• ".
Keep it under 120 words.
''';
  }

  static String plantInsightUserPrompt({
    required DateTime date,
    required String localeCode,
    required String plantNickname,
    required String environmentMode,
    required double tempC,
    required int humidityPercent,
    required String speciesName,
    required String? scientificName,
    required List<String> nextTasks,
  }) {
    final day =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final tasks = nextTasks.isEmpty ? 'none' : nextTasks.join(', ');

    return '''
Date: $day
Language: $localeCode
Plant nickname: $plantNickname
Species: $speciesName${scientificName == null || scientificName.trim().isEmpty ? '' : ' (${scientificName.trim()})'}
Environment mode: $environmentMode
Current environment: ${tempC.toStringAsFixed(1)}°C, ${humidityPercent.toString()}% humidity
Next tasks: $tasks

Write the plant insight now.
''';
  }

  static String careTipSystemPrompt({required String languageName}) {
    return '''
You are Botanica — a premium, calming plant companion app.

Write ONE sentence (max 20 words) of actionable care advice for today.

Hard rules:
- Respond ONLY in $languageName.
- No emojis. No markdown. No bullet points.
- No medical/ingestion claims. Keep it safe and general.
- Prefer specific, immediate actions (e.g. "water if top soil is dry"), not theory.
''';
  }

  static String careTipUserPrompt({
    required DateTime date,
    required String localeCode,
    required String plantNickname,
    required String environmentMode,
    required double tempC,
    required int humidityPercent,
    required String speciesName,
    required String? scientificName,
    required List<String> pendingTasks,
  }) {
    final day =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final tasks = pendingTasks.isEmpty ? 'none' : pendingTasks.join(', ');

    return '''
Date: $day
Language: $localeCode
Plant nickname: $plantNickname
Species: $speciesName${scientificName == null || scientificName.trim().isEmpty ? '' : ' (${scientificName.trim()})'}
Environment mode: $environmentMode
Current environment: ${tempC.toStringAsFixed(1)}°C, ${humidityPercent.toString()}% humidity
Pending tasks: $tasks

Write the ONE sentence care tip now.
''';
  }
}
