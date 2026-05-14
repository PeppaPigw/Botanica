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
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
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

    final tasksRepo = ref.read(tasksRepositoryProvider);
    final logsRepo = ref.read(logsRepositoryProvider);

    if (isToday) {
      final pending = tasks
          .where((t) =>
              !t.isDismissed &&
              t.plantId == plant.id &&
              t.type == TaskType.water)
          .toList(growable: false)
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

      await CareActions.waterNow(
        plant: plant,
        now: now,
        pendingWaterTask: pending.isEmpty ? null : pending.first,
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
    } else {
      // Past days: record only a log entry (do not reschedule tasks).
      final timestamp = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        12,
      );
      await logsRepo.add(
        CareLog(
          id: const Uuid().v4(),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.water_drop_rounded,
                size: BotanicaTokens.iconSizeSm, color: Theme.of(context).colorScheme.inversePrimary),
            BotanicaGaps.hSm,
            Text(
                '${l10n.taskTypeWater} · ${l10n.commonDone}: ${plant.nickname}'),
          ],
        ),
      ),
    );
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
            BotanicaGaps.vXxl,
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                    scheme.primary.withValues(alpha: 0.7)),
              ),
            ),
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
                              value: '$streak',
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
                              value: '$consistency%',
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
                        value: '$consistency%',
                        icon: Icons.check_circle_rounded,
                        color: scheme.primary,
                      ),
                    ).animateSection(index: 1),
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
                          child: Text(
                            l10n.calendarNoEvents,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.72),
                              height: 1.4,
                            ),
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

            final bg = isSelected
                ? scheme.primaryContainer.withValues(alpha: 0.45)
                : scheme.surface.withValues(alpha: 0.55);
            final border = isToday
                ? scheme.primary.withValues(alpha: 0.70)
                : scheme.outlineVariant.withValues(alpha: 0.45);

            final semanticsLabel = isToday
                ? '${localizations.formatFullDate(d)}, ${localizations.currentDateLabel}'
                : localizations.formatFullDate(d);

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
    this.isHistory = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String timeLabel;
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
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
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
                Text(
                  value,
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
    );
  }
}

List<String> _weekdayLabels(MaterialLocalizations loc) {
  // MaterialLocalizations provides narrowWeekdays starting with Sunday.
  return loc.narrowWeekdays;
}
