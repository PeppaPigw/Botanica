import 'package:hive_flutter/hive_flutter.dart';

import '../local/local_db.dart';

abstract class AiCacheRepository {
  const AiCacheRepository();

  String? readText(
    String key, {
    Duration maxAge = const Duration(days: 7),
    DateTime? now,
  });

  Future<void> writeText({
    required String key,
    required String value,
    Duration? ttl,
    DateTime? now,
  });

  /// Deletes cached entries that have exceeded their own TTL.
  ///
  /// If an entry doesn't have a stored TTL (older schema), a conservative
  /// fallback TTL is applied so the cache cannot grow unbounded.
  Future<void> evictExpired({DateTime? now});

  Future<void> clear();

  factory AiCacheRepository.local() =>
      _HiveAiCacheRepository(LocalDb.aiCacheBox);
}

class _HiveAiCacheRepository implements AiCacheRepository {
  const _HiveAiCacheRepository(this._box);

  final Box<Map> _box;

  @override
  String? readText(
    String key, {
    Duration maxAge = const Duration(days: 7),
    DateTime? now,
  }) {
    final raw = _box.get(key);
    if (raw == null) return null;

    final map = Map<String, dynamic>.from(raw);
    final tsMs = (map['ts'] as num?)?.toInt();
    final ttlMs = (map['ttlMs'] as num?)?.toInt();
    final value = map['value']?.toString();
    if (tsMs == null || value == null || value.trim().isEmpty) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(tsMs);
    final age = (now ?? DateTime.now()).difference(cachedAt);
    if (age.isNegative) return value.trim();
    final effectiveMaxAge = ttlMs == null
        ? maxAge
        : Duration(milliseconds: ttlMs.clamp(0, 365 * 24 * 60 * 60 * 1000));
    if (age > effectiveMaxAge) return null;

    return value.trim();
  }

  @override
  Future<void> writeText({
    required String key,
    required String value,
    Duration? ttl,
    DateTime? now,
  }) async {
    final normalized = value.trim();
    if (normalized.isEmpty) return;

    final ttlMs = ttl?.inMilliseconds;

    await _box.put(
      key,
      <String, dynamic>{
        'ts': (now ?? DateTime.now()).millisecondsSinceEpoch,
        'value': normalized,
        if (ttlMs != null) 'ttlMs': ttlMs,
      },
    );
  }

  @override
  Future<void> evictExpired({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final keys = _box.keys.cast<String>().toList(growable: false);

    // For older entries that predate per-entry TTL, use a conservative fallback
    // so stale content doesn't accumulate forever.
    const fallbackTtl = Duration(days: 7);

    for (final key in keys) {
      final raw = _box.get(key);
      if (raw == null) continue;

      final map = Map<String, dynamic>.from(raw);
      final tsMs = (map['ts'] as num?)?.toInt();
      final ttlMs = (map['ttlMs'] as num?)?.toInt();

      if (tsMs == null) {
        await _box.delete(key);
        continue;
      }

      final cachedAt = DateTime.fromMillisecondsSinceEpoch(tsMs);
      final age = current.difference(cachedAt);
      if (age.isNegative) continue;

      final ttl = ttlMs == null
          ? fallbackTtl
          : Duration(milliseconds: ttlMs.clamp(0, 365 * 24 * 60 * 60 * 1000));

      if (age > ttl) {
        await _box.delete(key);
      }
    }
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
