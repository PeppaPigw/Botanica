import 'dart:convert';

import 'belief_mode.dart';
import 'daily_flower_database.dart';

class DailyFlowerResolvedEntry {
  const DailyFlowerResolvedEntry({
    required this.id,
    required this.scientificName,
    required this.mode,
    required this.requestedLocale,
    required this.resolvedBaseLocale,
    required this.resolvedBeliefLocale,
    required this.sign,
    required this.name,
    required this.tags,
    required this.meaningKeywords,
    required this.symbolism,
    required this.appreciation,
    required this.care,
    required this.seed,
  });

  final String id;
  final String scientificName;
  final BeliefMode mode;
  final String requestedLocale;
  final String resolvedBaseLocale;
  final String resolvedBeliefLocale;
  final String? sign;
  final String name;
  final List<String> tags;
  final List<String> meaningKeywords;
  final String symbolism;
  final String appreciation;
  final CareBasics care;
  final String seed;
}

DailyFlowerResolvedEntry selectDailyFlower({
  required DailyFlowerDatabase database,
  required DateTime date,
  required String locale,
  required BeliefMode mode,
  String? sign,
}) {
  final normalizedLocale = _normalizeLocaleKey(locale);
  final normalizedSign = sign == null ? '' : _normalizeSeedComponent(sign);
  final seed =
      '${_formatDateKey(date)}|$normalizedLocale|${mode.jsonKey}|$normalizedSign';

  final candidates = database.entries
      .where((entry) => entry.belief.containsKey(mode))
      .toList(growable: false)
    ..sort((a, b) => a.id.compareTo(b.id));

  if (candidates.isEmpty) {
    throw StateError(
        'No Daily Flower entries available for mode ${mode.jsonKey}');
  }

  final selectedIndex = _fnv1a32(seed) % candidates.length;
  final selected = candidates[selectedIndex];

  final baseLocale = _resolveLocaleKey(
    availableLocales: selected.locales.keys,
    requestedLocale: normalizedLocale,
    fallbackLocale: database.defaultLocale,
  );
  final beliefContent = selected.belief[mode]!;
  final beliefLocale = _resolveLocaleKey(
    availableLocales: beliefContent.locales.keys,
    requestedLocale: normalizedLocale,
    fallbackLocale: database.defaultLocale,
  );

  final base = selected.locales[baseLocale]!;
  final belief = beliefContent.locales[beliefLocale]!;

  return DailyFlowerResolvedEntry(
    id: selected.id,
    scientificName: selected.flower.scientificName,
    mode: mode,
    requestedLocale: normalizedLocale,
    resolvedBaseLocale: baseLocale,
    resolvedBeliefLocale: beliefLocale,
    sign: sign,
    name: base.name,
    tags: selected.flower.tags,
    meaningKeywords: belief.meaningKeywords,
    symbolism: belief.symbolism,
    appreciation: belief.appreciation,
    care: base.care,
    seed: seed,
  );
}

String _formatDateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _normalizeLocaleKey(String localeKey) =>
    localeKey.replaceAll('_', '-').toLowerCase();

String _normalizeSeedComponent(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\\s+'), ' ');

String _resolveLocaleKey({
  required Iterable<String> availableLocales,
  required String requestedLocale,
  required String fallbackLocale,
}) {
  final normalizedRequested = _normalizeLocaleKey(requestedLocale);
  final normalizedFallback = _normalizeLocaleKey(fallbackLocale);

  final available = availableLocales.map(_normalizeLocaleKey).toSet();
  if (available.contains(normalizedRequested)) {
    return normalizedRequested;
  }

  final language = normalizedRequested.split('-').first;
  if (available.contains(language)) {
    return language;
  }

  final preferred =
      available.where((it) => it.startsWith('$language-')).toList()..sort();
  if (preferred.isNotEmpty) {
    return preferred.first;
  }

  if (available.contains(normalizedFallback)) {
    return normalizedFallback;
  }

  final sorted = available.toList()..sort();
  return sorted.first;
}

int _fnv1a32(String input) {
  const int fnvPrime = 0x01000193;
  const int offsetBasis = 0x811c9dc5;

  var hash = offsetBasis;
  for (final byte in utf8.encode(input)) {
    hash ^= byte;
    hash = (hash * fnvPrime) & 0xffffffff;
  }

  return hash;
}
