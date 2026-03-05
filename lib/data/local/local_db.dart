import 'package:hive_flutter/hive_flutter.dart';

class LocalDb {
  const LocalDb._();

  static const String settingsBoxName = 'settings';
  static const String plantsBoxName = 'plants';
  static const String tasksBoxName = 'tasks';
  static const String logsBoxName = 'logs';
  static const String photosBoxName = 'photos';
  static const String diaryBoxName = 'diary';
  static const String dailyDrawsBoxName = 'daily_draws';
  static const String dailyFavoritesBoxName = 'daily_favorites';
  static const String aiCacheBoxName = 'ai_cache';

  static bool _initialized = false;
  static Future<void>? _initFuture;

  static Box<Map>? _settingsBox;
  static Box<Map>? _plantsBox;
  static Box<Map>? _tasksBox;
  static Box<Map>? _logsBox;
  static Box<Map>? _photosBox;
  static Box<Map>? _diaryBox;
  static Box<Map>? _dailyDrawsBox;
  static Box<Map>? _dailyFavoritesBox;
  static Box<Map>? _aiCacheBox;

  static Box<Map> get settingsBox => _require(_settingsBox, settingsBoxName);
  static Box<Map> get plantsBox => _require(_plantsBox, plantsBoxName);
  static Box<Map> get tasksBox => _require(_tasksBox, tasksBoxName);
  static Box<Map> get logsBox => _require(_logsBox, logsBoxName);
  static Box<Map> get photosBox => _require(_photosBox, photosBoxName);
  static Box<Map> get diaryBox => _require(_diaryBox, diaryBoxName);
  static Box<Map> get dailyDrawsBox =>
      _require(_dailyDrawsBox, dailyDrawsBoxName);
  static Box<Map> get dailyFavoritesBox =>
      _require(_dailyFavoritesBox, dailyFavoritesBoxName);
  static Box<Map> get aiCacheBox => _require(_aiCacheBox, aiCacheBoxName);

  static Future<void> init() async {
    if (_initialized) return;
    final existing = _initFuture;
    if (existing != null) return existing;

    final future = _initInternal();
    _initFuture = future;
    return future;
  }

  static Future<void> _initInternal() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox<Map>(settingsBoxName);
    _plantsBox = await Hive.openBox<Map>(plantsBoxName);
    _tasksBox = await Hive.openBox<Map>(tasksBoxName);
    _logsBox = await Hive.openBox<Map>(logsBoxName);
    _photosBox = await Hive.openBox<Map>(photosBoxName);
    _diaryBox = await Hive.openBox<Map>(diaryBoxName);
    _dailyDrawsBox = await Hive.openBox<Map>(dailyDrawsBoxName);
    _dailyFavoritesBox = await Hive.openBox<Map>(dailyFavoritesBoxName);
    _aiCacheBox = await Hive.openBox<Map>(aiCacheBoxName);
    _initialized = true;
  }
}

Box<Map> _require(Box<Map>? box, String name) {
  if (box != null) return box;
  throw StateError(
    'LocalDb is not initialized. Call BotanicaBootstrap.initialize() before '
    'using Hive boxes (attempted to access "$name").',
  );
}
