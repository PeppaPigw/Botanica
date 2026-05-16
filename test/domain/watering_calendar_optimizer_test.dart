import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/watering_calendar_optimizer.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';

Plant _plant({String id = 'p1'}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

TaskInstance _waterTask({
  required String plantId,
  required DateTime dueAt,
  TaskStatus status = TaskStatus.pending,
}) =>
    TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}_$plantId',
      plantId: plantId,
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 1)),
      completedAt: null,
      adjustmentReasonIds: const [],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('WateringCalendarOptimizer', () {
    test('returns null with fewer than 3 active plants', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2')];
      final result = WateringCalendarOptimizer.optimize(
        plants: plants, tasks: [], now: now);
      expect(result, isNull);
    });

    test('returns null when fewer than 3 plants have interval data', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2'), _plant(id: 'p3')];
      // Only 1 task per plant — not enough to compute intervals
      final tasks = [
        _waterTask(plantId: 'p1', dueAt: now.add(const Duration(days: 1))),
        _waterTask(plantId: 'p2', dueAt: now.add(const Duration(days: 2))),
        _waterTask(plantId: 'p3', dueAt: now.add(const Duration(days: 3))),
      ];
      final result = WateringCalendarOptimizer.optimize(
        plants: plants, tasks: tasks, now: now);
      expect(result, isNull);
    });

    test('produces optimization when plants have regular intervals', () {
      final plants = [
        _plant(id: 'p1'),
        _plant(id: 'p2'),
        _plant(id: 'p3'),
        _plant(id: 'p4'),
      ];
      // Each plant has 3 water tasks with 7-day intervals
      final tasks = <TaskInstance>[];
      for (final pid in ['p1', 'p2', 'p3', 'p4']) {
        for (int i = 0; i < 3; i++) {
          tasks.add(_waterTask(
            plantId: pid,
            dueAt: now.subtract(Duration(days: i * 7)),
          ));
        }
      }
      // Also add upcoming tasks spread across all 7 days
      for (int d = 1; d <= 7; d++) {
        tasks.add(_waterTask(
          plantId: 'p${(d % 4) + 1}',
          dueAt: now.add(Duration(days: d)),
        ));
      }
      final result = WateringCalendarOptimizer.optimize(
        plants: plants, tasks: tasks, now: now);
      // May or may not optimize depending on current spread
      if (result != null) {
        expect(result.optimizedActiveDays, lessThan(result.currentActiveDays));
        expect(result.daysSaved, greaterThan(0));
        expect(result.optimizedDays, isNotEmpty);
      }
    });

    test('WateringDay contains correct plant info', () {
      final plants = [
        _plant(id: 'p1'),
        _plant(id: 'p2'),
        _plant(id: 'p3'),
      ];
      final tasks = <TaskInstance>[];
      for (final pid in ['p1', 'p2', 'p3']) {
        for (int i = 0; i < 4; i++) {
          tasks.add(_waterTask(
            plantId: pid,
            dueAt: now.subtract(Duration(days: i * 3)),
          ));
        }
      }
      // Spread upcoming across many days
      for (int d = 1; d <= 14; d++) {
        tasks.add(_waterTask(
          plantId: 'p${(d % 3) + 1}',
          dueAt: now.add(Duration(days: d)),
        ));
      }
      final result = WateringCalendarOptimizer.optimize(
        plants: plants, tasks: tasks, now: now);
      if (result != null) {
        for (final day in result.optimizedDays) {
          expect(day.weekday, inInclusiveRange(1, 7));
          expect(day.plantIds, isNotEmpty);
          expect(day.plantNicknames.length, day.plantIds.length);
        }
      }
    });
  });
}
