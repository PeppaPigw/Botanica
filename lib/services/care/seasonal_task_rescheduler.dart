import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/repositories/plants_repository.dart';
import '../../data/repositories/species_repository.dart';
import '../../data/repositories/plant_idea_repository.dart';
import '../../data/repositories/tasks_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/environment_snapshot.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/services/care_plan_engine.dart';
import '../../domain/services/seasonal_care_engine.dart';
import '../../domain/services/scheduling.dart';

class SeasonalTaskRescheduler {
  final Ref ref;

  TasksRepository get tasksRepo => ref.read(tasksRepositoryProvider);
  PlantsRepository get plantsRepo => ref.read(plantsRepositoryProvider);
  SpeciesRepository get speciesRepo => ref.read(speciesRepositoryProvider);
  PlantIdeaRepository get ideaRepo => ref.read(plantIdeaRepositoryProvider);
  SeasonalCareEngine get seasonalEngine => ref.read(seasonalCareEngineProvider);

  SeasonalTaskRescheduler(this.ref);

  /// Scans all pending tasks and reschedules them if the current season
  /// is different from the season logged when they were scheduled.
  Future<void> resyncPendingTasks({
    required DateTime now,
    required EnvironmentSnapshot environment,
    required UserSettings settings,
  }) async {
    final allTasks = tasksRepo.getAll();
    final pendingTasks =
        allTasks.where((t) => t.status == TaskStatus.pending).toList();

    final currentSeason = CarePlanEngine.seasonFor(
      hemisphere: settings.hemisphere,
      month: now.month,
    );

    final tasksToUpdate = <TaskInstance>[];

    for (final task in pendingTasks) {
      final snapshot = task.scheduleSnapshot;
      if (snapshot == null) continue; // Legacy tasks without a snapshot

      if (task.type != TaskType.water &&
          task.type != TaskType.mist &&
          task.type != TaskType.fertilize) {
        continue;
      }

      final cachedSeason = snapshot.season;
      if (cachedSeason == currentSeason) continue;

      // Season changed! We should recalculate the interval based on the
      // previous cycle start time.
      final plant = plantsRepo.byId(task.plantId);
      if (plant == null) continue;

      final species = await speciesRepo.byId(plant.speciesId);
      final idea = await ideaRepo.byId(plant.speciesId);

      final fallbackBaseDays = switch (task.type) {
        TaskType.water => species?.careDefaults.waterBaseDays,
        TaskType.fertilize => species?.careDefaults.fertilizeBaseDays,
        TaskType.mist => species?.careDefaults.mistBaseDays,
        TaskType.rotate => species?.careDefaults.rotateBaseDays,
        TaskType.prune => species?.careDefaults.pruneBaseDays,
        _ => null,
      };

      final cycleStartLine = task.completedAt ?? task.createdAt;

      final decisionForCurrentSeason = seasonalEngine.computeSchedule(
        taskType: task.type,
        now: now, // use current time so we get the current season
        environment: environment,
        hemisphere: settings.hemisphere,
        environmentMode: plant.environmentMode,
        plantIdea: idea,
        fallbackBaseDays: fallbackBaseDays,
      );

      if (decisionForCurrentSeason.dueAt != null) {
        final adjustedDays = decisionForCurrentSeason.snapshot.adjustedDays;

        final dueAt = alignToPreferredReminderTime(
          date: addLocalCalendarDays(cycleStartLine, adjustedDays),
          preference: settings.reminderTimePreference,
          override: plant.reminderTimeOverride,
        );

        tasksToUpdate.add(task.copyWith(
          dueAt: dueAt,
          scheduleSnapshot: decisionForCurrentSeason.snapshot,
          adjustmentReasonIds: decisionForCurrentSeason.snapshot.reasonIds,
        ));
      }
    }

    if (tasksToUpdate.isNotEmpty) {
      await tasksRepo.upsertMany(tasksToUpdate);
    }
  }
}

final seasonalTaskReschedulerProvider =
    Provider<SeasonalTaskRescheduler>((ref) {
  return SeasonalTaskRescheduler(ref);
});
