import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

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
import 'package:botanica/domain/services/care_plan_engine.dart';
import 'package:botanica/services/care/care_actions.dart';

/// In-memory [SpeciesRepository] that bypasses rootBundle for tests.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late TasksRepository tasksRepo;
  late LogsRepository logsRepo;
  late SpeciesRepository speciesRepo;
  late PlantIdeaRepository ideaRepo;

  final now = DateTime.utc(2026, 6, 15, 10);

  const testSpecies = Species(
    id: 'monstera_deliciosa',
    scientificName: 'Monstera deliciosa',
    commonNamesByLocale: {
      'en': ['Monstera'],
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

  final testPlant = Plant(
    id: 'plant_1',
    nickname: 'Monty',
    speciesId: 'monstera_deliciosa',
    room: 'Living Room',
    environmentMode: EnvironmentMode.indoor,
    coverAsset: null,
    createdAt: now.subtract(const Duration(days: 30)),
    meta: const PlantMeta(),
  );

  final normalEnvironment = EnvironmentSnapshot(
    timestamp: now,
    tempC: 22,
    humidity: 50,
  );

  final settings = UserSettings.defaults();
  Future<void> ignoreSettingsUpdate(UserSettings _) async {}

  const engine = CarePlanEngine();

  setUp(() async {
    tempDir =
        await Directory.systemTemp.createTemp('botanica_care_actions_test_');
    Hive.init(tempDir.path);

    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final tasksBox = await Hive.openBox<Map>('tasks_$suffix');
    final logsBox = await Hive.openBox<Map>('logs_$suffix');

    tasksRepo = TasksRepository(tasksBox);
    logsRepo = LogsRepository(logsBox);
    speciesRepo = _TestSpeciesRepository([testSpecies]);
    ideaRepo = PlantIdeaRepository(
      loader: (_) async => '{"plants": []}',
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('CareActions.waterNow', () {
    test('creates a care log and schedules next water task', () async {
      final nextTask = await CareActions.waterNow(
        plant: testPlant,
        now: now,
        pendingWaterTask: null,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: normalEnvironment,
        settings: settings,
        updateSettings: ignoreSettingsUpdate,
      );

      // A next task should be scheduled.
      expect(nextTask, isNotNull);
      expect(nextTask!.plantId, testPlant.id);
      expect(nextTask.type, TaskType.water);
      expect(nextTask.status, TaskStatus.pending);
      expect(nextTask.dueAt.isAfter(now), isTrue);

      // A care log should have been written.
      final logs = logsRepo.forPlant(testPlant.id);
      expect(logs, hasLength(1));
      expect(logs.first.type, TaskType.water);

      // The next task should be persisted.
      final allTasks = tasksRepo.getAll();
      expect(allTasks, hasLength(1));
      expect(allTasks.first.id, nextTask.id);
    });

    test('marks pending water task as done', () async {
      final pendingTask = TaskInstance(
        id: 'pending_water',
        plantId: testPlant.id,
        type: TaskType.water,
        dueAt: now,
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(days: 7)),
        completedAt: null,
        adjustmentReasonIds: const <String>[],
      );
      await tasksRepo.upsert(pendingTask);

      await CareActions.waterNow(
        plant: testPlant,
        now: now,
        pendingWaterTask: pendingTask,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: normalEnvironment,
        settings: settings,
        updateSettings: ignoreSettingsUpdate,
      );

      // The pending task should now be done.
      final completed = tasksRepo.byId('pending_water');
      expect(completed, isNotNull);
      expect(completed!.isDone, isTrue);
      expect(completed.completedAt, now);

      // 2 tasks total: the completed one + the newly scheduled one.
      expect(tasksRepo.getAll(), hasLength(2));
    });

    test('applies environment adjustment to next due date', () async {
      // Hot + dry environment should shorten the interval.
      final hotDryEnvironment = EnvironmentSnapshot(
        timestamp: now,
        tempC: 32,
        humidity: 25,
      );

      final nextTask = await CareActions.waterNow(
        plant: testPlant,
        now: now,
        pendingWaterTask: null,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: hotDryEnvironment,
        settings: settings,
        updateSettings: ignoreSettingsUpdate,
      );

      expect(nextTask, isNotNull);
      // With hot temp (×0.85) and low humidity (×0.75), the 7-day base
      // should be shortened. The adjusted days should be < 7.
      final daysDiff = nextTask!.dueAt.difference(now).inDays;
      expect(daysDiff, lessThan(7));
      expect(nextTask.adjustmentReasonIds, isNotEmpty);
    });
  });

  group('CareActions.completeTask', () {
    test('completes a rotate task and schedules next with base days', () async {
      final rotateTask = TaskInstance(
        id: 'rotate_1',
        plantId: testPlant.id,
        type: TaskType.rotate,
        dueAt: now,
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(days: 14)),
        completedAt: null,
        adjustmentReasonIds: const <String>[],
      );
      await tasksRepo.upsert(rotateTask);

      final nextTask = await CareActions.completeTask(
        task: rotateTask,
        plant: testPlant,
        now: now,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: normalEnvironment,
        settings: settings,
        updateSettings: ignoreSettingsUpdate,
      );

      // The original task should be marked done.
      final completed = tasksRepo.byId('rotate_1');
      expect(completed!.isDone, isTrue);

      // Next task should use base rotate days (14), aligned to reminder time.
      expect(nextTask, isNotNull);
      expect(nextTask!.type, TaskType.rotate);
      expect(nextTask.dueAt.isAfter(now.add(const Duration(days: 13))), isTrue);
      expect(
          nextTask.dueAt.isBefore(now.add(const Duration(days: 15))), isTrue);

      // No environment adjustment for rotate tasks.
      expect(nextTask.adjustmentReasonIds, isEmpty);

      // A care log should exist.
      final logs = logsRepo.forPlant(testPlant.id);
      expect(logs, hasLength(1));
      expect(logs.first.type, TaskType.rotate);
    });

    test('completes a mist task with environment adjustment', () async {
      // Humidity 38% is "low" for mist (threshold 40%), but not for watering
      // (threshold 35%). This guards that mist uses its own environment profile.
      final borderlineDryEnvironment = EnvironmentSnapshot(
        timestamp: now,
        tempC: 22,
        humidity: 38,
      );

      final mistTask = TaskInstance(
        id: 'mist_1',
        plantId: testPlant.id,
        type: TaskType.mist,
        dueAt: now,
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(days: 3)),
        completedAt: null,
        adjustmentReasonIds: const <String>[],
      );
      await tasksRepo.upsert(mistTask);

      final nextTask = await CareActions.completeTask(
        task: mistTask,
        plant: testPlant,
        now: now,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: borderlineDryEnvironment,
        settings: settings,
        updateSettings: ignoreSettingsUpdate,
      );

      expect(nextTask, isNotNull);
      expect(nextTask!.type, TaskType.mist);
      expect(nextTask.adjustmentReasonIds, contains('humidity_low'));
    });

    test('completes a water task with environment adjustment', () async {
      final waterTask = TaskInstance(
        id: 'water_1',
        plantId: testPlant.id,
        type: TaskType.water,
        dueAt: now,
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(days: 7)),
        completedAt: null,
        adjustmentReasonIds: const <String>[],
      );
      await tasksRepo.upsert(waterTask);

      final nextTask = await CareActions.completeTask(
        task: waterTask,
        plant: testPlant,
        now: now,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: normalEnvironment,
        settings: settings,
        updateSettings: ignoreSettingsUpdate,
      );

      expect(nextTask, isNotNull);
      expect(nextTask!.type, TaskType.water);
      // Water tasks get environment adjustments.
      // With normal environment (22°C, 50% humidity, June = not winter),
      // no adjustments should fire, so base 7 days aligned to reminder time.
      expect(nextTask.dueAt.isAfter(now.add(const Duration(days: 6))), isTrue);
      expect(nextTask.dueAt.isBefore(now.add(const Duration(days: 8))), isTrue);
    });

    test('completes a fertilize task with winter seasonal adjustment',
        () async {
      final winterNow = DateTime.utc(2026, 1, 15, 10);

      final winterPlant = Plant(
        id: 'plant_winter_1',
        nickname: 'Winter Monty',
        speciesId: testSpecies.id,
        room: 'Living Room',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: winterNow.subtract(const Duration(days: 30)),
        meta: const PlantMeta(),
      );

      final winterEnvironment = EnvironmentSnapshot(
        timestamp: winterNow,
        tempC: 22,
        humidity: 50,
      );

      final fertilizeTask = TaskInstance(
        id: 'fertilize_1',
        plantId: winterPlant.id,
        type: TaskType.fertilize,
        dueAt: winterNow,
        status: TaskStatus.pending,
        createdAt: winterNow.subtract(const Duration(days: 30)),
        completedAt: null,
        adjustmentReasonIds: const <String>[],
      );
      await tasksRepo.upsert(fertilizeTask);

      final nextTask = await CareActions.completeTask(
        task: fertilizeTask,
        plant: winterPlant,
        now: winterNow,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: winterEnvironment,
        settings: settings,
        updateSettings: ignoreSettingsUpdate,
      );

      expect(nextTask, isNotNull);
      expect(nextTask!.type, TaskType.fertilize);
      expect(nextTask.adjustmentReasonIds, contains('winter_season'));

      final daysDiff = nextTask.dueAt.difference(winterNow).inDays;
      expect(daysDiff, greaterThanOrEqualTo(33));
    });

    test('returns null for mist task with 0 base days', () async {
      const zeroMistSpecies = Species(
        id: 'zero_mist',
        scientificName: 'Test plant',
        commonNamesByLocale: {
          'en': ['Test'],
        },
        difficulty: 'easy',
        petSafe: true,
        light: 'bright',
        careDefaults: CareDefaults(
          waterBaseDays: 7,
          fertilizeBaseDays: 30,
          mistBaseDays: 0,
          rotateBaseDays: 14,
          pruneBaseDays: 90,
        ),
      );

      speciesRepo = _TestSpeciesRepository([zeroMistSpecies]);

      final plant = Plant(
        id: 'plant_zero_mist',
        nickname: 'Dry',
        speciesId: 'zero_mist',
        room: 'Office',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: now,
        meta: const PlantMeta(),
      );

      final mistTask = TaskInstance(
        id: 'mist_1',
        plantId: plant.id,
        type: TaskType.mist,
        dueAt: now,
        status: TaskStatus.pending,
        createdAt: now,
        completedAt: null,
        adjustmentReasonIds: const <String>[],
      );
      await tasksRepo.upsert(mistTask);

      final nextTask = await CareActions.completeTask(
        task: mistTask,
        plant: plant,
        now: now,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: normalEnvironment,
        settings: settings,
        updateSettings: ignoreSettingsUpdate,
      );

      // mist base days = 0, so no next task should be scheduled.
      expect(nextTask, isNull);

      // But a care log should still be written.
      final logs = logsRepo.forPlant(plant.id);
      expect(logs, hasLength(1));
    });

    test('already-done task still writes log but does not re-mark done',
        () async {
      final doneTask = TaskInstance(
        id: 'done_1',
        plantId: testPlant.id,
        type: TaskType.fertilize,
        dueAt: now.subtract(const Duration(days: 1)),
        status: TaskStatus.done,
        createdAt: now.subtract(const Duration(days: 31)),
        completedAt: now.subtract(const Duration(days: 1)),
        adjustmentReasonIds: const <String>[],
      );
      await tasksRepo.upsert(doneTask);

      final nextTask = await CareActions.completeTask(
        task: doneTask,
        plant: testPlant,
        now: now,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: normalEnvironment,
        settings: settings,
        updateSettings: ignoreSettingsUpdate,
      );

      // Should still schedule a next task.
      expect(nextTask, isNotNull);
      expect(nextTask!.type, TaskType.fertilize);

      // The original done task's completedAt should remain unchanged.
      final original = tasksRepo.byId('done_1');
      expect(original!.completedAt, now.subtract(const Duration(days: 1)));

      // A care log should be written.
      final logs = logsRepo.forPlant(testPlant.id);
      expect(logs, hasLength(1));
    });
  });
}
