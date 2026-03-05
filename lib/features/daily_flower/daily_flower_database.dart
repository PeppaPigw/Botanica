import 'dart:convert';

import 'belief_mode.dart';

class DailyFlowerDatabase {
  const DailyFlowerDatabase({
    required this.schemaVersion,
    required this.defaultLocale,
    required this.beliefModes,
    required this.entries,
  });

  final String schemaVersion;
  final String defaultLocale;
  final Set<BeliefMode> beliefModes;
  final List<DailyFlowerEntry> entries;

  factory DailyFlowerDatabase.fromJsonString(String jsonString) =>
      DailyFlowerDatabase.fromJson(
        jsonDecode(jsonString) as Map<String, Object?>,
      );

  factory DailyFlowerDatabase.fromJson(Map<String, Object?> json) {
    final schemaVersion =
        _requireString(json['schemaVersion'], 'schemaVersion');
    final defaultLocale = _normalizeLocaleKey(
      _requireString(json['defaultLocale'], 'defaultLocale'),
    );

    final beliefModes = _requireList(json['beliefModes'], 'beliefModes')
        .map((mode) => _requireString(mode, 'beliefModes[]'))
        .map(beliefModeFromJsonKey)
        .toSet();

    final entries = _requireList(json['entries'], 'entries')
        .map((entry) => DailyFlowerEntry.fromJson(
              _requireMap(entry, 'entries[]'),
              defaultLocale: defaultLocale,
            ))
        .toList(growable: false);

    return DailyFlowerDatabase(
      schemaVersion: schemaVersion,
      defaultLocale: defaultLocale,
      beliefModes: beliefModes,
      entries: entries,
    );
  }
}

class DailyFlowerEntry {
  const DailyFlowerEntry({
    required this.id,
    required this.flower,
    required this.locales,
    required this.belief,
  });

  final String id;
  final FlowerInfo flower;
  final Map<String, DailyFlowerBaseLocaleContent> locales;
  final Map<BeliefMode, DailyFlowerBeliefContent> belief;

  factory DailyFlowerEntry.fromJson(
    Map<String, Object?> json, {
    required String defaultLocale,
  }) {
    final id = _requireString(json['id'], 'id');

    final flower = FlowerInfo.fromJson(_requireMap(json['flower'], 'flower'));

    final localesJson = _requireMap(json['locales'], 'locales');
    final locales = <String, DailyFlowerBaseLocaleContent>{};
    for (final MapEntry(key: rawLocale, value: rawContent)
        in localesJson.entries) {
      locales[_normalizeLocaleKey(rawLocale)] =
          DailyFlowerBaseLocaleContent.fromJson(
        _requireMap(rawContent, 'locales.$rawLocale'),
      );
    }
    if (locales.isEmpty) {
      throw const FormatException('DailyFlowerEntry.locales must not be empty');
    }

    final beliefJson = _requireMap(json['belief'], 'belief');
    final belief = <BeliefMode, DailyFlowerBeliefContent>{};
    for (final MapEntry(key: rawMode, value: rawContent)
        in beliefJson.entries) {
      belief[beliefModeFromJsonKey(rawMode)] =
          DailyFlowerBeliefContent.fromJson(
        _requireMap(rawContent, 'belief.$rawMode'),
      );
    }
    if (belief.isEmpty) {
      throw const FormatException('DailyFlowerEntry.belief must not be empty');
    }

    if (!locales.containsKey(defaultLocale)) {
      throw FormatException(
        'Entry "$id" is missing defaultLocale "$defaultLocale" in locales',
      );
    }

    for (final MapEntry(:key, :value) in belief.entries) {
      if (!value.locales.containsKey(defaultLocale)) {
        throw FormatException(
          'Entry "$id" is missing defaultLocale "$defaultLocale" in belief.${key.jsonKey}.locales',
        );
      }
    }

    return DailyFlowerEntry(
        id: id, flower: flower, locales: locales, belief: belief);
  }
}

class FlowerInfo {
  const FlowerInfo({
    required this.scientificName,
    required this.tags,
  });

  final String scientificName;
  final List<String> tags;

  factory FlowerInfo.fromJson(Map<String, Object?> json) => FlowerInfo(
        scientificName:
            _requireString(json['scientificName'], 'scientificName'),
        tags: _optionalStringList(json['tags'], 'tags'),
      );
}

class DailyFlowerBaseLocaleContent {
  const DailyFlowerBaseLocaleContent({
    required this.name,
    required this.aliases,
    required this.care,
    required this.culturalNotesByRegion,
  });

  final String name;
  final List<String> aliases;
  final CareBasics care;
  final Map<String, String> culturalNotesByRegion;

  factory DailyFlowerBaseLocaleContent.fromJson(Map<String, Object?> json) {
    final culturalNotes = <String, String>{};
    final rawNotes = json['culturalNotesByRegion'];
    if (rawNotes != null) {
      final notesJson = _requireMap(rawNotes, 'culturalNotesByRegion');
      for (final MapEntry(key: rawKey, value: rawValue) in notesJson.entries) {
        culturalNotes[rawKey] = _requireString(
          rawValue,
          'culturalNotesByRegion.$rawKey',
        );
      }
    }

    return DailyFlowerBaseLocaleContent(
      name: _requireString(json['name'], 'name'),
      aliases: _optionalStringList(json['aliases'], 'aliases'),
      care: CareBasics.fromJson(_requireMap(json['care'], 'care')),
      culturalNotesByRegion: culturalNotes,
    );
  }
}

class CareBasics {
  const CareBasics({
    required this.light,
    required this.water,
    required this.temperature,
    required this.petSafety,
  });

  final String light;
  final String water;
  final String temperature;
  final String petSafety;

  factory CareBasics.fromJson(Map<String, Object?> json) => CareBasics(
        light: _requireString(json['light'], 'light'),
        water: _requireString(json['water'], 'water'),
        temperature: _requireString(json['temperature'], 'temperature'),
        petSafety: _requireString(json['petSafety'], 'petSafety'),
      );
}

class DailyFlowerBeliefContent {
  const DailyFlowerBeliefContent({required this.locales});

  final Map<String, DailyFlowerBeliefLocaleContent> locales;

  factory DailyFlowerBeliefContent.fromJson(Map<String, Object?> json) {
    final localesJson = _requireMap(json['locales'], 'locales');

    final locales = <String, DailyFlowerBeliefLocaleContent>{};
    for (final MapEntry(key: rawLocale, value: rawContent)
        in localesJson.entries) {
      locales[_normalizeLocaleKey(rawLocale)] =
          DailyFlowerBeliefLocaleContent.fromJson(
        _requireMap(rawContent, 'locales.$rawLocale'),
      );
    }
    if (locales.isEmpty) {
      throw const FormatException(
        'DailyFlowerBeliefContent.locales must not be empty',
      );
    }

    return DailyFlowerBeliefContent(locales: locales);
  }
}

class DailyFlowerBeliefLocaleContent {
  const DailyFlowerBeliefLocaleContent({
    required this.meaningKeywords,
    required this.symbolism,
    required this.appreciation,
    required this.disclaimer,
  });

  final List<String> meaningKeywords;
  final String symbolism;
  final String appreciation;
  final String? disclaimer;

  factory DailyFlowerBeliefLocaleContent.fromJson(Map<String, Object?> json) =>
      DailyFlowerBeliefLocaleContent(
        meaningKeywords:
            _requireList(json['meaningKeywords'], 'meaningKeywords')
                .map((kw) => _requireString(kw, 'meaningKeywords[]'))
                .toList(growable: false),
        symbolism: _requireString(json['symbolism'], 'symbolism'),
        appreciation: _requireString(json['appreciation'], 'appreciation'),
        disclaimer: json['disclaimer'] == null
            ? null
            : _requireString(json['disclaimer'], 'disclaimer'),
      );
}

Map<String, Object?> _requireMap(Object? value, String path) {
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Expected object at "$path"');
}

List<Object?> _requireList(Object? value, String path) {
  if (value is List<Object?>) {
    return value;
  }
  throw FormatException('Expected array at "$path"');
}

String _requireString(Object? value, String path) {
  if (value is String) {
    return value;
  }
  throw FormatException('Expected string at "$path"');
}

List<String> _optionalStringList(Object? value, String path) {
  if (value == null) {
    return const [];
  }

  return _requireList(value, path)
      .map((item) => _requireString(item, '$path[]'))
      .toList(growable: false);
}

String _normalizeLocaleKey(String localeKey) =>
    localeKey.replaceAll('_', '-').toLowerCase();
