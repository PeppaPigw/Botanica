import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/daily_flower_repository.dart';
import '../data/repositories/daily_draws_repository.dart';
import '../data/repositories/diary_repository.dart';
import '../data/repositories/daily_favorites_repository.dart';
import '../data/repositories/ai_cache_repository.dart';
import '../data/repositories/environment_repository.dart';
import '../data/repositories/logs_repository.dart';
import '../data/repositories/photos_repository.dart';
import '../data/repositories/plants_repository.dart';
import '../data/repositories/plant_idea_repository.dart';
import '../data/repositories/recently_viewed_repository.dart';
import '../data/repositories/scan_result_cache_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/species_favorites_repository.dart';
import '../data/repositories/species_repository.dart';
import '../data/repositories/tasks_repository.dart';
import '../domain/models/care_log.dart';
import '../domain/models/diary_entry.dart';
import '../domain/models/enums.dart';
import '../domain/models/environment_snapshot.dart';
import '../domain/models/photo_entry.dart';
import '../domain/models/plant.dart';
import '../domain/models/plant_idea.dart';
import '../domain/models/species.dart';
import '../domain/models/task_instance.dart';
import '../domain/models/user_settings.dart';
import '../domain/services/care_plan_engine.dart';
import '../domain/services/daily_flower_selector.dart';
import '../domain/services/plant_health_score.dart';
import '../domain/services/plant_id/fake_plant_identifier.dart';
import '../domain/services/plant_id/plant_identifier.dart';
import '../domain/services/seasonal_care_engine.dart';
import '../services/environment/environment_service.dart';
import '../services/environment/open_meteo_client.dart';
import '../services/ai/ai_config.dart';
import '../services/ai/ai_chat_client.dart';
import '../services/ai/botanica_ai_service.dart';
import '../services/permissions/permissions_service.dart';
import '../services/notifications/notifications_service.dart';
import '../services/notifications/task_reminders_syncer.dart';
import '../services/care/seasonal_task_rescheduler.dart';
import '../domain/services/plant_whisperer_score.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository.local();
});

final settingsControllerProvider =
    NotifierProvider<SettingsController, UserSettings>(SettingsController.new);

class SettingsController extends Notifier<UserSettings> {
  @override
  UserSettings build() {
    final stored = ref.read(settingsRepositoryProvider).read();

    // Normalize time-based settings on startup (streaks, date-only fields).
    //
    // This keeps UI deterministic even if old versions wrote DateTimes with a
    // non-midnight time component.
    var normalized = stored;
    final last = stored.lastCareDate;
    if (last != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(last.year, last.month, last.day);

      final daysSince = today.difference(lastDay).inDays;
      if (daysSince > 1 && stored.careStreakDays != 0 && !stored.isOnVacation) {
        normalized = normalized.copyWith(careStreakDays: 0);
      }

      if (last != lastDay) {
        normalized = normalized.copyWith(lastCareDate: lastDay);
      }
    }

    if (normalized != stored) {
      unawaited(ref.read(settingsRepositoryProvider).write(normalized));
    }

    return normalized;
  }

  Future<void> update(UserSettings settings) async {
    state = settings;
    await ref.read(settingsRepositoryProvider).write(settings);
  }

  Future<void> completeOnboarding() async {
    await update(state.copyWith(hasCompletedOnboarding: true));
  }

  Future<void> setLocaleCode(String? localeCode) async {
    await update(state.copyWith(localeCode: localeCode));
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    await update(state.copyWith(temperatureUnit: unit));
  }

  Future<void> setBeliefMode(BeliefMode mode) async {
    await update(state.copyWith(beliefMode: mode));
  }

  Future<void> setReminderTimePreference(ReminderTimePreference pref) async {
    await update(state.copyWith(reminderTimePreference: pref));
  }

  Future<void> setDynamicColorEnabled(bool enabled) async {
    await update(state.copyWith(enableDynamicColor: enabled));
  }

  Future<void> setAiInsightsEnabled(bool enabled) async {
    await update(state.copyWith(enableAiInsights: enabled));
  }

  Future<void> setVacationEnd(DateTime? endDate) async {
    await update(state.copyWith(vacationEndDate: endDate));
  }
}

final speciesRepositoryProvider = Provider<SpeciesRepository>((ref) {
  return SpeciesRepository();
});

final plantIdeaRepositoryProvider = Provider<PlantIdeaRepository>((ref) {
  return PlantIdeaRepository();
});

final plantIdeaMapProvider =
    FutureProvider<Map<String, PlantIdea>>((ref) async {
  return ref.read(plantIdeaRepositoryProvider).loadAll();
});

final plantIdeaListProvider = FutureProvider<List<PlantIdea>>((ref) async {
  final map = await ref.read(plantIdeaRepositoryProvider).loadAll();
  final list = map.values.toList(growable: true)
    ..sort((a, b) => a.plantId.compareTo(b.plantId));
  return list.toList(growable: false);
});

final plantIdeaByIdProvider = FutureProvider.family<PlantIdea?, String>(
  (ref, id) async => ref.read(plantIdeaRepositoryProvider).byId(id),
);

final plantIdentifierProvider = Provider<PlantIdentifier>((ref) {
  return const FakePlantIdentifier();
});

final speciesListProvider = FutureProvider<List<Species>>((ref) async {
  return ref.read(speciesRepositoryProvider).getAll();
});

final plantsRepositoryProvider = Provider<PlantsRepository>((ref) {
  return PlantsRepository.local();
});

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository.local();
});

final logsRepositoryProvider = Provider<LogsRepository>((ref) {
  return LogsRepository.local();
});

final photosRepositoryProvider = Provider<PhotosRepository>((ref) {
  return PhotosRepository.local();
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepository.local();
});

final dailyDrawsRepositoryProvider = Provider<DailyDrawsRepository>((ref) {
  return DailyDrawsRepository.local();
});

final dailyFavoritesRepositoryProvider =
    Provider<DailyFavoritesRepository>((ref) {
  return DailyFavoritesRepository.local();
});

final dailyFavoritesKeysProvider = StreamProvider<Set<String>>((ref) {
  return ref.read(dailyFavoritesRepositoryProvider).watchSavedKeys();
});

final speciesFavoritesRepositoryProvider =
    Provider<SpeciesFavoritesRepository>((ref) {
  return SpeciesFavoritesRepository.local();
});

final speciesFavoriteIdsProvider = StreamProvider<List<String>>((ref) {
  return ref.read(speciesFavoritesRepositoryProvider).watchIds();
});

final recentlyViewedRepositoryProvider =
    Provider<RecentlyViewedRepository>((ref) {
  return RecentlyViewedRepository.local();
});

final recentlyViewedIdsProvider = StreamProvider<List<String>>((ref) {
  return ref.read(recentlyViewedRepositoryProvider).watchIds();
});

final scanResultCacheRepositoryProvider =
    Provider<ScanResultCacheRepository>((ref) {
  return ScanResultCacheRepository.local();
});

final lastScanResultProvider = StreamProvider<CachedScanResult?>((ref) {
  return ref.read(scanResultCacheRepositoryProvider).watchLast();
});

final aiCacheRepositoryProvider = Provider<AiCacheRepository>((ref) {
  return AiCacheRepository.local();
});

final aiConfigProvider = Provider<AiConfig>((ref) {
  return AiConfig.fromEnvironment();
});

final aiChatClientProvider = Provider<AiChatClient>((ref) {
  return AiChatClient(
    config: ref.watch(aiConfigProvider),
  );
});

final botanicaAiServiceProvider = Provider<BotanicaAiService>((ref) {
  return BotanicaAiService(
    cache: ref.read(aiCacheRepositoryProvider),
    client: ref.read(aiChatClientProvider),
  );
});

final dailyFlowerRepositoryProvider = Provider<DailyFlowerRepository>((ref) {
  return DailyFlowerRepository();
});

final carePlanEngineProvider = Provider<CarePlanEngine>((ref) {
  return const CarePlanEngine();
});

final seasonalCareEngineProvider = Provider<SeasonalCareEngine>((ref) {
  return SeasonalCareEngine(ref.watch(carePlanEngineProvider));
});

final dailyFlowerSelectorProvider = Provider<DailyFlowerSelector>((ref) {
  return const DailyFlowerSelector();
});

final environmentRepositoryProvider = Provider<EnvironmentRepository>((ref) {
  return EnvironmentRepository.local();
});

final openMeteoClientProvider = Provider<OpenMeteoClient>((ref) {
  return OpenMeteoClient();
});

final environmentServiceProvider = Provider<EnvironmentService>((ref) {
  return EnvironmentService(
    repository: ref.read(environmentRepositoryProvider),
    openMeteo: ref.read(openMeteoClientProvider),
  );
});

final environmentControllerProvider =
    NotifierProvider<EnvironmentController, EnvironmentSnapshot>(
  EnvironmentController.new,
);

class EnvironmentController extends Notifier<EnvironmentSnapshot> {
  Future<void>? _inFlight;
  bool _pendingForce = false;
  bool _pendingAllowPrompt = false;

  @override
  EnvironmentSnapshot build() {
    final cached = ref.read(environmentServiceProvider).readCached();

    // Fire-and-forget refresh whenever this provider is (re)built. We rely on
    // EnvironmentService caching to avoid redundant network calls.
    unawaited(refresh());

    return cached ??
        EnvironmentSnapshot(
          timestamp: DateTime.now(),
          tempC: 24,
          humidity: 48,
        );
  }

  Future<void> refresh({
    bool force = false,
    bool allowPermissionPrompt = false,
  }) async {
    final inFlight = _inFlight;
    if (inFlight != null) {
      _pendingForce = _pendingForce || force;
      _pendingAllowPrompt = _pendingAllowPrompt || allowPermissionPrompt;
      return inFlight;
    }

    final future = _refreshInternal(
      force: force,
      allowPermissionPrompt: allowPermissionPrompt,
    );
    _inFlight = future;
    return future;
  }

  Future<void> _refreshInternal({
    required bool force,
    required bool allowPermissionPrompt,
  }) async {
    try {
      final next = await ref.read(environmentServiceProvider).getSnapshot(
            forceRefresh: force,
            allowPermissionPrompt: allowPermissionPrompt,
          );
      state = next;

      final derivedHemisphere = next.derivedHemisphere;
      final currentSettings = ref.read(settingsControllerProvider);
      if (derivedHemisphere != null) {
        if (currentSettings.hemisphere != derivedHemisphere) {
          unawaited(
            ref.read(settingsControllerProvider.notifier).update(
                  currentSettings.copyWith(hemisphere: derivedHemisphere),
                ),
          );
        }
      }

      unawaited(
        ref.read(seasonalTaskReschedulerProvider).resyncPendingTasks(
              now: DateTime.now(),
              environment: next,
              settings: currentSettings,
            ),
      );
    } finally {
      _inFlight = null;
    }

    if (_pendingForce || _pendingAllowPrompt) {
      final rerunForce = _pendingForce;
      final rerunAllowPrompt = _pendingAllowPrompt;
      _pendingForce = false;
      _pendingAllowPrompt = false;
      await refresh(force: rerunForce, allowPermissionPrompt: rerunAllowPrompt);
    }
  }
}

final notificationsServiceProvider =
    Provider<BotanicaNotificationsService>((ref) {
  return BotanicaNotificationsService(
    onNotificationTap: (plantId) {
      notificationPlantIdCallback?.call(plantId);
    },
  );
});

/// Set by the app after the router is available.
void Function(String plantId)? notificationPlantIdCallback;

/// Keeps scheduled local notifications in sync with the current task list.
///
/// Watch this provider once at app startup to activate it.
final taskRemindersSyncProvider = Provider<TaskRemindersSyncer>((ref) {
  final notificationsService = ref.read(notificationsServiceProvider);
  final syncer = TaskRemindersSyncer(
    notificationsService: notificationsService,
  );

  ref.listen(
    tasksStreamProvider,
    (_, next) => syncer.updateTasks(next.valueOrNull),
    fireImmediately: true,
  );
  ref.listen(
    plantsStreamProvider,
    (_, next) => syncer.updatePlants(next.valueOrNull),
    fireImmediately: true,
  );
  ref.listen(
    settingsControllerProvider,
    (_, next) => syncer.updateSettings(next),
    fireImmediately: true,
  );
  ref.listen(
    careLogsStreamProvider,
    (_, next) => syncer.updateLogs(next.valueOrNull),
    fireImmediately: true,
  );

  ref.onDispose(syncer.dispose);
  return syncer;
});

final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  return const DefaultPermissionsService();
});

final permissionsControllerProvider =
    AsyncNotifierProvider<PermissionsController, AppPermissionsSnapshot>(
  PermissionsController.new,
);

class PermissionsController extends AsyncNotifier<AppPermissionsSnapshot> {
  @override
  Future<AppPermissionsSnapshot> build() async {
    return ref.read(permissionsServiceProvider).snapshot();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(permissionsServiceProvider).snapshot(),
    );
  }

  Future<void> requestNotifications() async {
    await ref.read(permissionsServiceProvider).requestNotifications();
    await refresh();
  }

  Future<void> requestLocation() async {
    await ref.read(permissionsServiceProvider).requestLocationWhenInUse();
    await refresh();
    await ref.read(environmentControllerProvider.notifier).refresh(force: true);
  }

  Future<void> requestCamera() async {
    await ref.read(permissionsServiceProvider).requestCamera();
    await refresh();
  }

  Future<void> requestPhotos() async {
    await ref.read(permissionsServiceProvider).requestPhotos();
    await refresh();
  }

  Future<void> openSettings() async {
    await ref.read(permissionsServiceProvider).openSystemSettings();
  }
}

final plantsStreamProvider = StreamProvider<List<Plant>>((ref) async* {
  yield* ref.read(plantsRepositoryProvider).watchAll();
});

final tasksStreamProvider = StreamProvider<List<TaskInstance>>((ref) async* {
  yield* ref.read(tasksRepositoryProvider).watchAll();
});

final careLogsStreamProvider = StreamProvider<List<CareLog>>((ref) async* {
  yield* ref.read(logsRepositoryProvider).watchAll();
});

final photoEntriesStreamProvider =
    StreamProvider<List<PhotoEntry>>((ref) async* {
  yield* ref.read(photosRepositoryProvider).watchAll();
});

final diaryEntriesStreamProvider =
    StreamProvider<List<DiaryEntry>>((ref) async* {
  yield* ref.read(diaryRepositoryProvider).watchAll();
});

final careLogsForPlantProvider =
    StreamProvider.family<List<CareLog>, String>((ref, plantId) async* {
  yield* ref.read(logsRepositoryProvider).watchForPlant(plantId);
});

final plantHealthScoreProvider =
    Provider.family<AsyncValue<int>, String>((ref, plantId) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final logsAsync = ref.watch(careLogsForPlantProvider(plantId));

  if (tasksAsync.isLoading || logsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (tasksAsync.hasError) {
    return AsyncValue.error(
      tasksAsync.error!,
      tasksAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (logsAsync.hasError) {
    return AsyncValue.error(
      logsAsync.error!,
      logsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final tasks = tasksAsync.requireValue
      .where((t) => t.plantId == plantId)
      .toList(growable: false);
  final logs = logsAsync.requireValue;

  final score = PlantHealthScore.compute(
    allTasks: tasks,
    recentLogs: logs,
    now: DateTime.now(),
  );

  return AsyncValue.data(score);
});

final plantHealthBreakdownProvider =
    Provider.family<AsyncValue<HealthBreakdown>, String>((ref, plantId) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final logsAsync = ref.watch(careLogsForPlantProvider(plantId));

  if (tasksAsync.isLoading || logsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (tasksAsync.hasError) {
    return AsyncValue.error(
      tasksAsync.error!,
      tasksAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (logsAsync.hasError) {
    return AsyncValue.error(
      logsAsync.error!,
      logsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final tasks = tasksAsync.requireValue
      .where((t) => t.plantId == plantId)
      .toList(growable: false);
  final logs = logsAsync.requireValue;

  final breakdown = PlantHealthScore.breakdown(
    allTasks: tasks,
    recentLogs: logs,
    now: DateTime.now(),
  );

  return AsyncValue.data(breakdown);
});

final gardenHealthScoreProvider = Provider<int>((ref) {
  final plantsAsync = ref.watch(plantsStreamProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);
  final logsAsync = ref.watch(careLogsStreamProvider);

  final plants = plantsAsync.valueOrNull;
  final tasks = tasksAsync.valueOrNull;
  final logs = logsAsync.valueOrNull;

  if (plants == null || plants.isEmpty || tasks == null || logs == null) {
    return 100;
  }

  final activePlants = plants.where((p) => !p.isArchived).toList();
  if (activePlants.isEmpty) return 100;

  final now = DateTime.now();
  int total = 0;
  for (final plant in activePlants) {
    final plantTasks =
        tasks.where((t) => t.plantId == plant.id).toList(growable: false);
    final plantLogs =
        logs.where((l) => l.plantId == plant.id).toList(growable: false);
    total += PlantHealthScore.compute(
      allTasks: plantTasks,
      recentLogs: plantLogs,
      now: now,
    );
  }
  return (total / activePlants.length).round();
});

final plantWhispererScoreProvider = Provider<WhispererScore>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  final plantsAsync = ref.watch(plantsStreamProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);
  final logsAsync = ref.watch(careLogsStreamProvider);

  final plants = plantsAsync.valueOrNull ?? const [];
  final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];
  final logs = logsAsync.valueOrNull ?? const <CareLog>[];

  return PlantWhispererScore.compute(
    settings: settings,
    allLogs: logs,
    allTasks: tasks,
    plantCount: plants.length,
    now: DateTime.now(),
  );
});

final environmentSnapshotProvider = Provider<EnvironmentSnapshot>((ref) {
  return ref.watch(environmentControllerProvider);
});
