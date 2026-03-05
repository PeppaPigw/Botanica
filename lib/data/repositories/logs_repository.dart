import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/care_log.dart';
import '../local/local_db.dart';

class LogsRepository {
  const LogsRepository(this._box);

  static const _listEq = ListEquality<CareLog>();

  final Box<Map> _box;

  factory LogsRepository.local() => LogsRepository(LocalDb.logsBox);

  List<CareLog> all() {
    final logs = _box.values
        .map((e) => CareLog.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  List<CareLog> forPlant(String plantId) {
    final logs = _box.values
        .map((e) => CareLog.fromJson(Map<String, dynamic>.from(e)))
        .where((l) => l.plantId == plantId)
        .toList(growable: false)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  Stream<List<CareLog>> watchForPlant(String plantId) async* {
    yield forPlant(plantId);
    yield* _box.watch().map((_) => forPlant(plantId)).distinct(_listEq.equals);
  }

  Stream<List<CareLog>> watchAll() async* {
    yield all();
    yield* _box.watch().map((_) => all()).distinct(_listEq.equals);
  }

  Future<void> add(CareLog log) async {
    await _box.put(log.id, log.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    await _box.deleteAll(ids);
  }

  Future<int> deleteForPlant(String plantId) async {
    final ids = forPlant(plantId).map((l) => l.id).toList(growable: false);
    if (ids.isEmpty) return 0;
    await deleteMany(ids);
    return ids.length;
  }
}
