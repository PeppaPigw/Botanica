import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/task_instance.dart';
import '../local/local_db.dart';

class TasksRepository {
  const TasksRepository(this._box);

  static const _listEq = ListEquality<TaskInstance>();

  final Box<Map> _box;

  factory TasksRepository.local() => TasksRepository(LocalDb.tasksBox);

  List<TaskInstance> getAll() {
    return _box.values
        .map((e) => TaskInstance.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false)
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  List<TaskInstance> forPlant(String plantId) {
    return getAll().where((t) => t.plantId == plantId).toList(growable: false);
  }

  TaskInstance? byId(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return TaskInstance.fromJson(Map<String, dynamic>.from(raw));
  }

  Stream<List<TaskInstance>> watchAll() async* {
    yield getAll();
    yield* _box.watch().map((_) => getAll()).distinct(_listEq.equals);
  }

  Future<void> upsert(TaskInstance task) async {
    await _box.put(task.id, task.toJson());
  }

  Future<void> upsertMany(Iterable<TaskInstance> tasks) async {
    final map = <dynamic, Map>{};
    for (final task in tasks) {
      map[task.id] = task.toJson();
    }
    await _box.putAll(map);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    await _box.deleteAll(ids);
  }

  Future<int> deleteForPlant(String plantId) async {
    final ids = forPlant(plantId).map((t) => t.id).toList(growable: false);
    if (ids.isEmpty) return 0;
    await deleteMany(ids);
    return ids.length;
  }
}
