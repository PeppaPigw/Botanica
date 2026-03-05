import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/user_settings.dart';
import '../local/local_db.dart';

class SettingsRepository {
  const SettingsRepository(this._box);

  static const String _key = 'user_settings';

  final Box<Map> _box;

  factory SettingsRepository.local() => SettingsRepository(LocalDb.settingsBox);

  UserSettings read() {
    final raw = _box.get(_key);
    if (raw == null) return UserSettings.defaults();
    return UserSettings.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> write(UserSettings settings) async {
    await _box.put(_key, settings.toJson());
  }

  ValueListenable<Box<Map>> listenable() =>
      _box.listenable(keys: const <String>[_key]);
}
