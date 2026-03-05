import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_chip.dart';
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
  TaskType? _logFilter;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _shiftMonth(int delta) {
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
    setState(() => _focusedMonth = next);
    HapticFeedback.selectionClick();
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

    HapticFeedback.lightImpact();

    final tasksRepo = ref.read(tasksRepositoryProvider);
    final logsRepo = ref.read(logsRepositoryProvider);

    if (isToday) {
      final pending = tasks
          .where((t) =>
              !t.isDone && t.plantId == plant.id && t.type == TaskType.water)
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
        engine: ref.read(carePlanEngineProvider),
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
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.water_drop_rounded, size: 18, color: Theme.of(context).colorScheme.inversePrimary),
            const SizedBox(width: 10),
            Text('${l10n.taskTypeWater} · ${l10n.commonDone}: ${plant.nickname}'),
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

    final listPadding = widget.inShell
        ? BotanicaTokens.pagePaddingWithBottomNav(context)
        : BotanicaTokens.pagePadding;

    final header = widget.inShell
        ? <Widget>[
            BotanicaScreenTitle(l10n.navCalendar),
            const SizedBox(height: 12),
          ]
        : const <Widget>[];

    Widget content = SafeArea(
      child: plantsAsync.when(
        loading: () => ListView(
          padding: listPadding,
          children: [
            ...header,
            const SizedBox(height: 180),
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
              primaryAction: OutlinedButton.icon(
                onPressed: () => ref.invalidate(plantsStreamProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.commonTryAgain),
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
              final logsByDay = _logFilter == null
                  ? rawLogsByDay
                  : <String, List<CareLog>>{
                      for (final entry in rawLogsByDay.entries)
                        if (entry.value.any((log) => log.type == _logFilter))
                          entry.key: entry.value
                              .where((log) => log.type == _logFilter)
                              .toList(growable: false),
                    };

              final monthLabel = MaterialLocalizations.of(context)
                  .formatMonthYear(_focusedMonth);

              final grid = _buildMonthGrid(
                context: context,
                month: _focusedMonth,
                selected: _selectedDay,
                logsByDay: logsByDay,
                onSelect: (d) => setState(() {
                  _selectedDay = d;
                  if (d.year != _focusedMonth.year ||
                      d.month != _focusedMonth.month) {
                    _focusedMonth = DateTime(d.year, d.month, 1);
                  }
                }),
              );

              final dayKey = _dateKey(_selectedDay);
              final dayLogs = logsByDay[dayKey] ?? const <CareLog>[];
              final dayTasks = _tasksForDay(tasks, _selectedDay);

              final selectedLabel = MaterialLocalizations.of(context)
                  .formatFullDate(_selectedDay);

              return ListView(
                key: const ValueKey('calendar-list'),
                padding: listPadding,
                children: [
                  ...header,
                  BotanicaGlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _shiftMonth(-1),
                              icon: const Icon(Icons.chevron_left_rounded),
                              tooltip: l10n.calendarPrevMonth,
                            ),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: BotanicaTokens.motionMedium,
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
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
                              icon: const Icon(Icons.chevron_right_rounded),
                              tooltip: l10n.calendarNextMonth,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                      ],
                    ),
                  ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.04),
                  const SizedBox(height: 14),
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
                        icon: const Icon(Icons.water_drop_rounded, size: 18),
                        label: Text(l10n.gardenQuickWatered),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(BotanicaTokens.radiusXL),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 80.ms, duration: 380.ms),
                  const SizedBox(height: 6),
                  Text(
                    selectedLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 380.ms),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: BotanicaTokens.spacingXs,
                    runSpacing: BotanicaTokens.spacingXs,
                    children: [
                      BotanicaChip(
                        icon: Icons.filter_alt_off_rounded,
                        label: l10n.calendarFilterAll,
                        tint: scheme.onSurface,
                        selected: _logFilter == null,
                        onTap: () => setState(() => _logFilter = null),
                      ),
                      BotanicaChip(
                        icon: Icons.water_drop_rounded,
                        label: l10n.taskTypeWater,
                        tint: scheme.primary,
                        selected: _logFilter == TaskType.water,
                        onTap: () =>
                            setState(() => _logFilter = TaskType.water),
                      ),
                      BotanicaChip(
                        icon: Icons.science_rounded,
                        label: l10n.taskTypeFertilize,
                        tint: scheme.secondary,
                        selected: _logFilter == TaskType.fertilize,
                        onTap: () =>
                            setState(() => _logFilter = TaskType.fertilize),
                      ),
                      BotanicaChip(
                        icon: Icons.air_rounded,
                        label: l10n.taskTypeMist,
                        tint: scheme.tertiary,
                        selected: _logFilter == TaskType.mist,
                        onTap: () => setState(() => _logFilter = TaskType.mist),
                      ),
                    ],
                  ).animate().fadeIn(delay: 120.ms, duration: 380.ms),
                  const SizedBox(height: 10),
                  BotanicaGlassCard(
                    padding: const EdgeInsets.all(14),
                    child: (dayTasks.isEmpty && dayLogs.isEmpty)
                        ? Text(
                            l10n.calendarNoEvents,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.72),
                              height: 1.4,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dayTasks.isNotEmpty) ...[
                                Text(
                                  l10n.tasksTitle,
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.72),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...dayTasks.map((t) {
                                  final plant =
                                      plantsById[t.plantId]?.nickname ?? '—';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _iconForTask(t.type),
                                          color: scheme.onSurface
                                              .withValues(alpha: 0.78),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '${_taskTypeLabel(l10n, t.type)} · $plant',
                                            style:
                                                textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          MaterialLocalizations.of(context)
                                              .formatTimeOfDay(
                                            TimeOfDay.fromDateTime(t.dueAt),
                                          ),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurface
                                                .withValues(alpha: 0.62),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                              if (dayTasks.isNotEmpty && dayLogs.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: scheme.outlineVariant
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              if (dayLogs.isNotEmpty) ...[
                                Text(
                                  l10n.calendarSectionHistory,
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.72),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...dayLogs.map((log) {
                                  final plant =
                                      plantsById[log.plantId]?.nickname ?? '—';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _iconForTask(log.type),
                                          color: scheme.onSurface
                                              .withValues(alpha: 0.78),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '${_taskTypeLabel(l10n, log.type)} · $plant',
                                            style:
                                                textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          MaterialLocalizations.of(context)
                                              .formatTimeOfDay(
                                            TimeOfDay.fromDateTime(
                                              log.timestamp,
                                            ),
                                          ),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurface
                                                .withValues(alpha: 0.62),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                  )
                      .animate()
                      .fadeIn(delay: 120.ms, duration: 420.ms)
                      .slideY(begin: 0.03, curve: Curves.easeOutCubic),
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
}

Widget _buildMonthGrid({
  required BuildContext context,
  required DateTime month,
  required DateTime selected,
  required Map<String, List<CareLog>> logsByDay,
  required ValueChanged<DateTime> onSelect,
}) {
  final scheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final localizations = MaterialLocalizations.of(context);

  final firstOfMonth = DateTime(month.year, month.month, 1);
  final firstDayIndex = localizations.firstDayOfWeekIndex; // 0..6

  final firstWeekdayIndex = firstOfMonth.weekday % 7; // 0=Sun
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
          final hasWater = dayLogs.any((e) => e.type == TaskType.water);
          final hasFertilize = dayLogs.any((e) => e.type == TaskType.fertilize);
          final hasOther = dayLogs.any(
            (e) => e.type != TaskType.water && e.type != TaskType.fertilize,
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
              child: AnimatedContainer(
                duration: BotanicaTokens.motionMedium,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
                  color: bg,
                  border: Border.all(color: border),
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
                    if (dayLogs.isNotEmpty)
                      _EventDots(
                        water: hasWater,
                        fertilize: hasFertilize,
                        other: hasOther,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
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
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: l10n.commonSearch,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
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

    Widget dot(Color c) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c,
          ),
        );

    final dots = <Widget>[];
    if (water) dots.add(dot(scheme.primary.withValues(alpha: 0.85)));
    if (fertilize) dots.add(dot(scheme.secondary.withValues(alpha: 0.80)));
    if (other) dots.add(dot(scheme.tertiary.withValues(alpha: 0.80)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots.take(3).toList(growable: false),
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
        (t) => !t.isDone && !t.dueAt.isBefore(start) && t.dueAt.isBefore(end),
      )
      .toList(growable: false)
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
}

List<String> _weekdayLabels(MaterialLocalizations loc) {
  // MaterialLocalizations provides narrowWeekdays starting with Sunday.
  return loc.narrowWeekdays;
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

String _taskTypeLabel(AppLocalizations l10n, TaskType type) => switch (type) {
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
