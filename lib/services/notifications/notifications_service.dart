import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/enums.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/plant.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaNotificationsService {
  BotanicaNotificationsService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _currentTimezoneName;

  static const _androidChannel = AndroidNotificationChannel(
    'botanica_tasks',
    'Plant care reminders',
    description: 'Reminders for watering and other care tasks in Botanica.',
    importance: Importance.high,
  );

  Future<void> ensureInitialized() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    await _configureLocalTimezone(force: true);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: iOS);
    await _plugin.initialize(settings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(_androidChannel);

    _initialized = true;
  }

  Future<void> _configureLocalTimezone({required bool force}) async {
    String timezoneName;
    try {
      timezoneName = await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      timezoneName = 'UTC';
    }

    if (!force && timezoneName == _currentTimezoneName) return;

    try {
      tz.setLocalLocation(tz.getLocation(timezoneName));
      _currentTimezoneName = timezoneName;
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      _currentTimezoneName = 'UTC';
    }
  }

  /// Stable 31-bit notification id derived from a task id.
  ///
  /// Must remain stable across app launches; do NOT use String.hashCode.
  @visibleForTesting
  static int notificationIdForTaskId(String taskId) {
    final digest = sha1.convert(utf8.encode(taskId)).bytes;
    final value =
        (digest[0] << 24) | (digest[1] << 16) | (digest[2] << 8) | (digest[3]);
    final id = value & 0x7fffffff;
    return id == 0 ? 1 : id;
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await ensureInitialized();
    await _configureLocalTimezone(force: false);
    await _plugin.cancel(notificationIdForTaskId(taskId));
  }

  Future<void> cancelAll() async {
    await ensureInitialized();
    await _configureLocalTimezone(force: false);
    await _plugin.cancelAll();
  }

  Future<void> scheduleTaskReminder({
    required TaskInstance task,
    required Plant plant,
    required UserSettings settings,
  }) async {
    await ensureInitialized();
    await _configureLocalTimezone(force: false);

    if (task.isDone) {
      await cancelTaskReminder(task.id);
      return;
    }

    final now = DateTime.now();
    if (!task.dueAt.isAfter(now)) {
      // Don't schedule overdue reminders.
      await cancelTaskReminder(task.id);
      return;
    }

    final locale = settings.locale ?? const Locale('en');
    final l10n = lookupAppLocalizations(locale);

    final taskLabel = switch (task.type) {
      TaskType.water => l10n.taskTypeWater,
      TaskType.fertilize => l10n.taskTypeFertilize,
      TaskType.mist => l10n.taskTypeMist,
      TaskType.rotate => l10n.taskTypeRotate,
      TaskType.prune => l10n.taskTypePrune,
      TaskType.repot => l10n.taskTypeRepot,
      TaskType.checkPests => l10n.taskTypeCheckPests,
      TaskType.wipeLeaves => l10n.taskTypeWipeLeaves,
      TaskType.sunlightAdjustment => l10n.taskTypeSunlightAdjustment,
    };

    final title = l10n.notificationsTaskTitle(plant.nickname, taskLabel);
    final body = plant.room.trim().isEmpty
        ? l10n.notificationsTaskBodyNoRoom
        : l10n.notificationsTaskBodyRoom(plant.room);

    final id = notificationIdForTaskId(task.id);
    final scheduled = tz.TZDateTime.from(task.dueAt, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        styleInformation: const DefaultStyleInformation(true, true),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      payload: jsonEncode(<String, dynamic>{
        'type': 'task',
        'taskId': task.id,
        'plantId': plant.id,
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> resyncTaskReminders({
    required List<TaskInstance> tasks,
    required Map<String, Plant> plantsById,
    required UserSettings settings,
    Duration horizon = const Duration(days: 90),
    int maxScheduled = 64,
  }) async {
    await ensureInitialized();
    await _configureLocalTimezone(force: false);

    final now = DateTime.now();
    final latest = now.add(horizon);

    final pending = tasks
        .where((t) =>
            !t.isDone && t.dueAt.isAfter(now) && t.dueAt.isBefore(latest))
        .toList(growable: false)
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    final desiredTasks = <TaskInstance>[];
    for (final task in pending) {
      if (desiredTasks.length >= maxScheduled) break;
      if (!plantsById.containsKey(task.plantId)) continue;
      desiredTasks.add(task);
    }

    final desiredIds =
        desiredTasks.map((t) => notificationIdForTaskId(t.id)).toSet();

    // Avoid a "cancel all then reschedule" gap. If the app is killed mid-loop,
    // existing notifications remain scheduled.
    final existing = await _plugin.pendingNotificationRequests();
    final existingTaskIds = <int>{};
    for (final req in existing) {
      final payload = req.payload;
      if (payload == null || payload.trim().isEmpty) continue;
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map && decoded['type'] == 'task') {
          existingTaskIds.add(req.id);
        }
      } catch (_) {
        // Ignore invalid payloads from older versions or other notifications.
      }
    }

    for (final task in desiredTasks) {
      final plant = plantsById[task.plantId]!;
      await scheduleTaskReminder(task: task, plant: plant, settings: settings);
    }

    final toCancel = existingTaskIds.difference(desiredIds);
    for (final id in toCancel) {
      await _plugin.cancel(id);
    }
  }
}
