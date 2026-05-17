import 'dart:io';

import 'package:botanica/app/providers.dart';
import 'package:botanica/data/repositories/logs_repository.dart';
import 'package:botanica/data/repositories/plant_idea_repository.dart';
import 'package:botanica/data/repositories/species_repository.dart';
import 'package:botanica/data/repositories/tasks_repository.dart';
import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/environment_snapshot.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_idea.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/garden/garden_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/src/hive_impl.dart';
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

class _Fixture {
  _Fixture({
    required this.dir,
    required this.hiveInstance,
    required this.tasksRepo,
    required this.logsRepo,
    required this.speciesRepo,
    required this.ideaRepo,
    required this.plants,
  });
  final Directory dir;
  final HiveImpl hiveInstance;
  final TasksRepository tasksRepo;
  final LogsRepository logsRepo;
  final SpeciesRepository speciesRepo;
  final PlantIdeaRepository ideaRepo;
  final List<Plant> plants;
}

Plant _plant(String id, String nickname, String room) => Plant(
      id: id,
      nickname: nickname,
      speciesId: 'species_$id',
      room: room,
      environmentMode: EnvironmentMode.indoor,
      coverAsset: 'assets/placeholders/species/unknown.png',
      createdAt: DateTime(2026, 3, 7),
      meta: const PlantMeta(),
    );

Species _species(String id) => Species(
      id: id,
      scientificName: 'Plantae $id',
      commonNamesByLocale: <String, List<String>>{
        'en': <String>[id]
      },
      difficulty: 'easy',
      petSafe: true,
      light: 'bright_indirect',
      careDefaults: const CareDefaults(
        waterBaseDays: 7,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
    );

Future<_Fixture> _createFixture() async {
  final dir = await Directory.systemTemp.createTemp('botanica_garden_batch_');
  final hiveInstance = HiveImpl()..init(dir.path);
  final suffix = DateTime.now().microsecondsSinceEpoch.toString();
  final tasksBox = await hiveInstance.openBox<Map>('tasks_$suffix');
  final logsBox = await hiveInstance.openBox<Map>('logs_$suffix');
  final tasksRepo = TasksRepository(tasksBox);
  final logsRepo = LogsRepository(logsBox);

  final plants = <Plant>[
    _plant('a', 'Aloe', 'Living room'),
    _plant('b', 'Fern', 'Living room'),
    _plant('c', 'Pothos', 'Bedroom'),
  ];
  final current = DateTime.now();
  final now = DateTime(current.year, current.month, current.day, 10);
  await tasksRepo.upsert(TaskInstance(
      id: 'due_a',
      plantId: 'a',
      type: TaskType.water,
      dueAt: now,
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: const []));
  await tasksRepo.upsert(TaskInstance(
      id: 'due_b',
      plantId: 'b',
      type: TaskType.water,
      dueAt: now.subtract(const Duration(days: 1)),
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: const []));
  await tasksRepo.upsert(TaskInstance(
      id: 'future_b',
      plantId: 'b',
      type: TaskType.water,
      dueAt: now.add(const Duration(days: 3)),
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: const []));
  await tasksRepo.upsert(TaskInstance(
      id: 'other_room',
      plantId: 'c',
      type: TaskType.water,
      dueAt: now,
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: const []));

  return _Fixture(
    dir: dir,
    hiveInstance: hiveInstance,
    tasksRepo: tasksRepo,
    logsRepo: logsRepo,
    speciesRepo: _FakeSpeciesRepository(<Species>[
      _species('species_a'),
      _species('species_b'),
      _species('species_c')
    ]),
    ideaRepo: PlantIdeaRepository(loader: (_) async => '{"plants": []}'),
    plants: plants,
  );
}

Future<void> _pumpGarden(
  WidgetTester tester,
  _Fixture fixture, {
  String? initialSelectedRoom,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsControllerProvider.overrideWith(() => _TestSettingsController(
            UserSettings.defaults().copyWith(
                reminderTimePreference: ReminderTimePreference.evening))),
        plantsStreamProvider
            .overrideWith((ref) => Stream.value(fixture.plants)),
        tasksRepositoryProvider.overrideWithValue(fixture.tasksRepo),
        logsRepositoryProvider.overrideWithValue(fixture.logsRepo),
        speciesRepositoryProvider.overrideWithValue(fixture.speciesRepo),
        plantIdeaRepositoryProvider.overrideWithValue(fixture.ideaRepo),
        speciesListProvider.overrideWith((ref) async => const <Species>[]),
        plantIdeaMapProvider
            .overrideWith((ref) async => const <String, PlantIdea>{}),
        environmentSnapshotProvider.overrideWithValue(
          EnvironmentSnapshot(
            timestamp: DateTime(2026, 3, 7),
            tempC: 22,
            humidity: 50,
            weatherCode: 1,
          ),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GardenScreen(initialSelectedRoom: initialSelectedRoom),
        ),
      ),
    ),
  );
  await _settleUi(tester);
}

Future<void> _settleUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _waitForFinder(WidgetTester tester, Finder finder,
    {int attempts = 20}) async {
  for (var i = 0; i < attempts; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _waitForTaskStatus(
  WidgetTester tester,
  TasksRepository tasksRepo,
  String taskId,
  TaskStatus status, {
  int attempts = 20,
}) async {
  for (var i = 0; i < attempts; i++) {
    if (tasksRepo.byId(taskId)?.status == status) return;
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _scrollUntilVisible(WidgetTester tester, Finder finder) async {
  await tester.dragUntilVisible(
    finder,
    find.byType(CustomScrollView),
    const Offset(0, -300),
    maxIteration: 20,
  );
  await _settleUi(tester);
}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('water all only affects eligible tasks in selected room',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);
    final fixture = (await tester.runAsync(_createFixture))!;
    await _pumpGarden(
      tester,
      fixture,
      initialSelectedRoom: 'Living room',
    );

    final waterAllButton = find.widgetWithText(OutlinedButton, 'Water all');
    await _scrollUntilVisible(tester, waterAllButton);
    await tester.tap(waterAllButton);
    await tester.pump();
    await _waitForTaskStatus(
      tester,
      fixture.tasksRepo,
      'due_a',
      TaskStatus.done,
    );
    await _settleUi(tester);

    final watered = find.text('Watered 2 plants');
    await _waitForFinder(tester, watered);

    expect(fixture.tasksRepo.byId('due_a')!.status, TaskStatus.done);
    expect(fixture.tasksRepo.byId('due_b')!.status, TaskStatus.done);
    expect(fixture.tasksRepo.byId('future_b')!.status, TaskStatus.done);
    expect(fixture.tasksRepo.byId('other_room')!.status, TaskStatus.pending);

    final allTasks = fixture.tasksRepo.getAll();
    expect(allTasks, hasLength(6));
    final nextTasks = allTasks
        .where((task) =>
            !{'due_a', 'due_b', 'future_b', 'other_room'}.contains(task.id))
        .toList();
    expect(nextTasks, hasLength(2));
    expect(
        nextTasks.every((task) =>
            task.type == TaskType.water &&
            task.status == TaskStatus.pending &&
            task.dueAt.hour == 19),
        isTrue);
    expect(fixture.logsRepo.forPlant('a'), hasLength(1));
    expect(fixture.logsRepo.forPlant('b'), hasLength(2));
    expect(fixture.logsRepo.forPlant('c'), isEmpty);
    expect(watered, findsOneWidget);
  });
}
