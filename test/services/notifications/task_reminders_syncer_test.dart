import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/services/notifications/task_reminders_syncer.dart';
import 'package:botanica/services/notifications/notifications_service.dart';

/// Minimal stub that records calls without touching the notification plugin.
class _StubNotificationsService extends BotanicaNotificationsService {
  int resyncCallCount = 0;

  @override
  Future<void> resyncTaskReminders({
    required List<TaskInstance> tasks,
    required Map<String, Plant> plantsById,
    required UserSettings settings,
    Duration horizon = const Duration(days: 90),
    int maxScheduled = 64,
  }) async {
    resyncCallCount++;
  }
}

void main() {
  group('TaskRemindersSyncer', () {
    test('does not resync when data is incomplete', () async {
      final stub = _StubNotificationsService();
      final syncer = TaskRemindersSyncer(
        notificationsService: stub,
        debounceDuration: Duration.zero,
      );
      addTearDown(syncer.dispose);

      syncer.updateTasks([]);
      // plants and settings are still null
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(stub.resyncCallCount, 0);
    });

    test('resyncs when all data is provided', () async {
      final stub = _StubNotificationsService();
      final syncer = TaskRemindersSyncer(
        notificationsService: stub,
        debounceDuration: Duration.zero,
      );
      addTearDown(syncer.dispose);

      syncer.updateTasks([]);
      syncer.updatePlants([]);
      syncer.updateSettings(UserSettings.defaults());

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(stub.resyncCallCount, 1);
    });

    test('debounces rapid updates', () async {
      final stub = _StubNotificationsService();
      final syncer = TaskRemindersSyncer(
        notificationsService: stub,
        debounceDuration: const Duration(milliseconds: 100),
      );
      addTearDown(syncer.dispose);

      syncer.updateTasks([]);
      syncer.updatePlants([]);
      syncer.updateSettings(UserSettings.defaults());

      // Rapid updates
      syncer.updateTasks([]);
      syncer.updateTasks([]);
      syncer.updateTasks([]);

      await Future<void>.delayed(const Duration(milliseconds: 200));
      // Should have debounced to a single resync
      expect(stub.resyncCallCount, 1);
    });

    test('dispose cancels pending debounce', () async {
      final stub = _StubNotificationsService();
      final syncer = TaskRemindersSyncer(
        notificationsService: stub,
        debounceDuration: const Duration(milliseconds: 200),
      );

      syncer.updateTasks([]);
      syncer.updatePlants([]);
      syncer.updateSettings(UserSettings.defaults());

      syncer.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(stub.resyncCallCount, 0);
    });
  });
}
