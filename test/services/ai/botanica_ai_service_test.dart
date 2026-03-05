import 'package:botanica/data/repositories/ai_cache_repository.dart';
import 'package:botanica/domain/models/daily_flower.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/services/ai/ai_chat_client.dart';
import 'package:botanica/services/ai/botanica_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const flowerContent = DailyFlowerContent(
    key: 'peace_lily',
    name: 'Peace Lily',
    imagePath: null,
    meaningKeywords: ['calm', 'balance', 'focus'],
    symbolism: 'A reminder to breathe and stay present.',
    careBasics: {'Light': 'Bright, indirect', 'Water': 'Keep soil moist'},
    appreciation: 'Notice how the leaves unfurl when you breathe slowly.',
  );

  final date = DateTime(2025, 10, 7);
  const beliefMode = BeliefMode.westernZodiac;

  group('BotanicaAiService', () {
    test('daily note cache key is stable and sensitive to context', () {
      final service = BotanicaAiService(
        cache: FakeAiCacheRepository(),
        client: FakeAiChatClient(response: 'ignored'),
      );

      final keyA = service.dailyNoteCacheKey(
        date: date,
        localeCode: 'es',
        beliefMode: beliefMode,
        variantKey: 'aries',
        content: flowerContent,
      );

      final keyB = service.dailyNoteCacheKey(
        date: date,
        localeCode: 'es',
        beliefMode: beliefMode,
        variantKey: 'aries',
        content: flowerContent,
      );

      final keyC = service.dailyNoteCacheKey(
        date: date,
        localeCode: 'es',
        beliefMode: beliefMode,
        variantKey: 'taurus',
        content: flowerContent,
      );

      expect(keyA, keyB); // deterministic
      expect(keyA, startsWith('ai_cache:'));
      expect(keyC, isNot(keyA)); // variant key influences hash
    });

    test('returns cached note when available', () async {
      final cache = FakeAiCacheRepository();
      final client = FakeAiChatClient(response: 'should-not-be-used');
      final service = BotanicaAiService(cache: cache, client: client);

      final cacheKey = service.dailyNoteCacheKey(
        date: date,
        localeCode: 'es',
        beliefMode: beliefMode,
        variantKey: 'taurus',
        content: flowerContent,
      );

      await cache.writeText(key: cacheKey, value: 'cached note');

      final value = await service.generateDailyNote(
        date: date,
        localeCode: 'es',
        beliefMode: beliefMode,
        variantLabel: 'Taurus',
        variantKey: 'taurus',
        content: flowerContent,
      );

      expect(value, 'cached note');
      expect(client.callCount, 0,
          reason: 'client should not be invoked when cache hits');
    });

    test(
        'sanitizes client response, caches result, and instructs Spanish language',
        () async {
      final rawResponse = '\n\nHola Mundo\n\n\n${List.filled(720, 'A').join()}';
      final cache = FakeAiCacheRepository();
      final client = FakeAiChatClient(response: rawResponse);
      final service = BotanicaAiService(cache: cache, client: client);

      final value = await service.generateDailyNote(
        date: date,
        localeCode: 'es',
        beliefMode: beliefMode,
        variantLabel: 'Gemini',
        variantKey: 'gemini',
        content: flowerContent,
      );

      expect(value, endsWith('…'));
      expect(value.length, lessThanOrEqualTo(701));
      expect(
          cache.valueFor(service.dailyNoteCacheKey(
            date: date,
            localeCode: 'es',
            beliefMode: beliefMode,
            variantKey: 'gemini',
            content: flowerContent,
          )),
          value);
      expect(client.callCount, 1);
      final messages = client.lastMessages;
      expect(messages, isNotNull);
      expect(messages!.first['role'], 'system');
      expect(messages.first['content'], contains('Respond ONLY in Spanish'));
      expect(messages[1]['content'], contains('Language: es'));
    });
  });
}

class FakeAiCacheRepository implements AiCacheRepository {
  final Map<String, Map<String, dynamic>> _store = {};

  String? valueFor(String key) => _store[key]?['value'] as String?;

  @override
  Future<void> clear() async => _store.clear();

  @override
  String? readText(String key,
      {Duration maxAge = const Duration(days: 7), DateTime? now}) {
    final entry = _store[key];
    if (entry == null) return null;

    final ts = entry['ts'] as int?;
    final ttlMs = entry['ttlMs'] as int?;
    final value = entry['value'] as String?;
    if (ts == null || value == null) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    final age = (now ?? DateTime.now()).difference(cachedAt);
    final effectiveMaxAge =
        ttlMs == null ? maxAge : Duration(milliseconds: ttlMs);
    if (age > effectiveMaxAge) return null;
    return value.trim();
  }

  @override
  Future<void> writeText(
      {required String key,
      required String value,
      Duration? ttl,
      DateTime? now}) async {
    _store[key] = {
      'ts': (now ?? DateTime.now()).millisecondsSinceEpoch,
      'value': value.trim(),
      if (ttl != null) 'ttlMs': ttl.inMilliseconds,
    };
  }

  @override
  Future<void> evictExpired({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final keys = _store.keys.toList(growable: false);
    for (final key in keys) {
      final entry = _store[key];
      if (entry == null) continue;
      final ts = entry['ts'] as int?;
      final ttlMs = entry['ttlMs'] as int?;
      if (ts == null) {
        _store.remove(key);
        continue;
      }
      final ttl = ttlMs == null
          ? const Duration(days: 7)
          : Duration(milliseconds: ttlMs);
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
      if (current.difference(cachedAt) > ttl) {
        _store.remove(key);
      }
    }
  }
}

class FakeAiChatClient implements AiChatClient {
  FakeAiChatClient({required this.response});

  final String response;
  int callCount = 0;
  List<Map<String, String>>? lastMessages;

  @override
  bool get isConfigured => true;

  @override
  Future<String> createChatCompletion({
    required List<Map<String, String>> messages,
    double temperature = 0.35,
    int maxTokens = 220,
  }) async {
    callCount++;
    lastMessages = List<Map<String, String>>.from(
        messages.map((m) => Map<String, String>.from(m)));
    return response;
  }
}
