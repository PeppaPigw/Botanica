import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/diary_entry.dart';
import '../local/local_db.dart';

class DiaryRepository {
  const DiaryRepository(this._box);

  static const _listEq = ListEquality<DiaryEntry>();

  final Box<Map> _box;

  factory DiaryRepository.local() => DiaryRepository(LocalDb.diaryBox);

  List<DiaryEntry> forPlant(String plantId) {
    final items = _box.values
        .map((e) => DiaryEntry.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.plantId == plantId)
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Stream<List<DiaryEntry>> watchForPlant(String plantId) async* {
    yield forPlant(plantId);
    yield* _box.watch().map((_) => forPlant(plantId)).distinct(_listEq.equals);
  }

  Future<void> add(DiaryEntry entry) async {
    await _box.put(entry.id, entry.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    await _box.deleteAll(ids);
  }

  Future<int> deleteForPlant(String plantId) async {
    final ids = forPlant(plantId).map((d) => d.id).toList(growable: false);
    if (ids.isEmpty) return 0;
    await deleteMany(ids);
    return ids.length;
  }
}
