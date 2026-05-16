import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_impact_analyzer.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';

Plant _plant({String id = 'p1', DateTime? createdAt}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(DateTime ts, {
  String plantId = 'p1',
  TaskType type = TaskType.water,
}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task({
  String plantId = 'p1',
  required DateTime dueAt,
  DateTime? completedAt,
  TaskStatus status = TaskStatus.done,
}) => TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 7)),
      completedAt: completedAt ?? dueAt,
      adjustmentReasonIds: const [],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('CareImpactAnalyzer', () {
    test('returns null with no logs', () {
      expect(
        CareImpactAnalyzer.analyze(
          plants: [_plant()], logs: [], tasks: [], now: now),
        isNull,
      );
    });

    test('counts total care actions and watering events', () {
      final logs = [
        _log(now.subtract(const Duration(days: 1))),
        _log(now.subtract(const Duration(days: 2))),
        _log(now.subtract(const Duration(days: 3)), type: TaskType.fertilize),
      ];
      final result = CareImpactAnalyzer.analyze(
        plants: [_plant()], logs: logs, tasks: [], now: now);
      expect(result, isNotNull);
      expect(result!.totalCareActions, 3);
      expect(result.totalWateringEvents, 2);
    });

    test('counts unique care types', () {
      final logs = [
        _log(now.subtract(const Duration(days: 1)), type: TaskType.water),
        _log(now.subtract(const Duration(days: 2)), type: TaskType.fertilize),
        _log(now.subtract(const Duration(days: 3)), type: TaskType.mist),
        _log(now.subtract(const Duration(days: 4)), type: TaskType.rotate),
      ];
      final result = CareImpactAnalyzer.analyze(
        plants: [_plant()], logs: logs, tasks: [], now: now);
      expect(result!.uniqueCareTypes, 4);
    });

    test('finds longest cared plant', () {
      final plants = [
        _plant(id: 'p1', createdAt: DateTime(2024, 1, 1)),
        _plant(id: 'p2', createdAt: DateTime(2026, 4, 1)),
      ];
      final logs = [
        _log(now.subtract(const Duration(days: 5)), plantId: 'p1'),
        _log(now.subtract(const Duration(days: 3)), plantId: 'p2'),
      ];
      final result = CareImpactAnalyzer.analyze(
        plants: plants, logs: logs, tasks: [], now: now);
      expect(result!.longestCaredPlantName, 'Plant p1');
      expect(result.longestCaredPlantDays, greaterThan(500));
    });

    test('detects plants saved from decline', () {
      final logs = [
        _log(now.subtract(const Duration(days: 5))),
      ];
      final tasks = [
        _task(
          dueAt: now.subtract(const Duration(days: 20)),
          completedAt: now.subtract(const Duration(days: 17)),
        ),
        _task(
          dueAt: now.subtract(const Duration(days: 13)),
          completedAt: now.subtract(const Duration(days: 10)),
        ),
      ];
      final result = CareImpactAnalyzer.analyze(
        plants: [_plant()], logs: logs, tasks: tasks, now: now);
      expect(result!.plantsSavedFromDecline, 1);
    });

    test('detects busiest month', () {
      final logs = List.generate(15, (i) =>
          _log(DateTime(2026, 3, i + 1, 10, 0)));
      final result = CareImpactAnalyzer.analyze(
        plants: [_plant()], logs: logs, tasks: [], now: now);
      expect(result!.busiestMonth, 3);
    });

    test('busiest month is null with few logs', () {
      final logs = [
        _log(now.subtract(const Duration(days: 1))),
      ];
      final result = CareImpactAnalyzer.analyze(
        plants: [_plant()], logs: logs, tasks: [], now: now);
      expect(result!.busiestMonth, isNull);
    });

    test('computes average response time', () {
      final tasks = List.generate(5, (i) {
        final due = now.subtract(Duration(days: i * 7));
        return _task(
          dueAt: due,
          completedAt: due.add(const Duration(hours: 6)),
        );
      });
      final result = CareImpactAnalyzer.analyze(
        plants: [_plant()],
        logs: [_log(now.subtract(const Duration(days: 1)))],
        tasks: tasks,
        now: now,
      );
      expect(result!.averageResponseTimeHours, closeTo(6.0, 0.1));
    });

    test('impact score increases with more care', () {
      final fewLogs = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: i))));
      final manyLogs = List.generate(50, (i) =>
          _log(now.subtract(Duration(days: i))));

      final resultFew = CareImpactAnalyzer.analyze(
        plants: [_plant()], logs: fewLogs, tasks: [], now: now);
      final resultMany = CareImpactAnalyzer.analyze(
        plants: [_plant()], logs: manyLogs, tasks: [], now: now);

      expect(resultMany!.impactScore, greaterThan(resultFew!.impactScore));
    });

    test('impact score is clamped to 0-1', () {
      final logs = List.generate(200, (i) =>
          _log(now.subtract(Duration(days: i))));
      final result = CareImpactAnalyzer.analyze(
        plants: [_plant(createdAt: DateTime(2020, 1, 1))],
        logs: logs,
        tasks: [],
        now: now,
      );
      expect(result!.impactScore, lessThanOrEqualTo(1.0));
      expect(result.impactScore, greaterThanOrEqualTo(0.0));
    });
  });
}
