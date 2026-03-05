import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/photo_entry.dart';
import '../local/local_db.dart';

class PhotosRepository {
  const PhotosRepository(this._box);

  static const _listEq = ListEquality<PhotoEntry>();

  final Box<Map> _box;

  factory PhotosRepository.local() => PhotosRepository(LocalDb.photosBox);

  List<PhotoEntry> forPlant(String plantId) {
    final items = _box.values
        .map((e) => PhotoEntry.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.plantId == plantId)
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Stream<List<PhotoEntry>> watchForPlant(String plantId) async* {
    yield forPlant(plantId);
    yield* _box.watch().map((_) => forPlant(plantId)).distinct(_listEq.equals);
  }

  Future<void> add(PhotoEntry entry) async {
    await _box.put(entry.id, entry.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    await _box.deleteAll(ids);
  }

  Future<int> deleteForPlant(String plantId) async {
    final ids = forPlant(plantId).map((p) => p.id).toList(growable: false);
    if (ids.isEmpty) return 0;
    await deleteMany(ids);
    return ids.length;
  }
}
