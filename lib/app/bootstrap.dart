import '../data/local/local_db.dart';
import '../data/migrations/hive_migrator.dart';
import '../data/repositories/ai_cache_repository.dart';

class BotanicaBootstrap {
  const BotanicaBootstrap._();

  static Future<void> initialize() async {
    await LocalDb.init();
    await HiveMigrator.forLocalDb().run();
    await AiCacheRepository.local().evictExpired();
  }
}
