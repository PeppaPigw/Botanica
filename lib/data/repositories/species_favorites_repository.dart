import 'package:hive_flutter/hive_flutter.dart';

import '../local/local_db.dart';

class SpeciesFavoritesRepository {
  const SpeciesFavoritesRepository(this._box);

  static const String _key = 'species_favorites_v1';

  final Box<Map> _box;

  factory SpeciesFavoritesRepository.local() =>
      SpeciesFavoritesRepository(LocalDb.settingsBox);

  List<String> readIds() => _currentIds();

  Stream<List<String>> watchIds() async* {
    yield _currentIds();
    yield* _box.watch(key: _key).map((_) => _currentIds());
  }

  Future<bool> toggle(String speciesId) async {
    final id = speciesId.trim();
    if (id.isEmpty) return false;

    final ids = _currentIds().toList(growable: true);
    final existed = ids.remove(id);
    if (!existed) {
      ids.insert(0, id);
    }

    await _box.put(
      _key,
      <String, dynamic>{
        'ids': ids,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return !existed;
  }

  List<String> _currentIds() {
    final raw = _box.get(_key);
    final values = raw == null ? const <Object?>[] : raw['ids'];
    if (values is! List) return const <String>[];

    final seen = <String>{};
    final ids = <String>[];
    for (final value in values) {
      final id = value?.toString().trim() ?? '';
      if (id.isEmpty || !seen.add(id)) continue;
      ids.add(id);
    }
    return ids.toList(growable: false);
  }
}
