import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:botanica/app/providers.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/services/notifications/task_reminders_syncer.dart';
import 'package:botanica/services/notifications/notifications_service.dart';

class _TestSettingsController extends SettingsController {
  _TestSettingsController(this._settings);

  final UserSettings _settings;

  @override
  UserSettings build() => _settings;
}

class _ResyncRequest {
  const _ResyncRequest({
    required this.tasks,
    required this.plantsById,
    required this.settings,
  });

  final List<TaskInstance> tasks;
  final Map<String, Plant> plantsById;
  final UserSettings settings;
}

/// Minimal stub that records calls without touching the notification plugin.
class _StubNotificationsService extends BotanicaNotificationsService {
  int resyncCallCount = 0;
  final requests = <_ResyncRequest>[];

  @override
  Future<void> resyncTaskReminders({
    required List<TaskInstance> tasks,
    required Map<String, Plant> plantsById,
    required UserSettings settings,
    Duration horizon = const Duration(days: 90),
    int maxScheduled = 64,
  }) async {
    resyncCallCount++;
    requests.add(_ResyncRequest(
      tasks: tasks,
      plantsById: plantsById,
      settings: settings,
    ));
  }
}

Plant _plant(String id) => Plant(
      id: id,
      nickname: 'Aloe',
      speciesId: 'aloe_vera',
      room: 'Living room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: 'assets/placeholders/species/unknown.png',
      createdAt: DateTime(2026, 4, 26),
      meta: const PlantMeta(),
    );

TaskInstance _task({
  required String id,
  required String plantId,
  required TaskStatus status,
  DateTime? dueAt,
}) =>
    TaskInstance(
      id: id,
      plantId: plantId,
      type: TaskType.water,
      dueAt: dueAt ?? DateTime.now().add(const Duration(days: 1)),
      status: status,
      createdAt: DateTime(2026, 4, 26),
      completedAt: status == TaskStatus.done ? DateTime(2026, 4, 26, 10) : null,
      adjustmentReasonIds: const <String>[],
    );

Future<void> _waitForResync(
  _StubNotificationsService stub,
  int minimumCount,
) async {
  for (var i = 0; i < 20; i++) {
    if (stub.resyncCallCount >= minimumCount) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
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

  group('taskRemindersSyncProvider', () {
    test('resyncs reminders when task stream reflects completion and next task',
        () async {
      final stub = _StubNotificationsService();
      final tasksController = StreamController<List<TaskInstance>>.broadcast();
      final plantsController = StreamController<List<Plant>>.broadcast();
      final settings = UserSettings.defaults().copyWith(
        reminderTimePreference: ReminderTimePreference.evening,
      );
      final plant = _plant('plant-1');
      final completedTask = _task(
        id: 'task-done',
        plantId: plant.id,
        status: TaskStatus.done,
      );
      final nextTask = _task(
        id: 'task-next',
        plantId: plant.id,
        status: TaskStatus.pending,
        dueAt: DateTime.now().add(const Duration(days: 7)),
      );

      final container = ProviderContainer(
        overrides: [
          notificationsServiceProvider.overrideWithValue(stub),
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(settings),
          ),
          tasksStreamProvider.overrideWith((ref) => tasksController.stream),
          plantsStreamProvider.overrideWith((ref) => plantsController.stream),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await tasksController.close();
        await plantsController.close();
      });

      container.read(taskRemindersSyncProvider);
      tasksController.add(<TaskInstance>[completedTask, nextTask]);
      plantsController.add(<Plant>[plant]);

      await _waitForResync(stub, 1);

      expect(stub.resyncCallCount, 1);
      final request = stub.requests.single;
      expect(request.tasks.map((task) => task.id), <String>[
        completedTask.id,
        nextTask.id,
      ]);
      expect(request.plantsById.keys, <String>{plant.id});
      expect(
        request.settings.reminderTimePreference,
        ReminderTimePreference.evening,
      );
    });
  });
}
