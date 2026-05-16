import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/services/plant_mood.dart';

TaskInstance _task({
  required DateTime dueAt,
  TaskStatus status = TaskStatus.pending,
}) =>
    TaskInstance(
      id: 'task-1',
      plantId: 'plant-1',
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: DateTime(2026, 1, 1),
      completedAt: status == TaskStatus.done ? dueAt : null,
      adjustmentReasonIds: const <String>[],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PlantMoodResolver', () {
    test('returns newHere for plants less than 3 days old', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 50,
        plantTasks: [],
        plantCreatedAt: now.subtract(const Duration(days: 1)),
        now: now,
      );
      expect(mood, PlantMood.newHere);
    });

    test('returns newHere even with overdue tasks if plant is new', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 30,
        plantTasks: [_task(dueAt: now.subtract(const Duration(days: 2)))],
        plantCreatedAt: now.subtract(const Duration(days: 2)),
        now: now,
      );
      expect(mood, PlantMood.newHere);
    });

    test('returns neglected when overdue by 7+ days', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 80,
        plantTasks: [_task(dueAt: now.subtract(const Duration(days: 8)))],
        plantCreatedAt: now.subtract(const Duration(days: 60)),
        now: now,
      );
      expect(mood, PlantMood.neglected);
    });

    test('returns thirsty when overdue by 2-6 days', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 80,
        plantTasks: [_task(dueAt: now.subtract(const Duration(days: 3)))],
        plantCreatedAt: now.subtract(const Duration(days: 60)),
        now: now,
      );
      expect(mood, PlantMood.thirsty);
    });

    test('ignores dismissed (skipped) tasks for overdue calculation', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 90,
        plantTasks: [
          _task(
            dueAt: now.subtract(const Duration(days: 10)),
            status: TaskStatus.skipped,
          ),
        ],
        plantCreatedAt: now.subtract(const Duration(days: 60)),
        now: now,
      );
      expect(mood, PlantMood.thriving);
    });

    test('ignores completed tasks for overdue calculation', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 85,
        plantTasks: [
          _task(
            dueAt: now.subtract(const Duration(days: 10)),
            status: TaskStatus.done,
          ),
        ],
        plantCreatedAt: now.subtract(const Duration(days: 60)),
        now: now,
      );
      expect(mood, PlantMood.happy);
    });

    test('returns thriving for health >= 90 with no overdue', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 95,
        plantTasks: [],
        plantCreatedAt: now.subtract(const Duration(days: 30)),
        now: now,
      );
      expect(mood, PlantMood.thriving);
    });

    test('returns happy for health 70-89 with no overdue', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 75,
        plantTasks: [],
        plantCreatedAt: now.subtract(const Duration(days: 30)),
        now: now,
      );
      expect(mood, PlantMood.happy);
    });

    test('returns okay for health < 70 with no overdue', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 55,
        plantTasks: [],
        plantCreatedAt: now.subtract(const Duration(days: 30)),
        now: now,
      );
      expect(mood, PlantMood.okay);
    });

    test('overdue takes priority over high health score', () {
      final mood = PlantMoodResolver.resolve(
        healthScore: 95,
        plantTasks: [_task(dueAt: now.subtract(const Duration(days: 4)))],
        plantCreatedAt: now.subtract(const Duration(days: 60)),
        now: now,
      );
      expect(mood, PlantMood.thirsty);
    });
  });
}
