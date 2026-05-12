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
    final boxes = await Future.wait([
      Hive.openBox<Map>(settingsBoxName),
      Hive.openBox<Map>(plantsBoxName),
      Hive.openBox<Map>(tasksBoxName),
      Hive.openBox<Map>(logsBoxName),
      Hive.openBox<Map>(photosBoxName),
      Hive.openBox<Map>(diaryBoxName),
      Hive.openBox<Map>(dailyDrawsBoxName),
      Hive.openBox<Map>(dailyFavoritesBoxName),
      Hive.openBox<Map>(aiCacheBoxName),
    ]);

    _settingsBox = boxes[0];
    _plantsBox = boxes[1];
    _tasksBox = boxes[2];
    _logsBox = boxes[3];
    _photosBox = boxes[4];
    _diaryBox = boxes[5];
    _dailyDrawsBox = boxes[6];
    _dailyFavoritesBox = boxes[7];
    _aiCacheBox = boxes[8];
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
