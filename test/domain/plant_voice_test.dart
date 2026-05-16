import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_voice.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';

Plant _plant({String id = 'p1', DateTime? createdAt}) => Plant(
      id: id,
      nickname: 'Monstera',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(String plantId, DateTime ts) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task(String plantId, DateTime dueAt, {TaskType type = TaskType.water}) =>
    TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}',
      plantId: plantId,
      type: type,
      dueAt: dueAt,
      status: TaskStatus.pending,
      createdAt: dueAt.subtract(const Duration(days: 1)),
      completedAt: null,
      adjustmentReasonIds: const [],
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PlantVoice.personalityFor', () {
    test('returns deterministic personality for same plant', () {
      final plant = _plant(id: 'test-plant-1');
      final p1 = PlantVoice.personalityFor(plant);
      final p2 = PlantVoice.personalityFor(plant);
      expect(p1, equals(p2));
    });

    test('different plants can get different personalities', () {
      final personalities = <PlantPersonality>{};
      for (int i = 0; i < 20; i++) {
        personalities.add(PlantVoice.personalityFor(_plant(id: 'plant-$i')));
      }
      expect(personalities.length, greaterThan(1));
    });

    test('covers all personality values', () {
      final personalities = <PlantPersonality>{};
      for (int i = 0; i < 100; i++) {
        personalities.add(PlantVoice.personalityFor(_plant(id: 'x$i')));
      }
      expect(personalities, containsAll(PlantPersonality.values));
    });
  });

  group('PlantVoice.speak', () {
    test('returns new plant line for recently created plant', () {
      final plant = _plant(createdAt: now.subtract(const Duration(days: 3)));
      final message = PlantVoice.speak(
        plant: plant,
        recentLogs: [],
        pendingTasks: [],
        now: now,
      );
      expect(message, isNotEmpty);
    });

    test('returns neglected line when no care for 15+ days', () {
      final plant = _plant();
      final logs = [_log('p1', now.subtract(const Duration(days: 20)))];
      final message = PlantVoice.speak(
        plant: plant,
        recentLogs: logs,
        pendingTasks: [],
        now: now,
      );
      final neglectedLines = [
        'I can wait. But not forever.',
        'Hello?? Is anyone there??',
        'Miss you! Come say hi sometime.',
        'Patience has its limits, even for plants.',
        "It's okay... I understand you're busy.",
      ];
      expect(neglectedLines, contains(message));
    });

    test('returns thirsty line when water task is overdue', () {
      final plant = _plant();
      final logs = [_log('p1', now.subtract(const Duration(days: 5)))];
      final tasks = [_task('p1', now.subtract(const Duration(days: 1)))];
      final message = PlantVoice.speak(
        plant: plant,
        recentLogs: logs,
        pendingTasks: tasks,
        now: now,
      );
      final thirstyLines = [
        'Water would be appreciated.',
        'Parched! Absolutely parched!',
        'A little drink would make my day!',
        'The roots grow deeper when they seek.',
        'Um... could I maybe have some water?',
      ];
      expect(thirstyLines, contains(message));
    });

    test('returns happy line when recently cared and no pending tasks', () {
      final plant = _plant();
      final logs = [_log('p1', now.subtract(const Duration(hours: 12)))];
      final message = PlantVoice.speak(
        plant: plant,
        recentLogs: logs,
        pendingTasks: [],
        now: now,
      );
      final happyLines = [
        'All is well.',
        'Living my best life right now!',
        'Feeling great today!',
        'Contentment is the greatest wealth.',
        'I feel... really good actually.',
      ];
      expect(happyLines, contains(message));
    });

    test('returns neutral line for moderate care gap', () {
      final plant = _plant();
      final logs = [_log('p1', now.subtract(const Duration(days: 5)))];
      final message = PlantVoice.speak(
        plant: plant,
        recentLogs: logs,
        pendingTasks: [],
        now: now,
      );
      final neutralLines = [
        'Steady as always.',
        'Just here, being fabulous.',
        'Another good day in the garden!',
        'Growing takes time and trust.',
        'Doing okay over here.',
      ];
      expect(neutralLines, contains(message));
    });

    test('ignores logs from other plants', () {
      final plant = _plant(id: 'target');
      final logs = [_log('other-plant', now.subtract(const Duration(hours: 1)))];
      final message = PlantVoice.speak(
        plant: plant,
        recentLogs: logs,
        pendingTasks: [],
        now: now,
      );
      expect(message, isNotEmpty);
    });

    test('ignores dismissed tasks', () {
      final plant = _plant();
      final logs = [_log('p1', now.subtract(const Duration(days: 5)))];
      final task = TaskInstance(
        id: 'done-task',
        plantId: 'p1',
        type: TaskType.water,
        dueAt: now.subtract(const Duration(days: 1)),
        status: TaskStatus.done,
        createdAt: now.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(hours: 6)),
        adjustmentReasonIds: const [],
      );
      final message = PlantVoice.speak(
        plant: plant,
        recentLogs: logs,
        pendingTasks: [task],
        now: now,
      );
      final thirstyLines = [
        'Water would be appreciated.',
        'Parched! Absolutely parched!',
        'A little drink would make my day!',
        'The roots grow deeper when they seek.',
        'Um... could I maybe have some water?',
      ];
      expect(thirstyLines.contains(message), isFalse);
    });

    test('priority: new > neglected > thirsty > happy > neutral', () {
      final newPlant = _plant(createdAt: now.subtract(const Duration(days: 2)));
      final logs = [_log('p1', now.subtract(const Duration(days: 20)))];
      final tasks = [_task('p1', now.subtract(const Duration(days: 1)))];
      final message = PlantVoice.speak(
        plant: newPlant,
        recentLogs: logs,
        pendingTasks: tasks,
        now: now,
      );
      final newLines = [
        'Settling in quietly.',
        'New home, new me!',
        'Hi! I like it here already.',
        'Every journey begins with a single root.',
        'Still getting used to things...',
      ];
      expect(newLines, contains(message));
    });
  });
}
