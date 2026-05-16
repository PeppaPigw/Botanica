import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_consistency_scorer.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';

Plant _plant({String id = 'p1'}) => Plant(
      id: id,
      nickname: 'Monstera',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

TaskInstance _completedTask({
  required DateTime dueAt,
  required DateTime completedAt,
  String plantId = 'p1',
}) =>
    TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      dueAt: dueAt,
      status: TaskStatus.done,
      createdAt: dueAt.subtract(const Duration(days: 7)),
      completedAt: completedAt,
      adjustmentReasonIds: const [],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('CareConsistencyScorer', () {
    test('returns null for archived plant', () {
      final archived = Plant(
        id: 'p1',
        nickname: 'Dead',
        speciesId: 'sp1',
        room: 'Room',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1),
        meta: const PlantMeta(),
        isArchived: true,
      );
      expect(
        CareConsistencyScorer.score(
          plant: archived, tasks: [], logs: [], now: now),
        isNull,
      );
    });

    test('returns null with fewer than 5 completed tasks', () {
      final tasks = List.generate(3, (i) => _completedTask(
            dueAt: now.subtract(Duration(days: i * 7)),
            completedAt: now.subtract(Duration(days: i * 7)),
          ));
      expect(
        CareConsistencyScorer.score(
          plant: _plant(), tasks: tasks, logs: [], now: now),
        isNull,
      );
    });

    test('excellent grade for perfectly on-time care', () {
      final tasks = List.generate(8, (i) {
        final due = now.subtract(Duration(days: i * 7));
        return _completedTask(dueAt: due, completedAt: due);
      });
      final result = CareConsistencyScorer.score(
        plant: _plant(), tasks: tasks, logs: [], now: now);
      expect(result, isNotNull);
      expect(result!.grade, ConsistencyGrade.excellent);
      expect(result.score, greaterThan(0.85));
      expect(result.onTimePercentage, 1.0);
    });

    test('inconsistent grade for very late completions', () {
      final tasks = List.generate(6, (i) {
        final due = now.subtract(Duration(days: i * 7));
        return _completedTask(
          dueAt: due,
          completedAt: due.add(const Duration(days: 4)),
        );
      });
      final result = CareConsistencyScorer.score(
        plant: _plant(), tasks: tasks, logs: [], now: now);
      expect(result, isNotNull);
      expect(result!.grade, ConsistencyGrade.inconsistent);
      expect(result.averageDelayHours, greaterThan(48));
    });

    test('detects improving trend', () {
      final tasks = <TaskInstance>[];
      for (int i = 0; i < 10; i++) {
        final due = now.subtract(Duration(days: (9 - i) * 7));
        final delay = i < 5 ? 48 : 2; // older tasks: 48h late, recent: 2h
        tasks.add(_completedTask(
          dueAt: due,
          completedAt: due.add(Duration(hours: delay)),
        ));
      }
      final result = CareConsistencyScorer.score(
        plant: _plant(), tasks: tasks, logs: [], now: now);
      expect(result, isNotNull);
      expect(result!.improvingTrend, isTrue);
    });

    test('detects worsening trend', () {
      final tasks = <TaskInstance>[];
      for (int i = 0; i < 10; i++) {
        final due = now.subtract(Duration(days: (9 - i) * 7));
        final delay = i < 5 ? 2 : 48; // older tasks: 2h, recent: 48h late
        tasks.add(_completedTask(
          dueAt: due,
          completedAt: due.add(Duration(hours: delay)),
        ));
      }
      final result = CareConsistencyScorer.score(
        plant: _plant(), tasks: tasks, logs: [], now: now);
      expect(result, isNotNull);
      expect(result!.improvingTrend, isFalse);
    });

    test('scoreAll returns results for multiple plants', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2')];
      final tasks = [
        ...List.generate(6, (i) {
          final due = now.subtract(Duration(days: i * 7));
          return _completedTask(dueAt: due, completedAt: due, plantId: 'p1');
        }),
        ...List.generate(6, (i) {
          final due = now.subtract(Duration(days: i * 7));
          return _completedTask(dueAt: due, completedAt: due, plantId: 'p2');
        }),
      ];
      final results = CareConsistencyScorer.scoreAll(
        plants: plants, tasks: tasks, logs: [], now: now);
      expect(results.length, 2);
    });

    test('gardenConsistencyScore averages results', () {
      final results = {
        'p1': const CareConsistencyResult(
          plantId: 'p1',
          grade: ConsistencyGrade.excellent,
          score: 0.9,
          averageDelayHours: 1.0,
          onTimePercentage: 1.0,
          improvingTrend: true,
        ),
        'p2': const CareConsistencyResult(
          plantId: 'p2',
          grade: ConsistencyGrade.fair,
          score: 0.5,
          averageDelayHours: 30.0,
          onTimePercentage: 0.6,
          improvingTrend: false,
        ),
      };
      final score = CareConsistencyScorer.gardenConsistencyScore(results);
      expect(score, closeTo(0.7, 0.01));
    });

    test('on-time percentage counts tasks completed within 24h', () {
      final tasks = List.generate(6, (i) {
        final due = now.subtract(Duration(days: i * 7));
        final delay = i.isEven ? 2 : 30; // half on-time, half late
        return _completedTask(
          dueAt: due,
          completedAt: due.add(Duration(hours: delay)),
        );
      });
      final result = CareConsistencyScorer.score(
        plant: _plant(), tasks: tasks, logs: [], now: now);
      expect(result!.onTimePercentage, closeTo(0.5, 0.01));
    });
  });
}
