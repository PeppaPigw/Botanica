import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/services/notifications/task_reminder_notification_id.dart';

void main() {
  test('taskReminderNotificationIdForPlantTask is stable and non-zero', () {
    final a = taskReminderNotificationIdForPlantTask(
      plantId: 'plant-1',
      taskType: TaskType.water,
    );
    final b = taskReminderNotificationIdForPlantTask(
      plantId: 'plant-1',
      taskType: TaskType.water,
    );

    expect(a, b);
    expect(a, greaterThan(0));
  });

  test('taskReminderNotificationIdForTask uses plant and task type', () {
    final waterA = _task(id: 'task-a', plantId: 'plant-1', type: TaskType.water);
    final waterB = _task(id: 'task-b', plantId: 'plant-1', type: TaskType.water);
    final mist = _task(id: 'task-c', plantId: 'plant-1', type: TaskType.mist);

    expect(taskReminderNotificationIdForTask(waterA),
        taskReminderNotificationIdForTask(waterB));
    expect(taskReminderNotificationIdForTask(waterA),
        isNot(taskReminderNotificationIdForTask(mist)));
  });

  test('taskReminderNotificationPayload round-trips', () {
    const taskId = 't1';
    final payload = taskReminderNotificationPayload(taskId);

    expect(taskInstanceIdFromTaskReminderPayload(payload), taskId);
  });

  test('task reminder payload parser rejects unrelated payloads', () {
    expect(taskInstanceIdFromTaskReminderPayload(null), isNull);
    expect(taskInstanceIdFromTaskReminderPayload('other:t1'), isNull);
    expect(taskInstanceIdFromTaskReminderPayload('botanica.task_reminder:'),
        isNull);
  });

  test('different plants typically produce different notification IDs', () {
    final id1 = taskReminderNotificationIdForPlantTask(
      plantId: 'a',
      taskType: TaskType.water,
    );
    final id2 = taskReminderNotificationIdForPlantTask(
      plantId: 'b',
      taskType: TaskType.water,
    );

    expect(id1, isNot(id2));
  });
}

TaskInstance _task({
  required String id,
  required String plantId,
  required TaskType type,
}) {
  return TaskInstance(
    id: id,
    plantId: plantId,
    type: type,
    dueAt: DateTime(2026, 5, 12, 9),
    status: TaskStatus.pending,
    createdAt: DateTime(2026, 5, 11, 9),
    completedAt: null,
    adjustmentReasonIds: const <String>[],
  );
}
