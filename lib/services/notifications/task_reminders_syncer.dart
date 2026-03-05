import 'dart:async';

import '../../domain/models/plant.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/models/user_settings.dart';
import 'notifications_service.dart';

/// Debounces and syncs local notification schedules whenever the task list,
/// plant list, or user settings change.
///
/// Extracted from providers.dart for testability.
class TaskRemindersSyncer {
  TaskRemindersSyncer({
    required BotanicaNotificationsService notificationsService,
    this.debounceDuration = const Duration(milliseconds: 350),
  }) : _notificationsService = notificationsService;

  final BotanicaNotificationsService _notificationsService;
  final Duration debounceDuration;

  Timer? _debounce;
  List<TaskInstance>? _latestTasks;
  List<Plant>? _latestPlants;
  UserSettings? _latestSettings;

  void updateTasks(List<TaskInstance>? tasks) {
    _latestTasks = tasks;
    _scheduleDebounced();
  }

  void updatePlants(List<Plant>? plants) {
    _latestPlants = plants;
    _scheduleDebounced();
  }

  void updateSettings(UserSettings? settings) {
    _latestSettings = settings;
    _scheduleDebounced();
  }

  void _scheduleDebounced() {
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () {
      unawaited(_resync());
    });
  }

  Future<void> _resync() async {
    final tasks = _latestTasks;
    final plants = _latestPlants;
    final settings = _latestSettings;
    if (tasks == null || plants == null || settings == null) return;

    final plantsById = <String, Plant>{
      for (final p in plants) p.id: p,
    };

    await _notificationsService.resyncTaskReminders(
      tasks: tasks,
      plantsById: plantsById,
      settings: settings,
    );
  }

  void dispose() {
    _debounce?.cancel();
  }
}
