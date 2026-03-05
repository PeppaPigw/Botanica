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
import '../../domain/services/care_plan_engine.dart';
import '../../domain/services/scheduling.dart';

class CareActions {
  const CareActions._();

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static UserSettings updatedSettingsAfterCare({
    required UserSettings settings,
    required DateTime now,
  }) {
    final today = _dateOnly(now);
    final last = settings.lastCareDate;

    if (last == null) {
      return settings.copyWith(
        careStreakDays: 1,
        lastCareDate: today,
      );
    }

    final lastDay = _dateOnly(last);
    final diffDays = today.difference(lastDay).inDays;

    final normalizedBase =
        settings.careStreakDays < 1 ? 1 : settings.careStreakDays;

    final int nextStreak = switch (diffDays) {
      0 => normalizedBase,
      1 => normalizedBase + 1,
      _ => 1,
    };

    return settings.copyWith(
      careStreakDays: nextStreak,
      lastCareDate: today,
    );
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
    required CarePlanEngine engine,
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

    final species = await speciesRepository.byId(plant.speciesId);
    final idea = await plantIdeaRepository.byId(plant.speciesId);
    final baseWaterDays = idea?.careDefaults.waterBaseDays ??
        species?.careDefaults.waterBaseDays ??
        7;
    if (baseWaterDays <= 0) return null;

    final adjustment = engine.adjustInterval(
      taskType: TaskType.water,
      baseDays: baseWaterDays,
      environment: environment,
      environmentMode: plant.environmentMode,
      hemisphere: settings.hemisphere,
      now: now,
    );

    final dueAt = alignToReminderTime(
      now.add(Duration(days: adjustment.adjustedDays)),
      settings.reminderTimePreference,
    );

    final nextTask = TaskInstance(
      id: const Uuid().v4(),
      plantId: plant.id,
      type: TaskType.water,
      dueAt: dueAt,
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: adjustment.reasonIds,
    );

    await tasksRepository.upsert(nextTask);
    return nextTask;
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
    required CarePlanEngine engine,
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

    final adjustment = switch (task.type) {
      TaskType.water ||
      TaskType.mist ||
      TaskType.fertilize =>
        engine.adjustInterval(
          taskType: task.type,
          baseDays: baseDays,
          environment: environment,
          environmentMode: plant.environmentMode,
          hemisphere: settings.hemisphere,
          now: now,
        ),
      _ => null,
    };

    final dueAt = alignToReminderTime(
      now.add(Duration(days: adjustment?.adjustedDays ?? baseDays)),
      settings.reminderTimePreference,
    );

    final nextTask = TaskInstance(
      id: const Uuid().v4(),
      plantId: plant.id,
      type: task.type,
      dueAt: dueAt,
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: adjustment?.reasonIds ?? const <String>[],
    );

    await tasksRepository.upsert(nextTask);
    return nextTask;
  }
}
