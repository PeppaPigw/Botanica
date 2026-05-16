import 'package:hive_flutter/hive_flutter.dart';

import '../local/local_db.dart';

/// Persists the list of recently viewed species/plant-idea IDs in the Discover
/// screen so the section survives navigation and app restarts.
class RecentlyViewedRepository {
  const RecentlyViewedRepository(this._box);

  static const String _key = 'recently_viewed_species_v1';
  static const int _maxItems = 10;

  final Box<Map> _box;

  factory RecentlyViewedRepository.local() =>
      RecentlyViewedRepository(LocalDb.settingsBox);

  List<String> readIds() => _currentIds();

  Stream<List<String>> watchIds() async* {
    yield _currentIds();
    yield* _box.watch(key: _key).map((_) => _currentIds());
  }

  Future<void> markViewed(String speciesId) async {
    final id = speciesId.trim();
    if (id.isEmpty) return;

    final ids = _currentIds().toList(growable: true);
    ids.remove(id);
    ids.insert(0, id);
    if (ids.length > _maxItems) {
      ids.removeRange(_maxItems, ids.length);
    }

    await _box.put(
      _key,
      <String, dynamic>{
        'ids': ids,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
    );
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
