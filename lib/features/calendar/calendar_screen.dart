import 'dart:async';

import 'package:botanica/core/haptics/botanica_haptics.dart';
import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/task_labels.dart';
import '../../core/utils/motion_preferences.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_animated_counter.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_shimmer.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_title.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/task_instance.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/care/care_actions.dart';
import '../../core/widgets/botanica_celebration.dart';
import 'package:go_router/go_router.dart';

enum _CalendarLogFilter { all, water, fertilize, mist, other }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({
    super.key,
    this.inShell = false,
  });

  static const String location = '/calendar';
  static const String subLocation = 'calendar';

  /// When true, Calendar renders as a tab body (no nested Scaffold/AppBar).
  /// AppShell owns the scaffold + bottom navigation pill.
  final bool inShell;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  _CalendarLogFilter _logFilter = _CalendarLogFilter.all;

  bool _matchesLogFilter(CareLog log) {
    switch (_logFilter) {
      case _CalendarLogFilter.all:
        return true;
      case _CalendarLogFilter.water:
        return log.type == TaskType.water;
      case _CalendarLogFilter.fertilize:
        return log.type == TaskType.fertilize;
      case _CalendarLogFilter.mist:
        return log.type == TaskType.mist;
      case _CalendarLogFilter.other:
        return log.type != TaskType.water &&
            log.type != TaskType.fertilize &&
            log.type != TaskType.mist;
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _jumpToToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _selectedDay = today;
      _focusedMonth = DateTime(today.year, today.month, 1);
    });
    BotanicaHaptics.selectionTick();
  }

  void _selectDay({
    required BuildContext context,
    required DateTime day,
    required List<TaskInstance> tasks,
    required Map<String, List<CareLog>> logsByDay,
    required Map<String, Plant> plantsById,
  }) {
    final normalized = DateTime(day.year, day.month, day.day);
    BotanicaHaptics.selectionTick();
    setState(() {
      _selectedDay = normalized;
      if (normalized.year != _focusedMonth.year ||
          normalized.month != _focusedMonth.month) {
        _focusedMonth = DateTime(normalized.year, normalized.month, 1);
      }
    });

    _showDayAgendaSheet(
      context,
      normalized,
      _tasksForDay(tasks, normalized),
      logsByDay[_dateKey(normalized)] ?? const <CareLog>[],
      plantsById,
    );
  }

  void _shiftMonth(int delta) {
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
    setState(() => _focusedMonth = next);
    BotanicaHaptics.selectionTick();
  }

  Future<void> _promptWatered({
    required List<Plant> plants,
    required List<TaskInstance> tasks,
  }) async {
    final l10n = AppLocalizations.of(context);

    if (plants.isEmpty) return;

    final picked = await showBotanicaModalSheet<Plant>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (_) => _QuickWateredSheet(
        title: l10n.gardenQuickWatered,
        plants: plants,
      ),
    );

    if (!mounted) return;
    if (picked == null) return;

    await _recordWatered(plant: picked, tasks: tasks);
  }

  Future<void> _recordWatered({
    required Plant plant,
    required List<TaskInstance> tasks,
  }) async {
    final l10n = AppLocalizations.of(context);

    final now = DateTime.now();
    final selectedDate =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final isToday = _dateKey(selectedDate) == _dateKey(now);

    BotanicaHaptics.primaryPress();

    try {
      final tasksRepo = ref.read(tasksRepositoryProvider);
      final logsRepo = ref.read(logsRepositoryProvider);

      // Capture state for undo.
      TaskInstance? originalTask;
      TaskInstance? createdNextTask;
      String? createdLogId;

      if (isToday) {
        final pending = tasks
            .where((t) =>
                !t.isDismissed &&
                t.plantId == plant.id &&
                t.type == TaskType.water)
            .toList(growable: false)
          ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

        originalTask = pending.isEmpty ? null : pending.first;

        createdNextTask = await CareActions.waterNow(
          plant: plant,
          now: now,
          pendingWaterTask: originalTask,
          tasksRepository: tasksRepo,
          logsRepository: logsRepo,
          speciesRepository: ref.read(speciesRepositoryProvider),
          plantIdeaRepository: ref.read(plantIdeaRepositoryProvider),
          seasonalEngine: ref.read(seasonalCareEngineProvider),
          environment: ref.read(environmentSnapshotProvider),
          settings: ref.read(settingsControllerProvider),
          updateSettings: (next) =>
              ref.read(settingsControllerProvider.notifier).update(next),
        );

        // Find the log that was just created.
        final recentLogs = logsRepo.forPlant(plant.id);
        if (recentLogs.isNotEmpty) {
          final latest = recentLogs.reduce(
              (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
          if (latest.type == TaskType.water &&
              !latest.timestamp.isBefore(now.subtract(const Duration(seconds: 5)))) {
            createdLogId = latest.id;
          }
        }
      } else {
        final logId = const Uuid().v4();
        createdLogId = logId;
        final timestamp = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          12,
        );
        await logsRepo.add(
          CareLog(
            id: logId,
            plantId: plant.id,
            type: TaskType.water,
            timestamp: timestamp,
            note: null,
            linkedPhotoId: null,
          ),
        );
      }

      if (!mounted) return;
      BotanicaHaptics.completion();
      BotanicaCelebration.show(context);

      final settings = ref.read(settingsControllerProvider);

      Future<void> undoWater() async {
        if (isToday) {
          if (originalTask != null) {
            await tasksRepo.upsert(originalTask);
          }
          if (createdNextTask != null) {
            await tasksRepo.delete(createdNextTask.id);
          }
        }
        if (createdLogId != null) {
          await logsRepo.delete(createdLogId);
        }
        if (isToday) {
          await ref.read(settingsControllerProvider.notifier).update(settings);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  size: BotanicaTokens.iconSizeSm, color: Theme.of(context).colorScheme.inversePrimary),
              BotanicaGaps.hSm,
              Expanded(
                child: Text(
                    '${l10n.taskTypeWater} · ${l10n.commonDone}: ${plant.nickname}'),
              ),
            ],
          ),
          action: SnackBarAction(
            label: l10n.commonUndo,
            onPressed: () => unawaited(undoWater()),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      BotanicaHaptics.subtleError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.commonErrorTryAgain),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final plantsAsync = ref.watch(plantsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final logsRepo = ref.read(logsRepositoryProvider);
    final settings = ref.watch(settingsControllerProvider);

    final listPadding = widget.inShell
        ? BotanicaTokens.pagePaddingWithBottomNav(context)
        : BotanicaTokens.pagePadding;

    final header = widget.inShell
        ? <Widget>[
            BotanicaScreenTitle(l10n.navCalendar),
            BotanicaGaps.vSm,
          ]
        : const <Widget>[];

    Widget content = SafeArea(
      child: plantsAsync.when(
        loading: () => ListView(
          padding: listPadding,
          children: [
            ...header,
            const SizedBox(height: BotanicaTokens.spacingRelaxed),
            const BotanicaShimmer.card(height: 100),
            const SizedBox(height: BotanicaTokens.spacingBase),
            const BotanicaShimmer.card(height: 100),
            const SizedBox(height: BotanicaTokens.spacingBase),
            const BotanicaShimmer.card(height: 60),
          ],
        ),
        error: (_, __) => ListView(
          padding: listPadding,
          children: [
            ...header,
            BotanicaStateCard(
              icon: Icons.cloud_off_rounded,
              title: l10n.stateLoadFailedTitle,
              body: l10n.stateLoadFailedBody,
              primaryAction: BotanicaButton(
                variant: BotanicaButtonVariant.outlined,
                onPressed: () => ref.invalidate(plantsStreamProvider),
                icon: Icons.refresh_rounded,
                label: l10n.commonTryAgain,
              ),
            ),
          ],
        ),
        data: (plants) {
          final plantsById = <String, Plant>{
            for (final p in plants) p.id: p,
          };

          final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];

          return StreamBuilder<List<CareLog>>(
            stream: logsRepo.watchAll(),
            builder: (context, snapshot) {
              final logs = snapshot.data ?? const <CareLog>[];
              final rawLogsByDay = _groupLogsByDay(logs);
              final logsByDay = <String, List<CareLog>>{
                for (final entry in rawLogsByDay.entries)
                  if (entry.value.any(_matchesLogFilter))
                    entry.key: entry.value
                        .where(_matchesLogFilter)
                        .toList(growable: false),
              };

              final monthLabel = MaterialLocalizations.of(context)
                  .formatMonthYear(_focusedMonth);
              final reduceMotion = botanicaReduceMotion(context);

              final dayKey = _dateKey(_selectedDay);
              final isTodaySelected = dayKey == _dateKey(DateTime.now());

              final grid = CalendarMonthGrid(
                month: _focusedMonth,
                selected: _selectedDay,
                logsByDay: logsByDay,
                onSelect: (d) => _selectDay(
                  context: context,
                  day: d,
                  tasks: tasks,
                  logsByDay: logsByDay,
                  plantsById: plantsById,
                ),
              );

              final selectedLabel = MaterialLocalizations.of(context)
                  .formatFullDate(_selectedDay);

              final consistency =
                  _calculateConsistency(rawLogsByDay, _focusedMonth);
              final careActivityStreak =
                  _calculateCareActivityStreak(rawLogsByDay, DateTime.now());
              final streak = careActivityStreak > settings.careStreakDays
                  ? careActivityStreak
                  : settings.careStreakDays;

              return ListView(
                key: const ValueKey('calendar-list'),
                padding: listPadding,
                children: [
                  ...header,
                  BotanicaGlassCard(
                    padding: BotanicaTokens.cardPaddingDense,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _shiftMonth(-1),
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                              ),
                              tooltip: l10n.calendarPrevMonth,
                            ),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: reduceMotion
                                    ? Duration.zero
                                    : BotanicaTokens.motionMedium,
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  if (reduceMotion) return child;
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.10),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  monthLabel,
                                  key: ValueKey(monthLabel),
                                  textAlign: TextAlign.center,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _shiftMonth(1),
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                              ),
                              tooltip: l10n.calendarNextMonth,
                            ),
                          ],
                        ),
                        BotanicaGaps.vSm,
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragEnd: (details) {
                            final v = details.primaryVelocity ?? 0;
                            if (v.abs() < 380) return;
                            if (v < 0) {
                              _shiftMonth(1);
                            } else {
                              _shiftMonth(-1);
                            }
                          },
                          child: grid,
                        ),
                        if (!isTodaySelected || streak >= 2) ...[
                          BotanicaGaps.vSm,
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: BotanicaTokens.spacingXs,
                              runSpacing: BotanicaTokens.spacingXs,
                              alignment: WrapAlignment.end,
                              children: [
                                if (streak >= 2)
                                  BotanicaChip(
                                    key: const ValueKey(
                                        'calendar-streak-chip'),
                                    icon: Icons.eco_rounded,
                                    label: l10n.gardenCareStreakChip(streak),
                                    tint: scheme.tertiary,
                                    selected: true,
                                  ),
                                if (!isTodaySelected)
                                  TextButton.icon(
                                    key: const ValueKey(
                                        'calendar-jump-today'),
                                    onPressed: _jumpToToday,
                                    icon: const Icon(Icons.today_rounded,
                                        size: BotanicaTokens.iconSizeSm),
                                    label: Text(l10n.tasksTabToday),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animateSection(index: 0),
                  BotanicaGaps.vSm,
                  if (streak >= 2)
                    Row(
                      children: [
                        Expanded(
                          child: KeyedSubtree(
                            key: const ValueKey('calendar-stat-streak'),
                            child: _MonthStatCard(
                              label: l10n.gardenCareStreakChip(streak),
                              numericValue: streak,
                              icon: Icons.eco_rounded,
                              color: scheme.tertiary,
                            ),
                          ),
                        ),
                        BotanicaGaps.hSm,
                        Expanded(
                          child: KeyedSubtree(
                            key: const ValueKey('calendar-stat-consistency'),
                            child: _MonthStatCard(
                              label: l10n.calendarSectionConsistency,
                              numericValue: consistency,
                              suffix: '%',
                              icon: Icons.check_circle_rounded,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ).animateSection(index: 1)
                  else
                    KeyedSubtree(
                      key: const ValueKey('calendar-stat-consistency'),
                      child: _MonthStatCard(
                        label: l10n.calendarSectionConsistency,
                        numericValue: consistency,
                        suffix: '%',
                        icon: Icons.check_circle_rounded,
                        color: scheme.primary,
                      ),
                    ).animateSection(index: 1),
                  BotanicaGaps.vSm,
                  _CareHeatmap(logs: logs).animateSection(index: 2),
                  BotanicaGaps.vSm,
                  _WeekAheadForecast(tasks: tasks, plantsById: plantsById)
                      .animateSection(index: 3),
                  BotanicaGaps.vSm,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.calendarSectionHistory,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: plants.isEmpty
                                ? null
                                : () => _promptWatered(
                                      plants: plants,
                                      tasks: tasks,
                                    ),
                            icon: const Icon(Icons.water_drop_rounded,
                                size: BotanicaTokens.iconSizeSm),
                            label: Text(l10n.gardenQuickWatered),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    BotanicaTokens.radiusXL),
                              ),
                            ),
                          ),
                        ],
                      ),
                      BotanicaGaps.vXxs,
                      Text(
                        selectedLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.68),
                        ),
                      ),
                      BotanicaGaps.vSm,
                      Wrap(
                        spacing: BotanicaTokens.spacingXs,
                        runSpacing: BotanicaTokens.spacingXs,
                        children: [
                          BotanicaChip(
                            key: const ValueKey('calendar-filter-all'),
                            icon: Icons.filter_alt_off_rounded,
                            label: l10n.calendarFilterAll,
                            tint: scheme.onSurface,
                            selected: _logFilter == _CalendarLogFilter.all,
                            onTap: () => setState(
                                () => _logFilter = _CalendarLogFilter.all),
                          ),
                          BotanicaChip(
                            key: const ValueKey('calendar-filter-water'),
                            icon: Icons.water_drop_rounded,
                            label: l10n.taskTypeWater,
                            tint: scheme.primary,
                            selected: _logFilter == _CalendarLogFilter.water,
                            onTap: () => setState(
                                () => _logFilter = _CalendarLogFilter.water),
                          ),
                          BotanicaChip(
                            key: const ValueKey('calendar-filter-fertilize'),
                            icon: Icons.science_rounded,
                            label: l10n.taskTypeFertilize,
                            tint: scheme.secondary,
                            selected:
                                _logFilter == _CalendarLogFilter.fertilize,
                            onTap: () => setState(() =>
                                _logFilter = _CalendarLogFilter.fertilize),
                          ),
                          BotanicaChip(
                            key: const ValueKey('calendar-filter-mist'),
                            icon: Icons.air_rounded,
                            label: l10n.taskTypeMist,
                            tint: scheme.tertiary,
                            selected: _logFilter == _CalendarLogFilter.mist,
                            onTap: () => setState(
                                () => _logFilter = _CalendarLogFilter.mist),
                          ),
                          BotanicaChip(
                            key: const ValueKey('calendar-filter-other'),
                            icon: Icons.more_horiz_rounded,
                            label: l10n.calendarFilterOther,
                            tint: scheme.tertiary,
                            selected: _logFilter == _CalendarLogFilter.other,
                            onTap: () => setState(
                                () => _logFilter = _CalendarLogFilter.other),
                          ),
                        ],
                      ),
                    ],
                  ).animateSection(index: 2),
                  BotanicaGaps.vSm,
                ],
              );
            },
          );
        },
      ),
    );

    if (widget.inShell) return content;

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
      ),
      body: content,
    );
  }

  void _showDayAgendaSheet(
    BuildContext context,
    DateTime date,
    List<TaskInstance> dayTasks,
    List<CareLog> dayLogs,
    Map<String, Plant> plantsById,
  ) {
    showBotanicaModalSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (_) => _DayAgendaSheet(
        date: date,
        tasks: dayTasks,
        logs: dayLogs,
        plantsById: plantsById,
      ),
    );
  }
}

class _DayAgendaSheet extends StatelessWidget {
  const _DayAgendaSheet({
    required this.date,
    required this.tasks,
    required this.logs,
    required this.plantsById,
  });

  final DateTime date;
  final List<TaskInstance> tasks;
  final List<CareLog> logs;
  final Map<String, Plant> plantsById;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selectedLabel =
        MaterialLocalizations.of(context).formatFullDate(date);

    return BotanicaSheetBody(
      key: const ValueKey('calendar-day-sheet'),
      top: 10,
      bottom: 18,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedLabel,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.commonClose,
                ),
              ],
            ),
            BotanicaGaps.vSm,
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (tasks.isEmpty && logs.isEmpty)
                      BotanicaGlassCard(
                        padding: BotanicaTokens.cardPaddingDense,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: BotanicaTokens.spacingXxl),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_available_rounded,
                                size: 32,
                                color:
                                    scheme.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.calendarNoEvents,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.72),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      if (tasks.isNotEmpty) ...[
                        Text(
                          l10n.tasksTitle,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface.withValues(alpha: 0.72),
                          ),
                        ),
                        BotanicaGaps.vSm,
                        ...tasks.map((t) {
                          final plant = plantsById[t.plantId];
                          final plantName = plant?.nickname ?? '—';
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: BotanicaTokens.spacingSm),
                            child: _CalendarAgendaCard(
                              icon: iconForTask(t.type),
                              title:
                                  '${taskTypeLabel(l10n, t.type)} · $plantName',
                              timeLabel: MaterialLocalizations.of(context)
                                  .formatTimeOfDay(
                                TimeOfDay.fromDateTime(t.dueAt),
                              ),
                              onTap: plant == null
                                  ? null
                                  : () {
                                      Navigator.of(context).pop();
                                      context.push(
                                          '/garden/plant/${plant.id}?tab=care');
                                    },
                            ),
                          );
                        }),
                      ],
                      if (logs.isNotEmpty) ...[
                        if (tasks.isNotEmpty) BotanicaGaps.vMd,
                        Text(
                          l10n.calendarSectionHistory,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface.withValues(alpha: 0.72),
                          ),
                        ),
                        BotanicaGaps.vSm,
                        ...logs.map((log) {
                          final plant = plantsById[log.plantId];
                          final plantName = plant?.nickname ?? '—';
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: BotanicaTokens.spacingSm),
                            child: _CalendarAgendaCard(
                              icon: iconForTask(log.type),
                              title:
                                  '${taskTypeLabel(l10n, log.type)} · $plantName',
                              timeLabel: MaterialLocalizations.of(context)
                                  .formatTimeOfDay(
                                TimeOfDay.fromDateTime(log.timestamp),
                              ),
                              subtitle: log.note,
                              isHistory: true,
                              onTap: plant == null
                                  ? null
                                  : () {
                                      Navigator.of(context).pop();
                                      context.push(
                                          '/garden/plant/${plant.id}?tab=logs');
                                    },
                            ),
                          );
                        }),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.logsByDay,
    required this.onSelect,
    this.tasksByDay = const <String, List<TaskInstance>>{},
  });

  final DateTime month;
  final DateTime selected;
  final Map<String, List<CareLog>> logsByDay;
  final Map<String, List<TaskInstance>> tasksByDay;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);

    final firstOfMonth = DateTime(month.year, month.month, 1);
    final firstDayIndex = localizations.firstDayOfWeekIndex;

    final firstWeekdayIndex = firstOfMonth.weekday % 7;
    final shift = (firstWeekdayIndex - firstDayIndex + 7) % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: shift));

    final weekdayLabels = _weekdayLabels(localizations);
    final orderedWeekdayLabels = <String>[
      for (var i = 0; i < 7; i++) weekdayLabels[(i + firstDayIndex) % 7],
    ];

    Widget weekdayHeader() {
      return Row(
        children: [
          for (final w in orderedWeekdayLabels)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  w,
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.60),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final selectedKey = _dateKey(selected);
    final reduceMotion = botanicaReduceMotion(context);

    return Column(
      children: [
        weekdayHeader(),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 42,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final d = gridStart.add(Duration(days: index));
            final key = _dateKey(d);

            final inMonth = d.month == month.month;
            final isToday = key == todayKey;
            final isSelected = key == selectedKey;

            final dayLogs = logsByDay[key] ?? const <CareLog>[];
            final dayTasks = tasksByDay[key] ?? const <TaskInstance>[];
            final hasWater = dayLogs.any((e) => e.type == TaskType.water) ||
                dayTasks.any((e) => e.type == TaskType.water);
            final hasFertilize =
                dayLogs.any((e) => e.type == TaskType.fertilize) ||
                    dayTasks.any((e) => e.type == TaskType.fertilize);
            final hasOther = dayLogs.any(
                  (e) =>
                      e.type != TaskType.water && e.type != TaskType.fertilize,
                ) ||
                dayTasks.any(
                  (e) =>
                      e.type != TaskType.water && e.type != TaskType.fertilize,
                );

            final careCount = dayLogs.length + dayTasks.length;
            final careIntensity = inMonth && careCount > 0
                ? (careCount / 4).clamp(0.0, 1.0)
                : 0.0;

            final bg = isSelected
                ? scheme.primaryContainer.withValues(alpha: 0.45)
                : careIntensity > 0
                    ? Color.lerp(
                        scheme.surface.withValues(alpha: 0.55),
                        const Color(0xFF66BB6A).withValues(alpha: 0.28),
                        careIntensity,
                      )!
                    : scheme.surface.withValues(alpha: 0.55);
            final border = isToday
                ? scheme.primary.withValues(alpha: 0.70)
                : scheme.outlineVariant.withValues(alpha: 0.45);

            final l10n = AppLocalizations.of(context);
            final semanticsLabel = [
              isToday
                  ? '${localizations.formatFullDate(d)}, ${localizations.currentDateLabel}'
                  : localizations.formatFullDate(d),
              if (careCount > 0) l10n.calendarDayCareCount(careCount),
            ].join(', ');

            return Semantics(
              button: true,
              selected: isSelected,
              label: semanticsLabel,
              child: InkWell(
                key: ValueKey('cal-day-$key'),
                borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
                onTap: () => onSelect(DateTime(d.year, d.month, d.day)),
                child: AnimatedScale(
                  scale: isSelected && !reduceMotion ? 1.04 : 1,
                  duration: reduceMotion
                      ? Duration.zero
                      : BotanicaTokens.motionMedium,
                  curve: BotanicaTokens.curveReveal,
                  child: AnimatedContainer(
                    duration: reduceMotion
                        ? Duration.zero
                        : BotanicaTokens.motionMedium,
                    curve: BotanicaTokens.curveReveal,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(BotanicaTokens.radiusM),
                      color: bg,
                      border: Border.all(color: border),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.16),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ]
                          : const [],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${d.day}',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: inMonth
                                ? scheme.onSurface.withValues(alpha: 0.84)
                                : scheme.onSurface.withValues(alpha: 0.35),
                          ),
                        ),
                        const Spacer(),
                        if (dayLogs.isNotEmpty || dayTasks.isNotEmpty)
                          _EventDots(
                            water: hasWater,
                            fertilize: hasFertilize,
                            other: hasOther,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickWateredSheet extends StatefulWidget {
  const _QuickWateredSheet({
    required this.title,
    required this.plants,
  });

  final String title;
  final List<Plant> plants;

  @override
  State<_QuickWateredSheet> createState() => _QuickWateredSheetState();
}

class _QuickWateredSheetState extends State<_QuickWateredSheet> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final query = _controller.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.plants
        : widget.plants
            .where(
              (p) =>
                  p.nickname.toLowerCase().contains(query) ||
                  p.room.toLowerCase().contains(query) ||
                  p.speciesId.toLowerCase().contains(query),
            )
            .toList(growable: false);

    return BotanicaSheetBody(
      top: 10,
      bottom: 18,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.commonClose,
                ),
              ],
            ),
            BotanicaGaps.vSm,
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: l10n.commonSearch,
              ),
              onChanged: (_) => setState(() {}),
            ),
            BotanicaGaps.vSm,
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                separatorBuilder: (_, __) => BotanicaGaps.vSm,
                itemBuilder: (context, index) {
                  final plant = filtered[index];
                  return BotanicaGlassCard(
                    padding: BotanicaTokens.cardPaddingDense,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.spa_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.80),
                      ),
                      title: Text(
                        plant.nickname,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      subtitle: Text(
                        plant.room.isEmpty ? '—' : plant.room,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(plant),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarAgendaCard extends StatelessWidget {
  const _CalendarAgendaCard({
    required this.icon,
    required this.title,
    required this.timeLabel,
    this.subtitle,
    this.isHistory = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String timeLabel;
  final String? subtitle;
  final bool isHistory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
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
                    colors: isHistory
                        ? [
                            scheme.surfaceContainerHighest
                                .withValues(alpha: 0.55),
                            scheme.surfaceContainerHighest
                                .withValues(alpha: 0.30),
                          ]
                        : [
                            scheme.primaryContainer.withValues(alpha: 0.55),
                            scheme.tertiaryContainer.withValues(alpha: 0.30),
                          ],
                  ),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isHistory
                      ? scheme.onSurface.withValues(alpha: 0.55)
                      : scheme.onSurface.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isHistory
                            ? scheme.onSurface.withValues(alpha: 0.72)
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: BotanicaTokens.spacingMicro),
                    Text(
                      timeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: BotanicaTokens.spacingMicro),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.35),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDots extends StatelessWidget {
  const _EventDots({
    required this.water,
    required this.fertilize,
    required this.other,
  });

  final bool water;
  final bool fertilize;
  final bool other;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget dot(String kind, Color c) => Container(
          key: ValueKey('calendar-dot-$kind'),
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c,
          ),
        );

    final dots = <Widget>[];
    if (water) dots.add(dot('water', scheme.primary.withValues(alpha: 0.85)));
    if (fertilize) {
      dots.add(dot('fertilize', scheme.secondary.withValues(alpha: 0.80)));
    }
    if (other) {
      dots.add(dot('other', scheme.tertiary.withValues(alpha: 0.80)));
    }

    final visibleDots = dots.take(3).toList(growable: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final entry in visibleDots.asMap().entries)
          entry.value.animateIfAllowed(
            context,
            (child) => child
                .animate(key: ValueKey('calendar-dot-in-${entry.key}'))
                .fadeIn(
                  duration: BotanicaTokens.motionFast,
                  delay: BotanicaTokens.motionMicroFast * entry.key,
                  curve: BotanicaTokens.curveReveal,
                )
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: BotanicaTokens.motionFast,
                  delay: BotanicaTokens.motionMicroFast * entry.key,
                  curve: BotanicaTokens.curveReveal,
                ),
          ),
      ],
    );
  }
}

Map<String, List<CareLog>> _groupLogsByDay(List<CareLog> logs) {
  final map = <String, List<CareLog>>{};
  for (final log in logs) {
    final key = _dateKey(log.timestamp);
    (map[key] ??= <CareLog>[]).add(log);
  }

  for (final entry in map.entries) {
    entry.value.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  return map;
}

String _dateKey(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

List<TaskInstance> _tasksForDay(List<TaskInstance> tasks, DateTime day) {
  final start = DateTime(day.year, day.month, day.day);
  final end = start.add(const Duration(days: 1));
  return tasks
      .where(
        (t) =>
            !t.isDismissed &&
            !t.dueAt.isBefore(start) &&
            t.dueAt.isBefore(end),
      )
      .toList(growable: false)
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
}

int _calculateConsistency(
    Map<String, List<CareLog>> logsByDay, DateTime month) {
  if (logsByDay.isEmpty) return 0;
  final now = DateTime.now();
  int daysToConsider;
  if (month.year == now.year && month.month == now.month) {
    daysToConsider = now.day;
  } else if (month.isBefore(now)) {
    daysToConsider = DateTime(month.year, month.month + 1, 0).day;
  } else {
    return 0;
  }

  if (daysToConsider == 0) return 0;

  int activeDays = 0;
  for (int i = 1; i <= daysToConsider; i++) {
    final k = _dateKey(DateTime(month.year, month.month, i));
    if ((logsByDay[k] ?? []).isNotEmpty) {
      activeDays++;
    }
  }

  return ((activeDays / daysToConsider) * 100).round();
}

int _calculateCareActivityStreak(
  Map<String, List<CareLog>> logsByDay,
  DateTime anchor,
) {
  if (logsByDay.isEmpty) return 0;

  final today = DateTime(anchor.year, anchor.month, anchor.day);
  DateTime? latest;
  for (final logs in logsByDay.values) {
    for (final log in logs) {
      final day = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );
      if (day.isAfter(today)) continue;
      if (latest == null || day.isAfter(latest)) latest = day;
    }
  }

  if (latest == null) return 0;
  if (today.difference(latest).inDays > 1) return 0;

  var streak = 0;
  var cursor = latest;
  while ((logsByDay[_dateKey(cursor)] ?? const <CareLog>[]).isNotEmpty) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return streak;
}

class _MonthStatCard extends StatelessWidget {
  const _MonthStatCard({
    required this.label,
    required this.numericValue,
    required this.icon,
    required this.color,
    this.suffix = '',
  });

  final String label;
  final int numericValue;
  final IconData icon;
  final Color color;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$label: $numericValue$suffix',
      excludeSemantics: true,
      child: BotanicaGlassCard(
        padding: BotanicaTokens.cardPaddingDense,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: BotanicaTokens.iconSizeMd, color: color),
            ),
            BotanicaGaps.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BotanicaAnimatedCounter(
                    value: numericValue,
                    suffix: suffix,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

List<String> _weekdayLabels(MaterialLocalizations loc) {
  // MaterialLocalizations provides narrowWeekdays starting with Sunday.
  return loc.narrowWeekdays;
}

class _CareHeatmap extends StatefulWidget {
  const _CareHeatmap({required this.logs});

  final List<CareLog> logs;

  @override
  State<_CareHeatmap> createState() => _CareHeatmapState();
}

class _CareHeatmapState extends State<_CareHeatmap> {
  int? _tappedDay;
  OverlayEntry? _tooltipOverlay;

  void _showTooltip(BuildContext context, int dayIndex, Offset globalPosition) {
    _dismissTooltip();

    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 83));
    final date = startDate.add(Duration(days: dayIndex));

    final dayLogs = widget.logs.where((log) {
      final logDate = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );
      return logDate.year == date.year &&
          logDate.month == date.month &&
          logDate.day == date.day;
    }).toList();

    if (dayLogs.isEmpty) return;

    setState(() => _tappedDay = dayIndex);
    BotanicaHaptics.selectionTick();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final waters = dayLogs.where((l) => l.type == TaskType.water).length;
    final fertilizes =
        dayLogs.where((l) => l.type == TaskType.fertilize).length;
    final others = dayLogs.length - waters - fertilizes;

    final parts = <String>[];
    if (waters > 0) parts.add('$waters water');
    if (fertilizes > 0) parts.add('$fertilizes fertilize');
    if (others > 0) parts.add('$others other');
    final detail = parts.join(', ');

    final dateLabel = MaterialLocalizations.of(context).formatShortDate(date);

    final overlay = Overlay.of(context);
    _tooltipOverlay = OverlayEntry(
      builder: (ctx) => _HeatmapTooltipOverlay(
        globalPosition: globalPosition,
        dateLabel: dateLabel,
        detail: detail,
        totalCount: dayLogs.length,
        scheme: scheme,
        textTheme: textTheme,
        onDismiss: _dismissTooltip,
      ),
    );
    overlay.insert(_tooltipOverlay!);

    // Auto-dismiss after 2.5 seconds.
    Future.delayed(const Duration(milliseconds: 2500), () {
      _dismissTooltip();
    });
  }

  void _dismissTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
    if (_tappedDay != null && mounted) {
      setState(() => _tappedDay = null);
    }
  }

  @override
  void dispose() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 83));

    final countByDay = <int, int>{};
    for (final log in widget.logs) {
      final diff = log.timestamp.difference(startDate).inDays;
      if (diff >= 0 && diff < 84) {
        countByDay[diff] = (countByDay[diff] ?? 0) + 1;
      }
    }

    final maxCount = countByDay.values.fold<int>(0, (a, b) => a > b ? a : b);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.calendarHeatmapTitle,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          BotanicaGaps.vSm,
          LayoutBuilder(
            builder: (context, constraints) {
              const totalDays = 84;
              const gap = 2.0;
              final cols = (totalDays / 7).ceil();
              final colWidth =
                  (constraints.maxWidth - (cols - 1) * gap) / cols;
              final cellSize = colWidth < 12.0 ? colWidth : 12.0;
              final gridHeight = 7 * cellSize + 6 * gap;

              return SizedBox(
                height: gridHeight,
                child: Semantics(
                  label: '${l10n.calendarHeatmapTitle}, 84 days, peak $maxCount actions in a day',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) {
                      final local = details.localPosition;
                      final col = (local.dx / (cellSize + gap)).floor();
                      final row = (local.dy / (cellSize + gap)).floor();
                      if (col < 0 || col >= cols || row < 0 || row >= 7) return;
                      final dayIndex = col * 7 + row;
                      if (dayIndex < 0 || dayIndex >= totalDays) return;
                      _showTooltip(context, dayIndex, details.globalPosition);
                    },
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, gridHeight),
                      painter: _HeatmapPainter(
                        countByDay: countByDay,
                        maxCount: maxCount,
                        startWeekday: startDate.weekday % 7,
                        primaryColor: scheme.primary,
                        emptyColor: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        highlightedDay: _tappedDay,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeatmapTooltipOverlay extends StatelessWidget {
  const _HeatmapTooltipOverlay({
    required this.globalPosition,
    required this.dateLabel,
    required this.detail,
    required this.totalCount,
    required this.scheme,
    required this.textTheme,
    required this.onDismiss,
  });

  final Offset globalPosition;
  final String dateLabel;
  final String detail;
  final int totalCount;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onDismiss,
        child: Stack(
          children: [
            Positioned(
              left: (globalPosition.dx - 80).clamp(16.0, MediaQuery.of(context).size.width - 176),
              top: globalPosition.dy - 64,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                        BotanicaTokens.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  const _HeatmapPainter({
    required this.countByDay,
    required this.maxCount,
    required this.startWeekday,
    required this.primaryColor,
    required this.emptyColor,
    this.highlightedDay,
  });

  final Map<int, int> countByDay;
  final int maxCount;
  final int startWeekday;
  final Color primaryColor;
  final Color emptyColor;
  final int? highlightedDay;

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 12.0;
    const gap = 2.0;
    const totalDays = 84;
    final cols = (totalDays / 7).ceil();
    final colWidth = (size.width - (cols - 1) * gap) / cols;
    final actualCell = colWidth < cellSize ? colWidth : cellSize;

    for (int day = 0; day < totalDays; day++) {
      final col = day ~/ 7;
      final row = day % 7;

      final x = col * (actualCell + gap);
      final y = row * (actualCell + gap);

      final count = countByDay[day] ?? 0;
      final Color color;
      if (count == 0) {
        color = emptyColor;
      } else if (maxCount <= 0) {
        color = primaryColor.withValues(alpha: 0.3);
      } else {
        final intensity = (count / maxCount).clamp(0.2, 1.0);
        color = primaryColor.withValues(alpha: intensity);
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, actualCell, actualCell),
        const Radius.circular(2.5),
      );
      canvas.drawRRect(rect, Paint()..color = color);

      // Draw highlight ring around tapped cell.
      if (highlightedDay == day && count > 0) {
        final highlightPaint = Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        final highlightRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 1, y - 1, actualCell + 2, actualCell + 2),
          const Radius.circular(3.5),
        );
        canvas.drawRRect(highlightRect, highlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.countByDay != countByDay ||
        oldDelegate.maxCount != maxCount ||
        oldDelegate.highlightedDay != highlightedDay;
  }
}

class _WeekAheadForecast extends StatelessWidget {
  const _WeekAheadForecast({
    required this.tasks,
    required this.plantsById,
  });

  final List<TaskInstance> tasks;
  final Map<String, Plant> plantsById;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dayCounts = List.generate(7, (i) {
      final day = today.add(Duration(days: i));
      final nextDay = day.add(const Duration(days: 1));
      return tasks
          .where((t) =>
              !t.isDismissed &&
              t.status != TaskStatus.snoozed &&
              !t.dueAt.isBefore(day) &&
              t.dueAt.isBefore(nextDay) &&
              plantsById.containsKey(t.plantId))
          .length;
    });

    final totalUpcoming = dayCounts.fold<int>(0, (sum, c) => sum + c);
    if (totalUpcoming == 0) return const SizedBox.shrink();

    final maxCount = dayCounts.reduce((a, b) => a > b ? a : b);

    final dayLabels = List.generate(7, (i) {
      final day = today.add(Duration(days: i));
      return MaterialLocalizations.of(context)
          .narrowWeekdays[day.weekday % 7];
    });

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 16,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.calendarWeekAheadTitle,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                l10n.calendarWeekAheadCount(totalUpcoming),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final count = dayCounts[i];
              final barHeight = maxCount > 0
                  ? (count / maxCount * 28).clamp(4.0, 28.0)
                  : 4.0;
              final isToday = i == 0;
              return Column(
                children: [
                  SizedBox(
                    height: 32,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: BotanicaTokens.motionMedium,
                        width: 18,
                        height: count > 0 ? barHeight : 4,
                        decoration: BoxDecoration(
                          color: count > 0
                              ? (isToday
                                  ? scheme.primary
                                  : scheme.primary.withValues(alpha: 0.5))
                              : scheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayLabels[i],
                    style: textTheme.labelSmall?.copyWith(
                      color: isToday
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: isToday ? FontWeight.w700 : null,
                      fontSize: 10,
                    ),
                  ),
                  if (count > 0)
                    Text(
                      '$count',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                    )
                  else
                    const SizedBox(height: 11),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
