import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/enums.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/plant.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaNotificationsService {
  BotanicaNotificationsService({this.onNotificationTap, this.onTaskAction});

  final void Function(String plantId)? onNotificationTap;
  final void Function(String taskId, String action)? onTaskAction;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _currentTimezoneName;

  static const _actionMarkDone = 'mark_done';
  static const _actionSnooze = 'snooze';

  static const _androidChannel = AndroidNotificationChannel(
    'botanica_tasks',
    'Plant care reminders',
    description: 'Reminders for watering and other care tasks in Botanica.',
    importance: Importance.high,
  );

  Future<void> ensureInitialized({Locale locale = const Locale('en')}) async {
    if (_initialized) return;

    tz.initializeTimeZones();
    await _configureLocalTimezone(force: true);

    final l10n = lookupAppLocalizations(locale);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'task_reminder',
          actions: [
            DarwinNotificationAction.plain(
              _actionMarkDone,
              l10n.notificationActionDone,
              options: {DarwinNotificationActionOption.destructive},
            ),
            DarwinNotificationAction.plain(
              _actionSnooze,
              l10n.notificationActionSnooze,
            ),
          ],
        ),
      ],
    );

    final settings = InitializationSettings(android: android, iOS: iOS);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(_androidChannel);

    _initialized = true;
  }

  void _handleNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map && decoded['type'] == 'task') {
        final taskId = decoded['taskId'] as String?;
        final plantId = decoded['plantId'] as String?;

        if (response.actionId == _actionMarkDone && taskId != null) {
          onTaskAction?.call(taskId, _actionMarkDone);
          return;
        }
        if (response.actionId == _actionSnooze && taskId != null) {
          onTaskAction?.call(taskId, _actionSnooze);
          return;
        }

        if (plantId != null && plantId.isNotEmpty) {
          onNotificationTap?.call(plantId);
        }
      }
    } catch (_) {}
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
    await _updateBadgeCount(0);
  }

  Future<void> clearBadge() async {
    await ensureInitialized();
    await _updateBadgeCount(0);
  }

  Future<void> scheduleTaskReminder({
    required TaskInstance task,
    required Plant plant,
    required UserSettings settings,
  }) async {
    await ensureInitialized(locale: settings.locale ?? const Locale('en'));
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
        actions: [
          AndroidNotificationAction(
            _actionMarkDone,
            l10n.notificationActionDone,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            _actionSnooze,
            l10n.notificationActionSnooze,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        categoryIdentifier: 'task_reminder',
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
    await ensureInitialized(locale: settings.locale ?? const Locale('en'));
    await _configureLocalTimezone(force: false);

    final now = DateTime.now();
    final latest = now.add(horizon);

    final overdue = tasks.where((t) =>
        !t.isDismissed && !t.dueAt.isAfter(now) && plantsById.containsKey(t.plantId));
    await _updateBadgeCount(overdue.length);

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
    final random = Random();
    final variant = random.nextInt(3); // 0, 1, or 2
    return switch (type) {
      TaskType.water => switch (variant) {
        0 => l10n.notificationWaterTitle(plant),
        1 => l10n.notificationWaterTitle2(plant),
        _ => l10n.notificationWaterTitle3(plant),
      },
      TaskType.fertilize => switch (variant) {
        0 => l10n.notificationFertilizeTitle(plant),
        1 => l10n.notificationFertilizeTitle2(plant),
        _ => l10n.notificationFertilizeTitle3(plant),
      },
      TaskType.mist => switch (variant) {
        0 => l10n.notificationMistTitle(plant),
        1 => l10n.notificationMistTitle2(plant),
        _ => l10n.notificationMistTitle3(plant),
      },
      TaskType.rotate => switch (variant) {
        0 => l10n.notificationRotateTitle(plant),
        1 => l10n.notificationRotateTitle2(plant),
        _ => l10n.notificationRotateTitle3(plant),
      },
      TaskType.prune => switch (variant) {
        0 => l10n.notificationPruneTitle(plant),
        1 => l10n.notificationPruneTitle2(plant),
        _ => l10n.notificationPruneTitle3(plant),
      },
      TaskType.repot => l10n.notificationsTaskTitle(plant, l10n.taskTypeRepot),
      TaskType.checkPests =>
        l10n.notificationsTaskTitle(plant, l10n.taskTypeCheckPests),
      TaskType.wipeLeaves =>
        l10n.notificationsTaskTitle(plant, l10n.taskTypeWipeLeaves),
      TaskType.sunlightAdjustment =>
        l10n.notificationsTaskTitle(plant, l10n.taskTypeSunlightAdjustment),
    };
  }

  Future<void> _updateBadgeCount(int count) async {
    final iOSImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iOSImpl != null) {
      // Badge-only silent local notification to update the app icon badge.
      // Immediately cancelled so no notification appears in Notification Center.
      const badgeOnlyId = 2147483646;
      await _plugin.show(
        badgeOnlyId,
        null,
        null,
        NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentSound: false,
            presentBadge: true,
            badgeNumber: count,
          ),
        ),
      );
      await _plugin.cancel(badgeOnlyId);
    }
  }

  static const int _dailySummaryId = 2147483600;

  Future<void> scheduleDailySummary({
    required int todayTaskCount,
    required UserSettings settings,
  }) async {
    await ensureInitialized();
    await _configureLocalTimezone(force: false);

    if (todayTaskCount <= 0) {
      await _plugin.cancel(_dailySummaryId);
      return;
    }

    final locale = settings.locale ?? const Locale('en');
    final l10n = lookupAppLocalizations(locale);

    final title = l10n.notificationDailySummaryTitle;
    final body = l10n.notificationDailySummaryBody(todayTaskCount);

    final hour = switch (settings.reminderTimePreference) {
      ReminderTimePreference.morning => 8,
      ReminderTimePreference.evening => 18,
    };

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      0,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: false,
      ),
    );

    await _plugin.zonedSchedule(
      _dailySummaryId,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelDailySummary() async {
    await ensureInitialized();
    await _plugin.cancel(_dailySummaryId);
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

  static const int _streakProtectionId = 2147483601;

  Future<void> scheduleStreakProtection({
    required UserSettings settings,
    required List<CareLog> todayLogs,
  }) async {
    await ensureInitialized();
    await _configureLocalTimezone(force: false);

    if (settings.careStreakDays < 3 || settings.isOnVacation) {
      await _plugin.cancel(_streakProtectionId);
      return;
    }

    if (todayLogs.isNotEmpty) {
      await _plugin.cancel(_streakProtectionId);
      return;
    }

    final locale = settings.locale ?? const Locale('en');
    final l10n = lookupAppLocalizations(locale);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20,
      0,
    );
    if (scheduled.isBefore(now)) {
      await _plugin.cancel(_streakProtectionId);
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: false,
      ),
    );

    await _plugin.zonedSchedule(
      _streakProtectionId,
      l10n.notificationStreakProtectionTitle(settings.careStreakDays),
      l10n.notificationStreakProtectionBody,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelStreakProtection() async {
    await ensureInitialized();
    await _plugin.cancel(_streakProtectionId);
  }
}
