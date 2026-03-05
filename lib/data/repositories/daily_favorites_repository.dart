import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/daily_flower.dart';
import '../local/local_db.dart';

class DailyFavoritesRepository {
  const DailyFavoritesRepository(this._box);

  final Box<Map> _box;

  factory DailyFavoritesRepository.local() =>
      DailyFavoritesRepository(LocalDb.dailyFavoritesBox);

  String keyFor({
    required DailyFlowerEntry entry,
    required String? variantKey,
  }) {
    final day = _formatDateOnly(entry.date);
    final normalizedLocale = entry.localeCode.trim().toLowerCase();
    final normalizedVariant = (variantKey ?? '').trim().toLowerCase();
    final normalizedContentKey = entry.content.key.trim().toLowerCase();
    return <String>[
      'daily_fav_v1',
      day,
      normalizedLocale,
      entry.beliefMode.id,
      normalizedVariant,
      normalizedContentKey,
    ].join('|');
  }

  bool isSaved(String key) => _box.containsKey(key);

  Stream<Set<String>> watchSavedKeys() async* {
    yield _currentKeys();
    yield* _box.watch().map((_) => _currentKeys());
  }

  Set<String> _currentKeys() {
    return _box.keys.whereType<String>().toSet();
  }

  Future<bool> toggleSaved({
    required DailyFlowerEntry entry,
    required String? variantKey,
  }) async {
    final key = keyFor(entry: entry, variantKey: variantKey);
    if (_box.containsKey(key)) {
      await _box.delete(key);
      return false;
    }

    await _box.put(
      key,
      <String, dynamic>{
        'kind': 'daily_favorite',
        'date': _formatDateOnly(entry.date),
        'localeCode': entry.localeCode,
        'beliefMode': entry.beliefMode.id,
        'variantKey': variantKey,
        'contentKey': entry.content.key,
        'name': entry.content.name,
        'savedAt': DateTime.now().millisecondsSinceEpoch,
      },
    );
    return true;
  }
}

String _formatDateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
