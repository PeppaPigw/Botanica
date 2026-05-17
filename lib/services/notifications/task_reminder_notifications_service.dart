import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/enums.dart';
import '../../domain/models/task_instance.dart';
import 'task_reminder_notification_id.dart';

typedef LocalTimezoneNameProvider = Future<String> Function();

class TaskReminderNotificationContent {
  const TaskReminderNotificationContent({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

typedef TaskReminderContentBuilder = TaskReminderNotificationContent Function(
  TaskInstance task,
);

abstract interface class TaskReminderNotificationsService {
  Future<void> init();
  Future<bool> requestPermission();

  Future<void> scheduleForTask(
    TaskInstance task, {
    DateTime? reminderAt,
    TaskReminderNotificationContent? content,
  });

  Future<void> cancelForTask(TaskInstance task);

  Future<void> resyncAllTasks(
    Iterable<TaskInstance> tasks, {
    DateTime? Function(TaskInstance task)? reminderAtResolver,
    TaskReminderContentBuilder? contentBuilder,
  });
}

class FlutterLocalTaskReminderNotificationsService
    implements TaskReminderNotificationsService {
  FlutterLocalTaskReminderNotificationsService({
    required LocalTimezoneNameProvider localTimezoneNameProvider,
    FlutterLocalNotificationsPlugin? plugin,
    String androidChannelId = 'task_reminders',
    String androidChannelName = 'Task reminders',
    String androidChannelDescription = 'Task reminder notifications',
    String androidIcon = '@mipmap/ic_launcher',
    this.onMarkDone,
    this.onSnooze,
  })  : _localTimezoneNameProvider = localTimezoneNameProvider,
        _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _androidChannelId = androidChannelId,
        _androidChannelName = androidChannelName,
        _androidChannelDescription = androidChannelDescription,
        _androidIcon = androidIcon;

  final LocalTimezoneNameProvider _localTimezoneNameProvider;
  final FlutterLocalNotificationsPlugin _plugin;

  final String _androidChannelId;
  final String _androidChannelName;
  final String _androidChannelDescription;
  final String _androidIcon;

  final void Function(String taskId)? onMarkDone;
  final void Function(String taskId)? onSnooze;

  static const _actionMarkDone = 'mark_done';
  static const _actionSnooze = 'snooze';

  Future<void>? _init;
  String? _currentTimezoneName;

  @override
  Future<void> init() {
    _init ??= _initInternal();
    return _init!;
  }

  Future<void> _initInternal() async {
    tz_data.initializeTimeZones();
    await _configureLocalTimezone(force: true);

    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final androidSettings = AndroidInitializationSettings(_androidIcon);

    await _plugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iOSSettings),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          description: _androidChannelDescription,
          importance: Importance.high,
        ),
      );
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final taskId = taskInstanceIdFromTaskReminderPayload(response.payload);
    if (taskId == null) return;

    switch (response.actionId) {
      case _actionMarkDone:
        onMarkDone?.call(taskId);
      case _actionSnooze:
        onSnooze?.call(taskId);
    }
  }

  @override
  Future<bool> requestPermission() async {
    await init();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();

    final results = await Future.wait<bool?>([
      if (android != null) android.requestNotificationsPermission(),
      if (ios != null)
        ios.requestPermissions(alert: true, badge: true, sound: true),
      if (macos != null)
        macos.requestPermissions(alert: true, badge: true, sound: true),
    ]);

    return results.whereType<bool>().any((granted) => granted);
  }

  @override
  Future<void> scheduleForTask(
    TaskInstance task, {
    DateTime? reminderAt,
    TaskReminderNotificationContent? content,
  }) async {
    await init();
    await _configureLocalTimezone(force: false);

    await _scheduleForTaskInternal(
      task,
      reminderAt: reminderAt,
      content: content,
      now: DateTime.now(),
    );
  }

  @override
  Future<void> cancelForTask(TaskInstance task) async {
    await init();
    await _plugin.cancel(taskReminderNotificationIdForTask(task));
  }

  @override
  Future<void> resyncAllTasks(
    Iterable<TaskInstance> tasks, {
    DateTime? Function(TaskInstance task)? reminderAtResolver,
    TaskReminderContentBuilder? contentBuilder,
  }) async {
    await init();
    await _configureLocalTimezone(force: false);

    final now = DateTime.now();
    final desiredById = <int, String>{};
    for (final task in tasks) {
      final scheduledAt =
          (reminderAtResolver?.call(task) ?? task.dueAt).toLocal();
      if (task.isDismissed) continue;
      if (!scheduledAt.isAfter(now)) continue;

      final id = taskReminderNotificationIdForTask(task);
      desiredById[id] = taskReminderNotificationPayload(task.id);
    }

    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      final taskId = taskInstanceIdFromTaskReminderPayload(request.payload);
      if (taskId == null) continue;

      final expectedPayload = desiredById[request.id];
      if (expectedPayload == null || request.payload != expectedPayload) {
        await _plugin.cancel(request.id);
      }
    }

    for (final task in tasks) {
      await _scheduleForTaskInternal(
        task,
        reminderAt: reminderAtResolver?.call(task),
        content: contentBuilder?.call(task),
        now: now,
      );
    }
  }

  Future<void> _scheduleForTaskInternal(
    TaskInstance task, {
    required DateTime now,
    DateTime? reminderAt,
    TaskReminderNotificationContent? content,
  }) async {
    final id = taskReminderNotificationIdForTask(task);

    if (task.isDismissed) {
      await _plugin.cancel(id);
      return;
    }

    final scheduledAt = (reminderAt ?? task.dueAt).toLocal();
    if (!scheduledAt.isAfter(now)) {
      await _plugin.cancel(id);
      return;
    }

    final resolvedContent = content ?? _defaultContentFor(task);

    await _plugin.cancel(id);
    await _plugin.zonedSchedule(
      id,
      resolvedContent.title,
      resolvedContent.body,
      _toLocalTzDateTime(scheduledAt),
      _notificationDetails(),
      payload: taskReminderNotificationPayload(task.id),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _configureLocalTimezone({required bool force}) async {
    String? timezoneName;
    try {
      timezoneName = await _localTimezoneNameProvider();
    } catch (_) {
      timezoneName = null;
    }

    if (timezoneName == null || timezoneName.isEmpty) {
      if (!force && _currentTimezoneName != null) return;
      tz.setLocalLocation(tz.getLocation('UTC'));
      _currentTimezoneName ??= 'UTC';
      return;
    }

    if (!force && timezoneName == _currentTimezoneName) return;

    try {
      tz.setLocalLocation(tz.getLocation(timezoneName));
      _currentTimezoneName = timezoneName;
    } catch (_) {
      if (_currentTimezoneName == null) {
        tz.setLocalLocation(tz.getLocation('UTC'));
        _currentTimezoneName = 'UTC';
      }
    }
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

  NotificationDetails _notificationDetails() {
    final android = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      actions: const [
        AndroidNotificationAction(
          _actionMarkDone,
          'Done',
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          _actionSnooze,
          'Snooze 1h',
        ),
      ],
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      categoryIdentifier: 'task_reminder',
    );

    return NotificationDetails(android: android, iOS: ios);
  }

  TaskReminderNotificationContent _defaultContentFor(TaskInstance task) {
    final verb = switch (task.type) {
      TaskType.water => 'Water',
      TaskType.fertilize => 'Fertilize',
      TaskType.mist => 'Mist',
      TaskType.rotate => 'Rotate',
      TaskType.prune => 'Prune',
      TaskType.repot => 'Repot',
      TaskType.checkPests => 'Check pests',
      TaskType.wipeLeaves => 'Wipe leaves',
      TaskType.sunlightAdjustment => 'Adjust sunlight',
    };

    return TaskReminderNotificationContent(
      title: switch (task.type) {
        TaskType.water => 'Time to water your plant',
        TaskType.fertilize => 'Fertilize your plant today',
        TaskType.mist => 'Your plant would love some misting',
        TaskType.rotate => 'Give your plant a quarter turn',
        TaskType.prune => 'Your plant is ready for pruning',
        _ => 'Plant care reminder',
      },
      body: '$verb task is due.',
    );
  }
}
