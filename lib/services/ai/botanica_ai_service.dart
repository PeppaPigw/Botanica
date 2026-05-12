import 'dart:convert';

import 'package:characters/characters.dart';
import 'package:crypto/crypto.dart';

import '../../data/repositories/ai_cache_repository.dart';
import '../../domain/models/daily_flower.dart';
import '../../domain/models/enums.dart';
import 'ai_chat_client.dart';
import 'botanica_ai_prompts.dart';

class BotanicaAiService {
  const BotanicaAiService({
    required AiCacheRepository cache,
    required AiChatClient client,
  })  : _cache = cache,
        _client = client;

  static const Duration _dailyNoteTtl = Duration(hours: 24);
  static const Duration _plantInsightTtl = Duration(hours: 6);
  static const Duration _careTipTtl = Duration(hours: 2);
  static const Duration _requestThrottleTtl = Duration(minutes: 5);

  final AiCacheRepository _cache;
  final AiChatClient _client;

  bool get isConfigured => _client.isConfigured;

  String dailyNoteCacheKey({
    required DateTime date,
    required String localeCode,
    required BeliefMode beliefMode,
    required String? variantKey,
    required DailyFlowerContent content,
  }) {
    final day = _formatDay(date);
    final seed = <String>[
      'daily_note_v1',
      day,
      localeCode.trim().toLowerCase(),
      beliefMode.id,
      (variantKey ?? '').trim().toLowerCase(),
      content.key.trim().toLowerCase(),
    ].join('|');

    final digest = sha1.convert(utf8.encode(seed)).toString();
    return 'ai_cache:$digest';
  }

  String plantInsightCacheKey({
    required DateTime date,
    required String localeCode,
    required String plantId,
    required String plantNickname,
    required String speciesId,
    required EnvironmentMode environmentMode,
    required double tempC,
    required int humidityPercent,
    required List<String> nextTasks,
  }) {
    final day = _formatDay(date);

    final tempBucket = tempC.round().clamp(-40, 60);
    final humidityBucket =
        ((humidityPercent.clamp(0, 100) / 5).round() * 5).clamp(0, 100);

    final tasksSignature = nextTasks
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .take(6)
        .join(',');

    final seed = <String>[
      'plant_insight_v1',
      day,
      localeCode.trim().toLowerCase(),
      plantId.trim().toLowerCase(),
      plantNickname.trim().toLowerCase(),
      speciesId.trim().toLowerCase(),
      environmentMode.id,
      't$tempBucket',
      'h$humidityBucket',
      tasksSignature,
    ].join('|');

    final digest = sha1.convert(utf8.encode(seed)).toString();
    return 'ai_cache:$digest';
  }

  Future<String> generateDailyNote({
    required DateTime date,
    required String localeCode,
    required BeliefMode beliefMode,
    required String variantLabel,
    required String? variantKey,
    required DailyFlowerContent content,
  }) async {
    final cacheKey = dailyNoteCacheKey(
      date: date,
      localeCode: localeCode,
      beliefMode: beliefMode,
      variantKey: variantKey,
      content: content,
    );
    final throttleKey = _dailyNoteThrottleKey(
      date: date,
      localeCode: localeCode,
      beliefMode: beliefMode,
      variantKey: variantKey,
      content: content,
    );

    final cached = _cache.readText(throttleKey) ??
        _cache.readText(cacheKey, maxAge: _dailyNoteTtl);
    if (cached != null) return cached;

    final languageName =
        BotanicaAiPrompts.languageNameForLocaleCode(localeCode);

    final messages = <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': BotanicaAiPrompts.dailyNoteSystemPrompt(
          languageName: languageName,
        ),
      },
      <String, String>{
        'role': 'user',
        'content': BotanicaAiPrompts.dailyNoteUserPrompt(
          date: date,
          localeCode: localeCode,
          beliefMode: beliefMode,
          variantLabel: variantLabel,
          content: content,
        ),
      },
    ];

    final raw = await _client.createChatCompletion(
      messages: messages,
      temperature: 0.35,
      maxTokens: 240,
    );

    final value = _sanitizeMultilineText(raw);
    await _cache.writeText(key: cacheKey, value: value, ttl: _dailyNoteTtl);
    await _cache.writeText(
      key: throttleKey,
      value: value,
      ttl: _requestThrottleTtl,
    );
    return value;
  }

  Future<String> generatePlantInsight({
    required DateTime date,
    required String localeCode,
    required String plantId,
    required String plantNickname,
    required String speciesId,
    required String speciesName,
    required String? scientificName,
    required EnvironmentMode environmentMode,
    required double tempC,
    required int humidityPercent,
    required List<String> nextTasks,
  }) async {
    final cacheKey = plantInsightCacheKey(
      date: date,
      localeCode: localeCode,
      plantId: plantId,
      plantNickname: plantNickname,
      speciesId: speciesId,
      environmentMode: environmentMode,
      tempC: tempC,
      humidityPercent: humidityPercent,
      nextTasks: nextTasks,
    );
    final throttleKey = _plantRequestThrottleKey(
      kind: 'plant_insight',
      date: date,
      localeCode: localeCode,
      plantId: plantId,
      environmentMode: environmentMode,
    );

    final cached = _cache.readText(throttleKey) ??
        _cache.readText(cacheKey, maxAge: _plantInsightTtl);
    if (cached != null) return cached;

    final languageName =
        BotanicaAiPrompts.languageNameForLocaleCode(localeCode);

    final messages = <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': BotanicaAiPrompts.plantInsightSystemPrompt(
          languageName: languageName,
        ),
      },
      <String, String>{
        'role': 'user',
        'content': BotanicaAiPrompts.plantInsightUserPrompt(
          date: date,
          localeCode: localeCode,
          plantNickname: plantNickname,
          environmentMode: environmentMode.id,
          tempC: tempC,
          humidityPercent: humidityPercent,
          speciesName: speciesName,
          scientificName: scientificName,
          nextTasks: nextTasks,
        ),
      },
    ];

    final raw = await _client.createChatCompletion(
      messages: messages,
      temperature: 0.25,
      maxTokens: 260,
    );

    final value = _sanitizeMultilineText(raw);
    await _cache.writeText(
      key: cacheKey,
      value: value,
      ttl: _plantInsightTtl,
    );
    await _cache.writeText(
      key: throttleKey,
      value: value,
      ttl: _requestThrottleTtl,
    );
    return value;
  }

  String careTipCacheKey({
    required DateTime date,
    required String localeCode,
    required String plantId,
    required String plantNickname,
    required String speciesId,
    required EnvironmentMode environmentMode,
    required double tempC,
    required int humidityPercent,
    required List<String> pendingTasks,
  }) {
    final day = _formatDay(date);

    final tempBucket = tempC.round().clamp(-40, 60);
    final humidityBucket =
        ((humidityPercent.clamp(0, 100) / 5).round() * 5).clamp(0, 100);

    final tasksSignature = pendingTasks
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .take(6)
        .join(',');

    final seed = <String>[
      'care_tip_v1',
      day,
      localeCode.trim().toLowerCase(),
      plantId.trim().toLowerCase(),
      plantNickname.trim().toLowerCase(),
      speciesId.trim().toLowerCase(),
      environmentMode.id,
      't$tempBucket',
      'h$humidityBucket',
      tasksSignature,
    ].join('|');

    final digest = sha1.convert(utf8.encode(seed)).toString();
    return 'ai_cache:$digest';
  }

  Future<String> generateCareTip({
    required DateTime date,
    required String localeCode,
    required String plantId,
    required String plantNickname,
    required String speciesId,
    required EnvironmentMode environmentMode,
    required double tempC,
    required int humidityPercent,
    required String speciesName,
    required String? scientificName,
    required List<String> pendingTasks,
  }) async {
    final cacheKey = careTipCacheKey(
      date: date,
      localeCode: localeCode,
      plantId: plantId,
      plantNickname: plantNickname,
      speciesId: speciesId,
      environmentMode: environmentMode,
      tempC: tempC,
      humidityPercent: humidityPercent,
      pendingTasks: pendingTasks,
    );
    final throttleKey = _plantRequestThrottleKey(
      kind: 'care_tip',
      date: date,
      localeCode: localeCode,
      plantId: plantId,
      environmentMode: environmentMode,
    );

    final cached = _cache.readText(throttleKey) ??
        _cache.readText(cacheKey, maxAge: _careTipTtl);
    if (cached != null) return cached;

    final languageName =
        BotanicaAiPrompts.languageNameForLocaleCode(localeCode);

    final messages = <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': BotanicaAiPrompts.careTipSystemPrompt(
          languageName: languageName,
        ),
      },
      <String, String>{
        'role': 'user',
        'content': BotanicaAiPrompts.careTipUserPrompt(
          date: date,
          localeCode: localeCode,
          plantNickname: plantNickname,
          environmentMode: environmentMode.id,
          tempC: tempC,
          humidityPercent: humidityPercent,
          speciesName: speciesName,
          scientificName: scientificName,
          pendingTasks: pendingTasks,
        ),
      },
    ];

    final raw = await _client.createChatCompletion(
      messages: messages,
      temperature: 0.22,
      maxTokens: 80,
    );

    final value = _sanitizeSingleSentence(raw);
    await _cache.writeText(key: cacheKey, value: value, ttl: _careTipTtl);
    await _cache.writeText(
      key: throttleKey,
      value: value,
      ttl: _requestThrottleTtl,
    );
    return value;
  }

  String _dailyNoteThrottleKey({
    required DateTime date,
    required String localeCode,
    required BeliefMode beliefMode,
    required String? variantKey,
    required DailyFlowerContent content,
  }) {
    final day = _formatDay(date);
    final seed = <String>[
      'daily_note_throttle_v1',
      day,
      localeCode.trim().toLowerCase(),
      beliefMode.id,
      (variantKey ?? '').trim().toLowerCase(),
      content.key.trim().toLowerCase(),
    ].join('|');

    final digest = sha1.convert(utf8.encode(seed)).toString();
    return 'ai_throttle:$digest';
  }

  String _plantRequestThrottleKey({
    required String kind,
    required DateTime date,
    required String localeCode,
    required String plantId,
    required EnvironmentMode environmentMode,
  }) {
    final day = _formatDay(date);
    final seed = <String>[
      '${kind}_throttle_v1',
      day,
      localeCode.trim().toLowerCase(),
      plantId.trim().toLowerCase(),
      environmentMode.id,
    ].join('|');

    final digest = sha1.convert(utf8.encode(seed)).toString();
    return 'ai_throttle:$digest';
  }
}

String _formatDay(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _sanitizeMultilineText(String input) {
  var s = input.replaceAll('\r\n', '\n').trim();
  s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  const int maxGraphemes = 700;
  final chars = s.characters;
  if (chars.length > maxGraphemes) {
    var truncated = chars.take(maxGraphemes).toString().trimRight();
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 0 && lastSpace > (truncated.length * 0.6)) {
      truncated = truncated.substring(0, lastSpace).trimRight();
    }
    s = '$truncated…';
  }

  return s;
}

String _sanitizeSingleSentence(String input) {
  var s = input.replaceAll('\r\n', '\n').trim();
  s = s.replaceAll('\n', ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Strip common bullet markers / markdown noise.
  s = s.replaceAll(RegExp(r'^[•\\-\\*]\\s*'), '');

  // Keep only the first "sentence" if the model responds with multiple.
  final sentenceEnd = RegExp(r'[.!?。！？]');
  final match = sentenceEnd.firstMatch(s);
  if (match != null && match.end < s.length) {
    s = s.substring(0, match.end).trim();
  }

  const int maxGraphemes = 220;
  final chars = s.characters;
  if (chars.length > maxGraphemes) {
    var truncated = chars.take(maxGraphemes).toString().trimRight();
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 0 && lastSpace > (truncated.length * 0.6)) {
      truncated = truncated.substring(0, lastSpace).trimRight();
    }
    s = '$truncated…';
  }

  return s;
}
