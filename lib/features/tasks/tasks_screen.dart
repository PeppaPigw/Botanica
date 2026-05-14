import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/glass_card.dart';

import '../../domain/models/plant.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/services/care_plan_engine.dart';

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

    final seasonalTips =
        CarePlanEngine.seasonalTipKeys(settings.hemisphere, DateTime.now());
    final showSeasonalTips = seasonalTips.isNotEmpty &&
        seasonalTips.first != settings.dismissedSeasonTipKey;

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.tasksTitle),
        actions: [
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
                                    ),
                                    _TasksList(
                                      tasks: _filterSoon(tasks),
                                      plants: plants,
                                      emptyLabel: l10n.tasksEmptySoon,
                                      isToday: false,
                                    ),
                                    _TasksList(
                                      tasks: _filterWatch(tasks),
                                      plants: plants,
                                      emptyLabel: l10n.tasksEmptyWatch,
                                      isToday: false,
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

class _TasksList extends ConsumerWidget {
  const _TasksList({
    required this.tasks,
    required this.plants,
    required this.emptyLabel,
    required this.isToday,
  });

  final List<TaskInstance> tasks;
  final List<Plant> plants;
  final String emptyLabel;
  final bool isToday;

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

        return TaskTile(
          task: task,
          plant: plant,
          index: index,
          isToday: isToday,
        ).animateSection(index: index);
      },
    );
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

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
