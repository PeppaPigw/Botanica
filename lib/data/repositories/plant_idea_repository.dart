import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/plant_idea.dart';

typedef AssetLoader = Future<String> Function(String path);

class PlantIdeaRepository {
  PlantIdeaRepository({AssetLoader? loader})
      : _loader = loader ?? rootBundle.loadString;

  final AssetLoader _loader;

  Map<String, PlantIdea>? _cache;

  Future<Map<String, PlantIdea>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await _loader('assets/data/plantsidea.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw StateError('plantsidea.json root must be an object');
    }

    final plants = decoded['plants'];
    if (plants is! List) {
      throw StateError('plantsidea.json missing "plants" list');
    }

    final map = <String, PlantIdea>{};
    for (final item in plants) {
      if (item is! Map) continue;
      final entry = PlantIdea.fromJson(Map<String, dynamic>.from(item));
      map[entry.plantId] = entry;
    }

    _cache = map;
    return map;
  }

  Future<PlantIdea?> byId(String id) async {
    final all = await loadAll();
    return all[id];
  }
}
