import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/botanica_celebration.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/botanica_tokens.dart';
import '../../../core/haptics/botanica_haptics.dart';
import '../../../core/widgets/botanica_gaps.dart';
import '../../../app/theme/botanica_glass_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/care_transparency_card.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/plant.dart';
import '../../../domain/models/task_instance.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../services/care/care_actions.dart';
import '../../../services/care/care_combo_tracker.dart';
import '../../garden/garden_screen.dart';
import '../../garden/edit_plant_screen.dart';
import '../snooze_sheet.dart';

class TaskTile extends ConsumerStatefulWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.plant,
    required this.index,
    required this.isToday,
  });

  final TaskInstance task;
  final Plant plant;
  final int index;
  final bool isToday;

  @override
  ConsumerState<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<TaskTile> {
  bool _completing = false;
  bool _skipping = false;

  Future<void> _complete() async {
    if (_completing) return;
    setState(() => _completing = true);
    BotanicaHaptics.primaryPress();

    try {
      await Future<void>.delayed(BotanicaTokens.motionMedium);
      if (!mounted) return;

      final l10n = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final inversePrimary = Theme.of(context).colorScheme.inversePrimary;
      final comboTracker = ref.read(careComboTrackerProvider.notifier);

      final now = DateTime.now();
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final logsRepository = ref.read(logsRepositoryProvider);
      final speciesRepository = ref.read(speciesRepositoryProvider);
      final plantIdeaRepository = ref.read(plantIdeaRepositoryProvider);
      final engine = ref.read(seasonalCareEngineProvider);
      final environment = ref.read(environmentSnapshotProvider);
      final settings = ref.read(settingsControllerProvider);
      final settingsController = ref.read(settingsControllerProvider.notifier);
      final originalTask = widget.task;
      final previousSettings = settings;
      final previousLogIds =
          logsRepository.forPlant(widget.plant.id).map((log) => log.id).toSet();

      final nextTask = await CareActions.completeTask(
        task: widget.task,
        plant: widget.plant,
        now: now,
        tasksRepository: tasksRepository,
        logsRepository: logsRepository,
        speciesRepository: speciesRepository,
        plantIdeaRepository: plantIdeaRepository,
        seasonalEngine: engine,
        environment: environment,
        settings: settings,
        updateSettings: settingsController.update,
      );

      String? createdLogId;
      for (final log in logsRepository.forPlant(widget.plant.id)) {
        if (!previousLogIds.contains(log.id)) {
          createdLogId = log.id;
          break;
        }
      }

      Future<void> undoCompletion() async {
        await tasksRepository.upsert(originalTask);
        if (nextTask != null) {
          await tasksRepository.delete(nextTask.id);
        }
        if (createdLogId != null) {
          await logsRepository.delete(createdLogId);
        }
        await settingsController.update(previousSettings);
      }

      final streakSaved = previousSettings.lastCareDate != null &&
          now.difference(previousSettings.lastCareDate!).inDays == 1 &&
          previousSettings.careStreakDays >= 1;
      final displayStreak = previousSettings.careStreakDays + 1;

      final comboCount = comboTracker.recordCompletion();

      if (!messenger.mounted) return;

      BotanicaHaptics.completion();

      // Compute care confidence insight from updated logs
      final updatedLogs = logsRepository.forPlant(widget.plant.id);
      final confidenceInsight = CareActions.careConfidenceInsight(
        l10n: l10n,
        plantLogs: updatedLogs,
        taskType: widget.task.type,
      );

      String snackbarMessage = streakSaved
          ? l10n.streakSavedSnackbar(widget.plant.nickname, displayStreak)
          : '${l10n.commonDone} · ${widget.plant.nickname}';

      if (confidenceInsight != null) {
        snackbarMessage = '$snackbarMessage\n$confidenceInsight';
      }

      if (comboCount >= 2) {
        final comboText = comboCount >= 5
            ? l10n.careComboStreak(comboCount)
            : l10n.careCombo(comboCount);
        snackbarMessage = '$snackbarMessage · $comboText';
      }

      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                streakSaved ? Icons.local_fire_department_rounded : Icons.check_circle_rounded,
                size: BotanicaTokens.iconSizeSm,
                color: streakSaved ? Colors.orange : inversePrimary,
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: Text(snackbarMessage),
              ),
            ],
          ),
          action: SnackBarAction(
            label: l10n.commonUndo,
            onPressed: () => unawaited(undoCompletion()),
          ),
        ),
      );

      if (!mounted) return;
      final updatedSettings = ref.read(settingsControllerProvider);
      final milestone = CareActions.newMilestoneReached(
        updatedSettings.careStreakDays,
        updatedSettings.lastMilestoneCelebrated,
      );

      if (comboCount == 5) {
        BotanicaHaptics.milestone();
        if (mounted) {
          BotanicaCelebration.show(context);
        }
      } else if (milestone != null) {
        await ref.read(settingsControllerProvider.notifier).update(
              updatedSettings.copyWith(lastMilestoneCelebrated: milestone),
            );
        if (mounted) {
          BotanicaCelebration.show(context);
        }
      } else {
        if (mounted) {
          BotanicaCelebration.show(context);
        }
      }
    } catch (_) {
      if (!mounted) return;
      BotanicaHaptics.subtleError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(AppLocalizations.of(context).commonErrorTryAgain),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _completing = false);
      }
    }
  }

  Future<void> _quickSnooze() async {
    if (_completing || _skipping) return;

    BotanicaHaptics.selectionTick();

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final inversePrimary = Theme.of(context).colorScheme.inversePrimary;
    final settings = ref.read(settingsControllerProvider);
    final tasksRepo = ref.read(tasksRepositoryProvider);
    final originalTask = widget.task;

    final snoozeDate = CareActions.snoozeUntilTomorrow(
      now: DateTime.now(),
      plant: widget.plant,
      settings: settings,
    );

    await tasksRepo.upsert(
      widget.task.copyWith(
        status: TaskStatus.snoozed,
        dueAt: snoozeDate,
      ),
    );

    if (!messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.bedtime_outlined, size: BotanicaTokens.iconSizeSm, color: inversePrimary),
            BotanicaGaps.hSm,
            Expanded(child: Text(l10n.tasksSnoozedUntil(snoozeDate))),
          ],
        ),
        action: SnackBarAction(
          label: l10n.commonUndo,
          onPressed: () => unawaited(tasksRepo.upsert(originalTask)),
        ),
      ),
    );
  }

  Future<void> _snooze() async {
    final l10n = AppLocalizations.of(context);
    final settings = ref.read(settingsControllerProvider);
    final messenger = ScaffoldMessenger.of(context);
    final inversePrimary = Theme.of(context).colorScheme.inversePrimary;

    final resolvedDueAt = await showSnoozeSheet(
      context: context,
      reminderPref: settings.reminderTimePreference,
    );

    if (resolvedDueAt == null) return;
    if (!context.mounted) return;

    final tasksRepo = ref.read(tasksRepositoryProvider);

    await tasksRepo.upsert(
      widget.task.copyWith(
        status: TaskStatus.snoozed,
        dueAt: resolvedDueAt,
      ),
    );

    if (!messenger.mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.snooze_rounded, size: BotanicaTokens.iconSizeSm, color: inversePrimary),
              BotanicaGaps.hSm,
              Expanded(child: Text(l10n.tasksSnoozedUntil(resolvedDueAt))),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _skip() async {
    if (_skipping) return;
    setState(() => _skipping = true);
    BotanicaHaptics.selectionTick();

    try {
      final l10n = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final inversePrimary = Theme.of(context).colorScheme.inversePrimary;
      final now = DateTime.now();
      final tasksRepository = ref.read(tasksRepositoryProvider);
      final speciesRepository = ref.read(speciesRepositoryProvider);
      final plantIdeaRepository = ref.read(plantIdeaRepositoryProvider);
      final engine = ref.read(seasonalCareEngineProvider);
      final environment = ref.read(environmentSnapshotProvider);
      final settings = ref.read(settingsControllerProvider);
      final originalTask = widget.task;

      final nextTask = await CareActions.skipTask(
        task: widget.task,
        plant: widget.plant,
        now: now,
        tasksRepository: tasksRepository,
        speciesRepository: speciesRepository,
        plantIdeaRepository: plantIdeaRepository,
        seasonalEngine: engine,
        environment: environment,
        settings: settings,
      );

      Future<void> undoSkip() async {
        await tasksRepository.upsert(originalTask);
        if (nextTask != null) {
          await tasksRepository.delete(nextTask.id);
        }
      }

      if (!messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                Icons.skip_next_rounded,
                size: BotanicaTokens.iconSizeSm,
                color: inversePrimary,
              ),
              BotanicaGaps.hSm,
              Text('${l10n.tasksSkipped} · ${widget.plant.nickname}'),
            ],
          ),
          action: SnackBarAction(
            label: l10n.commonUndo,
            onPressed: () => unawaited(undoSkip()),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      BotanicaHaptics.subtleError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(AppLocalizations.of(context).commonErrorTryAgain),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _skipping = false);
      }
    }
  }

  void _editPlant() {
    context.push(
      '${GardenScreen.location}/${EditPlantScreen.subLocation}'
          .replaceFirst(':id', widget.plant.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final taskLabel = switch (widget.task.type) {
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

    final dueLabel =
        MaterialLocalizations.of(context).formatFullDate(widget.task.dueAt);

    final slidable = Slidable(
      key: ValueKey('task-${widget.task.id}'),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.32,
        children: [
          CustomSlidableAction(
            key: ValueKey('task-action-${widget.task.id}-done'),
            onPressed: (_) => _complete(),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: BotanicaTokens.spacingXxs,
              vertical: BotanicaTokens.spacingXs,
            ),
            child: _SlidableActionContent(
              icon: Icons.water_drop_rounded,
              label: l10n.commonDone,
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.56,
        children: [
          CustomSlidableAction(
            key: ValueKey('task-action-${widget.task.id}-snooze'),
            onPressed: (_) => _snooze(),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(
              horizontal: BotanicaTokens.spacingXxs,
              vertical: BotanicaTokens.spacingXs,
            ),
            child: _SlidableActionContent(
              icon: Icons.snooze_rounded,
              label: l10n.gardenQuickSnooze,
            ),
          ),
          CustomSlidableAction(
            key: ValueKey('task-action-${widget.task.id}-skip'),
            onPressed: (_) => _skip(),
            backgroundColor: scheme.secondary,
            foregroundColor: scheme.onSecondary,
            padding: const EdgeInsets.symmetric(
              horizontal: BotanicaTokens.spacingXxs,
              vertical: BotanicaTokens.spacingXs,
            ),
            child: _SlidableActionContent(
              icon: Icons.skip_next_rounded,
              label: l10n.commonSkip,
            ),
          ),
          CustomSlidableAction(
            key: ValueKey('task-action-${widget.task.id}-edit'),
            onPressed: (_) => _editPlant(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: BotanicaTokens.spacingXxs,
              vertical: BotanicaTokens.spacingXs,
            ),
            child: _SlidableActionContent(
              icon: Icons.edit_rounded,
              label: l10n.commonEdit,
            ),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
        onTap: () => context.push(
          '${GardenScreen.location}/plant/${widget.plant.id}',
        ),
        child: BotanicaGlassCard(
          tier: widget.isToday ? GlassTier.primary : GlassTier.subtle,
          padding: BotanicaTokens.cardPaddingDense,
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer.withValues(alpha: 0.55),
                      scheme.tertiaryContainer.withValues(alpha: 0.30),
                    ],
                  ),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Icon(
                  iconForTask(widget.task.type),
                  color: scheme.onSurface.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.plant.nickname} · $taskLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: BotanicaTokens.spacingMicro),
                    Text(
                      widget.plant.room.trim().isEmpty
                          ? MaterialLocalizations.of(context)
                              .formatShortMonthDay(widget.task.dueAt)
                          : '${MaterialLocalizations.of(context).formatShortMonthDay(widget.task.dueAt)} · ${widget.plant.room}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.task.scheduleSnapshot != null &&
                  widget.task.scheduleSnapshot!.reasonIds.isNotEmpty) ...[
                const SizedBox(width: BotanicaTokens.spacingXs),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => TransparencySheet(
                        task: widget.task,
                        plant: widget.plant,
                      ),
                    );
                  },
                  icon: const Icon(Icons.insights_rounded),
                  color: scheme.primary,
                  tooltip: l10n.commonWhy,
                ),
              ],
              if (_completing || _skipping) ...[
                const SizedBox(width: BotanicaTokens.spacingXs),
                ConstrainedBox(
                  constraints:
                      const BoxConstraints.tightFor(width: 48, height: 48),
                  child: Padding(
                    padding: BotanicaTokens.cardPaddingTight,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation(scheme.primary),
                    ),
                  ),
                ),
              ] else ...[
                if (widget.isToday) ...[
                  const SizedBox(width: BotanicaTokens.spacingXs),
                  IconButton(
                    onPressed: _quickSnooze,
                    icon: const Icon(Icons.bedtime_outlined),
                    color: Colors.amber.shade700,
                    tooltip: l10n.plantDetailNextWateringTomorrow,
                  ),
                ],
                const SizedBox(width: BotanicaTokens.spacingXs),
                IconButton(
                  onPressed: () => _complete(),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  color: scheme.primary,
                  tooltip: l10n.commonDone,
                ),
              ]
            ],
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      label: '${widget.plant.nickname} · $taskLabel',
      value: dueLabel,
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.commonDone): () =>
            unawaited(_complete()),
        CustomSemanticsAction(label: l10n.gardenQuickSnooze): () =>
            unawaited(_snooze()),
        CustomSemanticsAction(label: l10n.commonSkip): () =>
            unawaited(_skip()),
        CustomSemanticsAction(label: l10n.commonEdit): _editPlant,
      },
      child: AnimatedScale(
        scale: _completing || _skipping ? 0.97 : 1.0,
        duration: BotanicaTokens.motionMedium,
        curve: BotanicaTokens.curveReveal,
        child: AnimatedOpacity(
          opacity: _completing || _skipping ? 0.35 : 1.0,
          duration: BotanicaTokens.motionMedium,
          curve: BotanicaTokens.curveReveal,
          child: slidable,
        ),
      ),
    );
  }
}

class _SlidableActionContent extends StatelessWidget {
  const _SlidableActionContent({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: BotanicaTokens.iconSizeLg),
        const SizedBox(height: BotanicaTokens.spacingMicro),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

IconData iconForTask(TaskType type) => switch (type) {
      TaskType.water => Icons.water_drop_rounded,
      TaskType.fertilize => Icons.science_rounded,
      TaskType.mist => Icons.blur_on_rounded,
      TaskType.rotate => Icons.rotate_right_rounded,
      TaskType.prune => Icons.content_cut_rounded,
      TaskType.repot => Icons.local_florist_rounded,
      TaskType.checkPests => Icons.bug_report_rounded,
      TaskType.wipeLeaves => Icons.cleaning_services_rounded,
      TaskType.sunlightAdjustment => Icons.wb_sunny_rounded,
    };

class TransparencySheet extends ConsumerWidget {
  const TransparencySheet({super.key, required this.task, required this.plant});

  final TaskInstance task;
  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesRepo = ref.watch(speciesRepositoryProvider);

    return FutureBuilder(
      future: speciesRepo.byId(plant.speciesId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final defaults = snapshot.data!.careDefaults;
        final baseDays = switch (task.type) {
          TaskType.water => defaults.waterBaseDays,
          TaskType.fertilize => defaults.fertilizeBaseDays,
          TaskType.mist => defaults.mistBaseDays,
          TaskType.rotate => defaults.rotateBaseDays,
          TaskType.prune => defaults.pruneBaseDays,
          _ => 7,
        };

        return SafeArea(
          child: Padding(
            padding: BotanicaTokens.pagePadding
                .copyWith(bottom: BotanicaTokens.spacingXl),
            child: CareTransparencyCard(
              snapshot: task.scheduleSnapshot!,
              baseDays: baseDays,
            ),
          ),
        );
      },
    );
  }
}
