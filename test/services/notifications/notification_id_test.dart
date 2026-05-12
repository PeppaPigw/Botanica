import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/services/notifications/notifications_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('task notification ids are deterministic for plant and task type', () {
    final first = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-1',
      TaskType.water,
    );
    final second = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-1',
      TaskType.water,
    );

    expect(second, first);
    expect(first, inInclusiveRange(1, 0x7fffffff));
  });

  test('task notification ids do not change when task instance id changes', () {
    final fromOldTask = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-1',
      TaskType.water,
    );
    final fromNewTask = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-1',
      TaskType.water,
    );

    expect(fromNewTask, fromOldTask);
  });

  test('task notification ids differ across plants and task types', () {
    final water = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-1',
      TaskType.water,
    );
    final mist = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-1',
      TaskType.mist,
    );
    final otherPlant = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-2',
      TaskType.water,
    );

    expect(mist, isNot(water));
    expect(otherPlant, isNot(water));
  });
}
