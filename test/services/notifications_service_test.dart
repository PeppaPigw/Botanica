import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/services/notifications/notifications_service.dart';

void main() {
  test('notificationIdForTaskId is stable and non-zero', () {
    const id = 'task-123';
    final a = BotanicaNotificationsService.notificationIdForTaskId(id);
    final b = BotanicaNotificationsService.notificationIdForTaskId(id);
    expect(a, b);
    expect(a, isNot(0));
    expect(a, inInclusiveRange(1, 0x7fffffff));
  });

  test('notificationIdForTaskId varies for different ids', () {
    final a = BotanicaNotificationsService.notificationIdForTaskId('task-a');
    final b = BotanicaNotificationsService.notificationIdForTaskId('task-b');
    expect(a, isNot(b));
  });
}
