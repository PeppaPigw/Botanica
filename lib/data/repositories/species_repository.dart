import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/species.dart';

typedef AssetLoader = Future<String> Function(String assetKey);

class SpeciesRepository {
  SpeciesRepository({
    AssetLoader? assetLoader,
  }) : _assetLoader = assetLoader ?? rootBundle.loadString;

  final AssetLoader _assetLoader;
  List<Species>? _cache;

  Future<List<Species>> getAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await _assetLoader('assets/data/species_seed.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['species'] as List? ?? const <dynamic>[])
        .map((e) => Species.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
    _cache = list;
    return list;
  }

  Future<Species?> byId(String id) async {
    final all = await getAll();
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}
