import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/gen/l10n/app_localizations_en.dart';
import 'package:botanica/services/notifications/notifications_service.dart';

void main() {
  test('notificationIdForPlantTask is stable and non-zero', () {
    final a = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-123',
      TaskType.water,
    );
    final b = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-123',
      TaskType.water,
    );
    expect(a, b);
    expect(a, isNot(0));
    expect(a, inInclusiveRange(1, 0x7fffffff));
  });

  test('notificationIdForPlantTask varies by plant and type', () {
    final a = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-a',
      TaskType.water,
    );
    final b = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-a',
      TaskType.mist,
    );
    final c = BotanicaNotificationsService.notificationIdForPlantTask(
      'plant-b',
      TaskType.water,
    );
    expect(a, isNot(b));
    expect(a, isNot(c));
  });

  test('notification titles are specific to task type', () {
    final l10n = AppLocalizationsEn();

    expect(
      BotanicaNotificationsService.notificationTitleForTaskType(
        l10n,
        TaskType.water,
        'Aloe',
      ),
      'Time to water Aloe',
    );
    expect(
      BotanicaNotificationsService.notificationTitleForTaskType(
        l10n,
        TaskType.fertilize,
        'Aloe',
      ),
      'Fertilize Aloe today',
    );
    expect(
      BotanicaNotificationsService.notificationTitleForTaskType(
        l10n,
        TaskType.mist,
        'Aloe',
      ),
      'Aloe would love some misting',
    );
    expect(
      BotanicaNotificationsService.notificationTitleForTaskType(
        l10n,
        TaskType.rotate,
        'Aloe',
      ),
      'Give Aloe a quarter turn',
    );
    expect(
      BotanicaNotificationsService.notificationTitleForTaskType(
        l10n,
        TaskType.prune,
        'Aloe',
      ),
      'Aloe is ready for pruning',
    );
  });
}
