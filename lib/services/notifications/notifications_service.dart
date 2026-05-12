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

  @visibleForTesting
  static int notificationIdForPlantTask(String plantId, TaskType taskType) {
    final digest =
        sha1.convert(utf8.encode('$plantId:${taskType.id}')).bytes;
    final value =
        (digest[0] << 24) | (digest[1] << 16) | (digest[2] << 8) | (digest[3]);
    final id = value & 0x7fffffff;
    return id == 0 ? 1 : id;
  }

  Future<void> cancelTaskReminder(TaskInstance task) async {
    await ensureInitialized();
    await _configureLocalTimezone(force: false);
    await _plugin.cancel(notificationIdForPlantTask(task.plantId, task.type));
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

    if (task.isDismissed) {
      await cancelTaskReminder(task);
      return;
    }

    final now = DateTime.now();
    if (!task.dueAt.isAfter(now)) {
      await cancelTaskReminder(task);
      return;
    }

    final locale = settings.locale ?? const Locale('en');
    final l10n = lookupAppLocalizations(locale);

    final title =
        notificationTitleForTaskType(l10n, task.type, plant.nickname);
    final body = plant.room.trim().isEmpty
        ? l10n.notificationsTaskBodyNoRoom
        : l10n.notificationsTaskBodyRoom(plant.room);

    final id = notificationIdForPlantTask(task.plantId, task.type);
    final scheduled = _toLocalTzDateTime(task.dueAt);

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
        'taskType': task.type.id,
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
            !t.isDismissed && t.dueAt.isAfter(now) && t.dueAt.isBefore(latest))
        .toList(growable: false)
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    final desiredTasks = <TaskInstance>[];
    for (final task in pending) {
      if (desiredTasks.length >= maxScheduled) break;
      if (!plantsById.containsKey(task.plantId)) continue;
      desiredTasks.add(task);
    }

    final desiredIds =
        desiredTasks.map((t) => notificationIdForPlantTask(t.plantId, t.type)).toSet();

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
        continue;
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

  @visibleForTesting
  static String notificationTitleForTaskType(
    AppLocalizations l10n,
    TaskType type,
    String plant,
  ) {
    return switch (type) {
      TaskType.water => l10n.notificationWaterTitle(plant),
      TaskType.fertilize => l10n.notificationFertilizeTitle(plant),
      TaskType.mist => l10n.notificationMistTitle(plant),
      TaskType.rotate => l10n.notificationRotateTitle(plant),
      TaskType.prune => l10n.notificationPruneTitle(plant),
      TaskType.repot => l10n.notificationsTaskTitle(plant, l10n.taskTypeRepot),
      TaskType.checkPests =>
        l10n.notificationsTaskTitle(plant, l10n.taskTypeCheckPests),
      TaskType.wipeLeaves =>
        l10n.notificationsTaskTitle(plant, l10n.taskTypeWipeLeaves),
      TaskType.sunlightAdjustment =>
        l10n.notificationsTaskTitle(plant, l10n.taskTypeSunlightAdjustment),
    };
  }

  tz.TZDateTime _toLocalTzDateTime(DateTime dateTimeLocal) {
    final local = dateTimeLocal.toLocal();
    return tz.TZDateTime(
      tz.local,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    );
  }
}
