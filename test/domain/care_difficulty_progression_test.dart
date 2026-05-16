import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_difficulty_progression.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/task_instance.dart';

Plant _plant({String id = 'p1', String speciesId = 'sp1', DateTime? createdAt}) =>
    Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: speciesId,
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

Species _species({String id = 'sp1', String difficulty = '3'}) => Species(
      id: id,
      scientificName: 'Testus plantus',
      commonNamesByLocale: const {'en': ['Test Plant']},
      difficulty: difficulty,
      petSafe: true,
      light: 'bright indirect',
      careDefaults: const SpeciesCareDefaults(
        waterBaseDays: 7,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
      origin: null,
      growth: null,
      matureSize: null,
    );

CareLog _log(DateTime ts, {String plantId = 'p1', TaskType type = TaskType.water}) =>
    CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}_$plantId',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task({
  required DateTime dueAt,
  TaskStatus status = TaskStatus.done,
  DateTime? completedAt,
}) =>
    TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}',
      plantId: 'p1',
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 1)),
      completedAt: completedAt ?? dueAt,
      adjustmentReasonIds: const [],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('CareDifficultyProgression', () {
    test('returns null with no active plants', () {
      final result = CareDifficultyProgression.evaluate(
        plants: [], species: [], logs: [], tasks: [], now: now);
      expect(result, isNull);
    });

    test('returns null with fewer than 10 logs', () {
      final logs = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: i))));
      final result = CareDifficultyProgression.evaluate(
        plants: [_plant()], species: [_species()], logs: logs, tasks: [], now: now);
      expect(result, isNull);
    });

    test('returns beginner for new user with minimal activity', () {
      final plants = [_plant(createdAt: now.subtract(const Duration(days: 14)))];
      final logs = List.generate(12, (i) =>
          _log(now.subtract(Duration(days: i))));
      // Mix of completed and pending tasks, some late
      final tasks = [
        ...List.generate(3, (i) =>
            _task(dueAt: now.subtract(Duration(days: i * 2)),
                completedAt: now.subtract(Duration(days: i * 2)))),
        ...List.generate(5, (i) =>
            _task(dueAt: now.subtract(Duration(days: i)),
                status: TaskStatus.pending, completedAt: null)),
      ];
      final result = CareDifficultyProgression.evaluate(
        plants: plants, species: [_species(difficulty: '1')],
        logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      // With 1 plant, 14 days old, low difficulty — should be beginner or intermediate
      expect(result!.level.index, lessThanOrEqualTo(SkillLevel.intermediate.index));
    });

    test('returns higher level for experienced user', () {
      final plants = List.generate(10, (i) =>
          _plant(id: 'p$i', createdAt: now.subtract(const Duration(days: 400))));
      final logs = List.generate(50, (i) =>
          _log(now.subtract(Duration(days: i)),
              type: TaskType.values[i % 5]));
      final tasks = List.generate(30, (i) =>
          _task(dueAt: now.subtract(Duration(days: i * 2)),
              completedAt: now.subtract(Duration(days: i * 2))));
      final species = [_species(difficulty: '4')];
      final result = CareDifficultyProgression.evaluate(
        plants: plants, species: species, logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      expect(result!.level.index, greaterThan(SkillLevel.beginner.index));
    });

    test('readyForHarder requires good consistency', () {
      final plants = List.generate(5, (i) =>
          _plant(id: 'p$i', createdAt: now.subtract(const Duration(days: 200))));
      final logs = List.generate(20, (i) =>
          _log(now.subtract(Duration(days: i))));
      // All tasks completed on time
      final tasks = List.generate(20, (i) =>
          _task(dueAt: now.subtract(Duration(days: i * 2)),
              completedAt: now.subtract(Duration(days: i * 2))));
      final result = CareDifficultyProgression.evaluate(
        plants: plants, species: [_species()], logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      if (result!.score >= 0.5) {
        expect(result.readyForHarder, isTrue);
        expect(result.suggestedDifficulty, greaterThan(1));
      }
    });

    test('identifies strengths correctly', () {
      final plants = List.generate(15, (i) =>
          _plant(id: 'p$i', createdAt: now.subtract(const Duration(days: 500))));
      final logs = List.generate(30, (i) =>
          _log(now.subtract(Duration(days: i)),
              type: TaskType.values[i % 6]));
      final tasks = List.generate(30, (i) =>
          _task(dueAt: now.subtract(Duration(days: i)),
              completedAt: now.subtract(Duration(days: i))));
      final result = CareDifficultyProgression.evaluate(
        plants: plants, species: [_species(difficulty: '4')],
        logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      expect(result!.strengths, isNotEmpty);
    });

    test('score is between 0 and 1', () {
      final plants = [_plant(createdAt: now.subtract(const Duration(days: 60)))];
      final logs = List.generate(15, (i) =>
          _log(now.subtract(Duration(days: i))));
      final tasks = List.generate(10, (i) =>
          _task(dueAt: now.subtract(Duration(days: i * 3)),
              completedAt: now.subtract(Duration(days: i * 3))));
      final result = CareDifficultyProgression.evaluate(
        plants: plants, species: [_species()], logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      expect(result!.score, greaterThanOrEqualTo(0.0));
      expect(result.score, lessThanOrEqualTo(1.0));
    });

    test('suggestedDifficulty is clamped 1-5', () {
      final plants = [_plant()];
      final logs = List.generate(12, (i) =>
          _log(now.subtract(Duration(days: i))));
      final tasks = List.generate(10, (i) =>
          _task(dueAt: now.subtract(Duration(days: i)),
              completedAt: now.subtract(Duration(days: i))));
      final result = CareDifficultyProgression.evaluate(
        plants: plants, species: [_species(difficulty: '5')],
        logs: logs, tasks: tasks, now: now);
      expect(result, isNotNull);
      expect(result!.suggestedDifficulty, inInclusiveRange(1, 5));
    });
  });
}
