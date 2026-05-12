import 'dart:convert';

import 'package:botanica/app/providers.dart';
import 'package:botanica/data/repositories/photos_repository.dart';
import 'package:botanica/data/repositories/plant_idea_repository.dart';
import 'package:botanica/data/repositories/plants_repository.dart';
import 'package:botanica/data/repositories/species_repository.dart';
import 'package:botanica/data/repositories/tasks_repository.dart';
import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/environment_snapshot.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/add_plant/add_plant_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

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

class _TestSpeciesRepository extends SpeciesRepository {
  _TestSpeciesRepository(this._species);

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

class _Fixture {
  _Fixture({
    required this.plantsBox,
    required this.tasksBox,
    required this.photosBox,
    required this.plantsRepository,
    required this.tasksRepository,
    required this.photosRepository,
    required this.speciesRepository,
    required this.plantIdeaRepository,
  });

  final _MemoryBox plantsBox;
  final _MemoryBox tasksBox;
  final _MemoryBox photosBox;
  final PlantsRepository plantsRepository;
  final TasksRepository tasksRepository;
  final PhotosRepository photosRepository;
  final SpeciesRepository speciesRepository;
  final PlantIdeaRepository plantIdeaRepository;
  ProviderContainer? container;

  void dispose() {
    container?.dispose();
  }
}

class _MemoryBox implements Box<Map> {
  final _valuesByKey = <dynamic, Map>{};

  @override
  bool get isOpen => true;

  @override
  Iterable<Map> get values => _valuesByKey.values;

  @override
  Map? get(dynamic key, {Map? defaultValue}) {
    return _valuesByKey[key] ?? defaultValue;
  }

  @override
  Future<void> put(dynamic key, Map value) async {
    _valuesByKey[key] = Map<dynamic, dynamic>.from(value);
  }

  @override
  Future<void> putAll(Map<dynamic, Map> entries) async {
    for (final entry in entries.entries) {
      _valuesByKey[entry.key] = Map<dynamic, dynamic>.from(entry.value);
    }
  }

  @override
  Future<void> delete(dynamic key) async {
    _valuesByKey.remove(key);
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final key in keys) {
      _valuesByKey.remove(key);
    }
  }

  @override
  Stream<BoxEvent> watch({dynamic key}) => const Stream<BoxEvent>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _ideaJson(String id, String name) {
  return <String, dynamic>{
    'plant_id': id,
    'scientific_name': 'Monstera deliciosa',
    'common_names': <String, dynamic>{
      'en': <String>[name],
    },
    'category': 'indoor',
    'image_path': 'assets/placeholders/species/unknown.png',
    'difficulty': 'easy',
    'pet_safe': false,
    'light': 'bright_indirect',
    'history': const <String, String>{'en': 'History'},
    'habit': const <String, String>{'en': 'Habit'},
    'care_defaults': const <String, int>{
      'waterBaseDays': 6,
      'fertilizeBaseDays': 24,
      'mistBaseDays': 3,
      'rotateBaseDays': 14,
      'pruneBaseDays': 90,
    },
    'external_resources': const <String, String>{
      'wikipedia': 'https://example.com/wiki',
      'youtube_search': 'https://example.com/youtube',
      'baidu_baike_search': 'https://example.com/baike',
      'bilibili_search': 'https://example.com/bili',
      'care_guide': 'https://example.com/guide',
    },
  };
}

_Fixture _createFixture() {
  final plantsBox = _MemoryBox();
  final tasksBox = _MemoryBox();
  final photosBox = _MemoryBox();

  const species = Species(
    id: 'monstera_deliciosa',
    scientificName: 'Monstera deliciosa',
    commonNamesByLocale: <String, List<String>>{
      'en': <String>['Monstera'],
    },
    difficulty: 'easy',
    petSafe: false,
    light: 'bright_indirect',
    careDefaults: CareDefaults(
      waterBaseDays: 7,
      fertilizeBaseDays: 30,
      mistBaseDays: 0,
      rotateBaseDays: 14,
      pruneBaseDays: 90,
    ),
    imagePath: 'assets/placeholders/species/unknown.png',
  );

  return _Fixture(
    plantsBox: plantsBox,
    tasksBox: tasksBox,
    photosBox: photosBox,
    plantsRepository: PlantsRepository(plantsBox),
    tasksRepository: TasksRepository(tasksBox),
    photosRepository: PhotosRepository(photosBox),
    speciesRepository: _TestSpeciesRepository(const <Species>[species]),
    plantIdeaRepository: PlantIdeaRepository(
      loader: (_) async => jsonEncode(<String, dynamic>{
        'plants': <Map<String, dynamic>>[
          _ideaJson('monstera_deliciosa', 'Monstera'),
        ],
      }),
    ),
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required _Fixture fixture,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Garden')),
        ),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddPlantScreen(),
      ),
    ],
  );

  final container = ProviderContainer(
    overrides: [
      settingsControllerProvider.overrideWith(
        () => _TestSettingsController(UserSettings.defaults()),
      ),
      plantsRepositoryProvider.overrideWithValue(fixture.plantsRepository),
      tasksRepositoryProvider.overrideWithValue(fixture.tasksRepository),
      photosRepositoryProvider.overrideWithValue(fixture.photosRepository),
      speciesRepositoryProvider.overrideWithValue(fixture.speciesRepository),
      plantIdeaRepositoryProvider
          .overrideWithValue(fixture.plantIdeaRepository),
      environmentSnapshotProvider.overrideWithValue(
        EnvironmentSnapshot(
          timestamp: DateTime.now(),
          tempC: 22,
          humidity: 48,
        ),
      ),
    ],
  );
  fixture.container = container;

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: ThemeData(useMaterial3: true),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );

  await tester.pump();
  router.push('/add');
  await tester.pumpAndSettle();
}

Future<void> _settleAsync(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'Add Plant saves first library plant and creates initial scheduled tasks',
    (WidgetTester tester) async {
      final fixture = _createFixture();
      addTearDown(fixture.dispose);

      await _pumpApp(tester, fixture: fixture);

      await tester.tap(find.text('From library'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('add-plant-species-monstera_deliciosa')),
      );
      await tester.pumpAndSettle();

      final nicknameField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Nickname',
      );
      expect(nicknameField, findsOneWidget);
      await tester.enterText(nicknameField, 'Monty');
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('add-plant-save')));
      await tester.pump();
      await _settleAsync(tester);

      expect(find.text('Garden'), findsOneWidget);

      final plants = fixture.plantsRepository.getAll();
      expect(plants, hasLength(1));
      final plant = plants.single;
      expect(plant.nickname, 'Monty');
      expect(plant.speciesId, 'monstera_deliciosa');
      expect(plant.room, 'Living room');
      expect(plant.environmentMode, EnvironmentMode.indoor);
      expect(plant.coverAsset, 'assets/placeholders/species/unknown.png');

      final settings = fixture.container!.read(settingsControllerProvider);
      expect(settings.reminderTimePreference, ReminderTimePreference.morning);

      final tasks = fixture.tasksRepository.getAll();
      expect(tasks, hasLength(3));
      expect(
        tasks.map((task) => task.type).toSet(),
        <TaskType>{TaskType.water, TaskType.mist, TaskType.fertilize},
      );

      for (final task in tasks) {
        expect(task.plantId, plant.id);
        expect(task.status, TaskStatus.pending);
        expect(task.completedAt, isNull);
        expect(task.dueAt.hour, 9);
        expect(task.dueAt.minute, 0);
        expect(task.scheduleSnapshot, isNotNull);
        expect(task.scheduleSnapshot!.adjustedDays, greaterThan(0));
        expect(
          task.adjustmentReasonIds,
          task.scheduleSnapshot!.reasonIds,
        );
      }
    },
  );
}
