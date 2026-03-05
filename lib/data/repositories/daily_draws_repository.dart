import 'package:hive_flutter/hive_flutter.dart';

import '../local/local_db.dart';

class DailyDrawsRepository {
  const DailyDrawsRepository(this._box);

  final Box<Map> _box;

  factory DailyDrawsRepository.local() =>
      DailyDrawsRepository(LocalDb.dailyDrawsBox);

  String? readTarotCardIdForDate(DateTime date) {
    final key = _keyFor('tarot', date);
    final raw = _box.get(key);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(raw);
    final value = map['cardId']?.toString();
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  Future<void> writeTarotCardIdForDate({
    required DateTime date,
    required String cardId,
  }) async {
    final key = _keyFor('tarot', date);
    final normalized = cardId.trim();
    if (normalized.isEmpty) return;

    await _box.put(
      key,
      <String, dynamic>{
        'kind': 'tarot',
        'date': _formatDateOnly(date),
        'cardId': normalized,
        'ts': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}

String _keyFor(String kind, DateTime date) =>
    'daily_draw:$kind:${_formatDateOnly(date)}';

String _formatDateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
