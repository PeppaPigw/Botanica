import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/services/care_plan_engine.dart';
import '../../domain/services/scheduling.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/care/care_actions.dart';
import '../calendar/calendar_screen.dart';
import '../garden/garden_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  static const String subLocation = 'tasks';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(settingsControllerProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final plantsAsync = ref.watch(plantsStreamProvider);

    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];

    final seasonalTips =
        CarePlanEngine.seasonalTipKeys(settings.hemisphere, DateTime.now());
    final showSeasonalTips = seasonalTips.isNotEmpty &&
        seasonalTips.first != settings.dismissedSeasonTipKey;

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.tasksTitle),
        actions: [
          IconButton(
            onPressed: () => context.go(CalendarScreen.location),
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: l10n.tasksCalendarToggle,
          ),
          const SizedBox(width: BotanicaTokens.spacingTiny),
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Builder(
            builder: (tabContext) {
              final controller = DefaultTabController.of(tabContext);

              return Column(
                children: [
                  if (showSeasonalTips)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        BotanicaTokens.spacingLg,
                        BotanicaTokens.spacingXs,
                        BotanicaTokens.spacingLg,
                        BotanicaTokens.spacingXs,
                      ),
                      child: MaterialBanner(
                        backgroundColor:
                            scheme.primaryContainer.withValues(alpha: 0.28),
                        leading: Icon(
                          Icons.tips_and_updates_rounded,
                          color: scheme.onSurface.withValues(alpha: 0.82),
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.tasksSeasonalTipsTitle,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: BotanicaTokens.spacingXxs),
                            for (final tipKey in seasonalTips)
                              Text(
                                '• ${_seasonalTipLabel(l10n, tipKey)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.72),
                                  height: 1.35,
                                ),
                              ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(settingsControllerProvider.notifier)
                                  .update(
                                    settings.copyWith(
                                      dismissedSeasonTipKey: seasonalTips.first,
                                    ),
                                  );
                            },
                            child: Text(l10n.commonClose),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      BotanicaTokens.spacingLg,
                      0,
                      BotanicaTokens.spacingLg,
                      BotanicaTokens.spacingSm,
                    ),
                    child: _TasksTabChips(controller: controller),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _TasksList(
                          tasks: _filterToday(tasks),
                          plants: plants,
                          emptyLabel: l10n.gardenTasksDueToday(0),
                        ),
                        _TasksList(
                          tasks: _filterUpcoming(tasks),
                          plants: plants,
                          emptyLabel: l10n.tasksEmptyUpcoming,
                        ),
                        _TasksList(
                          tasks: _filterOverdue(tasks),
                          plants: plants,
                          emptyLabel: l10n.tasksEmptyOverdue,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TasksTabChips extends StatelessWidget {
  const _TasksTabChips({
    required this.controller,
  });

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = (textTheme.labelLarge ?? textTheme.labelMedium)
        ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.1);

    return AnimatedBuilder(
      animation: controller.animation ?? controller,
      builder: (context, _) {
        final index = controller.index;

        Widget chip({
          required int tabIndex,
          required String label,
          required IconData icon,
          required Color tint,
        }) {
          return Expanded(
            child: BotanicaChip(
              label: label,
              icon: icon,
              tint: tint,
              selected: index == tabIndex,
              textStyle: labelStyle,
              padding: const EdgeInsets.symmetric(
                horizontal: BotanicaTokens.spacingSm,
                vertical: BotanicaTokens.spacingXs,
              ),
              onTap: () => controller.animateTo(tabIndex),
            ),
          );
        }

        return Row(
          children: [
            chip(
              tabIndex: 0,
              label: l10n.tasksTabToday,
              icon: Icons.today_rounded,
              tint: scheme.primary,
            ),
            const SizedBox(width: BotanicaTokens.spacingXxs),
            chip(
              tabIndex: 1,
              label: l10n.tasksTabUpcoming,
              icon: Icons.schedule_rounded,
              tint: scheme.secondary,
            ),
            const SizedBox(width: BotanicaTokens.spacingXxs),
            chip(
              tabIndex: 2,
              label: l10n.tasksTabOverdue,
              icon: Icons.warning_amber_rounded,
              tint: scheme.tertiary,
            ),
          ],
        );
      },
    );
  }
}

String _seasonalTipLabel(AppLocalizations l10n, String tipKey) {
  return switch (tipKey) {
    'tipSpringRepot' => l10n.tipSpringRepot,
    'tipSpringFertilize' => l10n.tipSpringFertilize,
    'tipSummerWaterMore' => l10n.tipSummerWaterMore,
    'tipSummerShadeOutdoor' => l10n.tipSummerShadeOutdoor,
    'tipAutumnReduceWater' => l10n.tipAutumnReduceWater,
    'tipAutumnBringIndoor' => l10n.tipAutumnBringIndoor,
    'tipWinterReduceFertilize' => l10n.tipWinterReduceFertilize,
    'tipWinterLowLight' => l10n.tipWinterLowLight,
    _ => '',
  };
}

class _TasksList extends ConsumerWidget {
  const _TasksList({
    required this.tasks,
    required this.plants,
    required this.emptyLabel,
  });

  final List<TaskInstance> tasks;
  final List<Plant> plants;
  final String emptyLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: BotanicaTokens.pagePadding,
          child: BotanicaStateCard(
            icon: Icons.inbox_rounded,
            title: l10n.tasksTitle,
            body: emptyLabel,
            illustrationAsset:
                'assets/illustrations/empty_tasks_watering_can.jpg',
            tier: GlassTier.subtle,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: BotanicaTokens.pagePaddingWithBottomNav(context),
      itemCount: tasks.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: BotanicaTokens.spacingSm),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final plant = plants.where((p) => p.id == task.plantId).firstOrNull;
        if (plant == null) return const SizedBox.shrink();

        return _TaskTile(
          task: task,
          plant: plant,
          index: index,
        )
            .animate()
            .fadeIn(
              delay: (index * 35).ms,
              duration: BotanicaTokens.motionSlow,
            )
            .slideY(begin: 0.06, curve: BotanicaTokens.curveReveal);
      },
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({
    required this.task,
    required this.plant,
    required this.index,
  });

  final TaskInstance task;
  final Plant plant;
  final int index;

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    final now = DateTime.now();
    HapticFeedback.lightImpact();

    final tasksRepository = ref.read(tasksRepositoryProvider);
    final logsRepository = ref.read(logsRepositoryProvider);
    final speciesRepository = ref.read(speciesRepositoryProvider);
    final plantIdeaRepository = ref.read(plantIdeaRepositoryProvider);
    final engine = ref.read(carePlanEngineProvider);
    final environment = ref.read(environmentSnapshotProvider);
    final settings = ref.read(settingsControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);

    await CareActions.completeTask(
      task: task,
      plant: plant,
      now: now,
      tasksRepository: tasksRepository,
      logsRepository: logsRepository,
      speciesRepository: speciesRepository,
      plantIdeaRepository: plantIdeaRepository,
      engine: engine,
      environment: environment,
      settings: settings,
      updateSettings: settingsController.update,
    );

    if (!context.mounted) return;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 18, color: Theme.of(context).colorScheme.inversePrimary),
            const SizedBox(width: 10),
            Text('${l10n.commonDone} · ${plant.nickname}'),
          ],
        ),
      ),
    );
  }

  Future<void> _snooze(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final tasksRepo = ref.read(tasksRepositoryProvider);
    final settings = ref.read(settingsControllerProvider);

    final now = DateTime.now();
    final next = _alignToReminderTime(
      now.add(const Duration(days: 1)),
      settings.reminderTimePreference,
    );

    await tasksRepo.upsert(
      task.copyWith(
        status: TaskStatus.snoozed,
        dueAt: next,
      ),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.snooze_rounded,
                size: 18, color: Theme.of(context).colorScheme.inversePrimary),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.tasksSnoozedUntil(next))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

    final dueLabel =
        MaterialLocalizations.of(context).formatFullDate(task.dueAt);

    final slidable = Slidable(
      key: ValueKey('task-${task.id}'),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.26,
        children: [
          SlidableAction(
            key: ValueKey('task-action-${task.id}-done'),
            onPressed: (_) => _complete(context, ref),
            backgroundColor: scheme.primary.withValues(alpha: 0.25),
            foregroundColor: scheme.onSurface,
            icon: Icons.check_rounded,
            label: l10n.commonDone,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            key: ValueKey('task-action-${task.id}-snooze'),
            onPressed: (_) => _snooze(context, ref),
            backgroundColor: scheme.tertiary.withValues(alpha: 0.22),
            foregroundColor: scheme.onSurface,
            icon: Icons.snooze_rounded,
            label: l10n.gardenQuickSnooze,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
        onTap: () => context.push(
          '${GardenScreen.location}/plant/${plant.id}',
        ),
        child: BotanicaGlassCard(
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
                  _iconForTask(task.type),
                  color: scheme.onSurface.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plant.nickname} · $taskLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: BotanicaTokens.spacingMicro),
                    Text(
                      plant.room.trim().isEmpty
                          ? MaterialLocalizations.of(context)
                              .formatShortMonthDay(task.dueAt)
                          : '${MaterialLocalizations.of(context).formatShortMonthDay(task.dueAt)} · ${plant.room}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingXs),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      label: '${plant.nickname} · $taskLabel',
      value: dueLabel,
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.commonDone): () =>
            unawaited(_complete(context, ref)),
        CustomSemanticsAction(label: l10n.gardenQuickSnooze): () =>
            unawaited(_snooze(context, ref)),
      },
      child: slidable,
    );
  }
}

List<TaskInstance> _filterToday(List<TaskInstance> tasks) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return tasks
      .where(
        (t) => !t.isDone && !t.dueAt.isBefore(start) && t.dueAt.isBefore(end),
      )
      .toList(growable: false)
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
}

List<TaskInstance> _filterUpcoming(List<TaskInstance> tasks) {
  final now = DateTime.now();
  final start =
      DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  return tasks
      .where((t) => !t.isDone && !t.dueAt.isBefore(start))
      .toList(growable: false)
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
}

List<TaskInstance> _filterOverdue(List<TaskInstance> tasks) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return tasks
      .where((t) => !t.isDone && t.dueAt.isBefore(start))
      .toList(growable: false)
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
}

IconData _iconForTask(TaskType type) => switch (type) {
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

DateTime _alignToReminderTime(DateTime date, ReminderTimePreference pref) {
  return alignToReminderTime(date, pref);
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
