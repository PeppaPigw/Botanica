import 'dart:io';

import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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
import 'package:botanica/domain/services/seasonal_care_engine.dart';
import 'package:botanica/services/care/care_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  late Directory tempDir;
  late TasksRepository tasksRepo;
  late LogsRepository logsRepo;
  late SpeciesRepository speciesRepo;
  late PlantIdeaRepository ideaRepo;

  final now = DateTime.utc(2026, 6, 15, 10);
  final plant = Plant(
    id: 'plant_1',
    nickname: 'Fern',
    speciesId: 'test_species',
    room: 'Desk',
    environmentMode: EnvironmentMode.indoor,
    coverAsset: null,
    createdAt: now.subtract(const Duration(days: 30)),
    meta: const PlantMeta(),
  );
  const species = Species(
    id: 'test_species',
    scientificName: 'Test species',
    commonNamesByLocale: <String, List<String>>{
      'en': <String>['Test species'],
    },
    difficulty: 'easy',
    petSafe: true,
    light: 'bright_indirect',
    careDefaults: CareDefaults(
      waterBaseDays: 7,
      fertilizeBaseDays: 30,
      mistBaseDays: 0,
      rotateBaseDays: 14,
      pruneBaseDays: 90,
    ),
  );
  final environment = EnvironmentSnapshot(
    timestamp: now,
    tempC: 22,
    humidity: 50,
  );
  final settings = UserSettings.defaults();
  const engine = SeasonalCareEngine(CarePlanEngine());

  setUp(() async {
    tempDir =
        await Directory.systemTemp.createTemp('botanica_task_completion_');
    Hive.init(tempDir.path);
    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    tasksRepo = TasksRepository(await Hive.openBox<Map>('tasks_$suffix'));
    logsRepo = LogsRepository(await Hive.openBox<Map>('logs_$suffix'));
    speciesRepo = _TestSpeciesRepository(<Species>[species]);
    ideaRepo = PlantIdeaRepository(loader: (_) async => '{"plants": []}');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<TaskInstance?> complete(TaskInstance task) {
    return CareActions.completeTask(
      task: task,
      plant: plant,
      now: now,
      tasksRepository: tasksRepo,
      logsRepository: logsRepo,
      speciesRepository: speciesRepo,
      plantIdeaRepository: ideaRepo,
      seasonalEngine: engine,
      environment: environment,
      settings: settings,
      updateSettings: (_) async {},
    );
  }

  test('completing a water task creates the next water task', () async {
    final task = _waterTask(now: now, plantId: plant.id);
    await tasksRepo.upsert(task);

    final nextTask = await complete(task);

    expect(nextTask, isNotNull);
    expect(nextTask!.plantId, plant.id);
    expect(nextTask.type, TaskType.water);
    expect(nextTask.status, TaskStatus.pending);
    expect(nextTask.dueAt.year, 2026);
    expect(nextTask.dueAt.month, 6);
    expect(nextTask.dueAt.day, 22);
    expect(nextTask.dueAt.hour, 9);
    expect(nextTask.dueAt.minute, 0);
  });

  test('completed water task is marked done', () async {
    final task = _waterTask(now: now, plantId: plant.id);
    await tasksRepo.upsert(task);

    await complete(task);

    final completed = tasksRepo.byId(task.id);
    expect(completed, isNotNull);
    expect(completed!.status, TaskStatus.done);
    expect(completed.completedAt, now);
  });

  test('does not create a duplicate next water task', () async {
    final task = _waterTask(now: now, plantId: plant.id);
    final existingNext = TaskInstance(
      id: 'water_next',
      plantId: plant.id,
      type: TaskType.water,
      dueAt: DateTime(2026, 6, 22, 9),
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: const <String>[],
    );
    await tasksRepo.upsert(task);
    await tasksRepo.upsert(existingNext);

    final nextTask = await complete(task);

    expect(nextTask, isNull);
    expect(
      tasksRepo
          .getAll()
          .where((task) =>
              task.plantId == plant.id &&
              task.type == TaskType.water &&
              task.status == TaskStatus.pending)
          .length,
      1,
    );
  });
}

TaskInstance _waterTask({
  required DateTime now,
  required String plantId,
}) {
  return TaskInstance(
    id: 'water_due',
    plantId: plantId,
    type: TaskType.water,
    dueAt: now,
    status: TaskStatus.pending,
    createdAt: now.subtract(const Duration(days: 7)),
    completedAt: null,
    adjustmentReasonIds: const <String>[],
  );
}
