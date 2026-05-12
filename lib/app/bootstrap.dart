import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/local/local_db.dart';
import '../data/migrations/hive_migrator.dart';
import '../data/repositories/ai_cache_repository.dart';
import '../core/utils/app_logger.dart';

class BotanicaBootstrap {
  const BotanicaBootstrap._();

  static Future<void> initialize() async {
    await AppLogger.initialize();
    await _initializeTimezone();
    await LocalDb.init();
    await HiveMigrator.forLocalDb().run();
    AiCacheRepository.local().evictExpired().ignore();
    await AppLogger.info('bootstrap_complete');
  }

  static Future<void> _initializeTimezone() async {
    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }
}
