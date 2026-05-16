import 'package:botanica/app/providers.dart';
import 'package:botanica/app/routing/app_router.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/data/repositories/daily_favorites_repository.dart';
import 'package:botanica/data/repositories/daily_flower_repository.dart';
import 'package:botanica/data/repositories/diary_repository.dart';
import 'package:botanica/data/repositories/logs_repository.dart';
import 'package:botanica/data/repositories/plant_idea_repository.dart';
import 'package:botanica/data/repositories/photos_repository.dart';
import 'package:botanica/data/repositories/species_repository.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/diary_entry.dart';
import 'package:botanica/domain/models/daily_flower.dart';
import 'package:botanica/domain/models/environment_snapshot.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_idea.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/add_plant/add_plant_screen.dart';
import 'package:botanica/features/calendar/calendar_screen.dart';
import 'package:botanica/features/daily/daily_screen.dart';
import 'package:botanica/features/discover/discover_screen.dart';
import 'package:botanica/features/garden/garden_screen.dart';
import 'package:botanica/features/plant_detail/plant_detail_screen.dart';
import 'package:botanica/features/profile/profile_screen.dart';
import 'package:botanica/features/species/species_detail_screen.dart';
import 'package:botanica/features/tasks/tasks_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:botanica/services/permissions/permissions_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _TestSettingsController extends SettingsController {
  _TestSettingsController(this._settings);

  UserSettings _settings;

  @override
  UserSettings build() => _settings;

  @override
  Future<void> update(UserSettings settings) async {
    _settings = settings;
    state = settings;
  }
}

class _FakePermissionsService implements PermissionsService {
  const _FakePermissionsService();

  @override
  Future<AppPermissionsSnapshot> snapshot() async =>
      const AppPermissionsSnapshot(
        notifications: AppPermissionDecision.denied,
        location: LocationPermissionSnapshot(
          serviceEnabled: true,
          decision: AppPermissionDecision.denied,
        ),
        camera: AppPermissionDecision.denied,
        photos: AppPermissionDecision.denied,
      );

  @override
  Future<AppPermissionDecision> requestNotifications() async =>
      AppPermissionDecision.denied;

  @override
  Future<LocationPermissionSnapshot> requestLocationWhenInUse() async =>
      const LocationPermissionSnapshot(
        serviceEnabled: true,
        decision: AppPermissionDecision.denied,
      );

  @override
  Future<AppPermissionDecision> requestCamera() async =>
      AppPermissionDecision.denied;

  @override
  Future<AppPermissionDecision> requestPhotos() async =>
      AppPermissionDecision.denied;

  @override
  Future<void> openSystemSettings() async {}
}

class _FakeLogsRepository implements LogsRepository {
  const _FakeLogsRepository();

  @override
  List<CareLog> all() => const <CareLog>[];

  @override
  Future<void> add(CareLog log) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> deleteMany(Iterable<String> ids) async {}

  @override
  Future<int> deleteForPlant(String plantId) async => 0;

  @override
  List<CareLog> forPlant(String plantId) => const <CareLog>[];

  @override
  Stream<List<CareLog>> watchAll() => Stream.value(const <CareLog>[]);

  @override
  Stream<List<CareLog>> watchForPlant(String plantId) =>
      Stream.value(const <CareLog>[]);
}

class _FakePhotosRepository implements PhotosRepository {
  const _FakePhotosRepository();

  @override
  List<PhotoEntry> all() => const <PhotoEntry>[];

  @override
  Future<void> add(PhotoEntry entry) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> deleteMany(Iterable<String> ids) async {}

  @override
  Future<int> deleteForPlant(String plantId) async => 0;

  @override
  List<PhotoEntry> forPlant(String plantId) => const <PhotoEntry>[];

  @override
  Stream<List<PhotoEntry>> watchAll() => Stream.value(const <PhotoEntry>[]);

  @override
  Stream<List<PhotoEntry>> watchForPlant(String plantId) =>
      Stream.value(const <PhotoEntry>[]);
}

class _FakeDiaryRepository implements DiaryRepository {
  const _FakeDiaryRepository();

  @override
  List<DiaryEntry> all() => const <DiaryEntry>[];

  @override
  Future<void> add(DiaryEntry entry) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> deleteMany(Iterable<String> ids) async {}

  @override
  Future<int> deleteForPlant(String plantId) async => 0;

  @override
  List<DiaryEntry> forPlant(String plantId) => const <DiaryEntry>[];

  @override
  Stream<List<DiaryEntry>> watchAll() => Stream.value(const <DiaryEntry>[]);

  @override
  Stream<List<DiaryEntry>> watchForPlant(String plantId) =>
      Stream.value(const <DiaryEntry>[]);
}

class _FakeSpeciesRepository extends SpeciesRepository {
  _FakeSpeciesRepository(this._species);

  final List<Species> _species;

  @override
  Future<List<Species>> getAll() async => _species;

  @override
  Future<Species?> byId(String id) async {
    for (final species in _species) {
      if (species.id == id) return species;
    }
    return null;
  }
}

class _FakePlantIdeaRepository extends PlantIdeaRepository {
  _FakePlantIdeaRepository(this._ideas);

  final Map<String, PlantIdea> _ideas;

  @override
  Future<Map<String, PlantIdea>> loadAll() async => _ideas;

  @override
  Future<PlantIdea?> byId(String id) async => _ideas[id];
}

class _FakeDailyFlowerRepository extends DailyFlowerRepository {
  _FakeDailyFlowerRepository(this._pool);

  final List<DailyFlowerContent> _pool;

  @override
  Future<List<DailyFlowerContent>> loadPool(String localeCode) async => _pool;
}

class _FakeDailyFavoritesRepository implements DailyFavoritesRepository {
  const _FakeDailyFavoritesRepository();

  @override
  String keyFor({
    required DailyFlowerEntry entry,
    required String? variantKey,
  }) =>
      '${entry.content.key}|${variantKey ?? ''}';

  @override
  bool isSaved(String key) => false;

  @override
  Future<bool> toggleSaved({
    required DailyFlowerEntry entry,
    required String? variantKey,
  }) async =>
      true;

  @override
  Stream<Set<String>> watchSavedKeys() => Stream.value(const <String>{});
}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('tab and critical sub-routes are reachable',
      (WidgetTester tester) async {
    final now = DateTime(2026, 5, 11, 9);
    final plant = Plant(
      id: 'plant-1',
      nickname: 'Aloe',
      speciesId: 'aloe_vera',
      room: 'Living room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      createdAt: now,
      meta: const PlantMeta(),
    );
    const species = Species(
      id: 'aloe_vera',
      scientificName: 'Aloe vera',
      commonNamesByLocale: {'en': ['Aloe Vera']},
      difficulty: 'easy',
      petSafe: true,
      light: 'bright',
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: 14,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
    );
    const idea = PlantIdea(
      plantId: 'aloe_vera',
      scientificName: 'Aloe vera',
      commonNamesByLocale: {'en': ['Aloe Vera']},
      category: 'indoor',
      imagePath: '',
      difficulty: 'easy',
      petSafe: true,
      light: 'bright',
      historyByLocale: {},
      habitByLocale: {},
      careDefaults: PlantIdeaCareDefaults(
        waterBaseDays: 14,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
      externalResources: PlantIdeaExternalResources(
        wikipedia: null,
        youtubeSearch: null,
        baiduBaikeSearch: null,
        bilibiliSearch: null,
        gbif: null,
        careGuide: null,
      ),
      botanical: null,
      care: null,
      growth: null,
      suitability: null,
      commonProblems: [],
      toxicity: null,
      tags: [],
    );
    const dailyFlower = DailyFlowerContent(
      key: 'peace_lily',
      name: 'Peace Lily',
      imagePath: null,
      meaningKeywords: ['calm'],
      symbolism: 'Calm growth.',
      careBasics: {'Light': 'Bright, indirect'},
      appreciation: 'Notice the leaves.',
    );
    final task = TaskInstance(
      id: 'task-1',
      plantId: plant.id,
      type: TaskType.water,
      dueAt: now,
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: const [],
    );

    final container = ProviderContainer(
      overrides: [
        settingsControllerProvider.overrideWith(
          () => _TestSettingsController(
            UserSettings.defaults().copyWith(hasCompletedOnboarding: true),
          ),
        ),
        permissionsServiceProvider.overrideWithValue(
          const _FakePermissionsService(),
        ),
        logsRepositoryProvider.overrideWithValue(const _FakeLogsRepository()),
        photosRepositoryProvider.overrideWithValue(
          const _FakePhotosRepository(),
        ),
        diaryRepositoryProvider.overrideWithValue(const _FakeDiaryRepository()),
        speciesRepositoryProvider.overrideWithValue(
          _FakeSpeciesRepository(<Species>[species]),
        ),
        plantIdeaRepositoryProvider.overrideWithValue(
          _FakePlantIdeaRepository(<String, PlantIdea>{
            idea.plantId: idea,
          }),
        ),
        dailyFlowerRepositoryProvider.overrideWithValue(
          _FakeDailyFlowerRepository(<DailyFlowerContent>[dailyFlower]),
        ),
        dailyFavoritesRepositoryProvider.overrideWithValue(
          const _FakeDailyFavoritesRepository(),
        ),
        plantsStreamProvider.overrideWith(
          (ref) => Stream.value(<Plant>[plant]),
        ),
        tasksStreamProvider.overrideWith(
          (ref) => Stream.value(<TaskInstance>[task]),
        ),
        careLogsStreamProvider.overrideWith(
          (ref) => Stream.value(const <CareLog>[]),
        ),
        careLogsForPlantProvider.overrideWith(
          (ref, plantId) => Stream.value(const <CareLog>[]),
        ),
        photoEntriesStreamProvider.overrideWith(
          (ref) => Stream.value(const <PhotoEntry>[]),
        ),
        diaryEntriesStreamProvider.overrideWith(
          (ref) => Stream.value(const <DiaryEntry>[]),
        ),
        speciesListProvider.overrideWith(
          (ref) async => <Species>[species],
        ),
        plantIdeaMapProvider.overrideWith(
          (ref) async => <String, PlantIdea>{idea.plantId: idea},
        ),
        plantIdeaListProvider.overrideWith(
          (ref) async => <PlantIdea>[idea],
        ),
        plantIdeaByIdProvider.overrideWith(
          (ref, id) async => id == idea.plantId ? idea : null,
        ),
        dailyFavoritesKeysProvider.overrideWith(
          (ref) => Stream.value(const <String>{}),
        ),
        environmentSnapshotProvider.overrideWithValue(
          EnvironmentSnapshot(
            timestamp: now,
            tempC: 22,
            humidity: 48,
            weatherCode: 1,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                accessibleNavigation: true,
                disableAnimations: true,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );

    final routes = <String, Type>{
      GardenScreen.location: GardenScreen,
      CalendarScreen.location: CalendarScreen,
      DiscoverScreen.location: DiscoverScreen,
      DailyScreen.location: DailyScreen,
      ProfileScreen.location: ProfileScreen,
      '${GardenScreen.location}/${AddPlantScreen.subLocation}': AddPlantScreen,
      '${GardenScreen.location}/${PlantDetailScreen.subLocation}'
          .replaceFirst(':id', plant.id): PlantDetailScreen,
      '${GardenScreen.location}/${TasksScreen.subLocation}': TasksScreen,
      '${DiscoverScreen.location}/${SpeciesDetailScreen.subLocation}'
          .replaceFirst(':id', species.id): SpeciesDetailScreen,
    };

    for (final entry in routes.entries) {
      router.go(entry.key);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(entry.value), findsOneWidget, reason: entry.key);
      expect(tester.takeException(), isNull, reason: entry.key);
    }
  });
}
