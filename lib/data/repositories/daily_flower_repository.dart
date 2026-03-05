import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/daily_flower.dart';

class DailyFlowerRepository {
  final Map<String, List<DailyFlowerContent>> _cacheByLocale = {};

  Future<List<DailyFlowerContent>> loadPool(String localeCode) async {
    final normalized = _normalizeLocale(localeCode);
    final cached = _cacheByLocale[normalized];
    if (cached != null) return cached;

    Future<List<DailyFlowerContent>> parseAsset(String assetPath) async {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = (decoded['entries'] as List? ?? const <dynamic>[])
          .map(
            (e) => DailyFlowerContent.fromJson(
                Map<String, dynamic>.from(e as Map)),
          )
          .toList(growable: false);
      return list;
    }

    final primaryAsset = switch (normalized) {
      'zh' => 'assets/data/daily_flower_zh.json',
      _ => 'assets/data/daily_flower_en.json',
    };

    try {
      final list = await parseAsset(primaryAsset);
      if (list.isNotEmpty) {
        _cacheByLocale[normalized] = list;
        return list;
      }
    } catch (_) {
      // Fall through to the English fallback below.
    }

    if (normalized != 'en') {
      try {
        final fallback = await parseAsset('assets/data/daily_flower_en.json');
        if (fallback.isNotEmpty) {
          _cacheByLocale[normalized] = fallback;
          return fallback;
        }
      } catch (_) {
        // If both fail, return an empty pool and let the UI show a safe fallback.
      }
    }

    return const <DailyFlowerContent>[];
  }

  String _normalizeLocale(String localeCode) {
    if (localeCode.toLowerCase().startsWith('zh')) return 'zh';
    if (localeCode.toLowerCase().startsWith('en')) return 'en';
    return localeCode.toLowerCase();
  }
}
