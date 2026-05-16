import 'dart:async';
import 'dart:io';

import 'package:botanica/app/providers.dart';
import 'package:botanica/data/repositories/logs_repository.dart';
import 'package:botanica/data/repositories/plant_idea_repository.dart';
import 'package:botanica/data/repositories/species_repository.dart';
import 'package:botanica/data/repositories/tasks_repository.dart';
import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/environment_snapshot.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/tasks/tasks_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
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

class _CompletionFixture {
  _CompletionFixture({
    required this.tempDir,
    required this.hiveInstance,
    required this.tasksBox,
    required this.logsBox,
    required this.tasksRepository,
    required this.logsRepository,
    required this.speciesRepository,
    required this.plantIdeaRepository,
    required this.task,
    required this.plant,
  });

  final Directory tempDir;
  final HiveImpl hiveInstance;
  final Box<Map> tasksBox;
  final Box<Map> logsBox;
  final TasksRepository tasksRepository;
  final LogsRepository logsRepository;
  final SpeciesRepository speciesRepository;
  final PlantIdeaRepository plantIdeaRepository;
  final TaskInstance task;
  final Plant plant;
  ProviderContainer? container;

  Future<void> dispose() async {
    try {
      if (tasksBox.isOpen) {
        await tasksBox.deleteFromDisk().timeout(const Duration(seconds: 1));
      }
    } catch (_) {}
    try {
      if (logsBox.isOpen) {
        await logsBox.deleteFromDisk().timeout(const Duration(seconds: 1));
      }
    } catch (_) {}
    try {
      await hiveInstance.close().timeout(const Duration(seconds: 1));
    } catch (_) {}
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  }
}

Future<_CompletionFixture> _createFixture() async {
  final tempDir =
      await Directory.systemTemp.createTemp('botanica_tasks_completion_test_');
  final hiveInstance = HiveImpl()..init(tempDir.path);

  final suffix = DateTime.now().microsecondsSinceEpoch.toString();
  final tasksBox = await hiveInstance.openBox<Map>('tasks_$suffix');
  final logsBox = await hiveInstance.openBox<Map>('logs_$suffix');
  final tasksRepository = TasksRepository(tasksBox);
  final logsRepository = LogsRepository(logsBox);

  const species = Species(
    id: 'monstera_deliciosa',
    scientificName: 'Monstera deliciosa',
    commonNamesByLocale: <String, List<String>>{
      'en': <String>['Monstera'],
    },
    difficulty: 'easy',
    petSafe: false,
    light: 'indirect',
    careDefaults: CareDefaults(
      waterBaseDays: 7,
      fertilizeBaseDays: 30,
      mistBaseDays: 3,
      rotateBaseDays: 14,
      pruneBaseDays: 90,
    ),
  );

  final now = DateTime.now();
  final plant = Plant(
    id: 'plant-1',
    nickname: 'Monty',
    speciesId: species.id,
    room: 'Living room',
    environmentMode: EnvironmentMode.indoor,
    coverAsset: null,
    createdAt: now.subtract(const Duration(days: 30)),
    meta: const PlantMeta(),
  );
  final task = TaskInstance(
    id: 'task-1',
    plantId: plant.id,
    type: TaskType.rotate,
    dueAt: now,
    status: TaskStatus.pending,
    createdAt: now,
    completedAt: null,
    adjustmentReasonIds: const <String>[],
  );

  await tasksRepository.upsert(task);

  return _CompletionFixture(
    tempDir: tempDir,
    hiveInstance: hiveInstance,
    tasksBox: tasksBox,
    logsBox: logsBox,
    tasksRepository: tasksRepository,
    logsRepository: logsRepository,
    speciesRepository: _TestSpeciesRepository(<Species>[species]),
    plantIdeaRepository: PlantIdeaRepository(
      loader: (_) async => '{"plants": []}',
    ),
    task: task,
    plant: plant,
  );
}

Future<void> _pumpTasksScreen(
  WidgetTester tester, {
  required _CompletionFixture fixture,
  UserSettings? settings,
}) async {
  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);
  final resolvedSettings = settings ??
      UserSettings.defaults().copyWith(
        reminderTimePreference: ReminderTimePreference.evening,
        careStreakDays: 1,
        lastCareDate: todayDateOnly,
      );

  final container = ProviderContainer(
    overrides: [
      tasksRepositoryProvider.overrideWithValue(fixture.tasksRepository),
      logsRepositoryProvider.overrideWithValue(fixture.logsRepository),
      plantsStreamProvider.overrideWith(
        (ref) => Stream.value(<Plant>[fixture.plant]),
      ),
      speciesRepositoryProvider.overrideWithValue(fixture.speciesRepository),
      plantIdeaRepositoryProvider
          .overrideWithValue(fixture.plantIdeaRepository),
      settingsControllerProvider.overrideWith(
        () => _TestSettingsController(resolvedSettings),
      ),
      environmentSnapshotProvider.overrideWithValue(
        EnvironmentSnapshot(
          timestamp: DateTime.now(),
          tempC: 22,
          humidity: 50,
        ),
      ),
    ],
  );
  fixture.container = container;

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TasksScreen(),
      ),
    ),
  );

  await _settleUi(tester);
}

Future<void> _settleUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1600));
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

Future<void> _drainCompletionAsync(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _waitForFinder(
  WidgetTester tester,
  Finder finder, {
  int attempts = 20,
}) async {
  for (var i = 0; i < attempts; i++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pump(const Duration(milliseconds: 50));
  }
}

UserSettings _currentSettings(WidgetTester tester) {
  final element = tester.element(find.byType(TasksScreen));
  final container = ProviderScope.containerOf(element);
  return container.read(settingsControllerProvider);
}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  testWidgets(
      'Tasks done action completes rotate task, schedules next one, logs care, and updates the list',
      (WidgetTester tester) async {
    final fixture = (await tester.runAsync(_createFixture))!;
    addTearDown(() {
      fixture.container?.dispose();
      unawaited(fixture.dispose());
    });

    await _pumpTasksScreen(tester, fixture: fixture);

    final tileFinder = find.byKey(ValueKey('task-${fixture.task.id}'));
    expect(tileFinder, findsOneWidget);

    await tester.drag(tileFinder, const Offset(320, 0));
    await _settleUi(tester);

    final doneFinder =
        find.byKey(ValueKey('task-action-${fixture.task.id}-done'));
    expect(doneFinder, findsOneWidget);

    final l10n = AppLocalizations.of(tester.element(find.byType(TasksScreen)));
    final beforeTap = DateTime.now();
    await tester.tap(doneFinder);
    await tester.pump();
    await _drainCompletionAsync(tester);
    await _settleUi(tester);
    final afterTap = DateTime.now();

    final originalTask = fixture.tasksRepository.byId(fixture.task.id)!;
    expect(originalTask.status, TaskStatus.done);
    expect(originalTask.completedAt, isNotNull);
    expect(
      originalTask.completedAt!.isBefore(
        beforeTap.subtract(const Duration(seconds: 2)),
      ),
      isFalse,
    );
    expect(
      originalTask.completedAt!.isAfter(
        afterTap.add(const Duration(seconds: 2)),
      ),
      isFalse,
    );

    final allTasks = fixture.tasksRepository.getAll();
    expect(allTasks, hasLength(2));

    final nextTask = allTasks.singleWhere((task) => task.id != fixture.task.id);
    expect(nextTask.id, isNot(originalTask.id));
    expect(nextTask.plantId, fixture.plant.id);
    expect(nextTask.type, TaskType.rotate);
    expect(nextTask.status, TaskStatus.pending);
    expect(nextTask.completedAt, isNull);
    expect(nextTask.dueAt.hour, 19);
    expect(nextTask.dueAt.minute, 0);

    final expectedDateFromBefore =
        _dateOnly(beforeTap).add(const Duration(days: 14));
    final expectedDateFromAfter =
        _dateOnly(afterTap).add(const Duration(days: 14));
    expect(
      _sameDate(nextTask.dueAt, expectedDateFromBefore) ||
          _sameDate(nextTask.dueAt, expectedDateFromAfter),
      isTrue,
    );

    final logs = fixture.logsRepository.forPlant(fixture.plant.id);
    expect(logs, hasLength(1));
    expect(logs.single.type, TaskType.rotate);

    final completionText =
        find.text('${l10n.commonDone} · ${fixture.plant.nickname}');
    await _waitForFinder(tester, completionText);
    expect(completionText, findsOneWidget);
    expect(find.byKey(ValueKey('task-${fixture.task.id}')), findsNothing);
  });

  testWidgets(
      'Tasks completion snackbar undo restores task, log, next task, and settings',
      (WidgetTester tester) async {
    final fixture = (await tester.runAsync(_createFixture))!;
    addTearDown(() {
      fixture.container?.dispose();
      unawaited(fixture.dispose());
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final originalSettings = UserSettings.defaults().copyWith(
      reminderTimePreference: ReminderTimePreference.evening,
      careStreakDays: 1,
      lastCareDate: today.subtract(const Duration(days: 1)),
    );

    await _pumpTasksScreen(
      tester,
      fixture: fixture,
      settings: originalSettings,
    );

    final tileFinder = find.byKey(ValueKey('task-${fixture.task.id}'));
    expect(tileFinder, findsOneWidget);

    await tester.drag(tileFinder, const Offset(320, 0));
    await _settleUi(tester);

    final doneFinder =
        find.byKey(ValueKey('task-action-${fixture.task.id}-done'));
    expect(doneFinder, findsOneWidget);

    final l10n = AppLocalizations.of(tester.element(find.byType(TasksScreen)));

    await tester.tap(doneFinder);
    await tester.pump();
    await _drainCompletionAsync(tester);
    await _settleUi(tester);

    final undoText = find.text(l10n.commonUndo);
    await _waitForFinder(tester, undoText);
    expect(undoText, findsOneWidget);
    expect(find.byKey(ValueKey('task-${fixture.task.id}')), findsNothing);

    await tester.tap(undoText);
    await tester.pump();
    await _drainCompletionAsync(tester);
    await _drainCompletionAsync(tester);
    await _settleUi(tester);

    final allTasks = fixture.tasksRepository.getAll();
    expect(allTasks, hasLength(1));

    final restoredTask = fixture.tasksRepository.byId(fixture.task.id)!;
    expect(restoredTask.status, TaskStatus.pending);
    expect(restoredTask.completedAt, fixture.task.completedAt);
    expect(restoredTask.dueAt, fixture.task.dueAt);

    final logs = fixture.logsRepository.forPlant(fixture.plant.id);
    expect(logs, isEmpty);

    expect(_currentSettings(tester), originalSettings);
    expect(find.byKey(ValueKey('task-${fixture.task.id}')), findsOneWidget);
  });

  testWidgets('Tasks skip action dismisses task without care log',
      (WidgetTester tester) async {
    final fixture = (await tester.runAsync(_createFixture))!;
    addTearDown(() {
      fixture.container?.dispose();
      unawaited(fixture.dispose());
    });

    await _pumpTasksScreen(tester, fixture: fixture);

    final tileFinder = find.byKey(ValueKey('task-${fixture.task.id}'));
    expect(tileFinder, findsOneWidget);

    await tester.drag(tileFinder, const Offset(-360, 0));
    await _settleUi(tester);

    final skipFinder =
        find.byKey(ValueKey('task-action-${fixture.task.id}-skip'));
    expect(skipFinder, findsOneWidget);

    final l10n = AppLocalizations.of(tester.element(find.byType(TasksScreen)));
    await tester.tap(skipFinder);
    await tester.pump();
    await _drainCompletionAsync(tester);
    await _settleUi(tester);

    final skippedTask = fixture.tasksRepository.byId(fixture.task.id)!;
    expect(skippedTask.status, TaskStatus.skipped);
    expect(skippedTask.completedAt, isNull);

    final allTasks = fixture.tasksRepository.getAll();
    expect(allTasks, hasLength(2));

    final nextTask = allTasks.singleWhere((task) => task.id != fixture.task.id);
    expect(nextTask.type, TaskType.rotate);
    expect(nextTask.status, TaskStatus.pending);
    expect(nextTask.dueAt.hour, 19);
    expect(nextTask.dueAt.minute, 0);

    expect(fixture.logsRepository.forPlant(fixture.plant.id), isEmpty);

    final skippedText =
        find.text('${l10n.tasksSkipped} · ${fixture.plant.nickname}');
    await _waitForFinder(tester, skippedText);
    expect(skippedText, findsOneWidget);
    expect(find.byKey(ValueKey('task-${fixture.task.id}')), findsNothing);
  });
}
