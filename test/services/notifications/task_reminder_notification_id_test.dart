import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/services/notifications/task_reminder_notification_id.dart';

void main() {
  test('taskReminderNotificationId is stable and non-zero', () {
    const taskId = '550e8400-e29b-41d4-a716-446655440000';
    final a = taskReminderNotificationId(taskId);
    final b = taskReminderNotificationId(taskId);

    expect(a, b);
    expect(a, greaterThan(0));
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

  test('different task IDs typically produce different notification IDs', () {
    final id1 = taskReminderNotificationId('a');
    final id2 = taskReminderNotificationId('b');

    expect(id1, isNot(id2));
  });
}
