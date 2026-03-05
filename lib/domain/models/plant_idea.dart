class PlantIdea {
  const PlantIdea({
    required this.plantId,
    required this.scientificName,
    required this.commonNamesByLocale,
    required this.category,
    required this.imagePath,
    required this.difficulty,
    required this.petSafe,
    required this.light,
    required this.historyByLocale,
    required this.habitByLocale,
    required this.careDefaults,
    required this.externalResources,
    required this.botanical,
    required this.care,
    required this.growth,
    required this.suitability,
    required this.commonProblems,
    required this.toxicity,
    required this.tags,
  });

  final String plantId;
  final String scientificName;
  final Map<String, List<String>> commonNamesByLocale;
  final String category;
  final String imagePath;
  final String? difficulty;
  final bool petSafe;
  final String? light;
  final Map<String, String> historyByLocale;
  final Map<String, String> habitByLocale;
  final PlantIdeaCareDefaults careDefaults;
  final PlantIdeaExternalResources externalResources;
  final PlantIdeaBotanical? botanical;
  final PlantIdeaCare? care;
  final PlantIdeaGrowth? growth;
  final PlantIdeaSuitability? suitability;
  final List<String> commonProblems;
  final PlantIdeaToxicity? toxicity;
  final List<String> tags;

  String bestCommonName(String localeCode) {
    final lang = _normalizeLocale(localeCode);
    final localized = commonNamesByLocale[lang];
    if (localized != null && localized.isNotEmpty) {
      final first = localized.first.trim();
      if (first.isNotEmpty) return first;
    }

    final english = commonNamesByLocale['en'];
    if (english != null && english.isNotEmpty) {
      final first = english.first.trim();
      if (first.isNotEmpty) return first;
    }

    return plantId;
  }

  String? history(String localeCode) {
    final lang = _normalizeLocale(localeCode);
    return historyByLocale[lang] ?? historyByLocale['en'];
  }

  String? habit(String localeCode) {
    final lang = _normalizeLocale(localeCode);
    return habitByLocale[lang] ?? habitByLocale['en'];
  }

  String? localized(Map<String, String> valuesByLocale, String localeCode) {
    final lang = _normalizeLocale(localeCode);
    return valuesByLocale[lang] ?? valuesByLocale['en'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'plant_id': plantId,
        'scientific_name': scientificName,
        'common_names': commonNamesByLocale,
        'category': category,
        'image_path': imagePath,
        'difficulty': difficulty,
        'pet_safe': petSafe,
        'light': light,
        'history': historyByLocale,
        'habit': habitByLocale,
        'care_defaults': careDefaults.toJson(),
        'external_resources': externalResources.toJson(),
        if (botanical != null) 'botanical': botanical!.toJson(),
        if (care != null) 'care': care!.toJson(),
        if (growth != null) 'growth': growth!.toJson(),
        if (suitability != null) 'suitability': suitability!.toJson(),
        if (commonProblems.isNotEmpty) 'common_problems': commonProblems,
        if (toxicity != null) 'toxicity': toxicity!.toJson(),
        if (tags.isNotEmpty) 'tags': tags,
      };

  static PlantIdea fromJson(Map<String, dynamic> json) {
    final commonNames = _stringListMap(json['common_names']);
    final history = _stringMap(json['history']);
    final habit = _stringMap(json['habit']);
    final botanical = PlantIdeaBotanical.fromJson(json['botanical']);
    final care = PlantIdeaCare.fromJson(json['care']);
    final growth = PlantIdeaGrowth.fromJson(json['growth']);
    final suitability = PlantIdeaSuitability.fromJson(json['suitability']);
    final commonProblems = _stringList(json['common_problems']);
    final toxicity = PlantIdeaToxicity.fromJson(json['toxicity']);
    final tags = _stringList(json['tags']);
    return PlantIdea(
      plantId: (json['plant_id'] as String?)?.trim() ?? 'unknown',
      scientificName: (json['scientific_name'] as String?)?.trim() ?? '',
      commonNamesByLocale: commonNames,
      category: (json['category'] as String?)?.trim() ?? 'indoor',
      imagePath: (json['image_path'] as String?)?.trim() ?? '',
      difficulty: (json['difficulty'] as String?)?.trim(),
      petSafe: (json['pet_safe'] as bool?) ?? false,
      light: (json['light'] as String?)?.trim(),
      historyByLocale: history,
      habitByLocale: habit,
      careDefaults: PlantIdeaCareDefaults.fromJson(
        _map(json['care_defaults']),
      ),
      externalResources: PlantIdeaExternalResources.fromJson(
        _map(json['external_resources']),
      ),
      botanical: botanical,
      care: care,
      growth: growth,
      suitability: suitability,
      commonProblems: commonProblems,
      toxicity: toxicity,
      tags: tags,
    );
  }
}

class PlantIdeaBotanical {
  const PlantIdeaBotanical({
    required this.family,
    required this.genus,
    required this.order,
    required this.nativeRange,
    required this.nativeHabitat,
    required this.rank,
  });

  final String? family;
  final String? genus;
  final String? order;
  final String? nativeRange;
  final String? nativeHabitat;
  final String? rank;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'family': family,
        'genus': genus,
        'order': order,
        'native_range': nativeRange,
        'native_habitat': nativeHabitat,
        'rank': rank,
      };

  static PlantIdeaBotanical? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);

    String? text(Object? value) {
      final v = value?.toString().trim() ?? '';
      return v.isEmpty ? null : v;
    }

    String? localizedText(Object? value) {
      if (value == null) return null;
      if (value is String) return text(value);

      // The PlantIdea library uses locale maps for some fields, e.g.
      // {"en": "Unknown / needs confirmation"}.
      if (value is Map) {
        final map = Map<dynamic, dynamic>.from(value);
        final en = text(map['en']);
        if (en != null) return en;
        for (final v in map.values) {
          final candidate = text(v);
          if (candidate != null) return candidate;
        }
        return null;
      }

      if (value is List) {
        final parts = value
            .map((e) => text(e))
            .whereType<String>()
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
        if (parts.isEmpty) return null;
        return parts.join(', ');
      }

      return text(value);
    }

    return PlantIdeaBotanical(
      family: text(json['family']),
      genus: text(json['genus']),
      order: text(json['order']),
      nativeRange: localizedText(json['native_range']),
      nativeHabitat: localizedText(json['native_habitat']),
      rank: text(json['rank']),
    );
  }
}

class PlantIdeaCare {
  const PlantIdeaCare({
    required this.temperatureC,
    required this.humidityPct,
    required this.soil,
    required this.watering,
    required this.fertilizing,
    required this.pruning,
    required this.pestsAndDiseases,
    required this.extremeWeather,
    required this.climateStrategies,
  });

  final PlantIdeaTemperatureC? temperatureC;
  final PlantIdeaHumidityPct? humidityPct;
  final PlantIdeaSoil? soil;
  final PlantIdeaWatering? watering;
  final PlantIdeaFertilizing? fertilizing;
  final PlantIdeaPruning? pruning;
  final PlantIdeaPestsAndDiseases? pestsAndDiseases;
  final PlantIdeaExtremeWeather? extremeWeather;
  final PlantIdeaClimateStrategies? climateStrategies;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (temperatureC != null) 'temperature_c': temperatureC!.toJson(),
        if (humidityPct != null) 'humidity_pct': humidityPct!.toJson(),
        if (soil != null) 'soil': soil!.toJson(),
        if (watering != null) 'watering': watering!.toJson(),
        if (fertilizing != null) 'fertilizing': fertilizing!.toJson(),
        if (pruning != null) 'pruning': pruning!.toJson(),
        if (pestsAndDiseases != null)
          'pests_and_diseases': pestsAndDiseases!.toJson(),
        if (extremeWeather != null) 'extreme_weather': extremeWeather!.toJson(),
        if (climateStrategies != null)
          'climate_strategies': climateStrategies!.toJson(),
      };

  static PlantIdeaCare? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaCare(
      temperatureC: PlantIdeaTemperatureC.fromJson(json['temperature_c']),
      humidityPct: PlantIdeaHumidityPct.fromJson(json['humidity_pct']),
      soil: PlantIdeaSoil.fromJson(json['soil']),
      watering: PlantIdeaWatering.fromJson(json['watering']),
      fertilizing: PlantIdeaFertilizing.fromJson(json['fertilizing']),
      pruning: PlantIdeaPruning.fromJson(json['pruning']),
      pestsAndDiseases:
          PlantIdeaPestsAndDiseases.fromJson(json['pests_and_diseases']),
      extremeWeather: PlantIdeaExtremeWeather.fromJson(json['extreme_weather']),
      climateStrategies:
          PlantIdeaClimateStrategies.fromJson(json['climate_strategies']),
    );
  }
}

class PlantIdeaGrowth {
  const PlantIdeaGrowth({
    required this.rate,
    required this.form,
    required this.matureSizeCm,
  });

  final String? rate;
  final String? form;
  final PlantIdeaMatureSizeCm? matureSizeCm;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'rate': rate,
        'form': form,
        if (matureSizeCm != null) 'mature_size_cm': matureSizeCm!.toJson(),
      };

  static PlantIdeaGrowth? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaGrowth(
      rate: (json['rate'] as String?)?.trim(),
      form: (json['form'] as String?)?.trim(),
      matureSizeCm: PlantIdeaMatureSizeCm.fromJson(json['mature_size_cm']),
    );
  }
}

class PlantIdeaMatureSizeCm {
  const PlantIdeaMatureSizeCm({
    required this.heightCm,
    required this.spreadCm,
  });

  final PlantIdeaIntRange? heightCm;
  final PlantIdeaIntRange? spreadCm;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (heightCm != null) 'height_cm': heightCm!.toJson(),
        if (spreadCm != null) 'spread_cm': spreadCm!.toJson(),
      };

  static PlantIdeaMatureSizeCm? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaMatureSizeCm(
      heightCm: PlantIdeaIntRange.fromJson(json['height_cm']),
      spreadCm: PlantIdeaIntRange.fromJson(json['spread_cm']),
    );
  }
}

class PlantIdeaSuitability {
  const PlantIdeaSuitability({
    required this.indoor,
    required this.outdoor,
    required this.container,
    required this.ground,
    required this.usdaZones,
  });

  final bool? indoor;
  final bool? outdoor;
  final bool? container;
  final bool? ground;
  final PlantIdeaIntRange? usdaZones;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'indoor': indoor,
        'outdoor': outdoor,
        'container': container,
        'ground': ground,
        if (usdaZones != null) 'usda_zones': usdaZones!.toJson(),
      };

  static PlantIdeaSuitability? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaSuitability(
      indoor: json['indoor'] as bool?,
      outdoor: json['outdoor'] as bool?,
      container: json['container'] as bool?,
      ground: json['ground'] as bool?,
      usdaZones: PlantIdeaIntRange.fromJson(json['usda_zones']),
    );
  }
}

class PlantIdeaToxicity {
  const PlantIdeaToxicity({
    required this.pets,
    required this.humans,
    required this.notesByLocale,
  });

  final String? pets;
  final String? humans;
  final Map<String, String> notesByLocale;

  String? notes(String localeCode) {
    final lang = _normalizeLocale(localeCode);
    return notesByLocale[lang] ?? notesByLocale['en'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'pets': pets,
        'humans': humans,
        'notes': notesByLocale,
      };

  static PlantIdeaToxicity? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaToxicity(
      pets: (json['pets'] as String?)?.trim(),
      humans: (json['humans'] as String?)?.trim(),
      notesByLocale: _stringMap(json['notes']),
    );
  }
}

class PlantIdeaTemperatureC {
  const PlantIdeaTemperatureC({
    required this.ideal,
    required this.tolerates,
  });

  final PlantIdeaIntRange? ideal;
  final PlantIdeaIntRange? tolerates;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (ideal != null) 'ideal': ideal!.toJson(),
        if (tolerates != null) 'tolerates': tolerates!.toJson(),
      };

  static PlantIdeaTemperatureC? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaTemperatureC(
      ideal: PlantIdeaIntRange.fromJson(json['ideal']),
      tolerates: PlantIdeaIntRange.fromJson(json['tolerates']),
    );
  }
}

class PlantIdeaHumidityPct {
  const PlantIdeaHumidityPct({required this.ideal});

  final PlantIdeaIntRange? ideal;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (ideal != null) 'ideal': ideal!.toJson(),
      };

  static PlantIdeaHumidityPct? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaHumidityPct(
      ideal: PlantIdeaIntRange.fromJson(json['ideal']),
    );
  }
}

class PlantIdeaSoil {
  const PlantIdeaSoil({
    required this.mix,
    required this.ph,
  });

  final String? mix;
  final PlantIdeaDoubleRange? ph;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mix': mix,
        if (ph != null) 'ph': ph!.toJson(),
      };

  static PlantIdeaSoil? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaSoil(
      mix: (json['mix'] as String?)?.trim(),
      ph: PlantIdeaDoubleRange.fromJson(json['ph']),
    );
  }
}

class PlantIdeaWatering {
  const PlantIdeaWatering({
    required this.method,
    required this.growingSeasonDays,
    required this.dormantSeasonDays,
    required this.notesByLocale,
  });

  final String? method;
  final PlantIdeaIntRange? growingSeasonDays;
  final PlantIdeaIntRange? dormantSeasonDays;
  final Map<String, String> notesByLocale;

  String? notes(String localeCode) {
    final lang = _normalizeLocale(localeCode);
    return notesByLocale[lang] ?? notesByLocale['en'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method,
        if (growingSeasonDays != null)
          'growing_season_days': growingSeasonDays!.toJson(),
        if (dormantSeasonDays != null)
          'dormant_season_days': dormantSeasonDays!.toJson(),
        if (notesByLocale.isNotEmpty) 'notes': notesByLocale,
      };

  static PlantIdeaWatering? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaWatering(
      method: (json['method'] as String?)?.trim(),
      growingSeasonDays:
          PlantIdeaIntRange.fromJson(json['growing_season_days']),
      dormantSeasonDays:
          PlantIdeaIntRange.fromJson(json['dormant_season_days']),
      notesByLocale: _stringMap(json['notes']),
    );
  }
}

class PlantIdeaFertilizing {
  const PlantIdeaFertilizing({
    required this.growingSeasonDays,
    required this.dormantSeasonDays,
    required this.notesByLocale,
  });

  final int? growingSeasonDays;
  final int? dormantSeasonDays;
  final Map<String, String> notesByLocale;

  String? notes(String localeCode) {
    final lang = _normalizeLocale(localeCode);
    return notesByLocale[lang] ?? notesByLocale['en'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'growing_season_days': growingSeasonDays,
        'dormant_season_days': dormantSeasonDays,
        if (notesByLocale.isNotEmpty) 'notes': notesByLocale,
      };

  static PlantIdeaFertilizing? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaFertilizing(
      growingSeasonDays: (json['growing_season_days'] as num?)?.toInt(),
      dormantSeasonDays: (json['dormant_season_days'] as num?)?.toInt(),
      notesByLocale: _stringMap(json['notes']),
    );
  }
}

class PlantIdeaPruning {
  const PlantIdeaPruning({
    required this.whenByLocale,
    required this.howByLocale,
  });

  final Map<String, String> whenByLocale;
  final Map<String, String> howByLocale;

  String? when(String localeCode) {
    final lang = _normalizeLocale(localeCode);
    return whenByLocale[lang] ?? whenByLocale['en'];
  }

  String? how(String localeCode) {
    final lang = _normalizeLocale(localeCode);
    return howByLocale[lang] ?? howByLocale['en'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (whenByLocale.isNotEmpty) 'when': whenByLocale,
        if (howByLocale.isNotEmpty) 'how': howByLocale,
      };

  static PlantIdeaPruning? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaPruning(
      whenByLocale: _stringMap(json['when']),
      howByLocale: _stringMap(json['how']),
    );
  }
}

class PlantIdeaPestsAndDiseases {
  const PlantIdeaPestsAndDiseases({
    required this.commonPests,
    required this.commonDiseases,
    required this.prevention,
  });

  final List<String> commonPests;
  final List<String> commonDiseases;
  final List<String> prevention;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (commonPests.isNotEmpty) 'common_pests': commonPests,
        if (commonDiseases.isNotEmpty) 'common_diseases': commonDiseases,
        if (prevention.isNotEmpty) 'prevention': prevention,
      };

  static PlantIdeaPestsAndDiseases? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaPestsAndDiseases(
      commonPests: _stringList(json['common_pests']),
      commonDiseases: _stringList(json['common_diseases']),
      prevention: _stringList(json['prevention']),
    );
  }
}

class PlantIdeaExtremeWeather {
  const PlantIdeaExtremeWeather({
    required this.heatwave,
    required this.frost,
    required this.stormActions,
    required this.heavyRainActions,
  });

  final PlantIdeaHeatwave? heatwave;
  final PlantIdeaFrost? frost;
  final List<String> stormActions;
  final List<String> heavyRainActions;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (heatwave != null) 'heatwave': heatwave!.toJson(),
        if (frost != null) 'frost': frost!.toJson(),
        if (stormActions.isNotEmpty)
          'storm': <String, dynamic>{
            'actions': stormActions,
          },
        if (heavyRainActions.isNotEmpty)
          'heavy_rain': <String, dynamic>{
            'actions': heavyRainActions,
          },
      };

  static PlantIdeaExtremeWeather? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final storm = _map(json['storm']);
    final heavyRain = _map(json['heavy_rain']);
    return PlantIdeaExtremeWeather(
      heatwave: PlantIdeaHeatwave.fromJson(json['heatwave']),
      frost: PlantIdeaFrost.fromJson(json['frost']),
      stormActions: _stringList(storm['actions']),
      heavyRainActions: _stringList(heavyRain['actions']),
    );
  }
}

class PlantIdeaHeatwave {
  const PlantIdeaHeatwave({
    required this.riskAboveC,
    required this.actions,
  });

  final int? riskAboveC;
  final List<String> actions;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'risk_above_c': riskAboveC,
        if (actions.isNotEmpty) 'actions': actions,
      };

  static PlantIdeaHeatwave? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaHeatwave(
      riskAboveC: (json['risk_above_c'] as num?)?.toInt(),
      actions: _stringList(json['actions']),
    );
  }
}

class PlantIdeaFrost {
  const PlantIdeaFrost({
    required this.riskBelowC,
    required this.actions,
  });

  final int? riskBelowC;
  final List<String> actions;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'risk_below_c': riskBelowC,
        if (actions.isNotEmpty) 'actions': actions,
      };

  static PlantIdeaFrost? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaFrost(
      riskBelowC: (json['risk_below_c'] as num?)?.toInt(),
      actions: _stringList(json['actions']),
    );
  }
}

class PlantIdeaClimateStrategies {
  const PlantIdeaClimateStrategies({
    required this.hotDry,
    required this.coolWet,
  });

  final List<String> hotDry;
  final List<String> coolWet;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (hotDry.isNotEmpty) 'hot_dry': hotDry,
        if (coolWet.isNotEmpty) 'cool_wet': coolWet,
      };

  static PlantIdeaClimateStrategies? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return PlantIdeaClimateStrategies(
      hotDry: _stringList(json['hot_dry']),
      coolWet: _stringList(json['cool_wet']),
    );
  }
}

class PlantIdeaIntRange {
  const PlantIdeaIntRange({required this.min, required this.max});

  final int min;
  final int max;

  Map<String, dynamic> toJson() => <String, dynamic>{'min': min, 'max': max};

  static PlantIdeaIntRange? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final min = (json['min'] as num?)?.toInt();
    final max = (json['max'] as num?)?.toInt();
    if (min == null || max == null) return null;
    return PlantIdeaIntRange(min: min, max: max);
  }
}

class PlantIdeaDoubleRange {
  const PlantIdeaDoubleRange({required this.min, required this.max});

  final double min;
  final double max;

  Map<String, dynamic> toJson() => <String, dynamic>{'min': min, 'max': max};

  static PlantIdeaDoubleRange? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final min = (json['min'] as num?)?.toDouble();
    final max = (json['max'] as num?)?.toDouble();
    if (min == null || max == null) return null;
    return PlantIdeaDoubleRange(min: min, max: max);
  }
}

class PlantIdeaCareDefaults {
  const PlantIdeaCareDefaults({
    required this.waterBaseDays,
    required this.fertilizeBaseDays,
    required this.mistBaseDays,
    required this.rotateBaseDays,
    required this.pruneBaseDays,
  });

  final int waterBaseDays;
  final int fertilizeBaseDays;
  final int mistBaseDays;
  final int rotateBaseDays;
  final int pruneBaseDays;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'waterBaseDays': waterBaseDays,
        'fertilizeBaseDays': fertilizeBaseDays,
        'mistBaseDays': mistBaseDays,
        'rotateBaseDays': rotateBaseDays,
        'pruneBaseDays': pruneBaseDays,
      };

  static PlantIdeaCareDefaults fromJson(Map<String, dynamic> json) {
    return PlantIdeaCareDefaults(
      waterBaseDays: (json['waterBaseDays'] as num?)?.toInt() ?? 7,
      fertilizeBaseDays: (json['fertilizeBaseDays'] as num?)?.toInt() ?? 30,
      mistBaseDays: (json['mistBaseDays'] as num?)?.toInt() ?? 0,
      rotateBaseDays: (json['rotateBaseDays'] as num?)?.toInt() ?? 14,
      pruneBaseDays: (json['pruneBaseDays'] as num?)?.toInt() ?? 90,
    );
  }
}

class PlantIdeaExternalResources {
  const PlantIdeaExternalResources({
    required this.wikipedia,
    required this.youtubeSearch,
    required this.baiduBaikeSearch,
    required this.bilibiliSearch,
    required this.gbif,
    required this.careGuide,
  });

  final String? wikipedia;
  final String? youtubeSearch;
  final String? baiduBaikeSearch;
  final String? bilibiliSearch;
  final String? gbif;
  final String? careGuide;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'wikipedia': wikipedia,
        'youtube_search': youtubeSearch,
        'baidu_baike_search': baiduBaikeSearch,
        'bilibili_search': bilibiliSearch,
        'gbif': gbif,
        'care_guide': careGuide,
      };

  static PlantIdeaExternalResources fromJson(Map<String, dynamic> json) {
    return PlantIdeaExternalResources(
      wikipedia: (json['wikipedia'] as String?)?.trim(),
      youtubeSearch: (json['youtube_search'] as String?)?.trim(),
      baiduBaikeSearch: (json['baidu_baike_search'] as String?)?.trim(),
      bilibiliSearch: (json['bilibili_search'] as String?)?.trim(),
      gbif: (json['gbif'] as String?)?.trim(),
      careGuide: (json['care_guide'] as String?)?.trim(),
    );
  }
}

String _normalizeLocale(String localeCode) {
  return localeCode.trim().toLowerCase().split('_').first.split('-').first;
}

Map<String, dynamic> _map(Object? raw) {
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const <String, dynamic>{};
}

Map<String, String> _stringMap(Object? raw) {
  if (raw is! Map) return const <String, String>{};
  final mapped = <String, String>{};
  raw.forEach((key, value) {
    final k = key?.toString().trim();
    if (k == null || k.isEmpty) return;
    final v = value?.toString().trim() ?? '';
    if (v.isEmpty) return;
    mapped[k] = v;
  });
  return mapped;
}

Map<String, List<String>> _stringListMap(Object? raw) {
  if (raw is! Map) return const <String, List<String>>{};
  final mapped = <String, List<String>>{};
  raw.forEach((key, value) {
    final k = key?.toString().trim();
    if (k == null || k.isEmpty) return;
    if (value is! List) return;
    final names = value.map((e) => e.toString()).toList(growable: false);
    mapped[k] = names;
  });
  return mapped;
}

List<String> _stringList(Object? raw) {
  if (raw is! List) return const <String>[];
  final items = <String>[];
  for (final item in raw) {
    final value = item?.toString().trim() ?? '';
    if (value.isEmpty) continue;
    items.add(value);
  }
  return items.toList(growable: false);
}
