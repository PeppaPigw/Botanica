import 'package:uuid/uuid.dart';

import '../../data/repositories/logs_repository.dart';
import '../../data/repositories/plant_idea_repository.dart';
import '../../data/repositories/species_repository.dart';
import '../../data/repositories/tasks_repository.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/environment_snapshot.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/care_schedule_snapshot.dart';
import '../../domain/services/scheduling.dart';
import '../../domain/services/seasonal_care_engine.dart';
import '../../gen/l10n/app_localizations.dart';

class CareActions {
  const CareActions._();

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static bool _hasTaskOnDate({
    required TasksRepository tasksRepository,
    required String plantId,
    required TaskType taskType,
    required DateTime dueAt,
  }) {
    final targetDate = _dateOnly(dueAt);
    return tasksRepository.getAll().any(
          (task) =>
              task.plantId == plantId &&
              task.type == taskType &&
              _dateOnly(task.dueAt) == targetDate,
        );
  }

  static Future<TaskInstance?> _scheduleNextTask({
    required TaskInstance task,
    required Plant plant,
    required DateTime now,
    required TasksRepository tasksRepository,
    required SpeciesRepository speciesRepository,
    required PlantIdeaRepository plantIdeaRepository,
    required SeasonalCareEngine seasonalEngine,
    required EnvironmentSnapshot environment,
    required UserSettings settings,
  }) async {
    // Respect per-plant care type overrides.
    if (plant.careOverrideFor(task.type) == CareTypeOverride.disabled) {
      return null;
    }

    final species = await speciesRepository.byId(plant.speciesId);
    final idea = await plantIdeaRepository.byId(plant.speciesId);

    final int baseDays = switch (task.type) {
      TaskType.water => idea?.careDefaults.waterBaseDays ??
          species?.careDefaults.waterBaseDays ??
          7,
      TaskType.fertilize => idea?.careDefaults.fertilizeBaseDays ??
          species?.careDefaults.fertilizeBaseDays ??
          30,
      TaskType.mist => idea?.careDefaults.mistBaseDays ??
          species?.careDefaults.mistBaseDays ??
          0,
      TaskType.rotate => idea?.careDefaults.rotateBaseDays ??
          species?.careDefaults.rotateBaseDays ??
          14,
      TaskType.prune => idea?.careDefaults.pruneBaseDays ??
          species?.careDefaults.pruneBaseDays ??
          90,
      _ => 14,
    };

    if (baseDays <= 0) return null;

    CareScheduleDecision? decision;
    if (task.type == TaskType.water ||
        task.type == TaskType.mist ||
        task.type == TaskType.fertilize) {
      decision = seasonalEngine.computeSchedule(
        taskType: task.type,
        now: now,
        environment: environment,
        hemisphere: settings.hemisphere,
        environmentMode: plant.environmentMode,
        plantIdea: idea,
        fallbackBaseDays: switch (task.type) {
          TaskType.water => species?.careDefaults.waterBaseDays,
          TaskType.fertilize => species?.careDefaults.fertilizeBaseDays,
          TaskType.mist => species?.careDefaults.mistBaseDays,
          TaskType.rotate => species?.careDefaults.rotateBaseDays,
          TaskType.prune => species?.careDefaults.pruneBaseDays,
          _ => null,
        },
      );
    }

    if (decision?.dueAt == null && decision != null) return null;

    final dueAt = alignToPreferredReminderTime(
      date: decision?.dueAt ?? addLocalCalendarDays(now, baseDays),
      preference: settings.reminderTimePreference,
      override: plant.reminderTimeOverride,
    );

    if (_hasTaskOnDate(
      tasksRepository: tasksRepository,
      plantId: plant.id,
      taskType: task.type,
      dueAt: dueAt,
    )) {
      return null;
    }

    final nextTask = TaskInstance(
      id: const Uuid().v4(),
      plantId: plant.id,
      type: task.type,
      dueAt: dueAt,
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: decision?.snapshot.reasonIds ?? const <String>[],
      scheduleSnapshot: decision?.snapshot,
    );

    await tasksRepository.upsert(nextTask);
    return nextTask;
  }

  static UserSettings updatedSettingsAfterCare({
    required UserSettings settings,
    required DateTime now,
  }) {
    final today = _dateOnly(now);
    final last = settings.lastCareDate;

    if (last == null) {
      return settings.copyWith(
        careStreakDays: 1,
        longestStreak: settings.longestStreak < 1 ? 1 : settings.longestStreak,
        lastCareDate: today,
      );
    }

    final lastDay = _dateOnly(last);
    final diffDays = today.difference(lastDay).inDays;

    final normalizedBase =
        settings.careStreakDays < 1 ? 1 : settings.careStreakDays;

    final int nextStreak;
    int freezeCount = settings.streakFreezeCount;
    DateTime? freezeUsedDate = settings.lastStreakFreezeUsed;

    if (diffDays == 0) {
      nextStreak = normalizedBase;
    } else if (diffDays == 1) {
      nextStreak = normalizedBase + 1;
    } else if (diffDays == 2 && freezeCount > 0 && normalizedBase >= 2) {
      nextStreak = normalizedBase + 1;
      freezeCount -= 1;
      freezeUsedDate = today;
    } else if (settings.isOnVacation) {
      nextStreak = normalizedBase + 1;
    } else {
      nextStreak = 1;
    }

    final earnedFreeze =
        nextStreak > 0 && nextStreak % 7 == 0 && nextStreak > normalizedBase;
    if (earnedFreeze) freezeCount += 1;

    return settings.copyWith(
      careStreakDays: nextStreak,
      longestStreak:
          nextStreak > settings.longestStreak ? nextStreak : null,
      lastCareDate: today,
      streakFreezeCount: freezeCount,
      lastStreakFreezeUsed: freezeUsedDate,
    );
  }

  static const List<int> streakMilestones = [7, 30, 90, 365];

  static int? newMilestoneReached(int newStreak, int lastCelebrated) {
    for (final m in streakMilestones) {
      if (newStreak >= m && m > lastCelebrated) return m;
    }
    return null;
  }

  static UserSettings recordPerfectDay(UserSettings settings, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final lastPerfect = settings.lastPerfectDate;
    final yesterday = today.subtract(const Duration(days: 1));

    int newCount;
    if (lastPerfect != null &&
        DateTime(lastPerfect.year, lastPerfect.month, lastPerfect.day) ==
            yesterday) {
      newCount = settings.consecutivePerfectDays + 1;
    } else if (lastPerfect != null &&
        DateTime(lastPerfect.year, lastPerfect.month, lastPerfect.day) ==
            today) {
      return settings;
    } else {
      newCount = 1;
    }

    return settings.copyWith(
      consecutivePerfectDays: newCount,
      lastPerfectDate: today,
    );
  }

  static bool isPerfectWeek(UserSettings settings) {
    return settings.consecutivePerfectDays >= 7 &&
        settings.consecutivePerfectDays % 7 == 0;
  }

  /// Returns a care confidence insight based on the user's watering rhythm.
  /// Returns null if not enough data (< 3 water logs for this plant).
  static String? careConfidenceInsight({
    required AppLocalizations l10n,
    required List<CareLog> plantLogs,
    required TaskType taskType,
  }) {
    if (taskType != TaskType.water) return null;

    final waterLogs = plantLogs
        .where((l) => l.type == TaskType.water)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (waterLogs.length < 3) return null;

    // Compute average interval from last 10 waterings
    final recent = waterLogs.length > 10
        ? waterLogs.sublist(waterLogs.length - 10)
        : waterLogs;

    final intervals = <int>[];
    for (int i = 1; i < recent.length; i++) {
      intervals.add(
        recent[i].timestamp.difference(recent[i - 1].timestamp).inDays,
      );
    }

    if (intervals.isEmpty) return null;

    final avgInterval =
        intervals.fold<int>(0, (s, v) => s + v) / intervals.length;

    // The new log was just added, so waterLogs.last IS the one we just did.
    // The interval is between the previous-last water and now.
    final previousWater = waterLogs[waterLogs.length - 2].timestamp;
    final currentInterval = DateTime.now().difference(previousWater).inDays;

    final diff = currentInterval - avgInterval;

    if (diff.abs() <= 1) {
      return l10n.careConfidenceOnSchedule(avgInterval.round());
    } else if (diff < -1) {
      return l10n.careConfidenceEarly;
    } else {
      return l10n.careConfidenceLate;
    }
  }

  static bool isNewPersonalBest({
    required int previousLongest,
    required int currentStreak,
  }) {
    return currentStreak > previousLongest && previousLongest > 0;
  }

  static bool streakFreezeWasUsed({
    required UserSettings previousSettings,
    required UserSettings currentSettings,
  }) {
    return currentSettings.streakFreezeCount < previousSettings.streakFreezeCount;
  }

  static bool streakFreezeWasEarned({
    required UserSettings previousSettings,
    required UserSettings currentSettings,
  }) {
    return currentSettings.streakFreezeCount > previousSettings.streakFreezeCount;
  }

  static DateTime snoozeUntilTomorrow({
    required DateTime now,
    required Plant plant,
    required UserSettings settings,
  }) {
    return alignToPreferredReminderTime(
      date: addLocalCalendarDays(now, 1),
      preference: settings.reminderTimePreference,
      override: plant.reminderTimeOverride,
    );
  }

  static DateTime snoozeForDuration({
    required DateTime now,
    required Plant plant,
    required UserSettings settings,
    required SnoozeDuration duration,
  }) {
    switch (duration) {
      case SnoozeDuration.oneHour:
        return now.add(const Duration(hours: 1));
      case SnoozeDuration.threeHours:
        return now.add(const Duration(hours: 3));
      case SnoozeDuration.tomorrow:
        return alignToPreferredReminderTime(
          date: addLocalCalendarDays(now, 1),
          preference: settings.reminderTimePreference,
          override: plant.reminderTimeOverride,
        );
      case SnoozeDuration.tomorrowMorning:
        final tomorrow = addLocalCalendarDays(now, 1);
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8);
      case SnoozeDuration.weekend:
        var target = now;
        while (target.weekday != DateTime.saturday) {
          target = addLocalCalendarDays(target, 1);
        }
        return DateTime(target.year, target.month, target.day, 9);
    }
  }

  /// Records a "water now" action:
  /// - marks the pending water task done (if provided),
  /// - writes a `CareLog`,
  /// - schedules the next water task using the care plan engine.
  static Future<TaskInstance?> waterNow({
    required Plant plant,
    required DateTime now,
    TaskInstance? pendingWaterTask,
    required TasksRepository tasksRepository,
    required LogsRepository logsRepository,
    required SpeciesRepository speciesRepository,
    required PlantIdeaRepository plantIdeaRepository,
    required SeasonalCareEngine seasonalEngine,
    required EnvironmentSnapshot environment,
    required UserSettings settings,
    required Future<void> Function(UserSettings settings) updateSettings,
  }) async {
    final pending = pendingWaterTask;
    if (pending != null && !pending.isDone) {
      await tasksRepository.upsert(
        pending.copyWith(
          status: TaskStatus.done,
          completedAt: now,
        ),
      );
    }

    await logsRepository.add(
      CareLog(
        id: const Uuid().v4(),
        plantId: plant.id,
        type: TaskType.water,
        timestamp: now,
        note: null,
        linkedPhotoId: null,
      ),
    );

    final nextSettings = updatedSettingsAfterCare(settings: settings, now: now);
    if (nextSettings != settings) {
      await updateSettings(nextSettings);
    }

    return _scheduleNextTask(
      task: pending ??
          TaskInstance(
            id: '',
            plantId: plant.id,
            type: TaskType.water,
            dueAt: now,
            status: TaskStatus.done,
            createdAt: now,
            completedAt: now,
            adjustmentReasonIds: const <String>[],
          ),
      plant: plant,
      now: now,
      tasksRepository: tasksRepository,
      speciesRepository: speciesRepository,
      plantIdeaRepository: plantIdeaRepository,
      seasonalEngine: seasonalEngine,
      environment: environment,
      settings: settings,
    );
  }

  /// Completes an existing task instance:
  /// - marks the task done,
  /// - writes a `CareLog`,
  /// - schedules the next task based on the species defaults (water uses
  ///   environment adjustments).
  static Future<TaskInstance?> completeTask({
    required TaskInstance task,
    required Plant plant,
    required DateTime now,
    required TasksRepository tasksRepository,
    required LogsRepository logsRepository,
    required SpeciesRepository speciesRepository,
    required PlantIdeaRepository plantIdeaRepository,
    required SeasonalCareEngine seasonalEngine,
    required EnvironmentSnapshot environment,
    required UserSettings settings,
    required Future<void> Function(UserSettings settings) updateSettings,
  }) async {
    if (!task.isDone) {
      await tasksRepository.upsert(
        task.copyWith(
          status: TaskStatus.done,
          completedAt: now,
        ),
      );
    }

    await logsRepository.add(
      CareLog(
        id: const Uuid().v4(),
        plantId: plant.id,
        type: task.type,
        timestamp: now,
        note: null,
        linkedPhotoId: null,
      ),
    );

    final nextSettings = updatedSettingsAfterCare(settings: settings, now: now);
    if (nextSettings != settings) {
      await updateSettings(nextSettings);
    }

    return _scheduleNextTask(
      task: task,
      plant: plant,
      now: now,
      tasksRepository: tasksRepository,
      speciesRepository: speciesRepository,
      plantIdeaRepository: plantIdeaRepository,
      seasonalEngine: seasonalEngine,
      environment: environment,
      settings: settings,
    );
  }

  static Future<TaskInstance?> skipTask({
    required TaskInstance task,
    required Plant plant,
    required DateTime now,
    required TasksRepository tasksRepository,
    required SpeciesRepository speciesRepository,
    required PlantIdeaRepository plantIdeaRepository,
    required SeasonalCareEngine seasonalEngine,
    required EnvironmentSnapshot environment,
    required UserSettings settings,
  }) async {
    if (!task.isDismissed) {
      await tasksRepository.upsert(
        task.copyWith(
          status: TaskStatus.skipped,
        ),
      );
    }

    return _scheduleNextTask(
      task: task,
      plant: plant,
      now: now,
      tasksRepository: tasksRepository,
      speciesRepository: speciesRepository,
      plantIdeaRepository: plantIdeaRepository,
      seasonalEngine: seasonalEngine,
      environment: environment,
      settings: settings,
    );
  }

  /// Reschedules pending tasks if the plant's environment mode changes.
  static Future<void> reschedulePendingTasksIfNeeded({
    required Plant oldPlant,
    required Plant newPlant,
    required TasksRepository tasksRepository,
    required SpeciesRepository speciesRepository,
    required PlantIdeaRepository plantIdeaRepository,
    required SeasonalCareEngine seasonalEngine,
    required EnvironmentSnapshot environment,
    required UserSettings settings,
  }) async {
    if (oldPlant.environmentMode == newPlant.environmentMode &&
        oldPlant.reminderTimeOverride == newPlant.reminderTimeOverride) {
      return;
    }

    final now = DateTime.now();
    final species = await speciesRepository.byId(newPlant.speciesId);
    final idea = await plantIdeaRepository.byId(newPlant.speciesId);

    final waterDecision = seasonalEngine.computeSchedule(
      taskType: TaskType.water,
      now: now,
      environment: environment,
      hemisphere: settings.hemisphere,
      environmentMode: newPlant.environmentMode,
      plantIdea: idea,
      fallbackBaseDays: species?.careDefaults.waterBaseDays,
    );

    final mistDecision = ((idea?.careDefaults.mistBaseDays ?? 0) > 0 ||
            (species?.careDefaults.mistBaseDays ?? 0) > 0)
        ? seasonalEngine.computeSchedule(
            taskType: TaskType.mist,
            now: now,
            environment: environment,
            hemisphere: settings.hemisphere,
            environmentMode: newPlant.environmentMode,
            plantIdea: idea,
            fallbackBaseDays: species?.careDefaults.mistBaseDays,
          )
        : null;

    final fertilizeDecision = seasonalEngine.computeSchedule(
      taskType: TaskType.fertilize,
      now: now,
      environment: environment,
      hemisphere: settings.hemisphere,
      environmentMode: newPlant.environmentMode,
      plantIdea: idea,
      fallbackBaseDays: species?.careDefaults.fertilizeBaseDays,
    );

    final pendingTasks = tasksRepository
        .getAll()
        .where(
            (t) => t.plantId == newPlant.id && t.status == TaskStatus.pending)
        .toList();
    final toUpsert = <TaskInstance>[];

    TaskInstance? pendingTaskFor(TaskType type) {
      final matches = pendingTasks
          .where((task) => task.type == type)
          .toList(growable: false);
      if (matches.isEmpty) return null;
      return matches.first;
    }

    void adjustTask(TaskInstance? pending, CareScheduleSnapshot? snap) {
      if (snap == null || pending == null) return;

      final cycleStartLine = pending.completedAt ?? pending.createdAt;
      final dueAt = alignToPreferredReminderTime(
        date: addLocalCalendarDays(cycleStartLine, snap.adjustedDays),
        preference: settings.reminderTimePreference,
        override: newPlant.reminderTimeOverride,
      );

      toUpsert.add(pending.copyWith(
        dueAt: dueAt,
        scheduleSnapshot: snap,
        adjustmentReasonIds: snap.reasonIds,
      ));
    }

    adjustTask(
      pendingTaskFor(TaskType.water),
      waterDecision.snapshot,
    );
    if (mistDecision != null) {
      adjustTask(
        pendingTaskFor(TaskType.mist),
        mistDecision.snapshot,
      );
    }
    adjustTask(
      pendingTaskFor(TaskType.fertilize),
      fertilizeDecision.snapshot,
    );

    if (toUpsert.isNotEmpty) {
      await tasksRepository.upsertMany(toUpsert);
    }
  }
}
