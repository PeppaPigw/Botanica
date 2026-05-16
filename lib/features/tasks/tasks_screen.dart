import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_all_done_sheet.dart';
import '../../core/widgets/botanica_streak_milestone_sheet.dart';
import '../../core/widgets/botanica_perfect_week_sheet.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/haptics/botanica_haptics.dart';

import '../../domain/models/plant.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/services/care_plan_engine.dart';
import '../../domain/services/smart_notification_engine.dart';
import '../../domain/services/nudge_engine.dart';
import '../../domain/services/community_challenge_engine.dart';
import '../../core/widgets/botanica_nudge_card.dart';
import '../../core/widgets/botanica_community_challenge_card.dart';
import '../../core/widgets/botanica_smart_notification_card.dart';
import '../../services/care/care_actions.dart';

import '../../gen/l10n/app_localizations.dart';
import '../calendar/calendar_screen.dart';
import 'widgets/task_tile.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  static const String subLocation = 'tasks';

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  bool _showCalendarView = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  Future<void> _refreshTasks() async {
    ref.invalidate(tasksStreamProvider);
    // Allow the stream to re-emit before completing the refresh indicator.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  void _shiftMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + delta,
        1,
      );
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = DateTime(day.year, day.month, day.day);
      if (_selectedDay.year != _focusedMonth.year ||
          _selectedDay.month != _focusedMonth.month) {
        _focusedMonth = DateTime(_selectedDay.year, _selectedDay.month, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(settingsControllerProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final plantsAsync = ref.watch(plantsStreamProvider);

    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];

    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day + 1);
    final todayTasks = tasks.where((t) => t.dueAt.isBefore(todayEnd)).toList();
    final todayPending = todayTasks.where((t) => !t.isDismissed && !t.isDone).length;
    final todayDone = todayTasks.where((t) => t.isDone).length;
    final todayTotal = todayPending + todayDone;

    final seasonalTips =
        CarePlanEngine.seasonalTipKeys(settings.hemisphere, DateTime.now());
    final showSeasonalTips = seasonalTips.isNotEmpty &&
        seasonalTips.first != settings.dismissedSeasonTipKey;

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.tasksTitle),
        actions: [
          if (todayTotal > 0)
            Padding(
              padding: const EdgeInsets.only(right: BotanicaTokens.spacingXs),
              child: _DailyProgressRing(
                done: todayDone,
                total: todayTotal,
              ),
            ),
          IconButton(
            onPressed: () =>
                setState(() => _showCalendarView = !_showCalendarView),
            icon: Icon(
              _showCalendarView
                  ? Icons.view_agenda_rounded
                  : Icons.calendar_month_rounded,
            ),
            tooltip: l10n.tasksCalendarToggle,
          ),
          const SizedBox(width: BotanicaTokens.spacingTiny),
        ],
      ),
      body: SafeArea(
        child: Column(
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
                            color: scheme.onSurface.withValues(alpha: 0.72),
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
                                  dismissedSeasonTipKey: seasonalTips.first),
                            );
                      },
                      child: Text(l10n.commonClose),
                    ),
                  ],
                ),
              ),
            _SmartNotificationBanner(
              plants: plants,
              tasks: tasks,
              settings: settings,
            ),
            _NudgeBanner(
              plants: plants,
              tasks: tasks,
            ),
            _CommunityChallengeSection(
              tasks: tasks,
              plants: plants,
              settings: settings,
            ),
            Expanded(
              child: _showCalendarView
                  ? _TasksCalendarView(
                      tasks: tasks,
                      plants: plants,
                      focusedMonth: _focusedMonth,
                      selectedDay: _selectedDay,
                      onShiftMonth: _shiftMonth,
                      onSelectDay: _selectDay,
                    )
                  : DefaultTabController(
                      length: 3,
                      child: Builder(
                        builder: (tabContext) {
                          final controller =
                              DefaultTabController.of(tabContext);

                          return Column(
                            children: [
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
                                      isToday: true,
                                      onRefresh: _refreshTasks,
                                    ),
                                    _TasksList(
                                      tasks: _filterSoon(tasks),
                                      plants: plants,
                                      emptyLabel: l10n.tasksEmptySoon,
                                      isToday: false,
                                      onRefresh: _refreshTasks,
                                    ),
                                    _TasksList(
                                      tasks: _filterWatch(tasks),
                                      plants: plants,
                                      emptyLabel: l10n.tasksEmptyWatch,
                                      isToday: false,
                                      onRefresh: _refreshTasks,
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
          ],
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
              onTap: () {
                controller.animateTo(tabIndex);
                SemanticsService.sendAnnouncement(
                  View.of(context),
                  label,
                  TextDirection.ltr,
                );
              },
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
              label: l10n.tasksTabSoon,
              icon: Icons.schedule_rounded,
              tint: scheme.secondary,
            ),
            const SizedBox(width: BotanicaTokens.spacingXxs),
            chip(
              tabIndex: 2,
              label: l10n.tasksTabWatch,
              icon: Icons.visibility_rounded,
              tint: scheme.tertiary,
            ),
          ],
        );
      },
    );
  }
}

class _TasksCalendarView extends StatelessWidget {
  const _TasksCalendarView({
    required this.tasks,
    required this.plants,
    required this.focusedMonth,
    required this.selectedDay,
    required this.onShiftMonth,
    required this.onSelectDay,
  });

  final List<TaskInstance> tasks;
  final List<Plant> plants;
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final ValueChanged<int> onShiftMonth;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pendingTasks = tasks
        .where((task) => !task.isDismissed)
        .toList(growable: false)
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final tasksByDay = _groupTasksByDay(pendingTasks);
    final selectedTasks =
        tasksByDay[_taskDateKey(selectedDay)] ?? const <TaskInstance>[];
    final monthLabel =
        MaterialLocalizations.of(context).formatMonthYear(focusedMonth);
    final selectedLabel =
        MaterialLocalizations.of(context).formatFullDate(selectedDay);

    return ListView(
      padding: BotanicaTokens.pagePaddingWithBottomNav(context),
      children: [
        BotanicaGlassCard(
          padding: BotanicaTokens.cardPaddingDense,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => onShiftMonth(-1),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                    ),
                    tooltip: l10n.calendarPrevMonth,
                  ),
                  Expanded(
                    child: Text(
                      monthLabel,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onShiftMonth(1),
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                    ),
                    tooltip: l10n.calendarNextMonth,
                  ),
                ],
              ),
              BotanicaGaps.vSm,
              CalendarMonthGrid(
                month: focusedMonth,
                selected: selectedDay,
                logsByDay: const {},
                tasksByDay: tasksByDay,
                onSelect: onSelectDay,
              ),
            ],
          ),
        ),
        BotanicaGaps.vSm,
        Row(
          children: [
            Expanded(
              child: Text(
                selectedLabel,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            BotanicaChip(
              icon: Icons.event_rounded,
              label: '${selectedTasks.length}',
              tint: scheme.primary,
              selected: selectedTasks.isNotEmpty,
            ),
          ],
        ),
        BotanicaGaps.vSm,
        if (selectedTasks.isEmpty)
          BotanicaStateCard(
            icon: Icons.event_available_rounded,
            title: l10n.tasksTitle,
            body: l10n.calendarNoEvents,
            tier: GlassTier.subtle,
          )
        else
          ...selectedTasks.asMap().entries.map((entry) {
            final task = entry.value;
            final plant = _plantById(plants, task.plantId);
            if (plant == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(
                bottom: BotanicaTokens.spacingSm,
              ),
              child: TaskTile(
                task: task,
                plant: plant,
                index: entry.key,
                isToday:
                    _taskDateKey(selectedDay) == _taskDateKey(DateTime.now()),
              ).animateSection(index: entry.key),
            );
          }),
      ],
    );
  }
}

Plant? _plantById(List<Plant> plants, String plantId) {
  for (final plant in plants) {
    if (plant.id == plantId) return plant;
  }
  return null;
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

class _TasksList extends ConsumerStatefulWidget {
  const _TasksList({
    required this.tasks,
    required this.plants,
    required this.emptyLabel,
    required this.isToday,
    this.onRefresh,
  });

  final List<TaskInstance> tasks;
  final List<Plant> plants;
  final String emptyLabel;
  final bool isToday;
  final Future<void> Function()? onRefresh;

  @override
  ConsumerState<_TasksList> createState() => _TasksListState();
}

class _TasksListState extends ConsumerState<_TasksList> {
  bool _completing = false;

  Future<void> _completeAll() async {
    if (_completing) return;
    setState(() => _completing = true);
    BotanicaHaptics.primaryPress();

    try {
      final l10n = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final inversePrimary = Theme.of(context).colorScheme.inversePrimary;
      final now = DateTime.now();
      final tasksRepo = ref.read(tasksRepositoryProvider);
      final logsRepo = ref.read(logsRepositoryProvider);
      final speciesRepo = ref.read(speciesRepositoryProvider);
      final ideaRepo = ref.read(plantIdeaRepositoryProvider);
      final engine = ref.read(seasonalCareEngineProvider);
      final env = ref.read(environmentSnapshotProvider);
      final settingsController = ref.read(settingsControllerProvider.notifier);

      int completed = 0;
      for (final task in widget.tasks) {
        if (task.isDismissed) continue;
        final plant = widget.plants.where((p) => p.id == task.plantId).firstOrNull;
        if (plant == null) continue;

        final settings = ref.read(settingsControllerProvider);
        await CareActions.completeTask(
          task: task,
          plant: plant,
          now: now,
          tasksRepository: tasksRepo,
          logsRepository: logsRepo,
          speciesRepository: speciesRepo,
          plantIdeaRepository: ideaRepo,
          seasonalEngine: engine,
          environment: env,
          settings: settings,
          updateSettings: settingsController.update,
        );
        completed++;
      }

      if (!messenger.mounted) return;
      BotanicaHaptics.success();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.done_all_rounded, size: BotanicaTokens.iconSizeSm, color: inversePrimary),
              BotanicaGaps.hSm,
              Text(l10n.tasksCompleteAllDone(completed)),
            ],
          ),
        ),
      );

      if (!mounted) return;
      final updatedSettings = ref.read(settingsControllerProvider);
      final milestone = CareActions.newMilestoneReached(
        updatedSettings.careStreakDays,
        updatedSettings.lastMilestoneCelebrated,
      );

      if (milestone != null) {
        await ref.read(settingsControllerProvider.notifier).update(
              updatedSettings.copyWith(lastMilestoneCelebrated: milestone),
            );
        if (!mounted) return;
        await BotanicaStreakMilestoneSheet.show(context, milestone: milestone);
      } else if (mounted) {
        await BotanicaAllDoneSheet.show(context);
      }

      if (!mounted) return;
      final settingsAfterSheet = ref.read(settingsControllerProvider);
      final perfectUpdated =
          CareActions.recordPerfectDay(settingsAfterSheet, now);
      if (perfectUpdated != settingsAfterSheet) {
        await ref
            .read(settingsControllerProvider.notifier)
            .update(perfectUpdated);
        if (!mounted) return;
        if (CareActions.isPerfectWeek(perfectUpdated)) {
          final weeks = perfectUpdated.consecutivePerfectDays ~/ 7;
          await BotanicaPerfectWeekSheet.show(context, weeks: weeks);
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
      if (mounted) setState(() => _completing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);

    // Determine if streak is at risk (active streak, no care today, evening).
    final now = DateTime.now();
    final streakAtRisk = widget.isToday &&
        settings.careStreakDays >= 3 &&
        settings.lastCareDate != null &&
        now
                .difference(DateTime(
                  settings.lastCareDate!.year,
                  settings.lastCareDate!.month,
                  settings.lastCareDate!.day,
                ))
                .inDays ==
            1 &&
        now.hour >= 16;

    if (widget.tasks.isEmpty) {
      final emptyContent = Center(
        child: Padding(
          padding: BotanicaTokens.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (streakAtRisk) ...[
                _StreakAtRiskBanner(
                  streakDays: settings.careStreakDays,
                ),
                BotanicaGaps.vBase,
              ],
              BotanicaStateCard(
                icon: Icons.inbox_rounded,
                title: l10n.tasksTitle,
                body: widget.emptyLabel,
                illustrationAsset:
                    'assets/illustrations/empty_tasks_watering_can.jpg',
                tier: GlassTier.subtle,
                primaryAction: BotanicaButton(
                  variant: BotanicaButtonVariant.outlined,
                  icon: Icons.calendar_month_rounded,
                  label: l10n.calendarTitle,
                  onPressed: () =>
                      GoRouter.of(context).go(CalendarScreen.location),
                ),
              ),
              if (!widget.isToday) ...[
                BotanicaGaps.vSm,
                Text(
                  l10n.tasksEmptySoonMotivation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );

      if (widget.onRefresh != null) {
        return RefreshIndicator(
          onRefresh: widget.onRefresh!,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: emptyContent,
              ),
            ),
          ),
        );
      }
      return emptyContent;
    }

    final pendingCount = widget.tasks.where((t) => !t.isDismissed).length;
    final headerCount = (widget.isToday && pendingCount > 1 ? 1 : 0) +
        (streakAtRisk ? 1 : 0);

    final listView = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: BotanicaTokens.pagePaddingWithBottomNav(context),
      itemCount: widget.tasks.length + headerCount,
      separatorBuilder: (_, __) =>
          const SizedBox(height: BotanicaTokens.spacingSm),
      itemBuilder: (context, index) {
        // Streak-at-risk banner is always first when present.
        if (streakAtRisk && index == 0) {
          return _StreakAtRiskBanner(
            streakDays: settings.careStreakDays,
          ).animateSection(index: 0);
        }

        final adjustedIndex = streakAtRisk ? index - 1 : index;

        if (widget.isToday && pendingCount > 1 && adjustedIndex == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
            child: BotanicaButton(
              expand: true,
              variant: BotanicaButtonVariant.outlined,
              icon: Icons.done_all_rounded,
              label: l10n.tasksCompleteAll,
              onPressed: _completing ? null : _completeAll,
            ),
          );
        }

        final taskIndex = widget.isToday && pendingCount > 1
            ? adjustedIndex - 1
            : adjustedIndex;
        final task = widget.tasks[taskIndex];
        final plant = widget.plants.where((p) => p.id == task.plantId).firstOrNull;
        if (plant == null) return const SizedBox.shrink();

        return TaskTile(
          task: task,
          plant: plant,
          index: taskIndex,
          isToday: widget.isToday,
        ).animateSection(index: taskIndex);
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }
    return listView;
  }
}

List<TaskInstance> _filterToday(List<TaskInstance> tasks) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return tasks
      .where(
        (t) => !t.isDismissed && t.dueAt.isBefore(end),
      )
      .toList(growable: false)
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
}

List<TaskInstance> _filterSoon(List<TaskInstance> tasks) {
  final now = DateTime.now();
  final start =
      DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  final end = start.add(const Duration(days: 8));
  return tasks
      .where(
          (t) =>
              !t.isDismissed &&
              !t.dueAt.isBefore(start) &&
              t.dueAt.isBefore(end))
      .toList(growable: false)
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
}

List<TaskInstance> _filterWatch(List<TaskInstance> tasks) {
  final now = DateTime.now();
  final start =
      DateTime(now.year, now.month, now.day).add(const Duration(days: 8));
  return tasks
      .where((t) => !t.isDismissed && !t.dueAt.isBefore(start))
      .toList(growable: false)
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
}

Map<String, List<TaskInstance>> _groupTasksByDay(List<TaskInstance> tasks) {
  final grouped = <String, List<TaskInstance>>{};
  for (final task in tasks) {
    (grouped[_taskDateKey(task.dueAt)] ??= <TaskInstance>[]).add(task);
  }
  return grouped;
}

String _taskDateKey(DateTime date) {
  final local = date.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class _StreakAtRiskBanner extends StatelessWidget {
  const _StreakAtRiskBanner({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.tasksStreakAtRiskTitle,
      child: BotanicaGlassCard(
        tier: GlassTier.primary,
        padding: BotanicaTokens.cardPaddingDense,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    scheme.error.withValues(alpha: 0.25),
                    scheme.errorContainer.withValues(alpha: 0.40),
                  ],
                ),
                border: Border.all(
                  color: scheme.error.withValues(alpha: 0.45),
                ),
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: scheme.error,
                size: BotanicaTokens.iconSizeMd,
              ),
            ),
            BotanicaGaps.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tasksStreakAtRiskTitle,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.error,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: BotanicaTokens.spacingMicro),
                  Text(
                    l10n.tasksStreakAtRiskBody(streakDays),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.72),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _DailyProgressRing extends StatelessWidget {
  const _DailyProgressRing({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = total > 0 ? done / total : 0.0;
    final allDone = done == total;

    return Semantics(
      label: '$done of $total tasks done today',
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: BotanicaTokens.motionMedium,
              curve: Curves.easeOut,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                backgroundColor: scheme.outlineVariant.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(
                  allDone ? scheme.primary : scheme.tertiary,
                ),
              ),
            ),
            Text(
              '$done',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 10,
                color: allDone ? scheme.primary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartNotificationBanner extends ConsumerWidget {
  const _SmartNotificationBanner({
    required this.plants,
    required this.tasks,
    required this.settings,
  });

  final List<Plant> plants;
  final List<TaskInstance> tasks;
  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(careLogsStreamProvider);
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (logs.length < 5 || plants.isEmpty) return const SizedBox.shrink();

    final notifications = SmartNotificationEngine.generate(
      plants: plants,
      logs: logs,
      tasks: tasks,
      settings: settings,
      now: DateTime.now(),
    );

    if (notifications.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BotanicaTokens.spacingLg,
        0,
        BotanicaTokens.spacingLg,
        BotanicaTokens.spacingXs,
      ),
      child: BotanicaSmartNotificationCard(notification: notifications.first),
    );
  }
}

class _NudgeBanner extends ConsumerWidget {
  const _NudgeBanner({
    required this.plants,
    required this.tasks,
  });

  final List<Plant> plants;
  final List<TaskInstance> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(careLogsStreamProvider);
    final allLogs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (plants.where((p) => !p.isArchived).length < 2 || allLogs.length < 5) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final nudges = NudgeEngine.generate(
      plants: plants,
      logs: allLogs,
      tasks: tasks,
      now: now,
      isWinter: now.month == 12 || now.month <= 2,
      maxNudges: 1,
    );

    if (nudges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BotanicaTokens.spacingLg,
        0,
        BotanicaTokens.spacingLg,
        BotanicaTokens.spacingXs,
      ),
      child: BotanicaNudgeCard(nudges: nudges),
    );
  }
}

class _CommunityChallengeSection extends ConsumerWidget {
  const _CommunityChallengeSection({
    required this.tasks,
    required this.plants,
    required this.settings,
  });

  final List<TaskInstance> tasks;
  final List<Plant> plants;
  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 2) return const SizedBox.shrink();

    final logsAsync = ref.watch(careLogsStreamProvider);
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekActions = logs.where(
      (l) => !l.timestamp.isBefore(weekStart),
    ).length;

    final weekOfYear = ((now.difference(DateTime(now.year)).inDays) / 7).ceil();

    final result = CommunityChallengeEngine.generate(
      weekOfYear: weekOfYear,
      userCareActionsThisWeek: thisWeekActions,
      userPlantCount: activePlants.length,
      userStreakDays: settings.careStreakDays,
    );

    if (result.activeChallenges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(
        left: BotanicaTokens.spacingMd,
        right: BotanicaTokens.spacingMd,
        bottom: BotanicaTokens.spacingSm,
      ),
      child: BotanicaCommunityChallengeCard(result: result),
    );
  }
}

