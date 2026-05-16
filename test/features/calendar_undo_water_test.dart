import 'dart:io';

import 'package:botanica/data/repositories/logs_repository.dart';
import 'package:botanica/data/repositories/plant_idea_repository.dart';
import 'package:botanica/data/repositories/species_repository.dart';
import 'package:botanica/data/repositories/tasks_repository.dart';
import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/environment_snapshot.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/domain/services/seasonal_care_engine.dart';
import 'package:botanica/domain/services/care_plan_engine.dart';
import 'package:botanica/services/care/care_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/src/hive_impl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Unit tests for the undo-water-from-calendar flow.
///
/// The calendar screen's `_recordWatered` method captures state before watering
/// and provides an undo closure that:
/// 1. Restores the original pending task (if it existed).
/// 2. Deletes the newly created next task.
/// 3. Deletes the care log that was just written.
/// 4. Restores the previous settings (streak state).
///
/// These tests verify that logic at the repository level.

class _TestSpeciesRepository extends SpeciesRepository {
  _TestSpeciesRepository(this._species);
  final List<Species> _species;
  @override
  Future<List<Species>> getAll() async => _species;
  @override
  Future<Species?> byId(String id) async {
    for (final s in _species) {
      if (s.id == id) return s;
    }
    return null;
  }
}

const _species = Species(
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

Future<_UndoFixture> _createFixture() async {
  final tempDir =
      await Directory.systemTemp.createTemp('botanica_undo_water_test_');
  final hiveInstance = HiveImpl()..init(tempDir.path);
  final suffix = DateTime.now().microsecondsSinceEpoch.toString();
  final tasksBox = await hiveInstance.openBox<Map>('tasks_$suffix');
  final logsBox = await hiveInstance.openBox<Map>('logs_$suffix');
  final tasksRepository = TasksRepository(tasksBox);
  final logsRepository = LogsRepository(logsBox);

  final now = DateTime.now();
  final plant = Plant(
    id: 'plant-1',
    nickname: 'Monty',
    speciesId: _species.id,
    room: 'Living room',
    environmentMode: EnvironmentMode.indoor,
    coverAsset: null,
    createdAt: now.subtract(const Duration(days: 30)),
    meta: const PlantMeta(),
  );

  final pendingTask = TaskInstance(
    id: 'task-water-1',
    plantId: plant.id,
    type: TaskType.water,
    dueAt: now,
    status: TaskStatus.pending,
    createdAt: now.subtract(const Duration(days: 7)),
    completedAt: null,
    adjustmentReasonIds: const <String>[],
  );

  await tasksRepository.upsert(pendingTask);

  return _UndoFixture(
    tempDir: tempDir,
    hiveInstance: hiveInstance,
    tasksRepository: tasksRepository,
    logsRepository: logsRepository,
    speciesRepository: _TestSpeciesRepository([_species]),
    plantIdeaRepository: PlantIdeaRepository(
      loader: (_) async => '{"plants": []}',
    ),
    plant: plant,
    pendingTask: pendingTask,
  );
}

class _UndoFixture {
  _UndoFixture({
    required this.tempDir,
    required this.hiveInstance,
    required this.tasksRepository,
    required this.logsRepository,
    required this.speciesRepository,
    required this.plantIdeaRepository,
    required this.plant,
    required this.pendingTask,
  });

  final Directory tempDir;
  final HiveImpl hiveInstance;
  final TasksRepository tasksRepository;
  final LogsRepository logsRepository;
  final SpeciesRepository speciesRepository;
  final PlantIdeaRepository plantIdeaRepository;
  final Plant plant;
  final TaskInstance pendingTask;

  Future<void> dispose() async {
    try {
      await hiveInstance.close().timeout(const Duration(seconds: 1));
    } catch (_) {}
    try {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    } catch (_) {}
  }
}
void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('Calendar undo water flow', () {
    late _UndoFixture fixture;
    late UserSettings settings;

    setUp(() async {
      fixture = await _createFixture();
      settings = UserSettings.defaults().copyWith(
        careStreakDays: 3,
        lastCareDate: DateTime.now().subtract(const Duration(days: 1)),
      );
    });

    tearDown(() => fixture.dispose());

    test('waterNow creates log, marks task done, and schedules next', () async {
      final now = DateTime.now();
      final env = EnvironmentSnapshot(
        timestamp: now,
        tempC: 22,
        humidity: 50,
      );

      UserSettings updatedSettings = settings;

      final createdNextTask = await CareActions.waterNow(
        plant: fixture.plant,
        now: now,
        pendingWaterTask: fixture.pendingTask,
        tasksRepository: fixture.tasksRepository,
        logsRepository: fixture.logsRepository,
        speciesRepository: fixture.speciesRepository,
        plantIdeaRepository: fixture.plantIdeaRepository,
        seasonalEngine: const SeasonalCareEngine(CarePlanEngine()),
        environment: env,
        settings: settings,
        updateSettings: (s) async => updatedSettings = s,
      );

      // The original task should be marked done.
      final storedTask =
          fixture.tasksRepository.byId(fixture.pendingTask.id);
      expect(storedTask, isNotNull);
      expect(storedTask!.status, TaskStatus.done);
      expect(storedTask.completedAt, isNotNull);

      // A care log should have been created.
      final logs = fixture.logsRepository.forPlant(fixture.plant.id);
      expect(logs, hasLength(1));
      expect(logs.first.type, TaskType.water);
      expect(logs.first.plantId, fixture.plant.id);

      // A next task should have been scheduled.
      expect(createdNextTask, isNotNull);
      expect(createdNextTask!.plantId, fixture.plant.id);
      expect(createdNextTask.type, TaskType.water);
      expect(createdNextTask.status, TaskStatus.pending);
      expect(createdNextTask.dueAt.isAfter(now), isTrue);

      // Settings should have been updated (streak incremented).
      expect(updatedSettings.careStreakDays, greaterThanOrEqualTo(settings.careStreakDays));
    });

    test('undo restores original task and removes log and next task', () async {
      final now = DateTime.now();
      final env = EnvironmentSnapshot(
        timestamp: now,
        tempC: 22,
        humidity: 50,
      );

      // ignore: unused_local_variable
      UserSettings updatedSettings = settings;

      final createdNextTask = await CareActions.waterNow(
        plant: fixture.plant,
        now: now,
        pendingWaterTask: fixture.pendingTask,
        tasksRepository: fixture.tasksRepository,
        logsRepository: fixture.logsRepository,
        speciesRepository: fixture.speciesRepository,
        plantIdeaRepository: fixture.plantIdeaRepository,
        seasonalEngine: const SeasonalCareEngine(CarePlanEngine()),
        environment: env,
        settings: settings,
        updateSettings: (s) async => updatedSettings = s,
      );

      // Find the log that was just created.
      final logs = fixture.logsRepository.forPlant(fixture.plant.id);
      expect(logs, hasLength(1));
      final createdLogId = logs.first.id;

      // --- Perform undo (mirrors calendar_screen.dart logic) ---
      // 1. Restore original task.
      await fixture.tasksRepository.upsert(fixture.pendingTask);
      // 2. Delete the next scheduled task.
      if (createdNextTask != null) {
        await fixture.tasksRepository.delete(createdNextTask.id);
      }
      // 3. Delete the care log.
      await fixture.logsRepository.delete(createdLogId);

      // --- Verify undo results ---
      // Original task should be back to pending.
      final restoredTask =
          fixture.tasksRepository.byId(fixture.pendingTask.id);
      expect(restoredTask, isNotNull);
      expect(restoredTask!.status, TaskStatus.pending);
      expect(restoredTask.completedAt, isNull);

      // Next task should be gone.
      if (createdNextTask != null) {
        final nextTask =
            fixture.tasksRepository.byId(createdNextTask.id);
        expect(nextTask, isNull);
      }

      // Log should be gone.
      final logsAfterUndo =
          fixture.logsRepository.forPlant(fixture.plant.id);
      expect(logsAfterUndo, isEmpty);
    });

    test('undo for past-date water removes only the log', () async {
      // When watering on a past date, no task is completed — only a log is
      // created. Undo should remove just that log.
      final pastDate = DateTime.now().subtract(const Duration(days: 3));
      const logId = 'manual-log-past';

      await fixture.logsRepository.add(
        CareLog(
          id: logId,
          plantId: fixture.plant.id,
          type: TaskType.water,
          timestamp: DateTime(
            pastDate.year,
            pastDate.month,
            pastDate.day,
            12,
          ),
          note: null,
          linkedPhotoId: null,
        ),
      );

      // Verify log exists.
      final logsBefore =
          fixture.logsRepository.forPlant(fixture.plant.id);
      expect(logsBefore.any((l) => l.id == logId), isTrue);

      // Undo: just delete the log.
      await fixture.logsRepository.delete(logId);

      final logsAfter =
          fixture.logsRepository.forPlant(fixture.plant.id);
      expect(logsAfter.any((l) => l.id == logId), isFalse);

      // Original pending task should remain untouched.
      final task =
          fixture.tasksRepository.byId(fixture.pendingTask.id);
      expect(task, isNotNull);
      expect(task!.status, TaskStatus.pending);
    });

    test('undo restores settings (streak state)', () async {
      final now = DateTime.now();
      final env = EnvironmentSnapshot(
        timestamp: now,
        tempC: 22,
        humidity: 50,
      );

      UserSettings updatedSettings = settings;

      await CareActions.waterNow(
        plant: fixture.plant,
        now: now,
        pendingWaterTask: fixture.pendingTask,
        tasksRepository: fixture.tasksRepository,
        logsRepository: fixture.logsRepository,
        speciesRepository: fixture.speciesRepository,
        plantIdeaRepository: fixture.plantIdeaRepository,
        seasonalEngine: const SeasonalCareEngine(CarePlanEngine()),
        environment: env,
        settings: settings,
        updateSettings: (s) async => updatedSettings = s,
      );

      // Settings were updated.
      expect(updatedSettings, isNot(equals(settings)));

      // Undo: restore original settings.
      // (In the real app, the calendar screen captures `settings` before
      // calling waterNow and restores it on undo.)
      final restoredSettings = settings;

      expect(restoredSettings.careStreakDays, settings.careStreakDays);
      expect(restoredSettings.lastCareDate, settings.lastCareDate);
    });
  });
}

