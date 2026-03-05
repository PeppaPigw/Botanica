import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/environment_snapshot.dart';
import '../local/local_db.dart';

class EnvironmentRepository {
  const EnvironmentRepository(this._box);

  final Box<Map> _box;

  factory EnvironmentRepository.local() =>
      EnvironmentRepository(LocalDb.settingsBox);

  static const String _key = 'environment_snapshot_v1';

  EnvironmentSnapshot? readCached() {
    final raw = _box.get(_key);
    if (raw == null) return null;
    return EnvironmentSnapshot.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> write(EnvironmentSnapshot snapshot) async {
    await _box.put(_key, snapshot.toJson());
  }
}
