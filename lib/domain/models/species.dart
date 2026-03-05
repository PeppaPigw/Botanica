import 'care_defaults.dart';

class SpeciesOrigin {
  const SpeciesOrigin({
    required this.nativeRangeByLocale,
    this.notesByLocale = const <String, String>{},
  });

  final Map<String, String> nativeRangeByLocale;
  final Map<String, String> notesByLocale;

  String? nativeRange(String localeCode) =>
      _bestLocaleText(nativeRangeByLocale, localeCode);

  String? notes(String localeCode) =>
      _bestLocaleText(notesByLocale, localeCode);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'nativeRange': nativeRangeByLocale,
        if (notesByLocale.isNotEmpty) 'notes': notesByLocale,
      };

  static SpeciesOrigin? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final nativeRange = _parseLocaleTextMap(raw['nativeRange']);
    if (nativeRange.isEmpty) return null;
    return SpeciesOrigin(
      nativeRangeByLocale: nativeRange,
      notesByLocale: _parseLocaleTextMap(raw['notes']),
    );
  }
}

class SpeciesToxicity {
  const SpeciesToxicity({
    required this.pets,
    this.humans,
    this.notesByLocale = const <String, String>{},
  });

  /// Enum-like value from JSON: `pet_safe`, `toxic`, `unknown`.
  final String pets;

  /// Enum-like value from JSON: `non_toxic`, `mildly_toxic`, `toxic`, `unknown`.
  final String? humans;

  final Map<String, String> notesByLocale;

  String? notes(String localeCode) =>
      _bestLocaleText(notesByLocale, localeCode);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'pets': pets,
        if (humans != null) 'humans': humans,
        if (notesByLocale.isNotEmpty) 'notes': notesByLocale,
      };

  static SpeciesToxicity? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final pets = raw['pets']?.toString().trim() ?? '';
    if (pets.isEmpty) return null;
    return SpeciesToxicity(
      pets: pets,
      humans: raw['humans']?.toString(),
      notesByLocale: _parseLocaleTextMap(raw['notes']),
    );
  }
}

class SpeciesGrowth {
  const SpeciesGrowth({
    required this.rate,
    required this.form,
    this.notesByLocale = const <String, String>{},
  });

  /// Enum-like value from JSON: `slow`, `moderate`, `fast`, `unknown`.
  final String rate;

  /// Enum-like value from JSON: `upright`, `trailing`, `climbing`, etc.
  final String form;

  final Map<String, String> notesByLocale;

  String? notes(String localeCode) =>
      _bestLocaleText(notesByLocale, localeCode);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'rate': rate,
        'form': form,
        if (notesByLocale.isNotEmpty) 'notes': notesByLocale,
      };

  static SpeciesGrowth? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final rate = raw['rate']?.toString().trim() ?? '';
    final form = raw['form']?.toString().trim() ?? '';
    if (rate.isEmpty || form.isEmpty) return null;
    return SpeciesGrowth(
      rate: rate,
      form: form,
      notesByLocale: _parseLocaleTextMap(raw['notes']),
    );
  }
}

class SizeRangeCm {
  const SizeRangeCm({required this.min, required this.max});

  final int min;
  final int max;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'min': min,
        'max': max,
      };

  static SizeRangeCm? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final min = (raw['min'] as num?)?.toInt();
    final max = (raw['max'] as num?)?.toInt();
    if (min == null || max == null) return null;
    return SizeRangeCm(min: min, max: max);
  }
}

class SpeciesMatureSize {
  const SpeciesMatureSize({
    required this.heightCm,
    required this.spreadCm,
    this.vineLengthCm,
    this.notesByLocale = const <String, String>{},
  });

  final SizeRangeCm heightCm;
  final SizeRangeCm spreadCm;
  final SizeRangeCm? vineLengthCm;
  final Map<String, String> notesByLocale;

  String? notes(String localeCode) =>
      _bestLocaleText(notesByLocale, localeCode);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'heightCm': heightCm.toJson(),
        'spreadCm': spreadCm.toJson(),
        if (vineLengthCm != null) 'vineLengthCm': vineLengthCm!.toJson(),
        if (notesByLocale.isNotEmpty) 'notes': notesByLocale,
      };

  static SpeciesMatureSize? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final height = SizeRangeCm.fromJson(raw['heightCm']);
    final spread = SizeRangeCm.fromJson(raw['spreadCm']);
    if (height == null || spread == null) return null;
    return SpeciesMatureSize(
      heightCm: height,
      spreadCm: spread,
      vineLengthCm: SizeRangeCm.fromJson(raw['vineLengthCm']),
      notesByLocale: _parseLocaleTextMap(raw['notes']),
    );
  }
}

class Species {
  const Species({
    required this.id,
    required this.scientificName,
    required this.commonNamesByLocale,
    required this.difficulty,
    required this.petSafe,
    required this.light,
    required this.careDefaults,
    this.imagePath,
    this.historyByLocale = const <String, String>{},
    this.habitByLocale = const <String, String>{},
    this.origin,
    this.toxicity,
    this.growth,
    this.matureSize,
  });

  final String id;
  final String scientificName;
  final Map<String, List<String>> commonNamesByLocale;
  final String difficulty;
  final bool petSafe;
  final String light;
  final CareDefaults careDefaults;
  final String? imagePath;
  final Map<String, String> historyByLocale;
  final Map<String, String> habitByLocale;
  final SpeciesOrigin? origin;
  final SpeciesToxicity? toxicity;
  final SpeciesGrowth? growth;
  final SpeciesMatureSize? matureSize;

  String bestCommonName(String localeCode) {
    final localized = commonNamesByLocale[localeCode];
    if (localized != null && localized.isNotEmpty) {
      return localized.first;
    }
    final en = commonNamesByLocale['en'];
    if (en != null && en.isNotEmpty) return en.first;
    return scientificName;
  }

  String? history(String localeCode) =>
      _bestLocaleText(historyByLocale, localeCode);

  String? habit(String localeCode) =>
      _bestLocaleText(habitByLocale, localeCode);

  String? originNativeRange(String localeCode) =>
      origin?.nativeRange(localeCode);

  String? toxicityNotes(String localeCode) => toxicity?.notes(localeCode);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'scientificName': scientificName,
        'commonNames': commonNamesByLocale,
        'difficulty': difficulty,
        'petSafe': petSafe,
        'light': light,
        'careDefaults': careDefaults.toJson(),
        'imagePath': imagePath,
        'history': historyByLocale,
        'habit': habitByLocale,
        if (origin != null) 'origin': origin!.toJson(),
        if (toxicity != null) 'toxicity': toxicity!.toJson(),
        if (growth != null) 'growth': growth!.toJson(),
        if (matureSize != null) 'matureSize': matureSize!.toJson(),
      };

  static Species fromJson(Map<String, dynamic> json) => Species(
        id: json['id'] as String,
        scientificName: json['scientificName'] as String? ?? '',
        commonNamesByLocale: (json['commonNames'] as Map?) == null
            ? const <String, List<String>>{}
            : (json['commonNames'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value as List)
                      .map((e) => e.toString())
                      .toList(growable: false),
                ),
              ),
        difficulty: json['difficulty'] as String? ?? 'easy',
        petSafe: (json['petSafe'] as bool?) ?? false,
        light: json['light'] as String? ?? '',
        careDefaults: json['careDefaults'] == null
            ? CareDefaults.empty
            : CareDefaults.fromJson(
                Map<String, dynamic>.from(json['careDefaults'] as Map),
              ),
        imagePath: json['imagePath'] as String?,
        historyByLocale: (json['history'] as Map?) == null
            ? const <String, String>{}
            : (json['history'] as Map).map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              ),
        habitByLocale: (json['habit'] as Map?) == null
            ? const <String, String>{}
            : (json['habit'] as Map).map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              ),
        origin: SpeciesOrigin.fromJson(json['origin']),
        toxicity: SpeciesToxicity.fromJson(json['toxicity']),
        growth: SpeciesGrowth.fromJson(json['growth']),
        matureSize: SpeciesMatureSize.fromJson(json['matureSize']),
      );
}

Map<String, String> _parseLocaleTextMap(Object? raw) {
  if (raw is! Map) return const <String, String>{};
  return raw.map(
    (key, value) => MapEntry(key.toString(), value.toString()),
  );
}

String? _bestLocaleText(Map<String, String> map, String localeCode) {
  if (map.isEmpty) return null;
  final direct = map[localeCode];
  if (direct != null && direct.trim().isNotEmpty) return direct;
  final lang = localeCode.split('_').first.split('-').first;
  final byLang = map[lang];
  if (byLang != null && byLang.trim().isNotEmpty) return byLang;
  final en = map['en'];
  if (en != null && en.trim().isNotEmpty) return en;
  for (final value in map.values) {
    if (value.trim().isNotEmpty) return value;
  }
  return null;
}
