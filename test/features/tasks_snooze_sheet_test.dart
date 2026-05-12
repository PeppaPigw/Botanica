import 'dart:async';
import 'dart:io';

import 'package:botanica/app/providers.dart';
import 'package:botanica/data/repositories/tasks_repository.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/tasks/tasks_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive/src/hive_impl.dart';

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

class _TasksFixture {
  _TasksFixture({
    required this.tempDir,
    required this.hiveInstance,
    required this.tasksBox,
    required this.tasksRepository,
    required this.task,
    required this.plant,
  });

  final Directory tempDir;
  final HiveImpl hiveInstance;
  final Box<Map> tasksBox;
  final TasksRepository tasksRepository;
  final TaskInstance task;
  final Plant plant;
  ProviderContainer? container;

  Future<void> dispose() async {
    container?.dispose();
    try {
      if (tasksBox.isOpen) {
        await tasksBox.deleteFromDisk().timeout(const Duration(seconds: 1));
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

Future<_TasksFixture> _createFixture() async {
  final tempDir =
      await Directory.systemTemp.createTemp('botanica_tasks_snooze_test_');
  final hiveInstance = HiveImpl()..init(tempDir.path);

  final suffix = DateTime.now().microsecondsSinceEpoch.toString();
  final tasksBox = await hiveInstance.openBox<Map>('tasks_$suffix');
  final tasksRepository = TasksRepository(tasksBox);

  final now = DateTime.now();
  final task = TaskInstance(
    id: 'task-1',
    plantId: 'plant-1',
    type: TaskType.water,
    dueAt: now,
    status: TaskStatus.pending,
    createdAt: now,
    completedAt: null,
    adjustmentReasonIds: const <String>[],
  );
  final plant = Plant(
    id: 'plant-1',
    nickname: 'Aloe',
    speciesId: 'aloe_vera',
    room: 'Living room',
    environmentMode: EnvironmentMode.indoor,
    coverAsset: 'assets/placeholders/species/unknown.png',
    createdAt: now,
    meta: const PlantMeta(),
  );

  await tasksRepository.upsert(task);

  return _TasksFixture(
    tempDir: tempDir,
    hiveInstance: hiveInstance,
    tasksBox: tasksBox,
    tasksRepository: tasksRepository,
    task: task,
    plant: plant,
  );
}

Future<void> _pumpTasksScreen(
  WidgetTester tester, {
  required _TasksFixture fixture,
  ReminderTimePreference reminderTimePreference =
      ReminderTimePreference.morning,
}) async {
  final container = ProviderContainer(
    overrides: [
      settingsControllerProvider.overrideWith(
        () => _TestSettingsController(
          UserSettings.defaults().copyWith(
            reminderTimePreference: reminderTimePreference,
          ),
        ),
      ),
      tasksRepositoryProvider.overrideWithValue(fixture.tasksRepository),
      plantsStreamProvider.overrideWith(
        (ref) => Stream.value(<Plant>[fixture.plant]),
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

Future<void> _openSnoozeSheet(WidgetTester tester, String taskId) async {
  final tileFinder = find.byKey(ValueKey('task-$taskId'));
  expect(tileFinder, findsOneWidget);

  await tester.drag(tileFinder, const Offset(-320, 0));
  await _settleUi(tester);

  final snoozeFinder = find.byKey(ValueKey('task-action-$taskId-snooze'));
  expect(snoozeFinder, findsOneWidget);

  await tester.tap(snoozeFinder);
  await _settleUi(tester);
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

Future<void> _settleUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1600));
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

DateTime _nextWeekendDateAfter(DateTime now) {
  var candidate = _dateOnly(now).add(const Duration(days: 1));
  while (candidate.weekday != DateTime.saturday &&
      candidate.weekday != DateTime.sunday) {
    candidate = candidate.add(const Duration(days: 1));
  }
  return candidate;
}

void main() {
  testWidgets('Tasks snooze sheet shows premium options with target times',
      (WidgetTester tester) async {
    final fixture = (await tester.runAsync(_createFixture))!;
    addTearDown(() {
      fixture.container?.dispose();
      unawaited(fixture.dispose());
    });

    await _pumpTasksScreen(tester, fixture: fixture);
    await _openSnoozeSheet(tester, fixture.task.id);

    final l10n = AppLocalizations.of(tester.element(find.byType(TasksScreen)));

    expect(find.text(l10n.gardenQuickSnooze), findsOneWidget);
    expect(find.text('1 hour'), findsOneWidget);
    expect(find.text('3 hours'), findsOneWidget);
    expect(find.text('Tomorrow morning'), findsOneWidget);
    expect(find.text('This weekend'), findsOneWidget);
    expect(find.text('Custom time'), findsOneWidget);
    expect(find.textContaining(' · '), findsWidgets);
  });

  testWidgets('Tasks snooze 1 hour updates task and shows snackbar',
      (WidgetTester tester) async {
    final fixture = (await tester.runAsync(_createFixture))!;
    addTearDown(() {
      fixture.container?.dispose();
      unawaited(fixture.dispose());
    });

    await _pumpTasksScreen(tester, fixture: fixture);
    await _openSnoozeSheet(tester, fixture.task.id);

    final l10n = AppLocalizations.of(tester.element(find.byType(TasksScreen)));
    final beforeTap = DateTime.now();
    await tester.tap(find.text('1 hour'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await _settleUi(tester);
    final afterTap = DateTime.now();

    final updatedTask = fixture.tasksRepository.byId(fixture.task.id)!;
    expect(updatedTask.status, TaskStatus.snoozed);

    final lowerBound = beforeTap
        .add(const Duration(hours: 1))
        .subtract(const Duration(seconds: 2));
    final upperBound =
        afterTap.add(const Duration(hours: 1)).add(const Duration(seconds: 2));
    expect(updatedTask.dueAt.isBefore(lowerBound), isFalse);
    expect(updatedTask.dueAt.isAfter(upperBound), isFalse);
    final snackbarText = find.text(l10n.tasksSnoozedUntil(updatedTask.dueAt));
    await _waitForFinder(tester, snackbarText);
    expect(snackbarText, findsOneWidget);
  });

  testWidgets('Tasks snooze 3 hours updates task and shows snackbar',
      (WidgetTester tester) async {
    final fixture = (await tester.runAsync(_createFixture))!;
    addTearDown(() {
      fixture.container?.dispose();
      unawaited(fixture.dispose());
    });

    await _pumpTasksScreen(tester, fixture: fixture);
    await _openSnoozeSheet(tester, fixture.task.id);

    final l10n = AppLocalizations.of(tester.element(find.byType(TasksScreen)));
    final beforeTap = DateTime.now();
    await tester.tap(find.text('3 hours'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await _settleUi(tester);
    final afterTap = DateTime.now();

    final updatedTask = fixture.tasksRepository.byId(fixture.task.id)!;
    expect(updatedTask.status, TaskStatus.snoozed);

    final lowerBound = beforeTap
        .add(const Duration(hours: 3))
        .subtract(const Duration(seconds: 2));
    final upperBound =
        afterTap.add(const Duration(hours: 3)).add(const Duration(seconds: 2));
    expect(updatedTask.dueAt.isBefore(lowerBound), isFalse);
    expect(updatedTask.dueAt.isAfter(upperBound), isFalse);
    final snackbarText = find.text(l10n.tasksSnoozedUntil(updatedTask.dueAt));
    await _waitForFinder(tester, snackbarText);
    expect(snackbarText, findsOneWidget);
  });

  testWidgets('Tasks snooze tomorrow aligns to morning reminder time',
      (WidgetTester tester) async {
    final fixture = (await tester.runAsync(_createFixture))!;
    addTearDown(() {
      fixture.container?.dispose();
      unawaited(fixture.dispose());
    });

    await _pumpTasksScreen(
      tester,
      fixture: fixture,
      reminderTimePreference: ReminderTimePreference.morning,
    );
    await _openSnoozeSheet(tester, fixture.task.id);

    final beforeTap = DateTime.now();
    await tester.tap(find.text('Tomorrow morning'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await _settleUi(tester);
    final afterTap = DateTime.now();

    final updatedTask = fixture.tasksRepository.byId(fixture.task.id)!;
    final expectedFromBefore =
        _dateOnly(beforeTap).add(const Duration(days: 1));
    final expectedFromAfter = _dateOnly(afterTap).add(const Duration(days: 1));

    expect(updatedTask.status, TaskStatus.snoozed);
    expect(updatedTask.dueAt.hour, 9);
    expect(updatedTask.dueAt.minute, 0);
    expect(
      _sameDate(updatedTask.dueAt, expectedFromBefore) ||
          _sameDate(updatedTask.dueAt, expectedFromAfter),
      isTrue,
    );
  });

  testWidgets('Tasks snooze weekend aligns to evening reminder time',
      (WidgetTester tester) async {
    final fixture = (await tester.runAsync(_createFixture))!;
    addTearDown(() {
      fixture.container?.dispose();
      unawaited(fixture.dispose());
    });

    await _pumpTasksScreen(
      tester,
      fixture: fixture,
      reminderTimePreference: ReminderTimePreference.evening,
    );
    await _openSnoozeSheet(tester, fixture.task.id);

    final beforeTap = DateTime.now();
    await tester.tap(find.text('This weekend'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await _settleUi(tester);
    final afterTap = DateTime.now();

    final updatedTask = fixture.tasksRepository.byId(fixture.task.id)!;
    final expectedFromBefore = _nextWeekendDateAfter(beforeTap);
    final expectedFromAfter = _nextWeekendDateAfter(afterTap);

    expect(updatedTask.status, TaskStatus.snoozed);
    expect(updatedTask.dueAt.hour, 19);
    expect(updatedTask.dueAt.minute, 0);
    expect(
      _sameDate(updatedTask.dueAt, expectedFromBefore) ||
          _sameDate(updatedTask.dueAt, expectedFromAfter),
      isTrue,
    );
  });

  testWidgets('Tasks snooze dismissal leaves task unchanged',
      (WidgetTester tester) async {
    final fixture = (await tester.runAsync(_createFixture))!;
    addTearDown(() {
      fixture.container?.dispose();
      unawaited(fixture.dispose());
    });

    await _pumpTasksScreen(tester, fixture: fixture);
    await _openSnoozeSheet(tester, fixture.task.id);

    await tester.binding.handlePopRoute();
    await _settleUi(tester);

    final unchangedTask = fixture.tasksRepository.byId(fixture.task.id)!;
    expect(unchangedTask.status, TaskStatus.pending);
    expect(unchangedTask.dueAt, fixture.task.dueAt);
    expect(find.byType(SnackBar), findsNothing);
  });
}
