import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/plant.dart';
import '../local/local_db.dart';

class PlantsRepository {
  const PlantsRepository(this._box);

  static const _listEq = ListEquality<Plant>();

  final Box<Map> _box;

  factory PlantsRepository.local() => PlantsRepository(LocalDb.plantsBox);

  List<Plant> getAll() {
    return _box.values
        .map((e) => Plant.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Plant? byId(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return Plant.fromJson(Map<String, dynamic>.from(raw));
  }

  Stream<List<Plant>> watchAll() async* {
    yield getAll();
    yield* _box.watch().map((_) => getAll()).distinct(_listEq.equals);
  }

  Future<void> upsert(Plant plant) async {
    await _box.put(plant.id, plant.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    await _box.deleteAll(ids);
  }
}
