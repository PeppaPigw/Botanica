import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_text_styles.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/environment/weather_code.dart';
import '../../core/haptics/botanica_haptics.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/widgets/botanica_ambient_background.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_all_done_sheet.dart';
import '../../core/widgets/botanica_celebration.dart';
import '../../core/widgets/botanica_daily_briefing_card.dart';
import '../../core/widgets/botanica_perfect_week_sheet.dart';
import '../../core/widgets/botanica_rescue_reset_sheet.dart';
import '../../core/widgets/botanica_streak_milestone_sheet.dart';
import '../../core/widgets/botanica_weekly_recap_sheet.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_press_scale.dart';
import '../../core/widgets/botanica_search_field.dart';
import '../../core/widgets/botanica_shimmer.dart';
import '../../core/utils/motion_preferences.dart';
import '../../core/widgets/botanica_water_level.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/botanica_snooze_picker_sheet.dart';
import '../../core/widgets/screen_title.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/environment_snapshot.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_idea.dart';
import '../../domain/models/species.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/photo_entry.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/services/garden_wellness_summary.dart';
import '../../domain/services/plant_health_score.dart';
import '../../domain/services/garden_intelligence.dart';
import '../../domain/services/plant_mood.dart';
import '../../domain/services/plant_voice.dart';
import '../../domain/services/care_coaching.dart';
import '../../domain/services/plant_milestone.dart';
import '../../domain/services/seasonal_tips.dart';
import '../../domain/services/daily_briefing_engine.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/care/care_actions.dart';
import '../../services/review/review_prompt_service.dart';
import 'widgets/room_environment_card.dart';
import '../calendar/calendar_screen.dart';
import '../profile/garden_wellness_screen.dart';
import '../tasks/tasks_screen.dart';
import '../tasks/widgets/task_tile.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({
    super.key,
    this.initialSelectedRoom,
  });

  static const String location = '/garden';

  final String? initialSelectedRoom;

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

enum PlantCardMode { compact, gallery, careFirst }

enum GardenViewMode { list, map }

enum GardenSortMode { name, needsCare, newest, health, room }

class _GardenScreenState extends ConsumerState<GardenScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedRoom;
  PlantCardMode _cardMode = PlantCardMode.careFirst;
  GardenViewMode _viewMode = GardenViewMode.list;
  bool _isBatchActionRunning = false;

  String _searchQuery = '';
  bool _showArchived = false;
  GardenSortMode _sortMode = GardenSortMode.needsCare;
  bool _weeklyRecapChecked = false;
  bool _rescueResetChecked = false;

  @override
  void initState() {
    super.initState();
    _selectedRoom = _normalizedSelectedRoom(widget.initialSelectedRoom);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _maybeShowWeeklyRecap(UserSettings settings, List<CareLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    if (settings.lastWeeklyRecapShown != null) {
      final lastShown = settings.lastWeeklyRecapShown!;
      final lastShownDay = DateTime(lastShown.year, lastShown.month, lastShown.day);
      if (!lastShownDay.isBefore(weekStart)) return;
    }

    final prevWeekStart = weekStart.subtract(const Duration(days: 7));
    final prevWeekLogs = logs.where(
      (l) => !l.timestamp.isBefore(prevWeekStart) && l.timestamp.isBefore(weekStart),
    ).toList();

    if (prevWeekLogs.length < 3) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(settingsControllerProvider.notifier).update(
        settings.copyWith(lastWeeklyRecapShown: today),
      );
      BotanicaWeeklyRecapSheet.show(
        context,
        logs: prevWeekLogs,
        streakDays: settings.careStreakDays,
      );
    });
  }

  void _maybeShowRescueReset(UserSettings settings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = settings.lastCareDate;
    if (last == null) return;

    final lastDay = DateTime(last.year, last.month, last.day);
    final daysMissed = today.difference(lastDay).inDays;

    if (daysMissed < 3) return;
    if (settings.longestStreak < 3) return;
    if (settings.isOnVacation) return;

    final previousStreak = settings.longestStreak;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      BotanicaRescueResetSheet.show(
        context,
        previousStreak: previousStreak,
        daysMissed: daysMissed,
      );
    });
  }

  @override
  void didUpdateWidget(covariant GardenScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedRoom != widget.initialSelectedRoom) {
      _selectedRoom = _normalizedSelectedRoom(widget.initialSelectedRoom);
    }
  }

  Future<void> _waterAllInSelectedRoom(List<_RoomWaterEntry> entries) async {
    if (_isBatchActionRunning) return;
    setState(() => _isBatchActionRunning = true);

    try {
      final l10n = AppLocalizations.of(context);
      final now = DateTime.now();
      final tasksRepo = ref.read(tasksRepositoryProvider);
      final logsRepo = ref.read(logsRepositoryProvider);
      final speciesRepo = ref.read(speciesRepositoryProvider);
      final ideaRepo = ref.read(plantIdeaRepositoryProvider);
      final env = ref.read(environmentSnapshotProvider);
      final engine = ref.read(seasonalCareEngineProvider);
      final settingsController = ref.read(settingsControllerProvider.notifier);
      final completedPlantIds = <String>{};

      for (final entry in entries) {
        final currentSettings = ref.read(settingsControllerProvider);
        await CareActions.completeTask(
          task: entry.task,
          plant: entry.plant,
          now: now,
          tasksRepository: tasksRepo,
          logsRepository: logsRepo,
          speciesRepository: speciesRepo,
          plantIdeaRepository: ideaRepo,
          seasonalEngine: engine,
          environment: env,
          settings: currentSettings,
          updateSettings: settingsController.update,
        );
        completedPlantIds.add(entry.plant.id);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  size: BotanicaTokens.iconSizeSm,
                  color: Theme.of(context).colorScheme.inversePrimary),
              BotanicaGaps.hSm,
              Text(l10n.gardenRoomsWateredCount(completedPlantIds.length)),
            ],
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
      if (mounted) setState(() => _isBatchActionRunning = false);
    }
  }

  Future<void> _snoozeAllInSelectedRoom(List<_RoomTaskEntry> entries) async {
    if (_isBatchActionRunning) return;
    setState(() => _isBatchActionRunning = true);

    try {
      final l10n = AppLocalizations.of(context);
      final now = DateTime.now();
      final tasksRepo = ref.read(tasksRepositoryProvider);
      final settings = ref.read(settingsControllerProvider);

      for (final entry in entries) {
        final target = CareActions.snoozeUntilTomorrow(
          now: now,
          plant: entry.plant,
          settings: settings,
        );
        await tasksRepo.upsert(
          entry.task.copyWith(
            dueAt: target,
            status: TaskStatus.snoozed,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.snooze_rounded,
                  size: BotanicaTokens.iconSizeSm,
                  color: Theme.of(context).colorScheme.inversePrimary),
              BotanicaGaps.hSm,
              Text(l10n.gardenRoomsSnoozedCount(entries.length)),
            ],
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
      if (mounted) setState(() => _isBatchActionRunning = false);
    }
  }

  Future<void> _waterAllOverdue(
    List<TaskInstance> overdueTasks,
    Map<String, Plant> plantsById,
  ) async {
    if (_isBatchActionRunning) return;
    setState(() => _isBatchActionRunning = true);

    try {
      final l10n = AppLocalizations.of(context);
      final now = DateTime.now();
      final tasksRepo = ref.read(tasksRepositoryProvider);
      final logsRepo = ref.read(logsRepositoryProvider);
      final speciesRepo = ref.read(speciesRepositoryProvider);
      final ideaRepo = ref.read(plantIdeaRepositoryProvider);
      final env = ref.read(environmentSnapshotProvider);
      final engine = ref.read(seasonalCareEngineProvider);
      final settingsController = ref.read(settingsControllerProvider.notifier);
      int wateredCount = 0;

      for (final task in overdueTasks) {
        final plant = plantsById[task.plantId];
        if (plant == null) continue;
        final currentSettings = ref.read(settingsControllerProvider);
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
          settings: currentSettings,
          updateSettings: settingsController.update,
        );
        wateredCount++;
      }

      if (!mounted) return;
      BotanicaHaptics.completion();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  size: BotanicaTokens.iconSizeSm,
                  color: Theme.of(context).colorScheme.inversePrimary),
              BotanicaGaps.hSm,
              Text(l10n.gardenWateredAllOverdue(wateredCount)),
            ],
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
      if (mounted) setState(() => _isBatchActionRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final settings = ref.watch(settingsControllerProvider);
    final plantsAsync = ref.watch(plantsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final environment = ref.watch(environmentSnapshotProvider);
    final speciesAsync = ref.watch(speciesListProvider);
    final ideasAsync = ref.watch(plantIdeaMapProvider);

    final logsAsync = ref.watch(careLogsStreamProvider);
    final photosAsync = ref.watch(photoEntriesStreamProvider);

    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final allPhotos = photosAsync.valueOrNull ?? const <PhotoEntry>[];

    if (!_weeklyRecapChecked && logs.isNotEmpty) {
      _weeklyRecapChecked = true;
      _maybeShowWeeklyRecap(settings, logs);
    }

    if (!_rescueResetChecked) {
      _rescueResetChecked = true;
      _maybeShowRescueReset(settings);
    }

    final plants = plantsAsync.valueOrNull ?? const <Plant>[];
    final plantsById = <String, Plant>{
      for (final p in plants) p.id: p,
    };

    final todayDueTasks = tasks.where((t) {
      if (t.isDismissed || t.status == TaskStatus.snoozed) {
        return false;
      }
      final due = t.dueAt;
      final now = DateTime.now();
      return due.isBefore(now) ||
          (due.year == now.year &&
              due.month == now.month &&
              due.day == now.day);
    }).toList();
    todayDueTasks.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    // Overdue water tasks for batch action (only truly overdue, not just due today)
    final overdueWaterTasks = todayDueTasks.where((t) {
      if (t.type != TaskType.water) return false;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      return t.dueAt.isBefore(todayStart);
    }).toList();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayCompletedCount = logs.where((l) =>
        !l.timestamp.isBefore(todayStart)).length;

    // Overdue task count for mood indicator (all types, truly overdue)
    final overdueTaskCount = tasks.where((t) =>
        !t.isDismissed &&
        t.status != TaskStatus.done &&
        t.status != TaskStatus.snoozed &&
        t.dueAt.isBefore(todayStart)).length;
    final gardenHealthScore = ref.watch(gardenHealthScoreProvider);

    final tomorrowStart = DateTime(now.year, now.month, now.day + 1);
    final tomorrowEnd = tomorrowStart.add(const Duration(days: 1));
    final tomorrowTaskCount = tasks.where((t) {
      if (t.isDismissed || t.status == TaskStatus.snoozed) return false;
      final due = t.dueAt;
      return !due.isBefore(tomorrowStart) && due.isBefore(tomorrowEnd);
    }).length;

    final streakAtRisk = settings.careStreakDays >= 2 &&
        settings.lastCareDate != null &&
        (() {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final lastDay = DateTime(
            settings.lastCareDate!.year,
            settings.lastCareDate!.month,
            settings.lastCareDate!.day,
          );
          return today.difference(lastDay).inDays == 1;
        })();

    final localeCode =
        settings.localeCode ?? Localizations.localeOf(context).languageCode;

    final speciesById = <String, Species>{
      for (final s in speciesAsync.valueOrNull ?? const <Species>[]) s.id: s,
    };
    final ideaById = ideasAsync.valueOrNull ?? const <String, PlantIdea>{};

    final displayTemp = _displayTemperature(
      environment.tempC,
      settings.temperatureUnit,
    );
    final unitSymbol = _unitSymbol(settings.temperatureUnit);
    final conditionKind = weatherKindForWmoCode(environment.weatherCode);
    final conditionLabel = _weatherLabel(l10n, conditionKind);

    return SafeArea(
      child: Stack(
        children: [
          const Positioned.fill(
            child: BotanicaAmbientBackground(
              intensity: 0.08,
              speed: 0.6,
            ),
          ),
          RefreshIndicator(
            onRefresh: () => ref
                .read(environmentControllerProvider.notifier)
                .refresh(force: true),
            edgeOffset: 0,
            child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: BotanicaTokens.pagePadding,
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BotanicaScreenTitle(_timeGreeting(l10n)),
                        if (settings.careStreakDays >= 2) ...[
                          BotanicaGaps.vTiny,
                          Row(
                            children: [
                              _StreakProgressChip(
                                streakDays: settings.careStreakDays,
                                freezeCount: settings.streakFreezeCount,
                              ),
                              BotanicaGaps.hSm,
                              const _GardenHealthChip(),
                              if (plants.where((p) => !p.isArchived).isNotEmpty) ...[
                                BotanicaGaps.hSm,
                                _GardenMoodIndicator(
                                  overdueTasks: overdueTaskCount,
                                  avgHealthScore: gardenHealthScore.toDouble(),
                                ),
                              ],
                            ],
                          ),
                        ] else ...[
                          BotanicaGaps.vTiny,
                          Row(
                            children: [
                              const _GardenHealthChip(),
                              if (plants.where((p) => !p.isArchived).isNotEmpty) ...[
                                BotanicaGaps.hSm,
                                _GardenMoodIndicator(
                                  overdueTasks: overdueTaskCount,
                                  avgHealthScore: gardenHealthScore.toDouble(),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  _ViewModeToggle(
                    cardMode: _cardMode,
                    viewMode: _viewMode,
                    onCardModeChanged: (m) => setState(() => _cardMode = m),
                    onViewModeChanged: (m) => setState(() => _viewMode = m),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort_rounded, color: scheme.onSurface),
                    tooltip: l10n.gardenSortTitle,
                    onSelected: (val) {
                      if (val == 'archived') {
                        setState(() => _showArchived = !_showArchived);
                      } else if (val == 'name') {
                        setState(() => _sortMode = GardenSortMode.name);
                      } else if (val == 'care') {
                        setState(() => _sortMode = GardenSortMode.needsCare);
                      } else if (val == 'newest') {
                        setState(() => _sortMode = GardenSortMode.newest);
                      } else if (val == 'health') {
                        setState(() => _sortMode = GardenSortMode.health);
                      } else if (val == 'room') {
                        setState(() => _sortMode = GardenSortMode.room);
                      }
                    },
                    itemBuilder: (context) => [
                      CheckedPopupMenuItem(
                        value: 'archived',
                        checked: _showArchived,
                        child: Text(l10n.gardenFilterArchived),
                      ),
                      const PopupMenuDivider(),
                      CheckedPopupMenuItem(
                        value: 'care',
                        checked: _sortMode == GardenSortMode.needsCare,
                        child: Text(l10n.gardenSortCare),
                      ),
                      CheckedPopupMenuItem(
                        value: 'name',
                        checked: _sortMode == GardenSortMode.name,
                        child: Text(l10n.gardenSortName),
                      ),
                      CheckedPopupMenuItem(
                        value: 'newest',
                        checked: _sortMode == GardenSortMode.newest,
                        child: Text(l10n.gardenSortNewest),
                      ),
                      CheckedPopupMenuItem(
                        value: 'health',
                        checked: _sortMode == GardenSortMode.health,
                        child: Text(l10n.gardenSortHealth),
                      ),
                      CheckedPopupMenuItem(
                        value: 'room',
                        checked: _sortMode == GardenSortMode.room,
                        child: Text(l10n.gardenSortRoom),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.push(
                        '${GardenScreen.location}/${TasksScreen.subLocation}'),
                    icon: Badge(
                      isLabelVisible: todayDueTasks.isNotEmpty,
                      label: Text('${todayDueTasks.length}'),
                      child: Icon(Icons.today_rounded, color: scheme.onSurface),
                    ),
                    tooltip: l10n.tasksTitle,
                  ),
                  IconButton(
                    onPressed: () => context.go(CalendarScreen.location),
                    icon: Icon(
                      Icons.calendar_month_rounded,
                      color: scheme.onSurface,
                    ),
                    tooltip: l10n.navCalendar,
                  ),
                ],
              ).animateSection(index: 0),
            ),
          ),
          SliverPadding(
            padding: BotanicaTokens.pagePadding
                .copyWith(top: BotanicaTokens.spacingXs),
            sliver: SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 48),
                child: BotanicaSearchField(
                  controller: _searchController,
                  hintText: l10n.gardenSearchHint,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ).animateSection(index: 1),
            ),
          ),
          SliverPadding(
            padding: BotanicaTokens.pagePadding
                .copyWith(top: BotanicaTokens.spacingMd),
            sliver: SliverToBoxAdapter(
              child: _TodayCard(
                todayDueTasks: todayDueTasks,
                todayCompletedCount: todayCompletedCount,
                plantsById: plantsById,
                weatherIcon: iconForWeatherKind(conditionKind),
                weatherLabel: l10n.gardenWeatherChip(
                  conditionLabel,
                  displayTemp,
                  unitSymbol,
                  environment.humidity,
                ),
                weatherTip: _weatherCareTip(l10n, conditionKind, environment.tempC, humidity: environment.humidity),
                onOpenTasks: () => context.push(
                    '${GardenScreen.location}/${TasksScreen.subLocation}'),
                onOpenCalendar: () => context.go(CalendarScreen.location),
                onAddPlant: () => context.push('${GardenScreen.location}/add'),
                onWaterAllOverdue: overdueWaterTasks.length >= 2
                    ? () => _waterAllOverdue(overdueWaterTasks, plantsById)
                    : null,
                overdueWaterCount: overdueWaterTasks.length,
                streakAtRisk: streakAtRisk,
                currentStreak: settings.careStreakDays,
                tomorrowTaskCount: tomorrowTaskCount,
                motivationalMessage: _motivationalMessage(
                  l10n,
                  settings,
                  plants.length,
                  todayRemaining: todayDueTasks.length,
                  todayCompleted: todayCompletedCount,
                  plants: plants,
                ),
                isOnVacation: settings.isOnVacation,
                gardenInsight: GardenIntelligence.surfaceInsight(
                  plants: plants,
                  logs: logs,
                  tasks: tasks,
                  settings: settings,
                  now: DateTime.now(),
                ),
              ).animateSection(index: 2),
            ),
          ),
          if (PlantMilestoneEngine.todaysMilestones(plants).isNotEmpty)
            SliverPadding(
              padding: BotanicaTokens.pagePadding
                  .copyWith(top: BotanicaTokens.spacingSm),
              sliver: SliverToBoxAdapter(
                child: _PlantMilestoneBanner(
                  milestones: PlantMilestoneEngine.todaysMilestones(plants),
                ).animateSection(index: 3),
              ),
            ),
          if (plants.where((p) => !p.isArchived).length >= 2 && logs.length >= 5)
            SliverPadding(
              padding: BotanicaTokens.pagePadding
                  .copyWith(top: BotanicaTokens.spacingSm),
              sliver: SliverToBoxAdapter(
                child: _DailyBriefingSection(
                  plants: plants,
                  logs: logs,
                  tasks: tasks,
                  settings: settings,
                ).animateSection(index: 3),
              ),
            ),
          if (logs.isNotEmpty)
            SliverPadding(
              padding: BotanicaTokens.pagePadding
                  .copyWith(top: BotanicaTokens.spacingSm),
              sliver: SliverToBoxAdapter(
                child: _WeeklySummaryCard(logs: logs)
                    .animateSection(index: 3),
              ),
            ),
          if (_timeCapsuleMemory(allPhotos, plantsById) != null)
            SliverPadding(
              padding: BotanicaTokens.pagePadding
                  .copyWith(top: BotanicaTokens.spacingSm),
              sliver: SliverToBoxAdapter(
                child: _TimeCapsuleCard(
                  memory: _timeCapsuleMemory(allPhotos, plantsById)!,
                  plantsById: plantsById,
                ).animateSection(index: 3),
              ),
            ),
          if (_pulseReadyPlant(allPhotos, plants) case final pulse?)
            SliverPadding(
              padding: BotanicaTokens.pagePadding
                  .copyWith(top: BotanicaTokens.spacingSm),
              sliver: SliverToBoxAdapter(
                child: _PlantPulseCard(
                  plant: pulse.plant,
                  daysSincePhoto: pulse.daysSincePhoto,
                  onTap: () => context.push(
                    '/garden/plant/${pulse.plant.id}/journal',
                  ),
                ).animateSection(index: 3),
              ),
            ),
          if (tasks.isNotEmpty)
            SliverPadding(
              padding: BotanicaTokens.pagePadding
                  .copyWith(top: BotanicaTokens.spacingSm),
              sliver: SliverToBoxAdapter(
                child: _CareForecastCard(
                  tasks: tasks,
                  plantsById: plantsById,
                ).animateSection(index: 3),
              ),
            ),
          if (plants.length >= 2)
            SliverPadding(
              padding: BotanicaTokens.pagePadding
                  .copyWith(top: BotanicaTokens.spacingSm),
              sliver: SliverToBoxAdapter(
                child: _GardenHealthBar(
                  plants: plants,
                  tasks: tasks,
                  logs: logs,
                  onTap: () => context.push(
                    '/profile/${GardenWellnessScreen.subLocation}',
                  ),
                ).animateSection(index: 4),
              ),
            ),
          SliverPadding(
            padding: BotanicaTokens.pagePadding
                .copyWith(top: BotanicaTokens.spacingSm),
            sliver: SliverToBoxAdapter(
              child: const _SeasonalTipCard().animateSection(index: 5),
            ),
          ),
          SliverPadding(
            padding: BotanicaTokens.pagePadding
                .copyWith(top: BotanicaTokens.spacingXxs),
            sliver: SliverToBoxAdapter(
              child: AnimatedSize(
                duration: BotanicaTokens.motionMedium,
                curve: BotanicaTokens.curveSettle,
                alignment: Alignment.topCenter,
                child: const _CoachingInsightCard(),
              ).animateSection(index: 6),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: BotanicaTokens.spacingRelaxed),
          ),
          plantsAsync.when(
            data: (rawPlants) {
              if (rawPlants.isEmpty) {
                return SliverPadding(
                  padding: BotanicaTokens.pagePaddingWithBottomNav(context),
                  sliver: SliverToBoxAdapter(
                    child: _GardenEmptyState(
                      onAdd: () => context.push('${GardenScreen.location}/add'),
                    ),
                  ),
                );
              }

              var plants = rawPlants
                  .where((p) => p.isArchived == _showArchived)
                  .toList();

              if (_searchQuery.trim().isNotEmpty) {
                final q = _searchQuery.trim().toLowerCase();
                plants = plants.where((p) {
                  final matchesNick = p.nickname.toLowerCase().contains(q);
                  final roomName = _normalizedRoom(p.room).toLowerCase();
                  final speciesName = speciesById[p.speciesId]
                          ?.bestCommonName(localeCode)
                          .toLowerCase() ??
                      ideaById[p.speciesId]
                          ?.bestCommonName(localeCode)
                          .toLowerCase() ??
                      p.speciesId.toLowerCase();
                  final matchesSpecies = speciesName.contains(q);
                  final matchesRoom = roomName.contains(q);
                  return matchesNick || matchesSpecies || matchesRoom;
                }).toList();
              }

              final nowPlusOneDay = DateTime.now().add(const Duration(days: 1));
              final needsCareByPlantId = <String, bool>{};
              if (_sortMode == GardenSortMode.needsCare) {
                for (final t in tasks) {
                  if (!t.isDismissed &&
                      t.status != TaskStatus.snoozed &&
                      t.dueAt.isBefore(nowPlusOneDay)) {
                    needsCareByPlantId[t.plantId] = true;
                  }
                }
              }

              final healthScoreByPlantId = <String, int>{};
              if (_sortMode == GardenSortMode.health) {
                final now = DateTime.now();
                final allLogs =
                    ref.read(careLogsStreamProvider).valueOrNull ?? const <CareLog>[];
                for (final plant in plants) {
                  final plantTasks = tasks
                      .where((t) => t.plantId == plant.id)
                      .toList(growable: false);
                  final plantLogs = allLogs
                      .where((l) => l.plantId == plant.id)
                      .toList(growable: false);
                  healthScoreByPlantId[plant.id] = PlantHealthScore.compute(
                    allTasks: plantTasks,
                    recentLogs: plantLogs,
                    now: now,
                  );
                }
              }

              plants.sort((a, b) {
                if (_sortMode == GardenSortMode.name) {
                  return a.nickname
                      .toLowerCase()
                      .compareTo(b.nickname.toLowerCase());
                } else if (_sortMode == GardenSortMode.newest) {
                  return b.createdAt.compareTo(a.createdAt);
                } else if (_sortMode == GardenSortMode.health) {
                  final aScore = healthScoreByPlantId[a.id] ?? 100;
                  final bScore = healthScoreByPlantId[b.id] ?? 100;
                  if (aScore != bScore) return aScore.compareTo(bScore);
                  return a.nickname
                      .toLowerCase()
                      .compareTo(b.nickname.toLowerCase());
                } else if (_sortMode == GardenSortMode.room) {
                  final aRoom = a.room.trim().isEmpty ? '￿' : a.room.toLowerCase();
                  final bRoom = b.room.trim().isEmpty ? '￿' : b.room.toLowerCase();
                  final cmp = aRoom.compareTo(bRoom);
                  if (cmp != 0) return cmp;
                  return a.nickname
                      .toLowerCase()
                      .compareTo(b.nickname.toLowerCase());
                } else {
                  final aNeedsCare = (needsCareByPlantId[a.id] == true) ? 1 : 0;
                  final bNeedsCare = (needsCareByPlantId[b.id] == true) ? 1 : 0;
                  if (aNeedsCare != bNeedsCare) {
                    return bNeedsCare.compareTo(aNeedsCare);
                  }
                  return b.createdAt.compareTo(a.createdAt);
                }
              });

              if (plants.isEmpty) {
                return SliverPadding(
                  padding: BotanicaTokens.pagePaddingWithBottomNav(context),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 64),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? l10n.discoverNoResultsBody
                              : l10n.gardenFilterEmptyTitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final rooms = _roomOptions(plants);
              final selectedRoom =
                  rooms.contains(_selectedRoom) ? _selectedRoom : null;
              final visiblePlants = _filterPlantsByRoom(plants, selectedRoom);
              final eligibleWaterEntries =
                  _eligibleRoomWaterEntries(visiblePlants, tasks);
              final eligibleSnoozeEntries =
                  _eligibleRoomSnoozeEntries(visiblePlants, tasks);

              return SliverPadding(
                padding: BotanicaTokens.pagePaddingWithBottomNav(context),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    if (rooms.length >= 2)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: BotanicaTokens.spacingBase,
                          ),
                          child: _GardenRoomFilterRow(
                            rooms: rooms,
                            selectedRoom: selectedRoom,
                            onSelected: (room) => setState(() {
                              _selectedRoom = room;
                            }),
                          ).animateSection(index: 3),
                        ),
                      ),
                    if (selectedRoom != null &&
                        (eligibleWaterEntries.isNotEmpty ||
                            eligibleSnoozeEntries.isNotEmpty))
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: BotanicaTokens.spacingBase,
                          ),
                          child: _GardenRoomBatchActionsRow(
                            onWaterAll: eligibleWaterEntries.isEmpty
                                ? null
                                : () => _waterAllInSelectedRoom(
                                      eligibleWaterEntries,
                                    ),
                            onSnoozeAll: eligibleSnoozeEntries.isEmpty
                                ? null
                                : () => _snoozeAllInSelectedRoom(
                                      eligibleSnoozeEntries,
                                    ),
                          ).animateSection(index: 4),
                        ),
                      ),
                    if (_viewMode == GardenViewMode.list)
                      ..._buildPlantListSlivers(
                        visiblePlants: visiblePlants,
                        tasks: tasks,
                        logs: logs,
                        speciesById: speciesById,
                        ideaById: ideaById,
                        localeCode: localeCode,
                        showRoomHeaders:
                            _sortMode == GardenSortMode.room &&
                            selectedRoom == null,
                      )
                    else
                      SliverToBoxAdapter(
                        child: _GardenMapView(
                          plants: plants,
                          rooms: rooms,
                          speciesById: speciesById,
                          ideaById: ideaById,
                          tasks: tasks,
                          environment: environment,
                          localeCode: localeCode,
                          settings: settings,
                          onRoomSelected: (r) => setState(() {
                            _selectedRoom = r;
                            _viewMode = GardenViewMode.list;
                          }),
                        ).animateSection(index: 3),
                      ),
                  ],
                ),
              );
            },
            error: (_, __) => SliverPadding(
              padding: BotanicaTokens.pagePadding,
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.gardenLoadError,
                  style: textTheme.bodyMedium,
                ),
              ),
            ),
            loading: () => const SliverPadding(
              padding: BotanicaTokens.pagePadding,
              sliver: SliverToBoxAdapter(
                child: BotanicaListSkeleton(
                  itemCount: 4,
                  showHero: false,
                ),
              ),
            ),
          ),
        ],
      ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlantListSlivers({
    required List<Plant> visiblePlants,
    required List<TaskInstance> tasks,
    required List<CareLog> logs,
    required Map<String, Species> speciesById,
    required Map<String, PlantIdea> ideaById,
    required String localeCode,
    required bool showRoomHeaders,
  }) {
    if (visiblePlants.isEmpty) return const [];

    Widget buildCard(Plant plant, int index) {
      final nextWater = _nextTask(
        tasks: tasks,
        plantId: plant.id,
        type: TaskType.water,
      );
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final twoWeeksAgo = now.subtract(const Duration(days: 14));
      final recentLogs = logs
          .where(
              (l) => l.plantId == plant.id && l.timestamp.isAfter(weekAgo))
          .length;
      final priorLogs = logs
          .where((l) =>
              l.plantId == plant.id &&
              l.timestamp.isAfter(twoWeeksAgo) &&
              !l.timestamp.isAfter(weekAgo))
          .length;
      final careTrend = recentLogs > priorLogs
          ? _CareTrend.improving
          : recentLogs < priorLogs
              ? _CareTrend.declining
              : _CareTrend.stable;
      return RepaintBoundary(
        child: _PlantCard(
          plant: plant,
          species: speciesById[plant.speciesId],
          idea: ideaById[plant.speciesId],
          nextWaterTask: nextWater,
          localeCode: localeCode,
          index: index,
          mode: _cardMode,
          careTrend: careTrend,
        ),
      );
    }

    if (!showRoomHeaders) {
      return [
        SliverList.separated(
          itemCount: visiblePlants.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: BotanicaTokens.spacingBase),
          itemBuilder: (context, index) =>
              buildCard(visiblePlants[index], index),
        ),
      ];
    }

    final l10n = AppLocalizations.of(context);
    final grouped = <String, List<Plant>>{};
    for (final plant in visiblePlants) {
      final room = plant.room.trim().isEmpty
          ? l10n.gardenWellnessRoomUnassigned
          : plant.room.trim();
      (grouped[room] ??= []).add(plant);
    }

    final slivers = <Widget>[];
    var globalIndex = 0;
    for (final entry in grouped.entries) {
      slivers.add(SliverToBoxAdapter(
        child: _RoomSectionHeader(
          room: entry.key,
          plantCount: entry.value.length,
        ),
      ));
      final groupPlants = entry.value;
      final startIndex = globalIndex;
      slivers.add(SliverList.separated(
        itemCount: groupPlants.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: BotanicaTokens.spacingBase),
        itemBuilder: (context, index) =>
            buildCard(groupPlants[index], startIndex + index),
      ));
      globalIndex += groupPlants.length;
    }
    return slivers;
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.todayDueTasks,
    this.todayCompletedCount = 0,
    required this.plantsById,
    required this.weatherIcon,
    required this.weatherLabel,
    this.weatherTip,
    required this.onOpenTasks,
    required this.onOpenCalendar,
    required this.onAddPlant,
    this.onWaterAllOverdue,
    this.overdueWaterCount = 0,
    this.streakAtRisk = false,
    this.currentStreak = 0,
    this.tomorrowTaskCount = 0,
    this.motivationalMessage,
    this.isOnVacation = false,
    this.gardenInsight,
  });

  final List<TaskInstance> todayDueTasks;
  final int todayCompletedCount;
  final Map<String, Plant> plantsById;
  final IconData weatherIcon;
  final String weatherLabel;
  final String? weatherTip;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenCalendar;
  final VoidCallback onAddPlant;
  final VoidCallback? onWaterAllOverdue;
  final int overdueWaterCount;
  final bool streakAtRisk;
  final int currentStreak;
  final int tomorrowTaskCount;
  final String? motivationalMessage;
  final bool isOnVacation;
  final GardenInsight? gardenInsight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasTasks = todayDueTasks.isNotEmpty;
    final taskWidgets = <Widget>[];

    for (int i = 0; i < todayDueTasks.length && i < 3; i++) {
      final task = todayDueTasks[i];
      final plant = plantsById[task.plantId];
      if (plant != null) {
        taskWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingSm),
          child: TaskTile(
            task: task,
            plant: plant,
            index: i,
            isToday: true,
          ),
        ));
      }
    }

    final hour = DateTime.now().hour;
    final timeGradient = _timeOfDayGradient(hour, scheme, isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BotanicaPressScale(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
              gradient: timeGradient,
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      _timeOfDayIcon(hour),
                      size: 120,
                      color: (isDark ? Colors.white : scheme.primary)
                          .withValues(alpha: 0.06),
                    ),
                  ),
                  Padding(
                    padding: BotanicaTokens.cardPaddingAiry,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _timeOfDayGreeting(l10n),
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  BotanicaGaps.vMicro,
                                  Text(
                                    MaterialLocalizations.of(context)
                                        .formatFullDate(DateTime.now()),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                  if (motivationalMessage != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      motivationalMessage!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.primary
                                            .withValues(alpha: 0.75),
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            BotanicaChip(
                              icon: weatherIcon,
                              label: weatherLabel,
                              tint: scheme.onSurface,
                              padding: const EdgeInsets.symmetric(
                                horizontal: BotanicaTokens.spacingXs,
                                vertical: BotanicaTokens.spacingTiny,
                              ),
                              iconSize: BotanicaTokens.iconSizeSm,
                            ),
                          ],
                        ),
                        if (weatherTip != null) ...[
                          BotanicaGaps.vSm,
                          Row(
                            children: [
                              Icon(
                                Icons.tips_and_updates_rounded,
                                size: 14,
                                color: scheme.onSurface.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  weatherTip!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color:
                                        scheme.onSurface.withValues(alpha: 0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        BotanicaGaps.vMd,
                        if (gardenInsight != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: BotanicaTokens.spacingSm,
                              vertical: BotanicaTokens.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(
                                BotanicaTokens.radiusL,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 14,
                                  color: scheme.secondary.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _resolveInsightMessage(l10n, gardenInsight!),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onSecondaryContainer.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BotanicaGaps.vSm,
                        ],
                        if (isOnVacation) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: BotanicaTokens.spacingSm,
                              vertical: BotanicaTokens.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.tertiaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(
                                BotanicaTokens.radiusL,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.beach_access_rounded,
                                  size: 16,
                                  color: scheme.tertiary.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    l10n.gardenVacationBanner,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onTertiaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BotanicaGaps.vSm,
                        ],
                        if (streakAtRisk) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: BotanicaTokens.spacingSm,
                              vertical: BotanicaTokens.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(
                                BotanicaTokens.radiusL,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 16,
                                  color: scheme.error.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    l10n.gardenStreakAtRisk(currentStreak),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onErrorContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BotanicaGaps.vSm,
                        ],
                        if (overdueWaterCount >= 2 && onWaterAllOverdue != null) ...[
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
                              onTap: onWaterAllOverdue,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: BotanicaTokens.spacingSm,
                                  vertical: BotanicaTokens.spacingXs,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(
                                    BotanicaTokens.radiusL,
                                  ),
                                  border: Border.all(
                                    color: scheme.primary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.water_drop_rounded,
                                      size: 16,
                                      color: scheme.primary.withValues(alpha: 0.85),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l10n.gardenWaterAllOverdueCount(overdueWaterCount),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: scheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: scheme.primary.withValues(alpha: 0.7),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          BotanicaGaps.vSm,
                        ],
                        if (!hasTasks) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: BotanicaTokens.spacingSm,
                              vertical: BotanicaTokens.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(
                                BotanicaTokens.radiusL,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: scheme.primary.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.gardenAllCaughtUp,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color:
                                        scheme.primary.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BotanicaGaps.vSm,
                        ],
                        Wrap(
                          spacing: BotanicaTokens.spacingXs,
                          runSpacing: BotanicaTokens.spacingXs,
                          children: [
                            if (hasTasks || todayCompletedCount > 0)
                              _TodayProgressChip(
                                completed: todayCompletedCount,
                                remaining: todayDueTasks.length,
                                color: scheme.primary,
                                onTap: onOpenTasks,
                              ),
                            if (!hasTasks)
                              BotanicaChip(
                                icon: Icons.calendar_month_rounded,
                                label: l10n.calendarTitle,
                                tint: scheme.tertiary,
                                onTap: onOpenCalendar,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: BotanicaTokens.spacingBase,
                                  vertical: BotanicaTokens.spacingSm,
                                ),
                              ),
                            BotanicaChip(
                              icon: Icons.add_rounded,
                              label: l10n.gardenQuickAddPlant,
                              tint: scheme.secondary,
                              onTap: onAddPlant,
                              padding: const EdgeInsets.symmetric(
                                horizontal: BotanicaTokens.spacingBase,
                                vertical: BotanicaTokens.spacingSm,
                              ),
                            ),
                          ],
                        ),
                        if (tomorrowTaskCount > 0) ...[
                          BotanicaGaps.vSm,
                          Row(
                            children: [
                              Icon(
                                Icons.event_rounded,
                                size: 14,
                                color: scheme.onSurface.withValues(alpha: 0.45),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.gardenTomorrowPreview(tomorrowTaskCount),
                                style: textTheme.bodySmall?.copyWith(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (taskWidgets.isNotEmpty) BotanicaGaps.vSm,
        ...taskWidgets,
      ],
    );
  }
}

String _resolveInsightMessage(AppLocalizations l10n, GardenInsight insight) {
  final a = insight.args;
  switch (insight.messageKey) {
    case 'insightRhythmShift':
      return l10n.insightRhythmShift(a['plant']!, a['oldDays']!, a['newDays']!);
    case 'insightFavoriteCareDay':
      return l10n.insightFavoriteCareDay(a['percent']!, a['day']!);
    case 'insightActiveTime':
      return l10n.insightActiveTime(a['period']!, a['percent']!);
    case 'insightMostLovedPlant':
      return l10n.insightMostLovedPlant(a['plant']!, a['actions']!);
    case 'insightQuietThenBusy':
      return l10n.insightQuietThenBusy(a['quietDays']!, a['taskCount']!);
    case 'insightCareAcceleration':
      return l10n.insightCareAcceleration(a['thisWeek']!, a['lastWeek']!);
    case 'insightGardenGrowing':
      return l10n.insightGardenGrowing(a['total']!, a['recent']!);
    case 'insightSeasonalActivity':
      return l10n.insightSeasonalActivity(a['direction']!, a['thisMonth']!, a['lastMonth']!);
    default:
      return '';
  }
}

String _timeOfDayGreeting(AppLocalizations l10n) {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return l10n.gardenGreetingMorning;
  if (hour >= 12 && hour < 18) return l10n.gardenGreetingAfternoon;
  return l10n.gardenGreetingEvening;
}

LinearGradient _timeOfDayGradient(int hour, ColorScheme scheme, bool isDark) {
  if (hour >= 5 && hour < 12) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              scheme.primaryContainer.withValues(alpha: 0.3),
              scheme.surface.withValues(alpha: 0.8),
            ]
          : [
              const Color(0xFFF0F9F4),
              const Color(0xFFFBFAF6),
            ],
    );
  } else if (hour >= 12 && hour < 17) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              scheme.tertiaryContainer.withValues(alpha: 0.25),
              scheme.surface.withValues(alpha: 0.8),
            ]
          : [
              const Color(0xFFFFF8E8),
              const Color(0xFFFBFAF6),
            ],
    );
  } else if (hour >= 17 && hour < 21) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF2D1B4E).withValues(alpha: 0.4),
              scheme.surface.withValues(alpha: 0.8),
            ]
          : [
              const Color(0xFFF5EEF8),
              const Color(0xFFFBFAF6),
            ],
    );
  } else {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              scheme.surface.withValues(alpha: 0.8),
            ]
          : [
              const Color(0xFFEEF2F7),
              const Color(0xFFFBFAF6),
            ],
    );
  }
}

IconData _timeOfDayIcon(int hour) {
  if (hour >= 5 && hour < 12) return Icons.wb_sunny_rounded;
  if (hour >= 12 && hour < 17) return Icons.light_mode_rounded;
  if (hour >= 17 && hour < 21) return Icons.wb_twilight_rounded;
  return Icons.nightlight_rounded;
}

String? _motivationalMessage(
  AppLocalizations l10n,
  UserSettings settings,
  int plantCount, {
  int todayRemaining = 0,
  int todayCompleted = 0,
  List<Plant> plants = const [],
}) {
  final streak = settings.careStreakDays;
  if (streak >= 30) return l10n.gardenMotivation30DayStreak;
  if (streak >= 7) return l10n.gardenMotivation7DayStreak;

  if (settings.lastCareDate != null) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      settings.lastCareDate!.year,
      settings.lastCareDate!.month,
      settings.lastCareDate!.day,
    );
    final gap = today.difference(lastDay).inDays;
    if (gap >= 3) return l10n.gardenMotivationWelcomeBack;
  }

  if (todayRemaining == 0 && todayCompleted > 0) {
    return l10n.gardenMotivationAllDoneToday;
  }

  if (plants.isNotEmpty) {
    final now = DateTime.now();
    final hasNewPlant = plants.any(
      (p) => now.difference(p.createdAt).inDays <= 7 && !p.isArchived,
    );
    if (hasNewPlant) return l10n.gardenMotivationNewPlant;
  }

  if (plantCount >= 10) return l10n.gardenMotivationBigGarden;

  final hour = DateTime.now().hour;
  if (hour >= 6 && hour < 11) return l10n.gardenMotivationMorning;
  if (hour >= 19) return l10n.gardenMotivationEvening;

  return null;
}

enum _CareTrend { improving, stable, declining }

class _PlantCard extends ConsumerStatefulWidget {
  const _PlantCard({
    required this.plant,
    required this.species,
    required this.idea,
    required this.nextWaterTask,
    required this.localeCode,
    required this.index,
    required this.mode,
    required this.careTrend,
  });

  final Plant plant;
  final Species? species;
  final PlantIdea? idea;
  final TaskInstance? nextWaterTask;
  final String localeCode;
  final int index;
  final PlantCardMode mode;
  final _CareTrend careTrend;

  @override
  ConsumerState<_PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends ConsumerState<_PlantCard>
    with TickerProviderStateMixin {
  bool _watering = false;
  bool _recentlyWatered = false;
  late final AnimationController _rippleController;
  late final AnimationController _pulseController;
  late final AnimationController _streakFloatController;
  int _floatingStreakValue = 0;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _streakFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _updatePulse();
  }

  @override
  void didUpdateWidget(covariant _PlantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulse();
  }

  void _updatePulse() {
    final dueInDays =
        widget.nextWaterTask?.dueAt.difference(DateTime.now()).inDays;
    if (dueInDays != null && dueInDays <= 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _pulseController.dispose();
    _streakFloatController.dispose();
    super.dispose();
  }

  static CareLog? _lastWaterLog(List<CareLog> logs, String plantId) {
    CareLog? latest;
    for (final log in logs) {
      if (log.plantId == plantId && log.type == TaskType.water) {
        if (latest == null || log.timestamp.isAfter(latest.timestamp)) {
          latest = log;
        }
      }
    }
    return latest;
  }

  Future<void> _waterNow() async {
    if (_watering) return;

    setState(() => _watering = true);
    try {
      BotanicaHaptics.primaryPress();

      final l10n = AppLocalizations.of(context);
      final now = DateTime.now();

      final tasksRepo = ref.read(tasksRepositoryProvider);
      final logsRepo = ref.read(logsRepositoryProvider);
      final speciesRepo = ref.read(speciesRepositoryProvider);
      final ideaRepo = ref.read(plantIdeaRepositoryProvider);
      final env = ref.read(environmentSnapshotProvider);
      final engine = ref.read(seasonalCareEngineProvider);
      final settings = ref.read(settingsControllerProvider);
      final previousLongest = settings.longestStreak;
      final originalTask = widget.nextWaterTask;

      final nextTask = await CareActions.waterNow(
        plant: widget.plant,
        now: now,
        pendingWaterTask: widget.nextWaterTask,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        seasonalEngine: engine,
        environment: env,
        settings: settings,
        updateSettings: (next) =>
            ref.read(settingsControllerProvider.notifier).update(next),
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
      } else {
        final allTasks =
            ref.read(tasksStreamProvider).valueOrNull ?? const <TaskInstance>[];
        final todayEnd = DateTime(now.year, now.month, now.day + 1);
        final remainingToday = allTasks.where(
            (t) => !t.isDismissed && t.dueAt.isBefore(todayEnd)).toList();

        if (remainingToday.isEmpty) {
          if (!mounted) return;
          await BotanicaAllDoneSheet.show(context);
          if (!mounted) return;
          final currentSettings = ref.read(settingsControllerProvider);
          final perfectUpdated =
              CareActions.recordPerfectDay(currentSettings, now);
          if (perfectUpdated != currentSettings) {
            await ref
                .read(settingsControllerProvider.notifier)
                .update(perfectUpdated);
            if (!mounted) return;
            if (CareActions.isPerfectWeek(perfectUpdated)) {
              final weeks = perfectUpdated.consecutivePerfectDays ~/ 7;
              await BotanicaPerfectWeekSheet.show(context, weeks: weeks);
            }
          }
          if (!mounted) return;
          final settingsForReview = ref.read(settingsControllerProvider);
          if (ReviewPromptService.shouldPrompt(settingsForReview)) {
            await ReviewPromptService.maybeRequestReview(context);
            ref.read(settingsControllerProvider.notifier).update(
                  settingsForReview.copyWith(
                    lastReviewPromptDate: DateTime.now(),
                  ),
                );
          }
        } else {
          BotanicaHaptics.completion();
          BotanicaCelebration.show(context);
          _rippleController.forward(from: 0);
        }
      }

      if (!mounted) return;

      final currentAfterWater = ref.read(settingsControllerProvider);

      if (currentAfterWater.careStreakDays > 0) {
        _floatingStreakValue = currentAfterWater.careStreakDays;
        _streakFloatController.forward(from: 0);
      }

      final isPersonalBest = CareActions.isNewPersonalBest(
        previousLongest: previousLongest,
        currentStreak: currentAfterWater.careStreakDays,
      );
      final freezeUsed = CareActions.streakFreezeWasUsed(
        previousSettings: settings,
        currentSettings: currentAfterWater,
      );
      final freezeEarned = CareActions.streakFreezeWasEarned(
        previousSettings: settings,
        currentSettings: currentAfterWater,
      );

      final String snackText;
      final IconData snackIcon;
      if (freezeUsed) {
        snackText = l10n.gardenStreakFreezeUsed(currentAfterWater.careStreakDays);
        snackIcon = Icons.ac_unit_rounded;
      } else if (freezeEarned) {
        snackText = l10n.gardenStreakFreezeEarned(currentAfterWater.streakFreezeCount);
        snackIcon = Icons.ac_unit_rounded;
      } else if (isPersonalBest) {
        snackText = l10n.gardenNewPersonalBest(currentAfterWater.careStreakDays);
        snackIcon = Icons.emoji_events_rounded;
      } else {
        if (nextTask != null) {
          final daysUntil = nextTask.dueAt.difference(now).inDays;
          final nextLabel = daysUntil <= 0
              ? l10n.plantDetailNextWateringToday
              : daysUntil == 1
                  ? l10n.plantDetailNextWateringTomorrow
                  : l10n.plantDetailNextWateringInDays(daysUntil);
          snackText = '${l10n.taskTypeWater} · ${l10n.commonDone} · $nextLabel';
        } else {
          snackText = '${l10n.taskTypeWater} · ${l10n.commonDone}';
        }
        snackIcon = Icons.water_drop_rounded;
      }

      Future<void> undoWater() async {
        if (originalTask != null) {
          await tasksRepo.upsert(originalTask);
        }
        if (nextTask != null) {
          await tasksRepo.delete(nextTask.id);
        }
        final recentLogs = logsRepo.forPlant(widget.plant.id);
        if (recentLogs.isNotEmpty) {
          final latest = recentLogs.reduce(
              (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
          if (latest.type == TaskType.water &&
              !latest.timestamp.isBefore(now)) {
            await logsRepo.delete(latest.id);
          }
        }
        await ref.read(settingsControllerProvider.notifier).update(settings);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                snackIcon,
                size: BotanicaTokens.iconSizeSm,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              BotanicaGaps.hSm,
              Expanded(child: Text(snackText)),
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
          content: Text(AppLocalizations.of(context).commonErrorTryAgain),
        ),
      );
    } finally {
      if (mounted) setState(() => _watering = false);
    }
  }

  Future<void> _snoozePlant() async {
    final task = widget.nextWaterTask;
    if (task == null) return;

    final duration = await showBotanicaSnoozePicker(context: context);
    if (duration == null || !mounted) return;

    final settings = ref.read(settingsControllerProvider);
    final target = CareActions.snoozeForDuration(
      now: DateTime.now(),
      plant: widget.plant,
      settings: settings,
      duration: duration,
    );

    await ref.read(tasksRepositoryProvider).upsert(
          task.copyWith(dueAt: target, status: TaskStatus.snoozed),
        );

    if (!mounted) return;
    BotanicaHaptics.selectionTick();
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.snooze_rounded,
                size: BotanicaTokens.iconSizeSm,
                color: Theme.of(context).colorScheme.inversePrimary),
            BotanicaGaps.hSm,
            Text(l10n.gardenRoomsSnoozedCount(1)),
          ],
        ),
      ),
    );
  }

  Future<void> _quickLogCare() async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final careTypes = [
      TaskType.fertilize,
      TaskType.mist,
      TaskType.rotate,
      TaskType.prune,
      TaskType.wipeLeaves,
      TaskType.repot,
    ];

    final selected = await showBotanicaModalSheet<TaskType>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.only(
          left: BotanicaTokens.spacingMd,
          right: BotanicaTokens.spacingMd,
          bottom: BotanicaTokens.spacingXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.gardenQuickLogCare,
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: BotanicaTokens.spacingMd),
            Wrap(
              spacing: BotanicaTokens.spacingXs,
              runSpacing: BotanicaTokens.spacingXs,
              children: careTypes.map((type) {
                final icon = _careTypeIcon(type);
                final label = _careTypeLabel(l10n, type);
                return ActionChip(
                  avatar: Icon(icon, size: 18),
                  label: Text(label),
                  onPressed: () => Navigator.of(ctx).pop(type),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;

    final now = DateTime.now();
    final log = CareLog(
      id: '${widget.plant.id}-${selected.id}-${now.millisecondsSinceEpoch}',
      plantId: widget.plant.id,
      type: selected,
      timestamp: now,
      note: null,
      linkedPhotoId: null,
    );
    await ref.read(logsRepositoryProvider).add(log);

    final matchingTask = ref.read(tasksStreamProvider).valueOrNull?.where((t) =>
        t.plantId == widget.plant.id &&
        t.type == selected &&
        !t.isDismissed).firstOrNull;
    if (matchingTask != null) {
      await ref.read(tasksRepositoryProvider).upsert(
            matchingTask.copyWith(
              status: TaskStatus.done,
              completedAt: now,
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
            Icon(
              Icons.check_circle_rounded,
              size: BotanicaTokens.iconSizeSm,
              color: scheme.inversePrimary,
            ),
            BotanicaGaps.hSm,
            Text(l10n.gardenQuickLogDone),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static IconData _careTypeIcon(TaskType type) => switch (type) {
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

  static String _careTypeLabel(AppLocalizations l10n, TaskType type) =>
      switch (type) {
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

  Future<void> _editPlant() async {
    final l10n = AppLocalizations.of(context);

    final updated = await showBotanicaModalSheet<Plant?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (_) => _EditPlantSheet(plant: widget.plant),
    );

    if (!mounted) return;
    if (updated == null) return;

    await CareActions.reschedulePendingTasksIfNeeded(
      oldPlant: widget.plant,
      newPlant: updated,
      tasksRepository: ref.read(tasksRepositoryProvider),
      speciesRepository: ref.read(speciesRepositoryProvider),
      plantIdeaRepository: ref.read(plantIdeaRepositoryProvider),
      seasonalEngine: ref.read(seasonalCareEngineProvider),
      environment: ref.read(environmentSnapshotProvider),
      settings: ref.read(settingsControllerProvider),
    );

    await ref.read(plantsRepositoryProvider).upsert(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: BotanicaTokens.iconSizeSm, color: Theme.of(context).colorScheme.inversePrimary),
            BotanicaGaps.hSm,
            Text('${l10n.commonDone} · ${updated.nickname}'),
          ],
        ),
      ),
    );
  }

  void _showQuickActions(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    BotanicaHaptics.selectionTick();
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width / 2,
        offset.dy + size.height / 2,
        offset.dx + size.width / 2,
        offset.dy + size.height / 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
      ),
      items: [
        PopupMenuItem(
          value: 'water',
          child: Row(
            children: [
              Icon(Icons.water_drop_rounded, size: 20, color: scheme.primary),
              const SizedBox(width: 12),
              Text(l10n.plantDetailWaterNow),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 20, color: scheme.secondary),
              const SizedBox(width: 12),
              Text(l10n.commonEdit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'detail',
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: scheme.tertiary),
              const SizedBox(width: 12),
              Text(l10n.gardenViewDetails),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logCare',
          child: Row(
            children: [
              const Icon(Icons.playlist_add_check_rounded, size: 20, color: Colors.teal),
              const SizedBox(width: 12),
              Text(l10n.gardenQuickLogCare),
            ],
          ),
        ),
        if (widget.nextWaterTask != null)
          PopupMenuItem(
            value: 'snooze',
            child: Row(
              children: [
                Icon(Icons.snooze_rounded, size: 20, color: Colors.amber.shade700),
                const SizedBox(width: 12),
                Text(l10n.gardenQuickSnooze),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'photo',
          child: Row(
            children: [
              Icon(Icons.camera_alt_rounded, size: 20, color: scheme.onSurface.withValues(alpha: 0.7)),
              const SizedBox(width: 12),
              Text(l10n.plantDetailAddPhoto),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!mounted || value == null) return;
      switch (value) {
        case 'water':
          _waterNow();
        case 'edit':
          _editPlant();
        case 'detail':
          this.context.push('${GardenScreen.location}/plant/${widget.plant.id}');
        case 'snooze':
          _snoozePlant();
        case 'logCare':
          _quickLogCare();
        case 'photo':
          this.context.push(
            '${GardenScreen.location}/plant/${widget.plant.id}?tab=journal&action=add_photo',
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final dueInDays =
        widget.nextWaterTask?.dueAt.difference(DateTime.now()).inDays;

    final progress = dueInDays == null
        ? 0.0
        : (1 - (dueInDays.clamp(0, 14) / 14.0)).clamp(0.0, 1.0);

    final logs = ref.watch(careLogsStreamProvider).valueOrNull ?? const [];
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    _recentlyWatered = logs.any((l) =>
        l.plantId == widget.plant.id &&
        l.type == TaskType.water &&
        l.timestamp.isAfter(oneHourAgo));

    final lastWaterLog = _lastWaterLog(logs, widget.plant.id);

    final healthScoreAsync =
        ref.watch(plantHealthScoreProvider(widget.plant.id));

    final allTasks =
        ref.watch(tasksStreamProvider).valueOrNull ?? const <TaskInstance>[];
    final plantTasks =
        allTasks.where((t) => t.plantId == widget.plant.id).toList();
    final healthScore = healthScoreAsync.valueOrNull ?? 75;
    final mood = PlantMoodResolver.resolve(
      healthScore: healthScore,
      plantTasks: plantTasks,
      plantCreatedAt: widget.plant.createdAt,
      now: DateTime.now(),
    );

    final species = widget.species;
    final idea = widget.idea;
    final speciesName = species?.bestCommonName(widget.localeCode) ??
        idea?.bestCommonName(widget.localeCode) ??
        widget.plant.speciesId;
    final habit =
        species?.habit(widget.localeCode) ?? idea?.habit(widget.localeCode);
    final coverPath = _resolvePlantCoverPath(
      coverPhotoPath: widget.plant.coverPhotoPath,
      coverAsset: widget.plant.coverAsset,
      speciesImagePath: species?.imagePath ?? idea?.imagePath,
    );

    final semanticLabel = speciesName.trim().isEmpty
        ? widget.plant.nickname
        : '${widget.plant.nickname}, $speciesName';
    final semanticValue = switch (dueInDays) {
      null => l10n.gardenNoScheduleYet,
      <= 0 => '${l10n.taskTypeWater} · ${l10n.commonOverdue}',
      1 => '${l10n.taskTypeWater} · ${l10n.plantDetailNextWateringTomorrow}',
      final days =>
        '${l10n.taskTypeWater} · ${l10n.plantDetailNextWateringInDays(days)}',
    };

    final card = Slidable(
      key: ValueKey('plant-${widget.plant.id}'),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.32,
        children: [
          CustomSlidableAction(
            onPressed: (_) => _waterNow(),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: BotanicaTokens.spacingXxs,
              vertical: BotanicaTokens.spacingXs,
            ),
            child: _GardenSlidableActionContent(
              icon: Icons.water_drop_rounded,
              label: l10n.plantDetailWaterNow,
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.40,
        children: [
          CustomSlidableAction(
            onPressed: (_) => _snoozePlant(),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(
              horizontal: BotanicaTokens.spacingXxs,
              vertical: BotanicaTokens.spacingXs,
            ),
            child: _GardenSlidableActionContent(
              icon: Icons.snooze_rounded,
              label: l10n.gardenQuickSnooze,
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) => _editPlant(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: BotanicaTokens.spacingXxs,
              vertical: BotanicaTokens.spacingXs,
            ),
            child: _GardenSlidableActionContent(
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
        onDoubleTap: _waterNow,
        onLongPress: () => _showQuickActions(context, l10n, scheme),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseValue = _pulseController.value;
            final isOverdue = dueInDays != null && dueInDays <= 0;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
                boxShadow: isOverdue
                    ? [
                        BoxShadow(
                          color: scheme.error
                              .withValues(alpha: 0.08 + 0.10 * pulseValue),
                          blurRadius: 12 + 8 * pulseValue,
                          spreadRadius: 1,
                        ),
                      ]
                    : const [],
              ),
              child: child!,
            );
          },
          child: Stack(
            children: [
              BotanicaGlassCard(
                padding: BotanicaTokens.cardPaddingDense,
                child: AnimatedSize(
                  duration: BotanicaTokens.motionSlow,
            curve: BotanicaTokens.curveReveal,
            child: AnimatedSwitcher(
              duration: BotanicaTokens.motionSlow,
              child: SizedBox(
                key: ValueKey(widget.mode),
                child: switch (widget.mode) {
                  PlantCardMode.compact => _buildCompactContent(
                      context,
                      textTheme,
                      scheme,
                      l10n,
                      coverPath,
                      progress,
                      speciesName,
                      habit,
                      species,
                      idea,
                      dueInDays,
                      lastWaterLog,
                      mood),
                  PlantCardMode.gallery => _buildGalleryContent(
                      context,
                      textTheme,
                      scheme,
                      l10n,
                      coverPath,
                      progress,
                      speciesName,
                      habit,
                      species,
                      idea,
                      dueInDays,
                      lastWaterLog,
                      mood),
                  PlantCardMode.careFirst => _buildCareFirstContent(
                      context,
                      textTheme,
                      scheme,
                      l10n,
                      coverPath,
                      progress,
                      speciesName,
                      habit,
                      species,
                      idea,
                      dueInDays,
                      lastWaterLog,
                      mood),
                },
              ),
            ),
          ),
        ),
            AnimatedBuilder(
              animation: _rippleController,
              builder: (context, _) {
                if (!_rippleController.isAnimating &&
                    _rippleController.value == 0) {
                  return const SizedBox.shrink();
                }
                final t = _rippleController.value;
                return Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(BotanicaTokens.radiusXL),
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.4 + t * 1.2,
                            colors: [
                              Colors.blue.withValues(
                                  alpha: 0.18 * (1 - t)),
                              Colors.cyan.withValues(
                                  alpha: 0.08 * (1 - t)),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _streakFloatController,
              builder: (context, _) {
                if (!_streakFloatController.isAnimating &&
                    _streakFloatController.value == 0) {
                  return const SizedBox.shrink();
                }
                final t = _streakFloatController.value;
                final opacity = t < 0.3 ? t / 0.3 : 1.0 - ((t - 0.3) / 0.7);
                return Positioned(
                  top: 12 - (t * 28),
                  right: 12,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BotanicaTokens.spacingSm,
                          vertical: BotanicaTokens.spacingMicro,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            BotanicaTokens.radiusPill,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$_floatingStreakValue',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_isPlantAnniversary(widget.plant.createdAt))
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cake_rounded,
                    size: 14,
                    color: Color(0xFF5D4037),
                  ),
                ),
              )
            else if (healthScoreAsync is AsyncData<int>)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: healthScoreAsync.requireValue >= 70
                        ? scheme.primary
                        : healthScoreAsync.requireValue >= 40
                            ? Colors.amber
                            : scheme.error,
                    border: Border.all(
                      color: scheme.surface.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      value: semanticValue,
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.plantDetailWaterNow): () =>
            unawaited(_waterNow()),
        CustomSemanticsAction(label: l10n.commonEdit): () =>
            unawaited(_editPlant()),
        CustomSemanticsAction(label: l10n.plantDetailAddPhoto): () =>
            context.push(
              '${GardenScreen.location}/plant/${widget.plant.id}?tab=journal&action=add_photo',
            ),
      },
      child: card,
    ).animateSection(index: widget.index);
  }

  Widget _buildCompactContent(
      BuildContext context,
      TextTheme textTheme,
      ColorScheme scheme,
      AppLocalizations l10n,
      String coverPath,
      double progress,
      String speciesName,
      String? habit,
      Species? species,
      PlantIdea? idea,
      int? dueInDays,
      CareLog? lastWaterLog,
      PlantMood mood) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlantAvatar(
          heroTag: widget.plant.id,
          coverPath: coverPath,
          progress: progress,
          icon: Icons.spa_rounded,
          width: 56,
          height: 56,
          recentlyWatered: _recentlyWatered,
        ),
        BotanicaGaps.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plant.nickname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          speciesName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.68),
                            height: 1.25,
                          ),
                        ),
                        Text(
                          PlantVoice.speak(
                            plant: widget.plant,
                            recentLogs: ref.read(careLogsStreamProvider).valueOrNull ?? const [],
                            pendingTasks: ref.read(tasksStreamProvider).valueOrNull ?? const [],
                            now: DateTime.now(),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: PlantMoodResolver.moodColor(mood, scheme),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusLine(dueInDays: dueInDays, trend: widget.careTrend),
                ],
              ),
              if (habit != null && habit.trim().isNotEmpty) ...[
                const SizedBox(height: BotanicaTokens.spacingTiny),
                Text(
                  habit.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                    height: 1.25,
                  ),
                ),
              ],
              if (species != null || idea != null) ...[
                const SizedBox(height: BotanicaTokens.spacingXs),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildCareTags(l10n, species, idea),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryContent(
      BuildContext context,
      TextTheme textTheme,
      ColorScheme scheme,
      AppLocalizations l10n,
      String coverPath,
      double progress,
      String speciesName,
      String? habit,
      Species? species,
      PlantIdea? idea,
      int? dueInDays,
      CareLog? lastWaterLog,
      PlantMood mood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlantAvatar(
          heroTag: widget.plant.id,
          coverPath: coverPath,
          progress: progress,
          icon: Icons.spa_rounded,
          width: double.infinity,
          height: 160,
          recentlyWatered: _recentlyWatered,
        ),
        BotanicaGaps.vSm,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plant.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    speciesName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                      height: 1.25,
                    ),
                  ),
                  Text(
                    PlantVoice.speak(
                      plant: widget.plant,
                      recentLogs: ref.read(careLogsStreamProvider).valueOrNull ?? const [],
                      pendingTasks: ref.read(tasksStreamProvider).valueOrNull ?? const [],
                      now: DateTime.now(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: PlantMoodResolver.moodColor(mood, scheme),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                  if (habit != null && habit.trim().isNotEmpty) ...[
                    const SizedBox(height: BotanicaTokens.spacingTiny),
                    Text(
                      habit.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.72),
                        height: 1.25,
                      ),
                    ),
                  ],
                  if (species != null || idea != null) ...[
                    const SizedBox(height: BotanicaTokens.spacingXs),
                    _buildCareTags(l10n, species, idea),
                  ],
                ],
              ),
            ),
            _StatusLine(dueInDays: dueInDays, trend: widget.careTrend),
          ],
        ),
      ],
    );
  }

  Widget _buildCareFirstContent(
      BuildContext context,
      TextTheme textTheme,
      ColorScheme scheme,
      AppLocalizations l10n,
      String coverPath,
      double progress,
      String speciesName,
      String? habit,
      Species? species,
      PlantIdea? idea,
      int? dueInDays,
      CareLog? lastWaterLog,
      PlantMood mood) {
    return Row(
      children: [
        _PlantAvatar(
          heroTag: widget.plant.id,
          coverPath: coverPath,
          progress: progress,
          icon: Icons.spa_rounded,
          recentlyWatered: _recentlyWatered,
        ),
        BotanicaGaps.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.plant.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              BotanicaGaps.vMicro,
              Text(
                speciesName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                  height: 1.25,
                ),
              ),
              Text(
                PlantVoice.speak(
                  plant: widget.plant,
                  recentLogs: ref.read(careLogsStreamProvider).valueOrNull ?? const [],
                  pendingTasks: ref.read(tasksStreamProvider).valueOrNull ?? const [],
                  now: DateTime.now(),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: PlantMoodResolver.moodColor(mood, scheme),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
              if (habit != null && habit.trim().isNotEmpty) ...[
                const SizedBox(height: BotanicaTokens.spacingTiny),
                Text(
                  habit.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                    height: 1.25,
                  ),
                ),
              ],
              if (species != null) ...[
                const SizedBox(height: BotanicaTokens.spacingXs),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaTag(
                      icon: Icons.wb_sunny_rounded,
                      label: lightLabel(l10n, species.light),
                    ),
                    _MetaTag(
                      icon: Icons.school_rounded,
                      label: difficultyLabel(l10n, species.difficulty),
                    ),
                    _MetaTag(
                      icon: Icons.pets_rounded,
                      label: species.petSafe
                          ? l10n.discoverTagPetSafe
                          : l10n.discoverTagToxic,
                    ),
                  ],
                ),
              ],
              if (species == null && idea != null) ...[
                const SizedBox(height: BotanicaTokens.spacingXs),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if ((idea.light ?? '').trim().isNotEmpty)
                      _MetaTag(
                        icon: Icons.wb_sunny_rounded,
                        label: lightLabel(l10n, idea.light!.trim()),
                      ),
                    if ((idea.difficulty ?? '').trim().isNotEmpty)
                      _MetaTag(
                        icon: Icons.school_rounded,
                        label: difficultyLabel(l10n, idea.difficulty!.trim()),
                      ),
                    _MetaTag(
                      icon: Icons.pets_rounded,
                      label: idea.petSafe
                          ? l10n.discoverTagPetSafe
                          : l10n.discoverTagToxic,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: BotanicaTokens.spacingXs),
              _StatusLine(dueInDays: dueInDays, trend: widget.careTrend),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCareTags(
      AppLocalizations l10n, Species? species, PlantIdea? idea) {
    if (species != null) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MetaTag(
              icon: Icons.wb_sunny_rounded,
              label: lightLabel(l10n, species.light)),
          _MetaTag(
              icon: Icons.school_rounded,
              label: difficultyLabel(l10n, species.difficulty)),
          _MetaTag(
              icon: Icons.pets_rounded,
              label: species.petSafe
                  ? l10n.discoverTagPetSafe
                  : l10n.discoverTagToxic),
        ],
      );
    }
    if (idea != null) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if ((idea.light ?? '').trim().isNotEmpty)
            _MetaTag(
                icon: Icons.wb_sunny_rounded,
                label: lightLabel(l10n, idea.light!.trim())),
          if ((idea.difficulty ?? '').trim().isNotEmpty)
            _MetaTag(
                icon: Icons.school_rounded,
                label: difficultyLabel(l10n, idea.difficulty!.trim())),
          _MetaTag(
              icon: Icons.pets_rounded,
              label: idea.petSafe
                  ? l10n.discoverTagPetSafe
                  : l10n.discoverTagToxic),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class _PlantAvatar extends StatelessWidget {
  const _PlantAvatar({
    required this.coverPath,
    required this.progress,
    required this.icon,
    required this.heroTag,
    this.width,
    this.height,
    this.recentlyWatered = false,
  });

  final String coverPath;
  final double progress;
  final IconData icon;
  final String heroTag;
  final double? width;
  final double? height;
  final bool recentlyWatered;

  bool get _hasRealImage {
    final p = coverPath.trim();
    return p.isNotEmpty &&
        !p.endsWith('unknown.png') &&
        !p.endsWith('placeholder_plant.jpg') &&
        !p.endsWith('white.png');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final image = Stack(
      fit: StackFit.expand,
      children: [
        _CoverImage(path: coverPath),
        if (_hasRealImage) ...[
          Positioned(
            right: 3,
            bottom: 3,
            child: BotanicaWaterLevel(
              progress: progress,
              size: 22,
              strokeWidth: 2.0,
              showWave: false,
            ),
          ),
        ] else ...[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.38),
                  scheme.tertiaryContainer.withValues(alpha: 0.22),
                  scheme.surface.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
          Center(
            child: BotanicaWaterLevel(
              progress: progress,
              size: (width ?? 62) * 0.62,
              strokeWidth: 3.0,
            ),
          ),
        ],
      ],
    );

    return Hero(
      tag: heroTag,
      child: Container(
        width: width ?? 62,
        height: height ?? 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            if (recentlyWatered)
              Positioned(
                left: 3,
                top: 3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.surface.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    size: 10,
                    color: scheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final normalized = path.trim();

    Widget fallback() => Image.asset(
          'assets/images/placeholder_plant.jpg',
          fit: BoxFit.cover,
        );

    if (normalized.isEmpty) return fallback();

    if (normalized.startsWith('assets/')) {
      return Image.asset(
        normalized,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    final file = File(normalized);
    if (!file.existsSync()) return fallback();

    return Image.file(
      file,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
}

String _resolvePlantCoverPath({
  required String? coverPhotoPath,
  required String? coverAsset,
  required String? speciesImagePath,
}) {
  final photo = (coverPhotoPath ?? '').trim();
  final cover = (coverAsset ?? '').trim();
  final species = (speciesImagePath ?? '').trim();

  final isGenericPlaceholder = cover.isEmpty ||
      cover.endsWith('/white.png') ||
      cover.endsWith('white.png') ||
      cover.endsWith('/unknown.png') ||
      cover.endsWith('unknown.png') ||
      cover == 'assets/images/placeholder_plant.jpg';

  if (photo.isNotEmpty) return photo;
  if (!isGenericPlaceholder) return cover;
  if (species.isNotEmpty) return species;
  return 'assets/images/placeholder_plant.jpg';
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingXs,
        vertical: BotanicaTokens.spacingTiny,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: scheme.surface.withValues(alpha: 0.55),
        border:
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: BotanicaTokens.iconSizeXs, color: scheme.onSurface.withValues(alpha: 0.70)),
          BotanicaGaps.hXxs,
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenSlidableActionContent extends StatelessWidget {
  const _GardenSlidableActionContent({
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

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.dueInDays, this.trend});

  final int? dueInDays;
  final _CareTrend? trend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final due = dueInDays;
    if (due == null) {
      return Text(
        l10n.gardenNoScheduleYet,
        style: textTheme.labelMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.55),
        ),
      );
    }

    final isOverdue = due <= 0;
    final label = isOverdue
        ? '${l10n.taskTypeWater} · ${l10n.commonOverdue}'
        : due == 1
            ? '${l10n.taskTypeWater} · ${l10n.plantDetailNextWateringTomorrow}'
            : '${l10n.taskTypeWater} · ${l10n.plantDetailNextWateringInDays(due)}';

    final trendIcon = switch (trend) {
      _CareTrend.improving => Icon(
          Icons.trending_up_rounded,
          size: 14,
          color: scheme.primary.withValues(alpha: 0.8),
        ),
      _CareTrend.declining => Icon(
          Icons.trending_down_rounded,
          size: 14,
          color: scheme.error.withValues(alpha: 0.7),
        ),
      _ => null,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: AnimatedSwitcher(
            duration: BotanicaTokens.motionMedium,
            child: Text(
              label,
              key: ValueKey(label),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: isOverdue
                    ? scheme.error.withValues(alpha: 0.85)
                    : scheme.onSurface.withValues(alpha: 0.62),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (trendIcon != null) ...[
          const SizedBox(width: 4),
          trendIcon,
        ],
      ],
    );
  }
}

class _GardenEmptyState extends StatelessWidget {
  const _GardenEmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return BotanicaGlassCard(
      tier: GlassTier.primary,
      padding: BotanicaTokens.cardPaddingAiry,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 192,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.45),
                  scheme.tertiaryContainer.withValues(alpha: 0.2),
                  scheme.surface.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(BotanicaTokens.radiusXL),
                    child: const BotanicaAmbientBackground(
                      intensity: 0.12,
                      speed: 0.5,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primaryContainer.withValues(alpha: 0.6),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.local_florist_rounded,
                        size: 36,
                        color: scheme.primary.withValues(alpha: 0.85),
                      ),
                    ),
                    BotanicaGaps.vSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          size: BotanicaTokens.iconSizeSm,
                          color: scheme.secondary.withValues(alpha: 0.6),
                        ),
                        BotanicaGaps.hXxs,
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: BotanicaTokens.iconSizeSm,
                          color: scheme.tertiary.withValues(alpha: 0.6),
                        ),
                        BotanicaGaps.hXxs,
                        Icon(
                          Icons.water_drop_rounded,
                          size: BotanicaTokens.iconSizeSm,
                          color: scheme.primary.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          Text(
            l10n.gardenEmptyTitle,
            style: context.tsHeadline,
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vXs,
          Text(
            l10n.gardenEmptyBody,
            style: context.tsBodyMuted,
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vMd,
          BotanicaButton(
            icon: Icons.add_rounded,
            label: l10n.gardenEmptyCta,
            onPressed: onAdd,
            expand: true,
          ),
        ],
      ),
    ).animateSection(index: 3);
  }
}

class _EditPlantSheet extends StatefulWidget {
  const _EditPlantSheet({
    required this.plant,
  });

  final Plant plant;

  @override
  State<_EditPlantSheet> createState() => _EditPlantSheetState();
}

class _EditPlantSheetState extends State<_EditPlantSheet> {
  late final TextEditingController _nicknameController =
      TextEditingController(text: widget.plant.nickname);
  late final TextEditingController _roomController =
      TextEditingController(text: widget.plant.room);
  late EnvironmentMode _environmentMode = widget.plant.environmentMode;

  @override
  void dispose() {
    _nicknameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _save() {
    final nickname = _nicknameController.text.trim();
    Navigator.of(context).pop(
      widget.plant.copyWith(
        nickname: nickname.isEmpty ? widget.plant.nickname : nickname,
        room: _roomController.text.trim(),
        environmentMode: _environmentMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return BotanicaSheetBody(
      top: BotanicaTokens.spacingSm,
      bottom: BotanicaTokens.spacingLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: scheme.onSurface.withValues(alpha: 0.82),
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: Text(
                  l10n.commonEdit,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(null),
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.commonClose,
              ),
            ],
          ),
          BotanicaGaps.vSm,
          BotanicaGlassCard(
            padding: BotanicaTokens.cardPaddingDense,
            child: Column(
              children: [
                TextField(
                  controller: _nicknameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.addPlantFieldNickname,
                    prefixIcon: const Icon(Icons.badge_rounded),
                  ),
                ),
                BotanicaGaps.vSm,
                TextField(
                  controller: _roomController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.addPlantFieldRoom,
                    prefixIcon: const Icon(Icons.meeting_room_rounded),
                  ),
                ),
              ],
            ),
          ),
          BotanicaGaps.vSm,
          BotanicaGlassCard(
            padding: BotanicaTokens.cardPaddingDense,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addPlantFieldEnvironment,
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                BotanicaGaps.vSm,
                SegmentedButton<EnvironmentMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: EnvironmentMode.indoor,
                      icon: const Icon(Icons.home_rounded),
                      label: Text(l10n.addPlantEnvIndoor),
                    ),
                    ButtonSegment(
                      value: EnvironmentMode.balcony,
                      icon: const Icon(Icons.balcony_rounded),
                      label: Text(l10n.addPlantEnvBalcony),
                    ),
                    ButtonSegment(
                      value: EnvironmentMode.outdoor,
                      icon: const Icon(Icons.park_rounded),
                      label: Text(l10n.addPlantEnvOutdoor),
                    ),
                  ],
                  selected: {_environmentMode},
                  onSelectionChanged: (selection) {
                    if (selection.isEmpty) return;
                    setState(() => _environmentMode = selection.first);
                  },
                ),
              ],
            ),
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(l10n.commonCancel),
                ),
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

TaskInstance? _nextTask({
  required List<TaskInstance> tasks,
  required String plantId,
  required TaskType type,
}) {
  final pending = tasks
      .where((t) => !t.isDismissed && t.plantId == plantId && t.type == type)
      .toList(growable: false)
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  return pending.isEmpty ? null : pending.first;
}

int _displayTemperature(double tempC, TemperatureUnit unit) => switch (unit) {
      TemperatureUnit.celsius => tempC.round(),
      TemperatureUnit.fahrenheit => ((tempC * 9 / 5) + 32).round(),
    };

bool _isPlantAnniversary(DateTime createdAt) {
  final now = DateTime.now();
  return createdAt.month == now.month &&
      createdAt.day == now.day &&
      createdAt.year < now.year;
}

String _unitSymbol(TemperatureUnit unit) =>
    unit == TemperatureUnit.celsius ? 'C' : 'F';

String _timeGreeting(AppLocalizations l10n) {
  final hour = DateTime.now().hour;
  if (hour < 12) return l10n.gardenGreetingMorning;
  if (hour < 18) return l10n.gardenGreetingAfternoon;
  return l10n.gardenGreetingEvening;
}

const String _unassignedRoomLabel = 'Unassigned';

String _normalizedRoom(String room) {
  final normalized = room.trim();
  return normalized.isEmpty ? _unassignedRoomLabel : normalized;
}

String? _normalizedSelectedRoom(String? room) {
  final normalized = room?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return _normalizedRoom(normalized);
}

String _displayRoomLabel(BuildContext context, String room) {
  if (room == _unassignedRoomLabel) {
    return AppLocalizations.of(context).gardenWellnessRoomUnassigned;
  }
  return room;
}

List<String> _roomOptions(List<Plant> plants) {
  final rooms = plants
      .map((plant) => _normalizedRoom(plant.room))
      .where((room) => room.isNotEmpty)
      .toSet()
      .toList(growable: false)
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return rooms;
}

List<Plant> _filterPlantsByRoom(List<Plant> plants, String? selectedRoom) {
  if (selectedRoom == null) return plants;
  return plants
      .where((plant) => _normalizedRoom(plant.room) == selectedRoom)
      .toList(growable: false);
}

class _GardenRoomFilterRow extends StatelessWidget {
  const _GardenRoomFilterRow({
    required this.rooms,
    required this.selectedRoom,
    required this.onSelected,
  });

  final List<String> rooms;
  final String? selectedRoom;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gardenRoomsTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
        ),
        const SizedBox(height: BotanicaTokens.spacingXs),
        Wrap(
          spacing: BotanicaTokens.spacingXs,
          runSpacing: BotanicaTokens.spacingXs,
          children: [
            BotanicaChip(
              label: l10n.gardenRoomsAll,
              icon: Icons.apps_rounded,
              tint: scheme.primary,
              selected: selectedRoom == null,
              onTap: () => onSelected(null),
            ),
            ...rooms.map(
              (room) => BotanicaChip(
                label: _displayRoomLabel(context, room),
                icon: Icons.meeting_room_rounded,
                tint: scheme.secondary,
                selected: selectedRoom == room,
                onTap: () => onSelected(room),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

typedef _RoomWaterEntry = ({Plant plant, TaskInstance task});
typedef _RoomTaskEntry = ({Plant plant, TaskInstance task});

List<_RoomWaterEntry> _eligibleRoomWaterEntries(
  List<Plant> visiblePlants,
  List<TaskInstance> tasks,
) {
  final plantsById = {for (final plant in visiblePlants) plant.id: plant};
  final entries = <_RoomWaterEntry>[];
  for (final task in tasks) {
    if (task.type != TaskType.water) continue;
    if (task.status != TaskStatus.pending) continue;
    final plant = plantsById[task.plantId];
    if (plant == null) continue;
    entries.add((plant: plant, task: task));
  }
  return entries;
}

List<_RoomTaskEntry> _eligibleRoomSnoozeEntries(
  List<Plant> visiblePlants,
  List<TaskInstance> tasks,
) {
  final plantsById = {for (final plant in visiblePlants) plant.id: plant};
  final entries = <_RoomTaskEntry>[];
  for (final task in tasks) {
    if (task.status != TaskStatus.pending) continue;
    final plant = plantsById[task.plantId];
    if (plant == null) continue;
    entries.add((plant: plant, task: task));
  }
  return entries;
}

class _GardenRoomBatchActionsRow extends StatelessWidget {
  const _GardenRoomBatchActionsRow({
    required this.onWaterAll,
    required this.onSnoozeAll,
  });

  final VoidCallback? onWaterAll;
  final VoidCallback? onSnoozeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        children: [
          if (onWaterAll != null)
            Expanded(
              child: BotanicaButton(
                variant: BotanicaButtonVariant.outlined,
                icon: Icons.water_drop_rounded,
                label: l10n.gardenRoomsWaterAll,
                onPressed: onWaterAll,
              ),
            ),
          if (onWaterAll != null && onSnoozeAll != null) BotanicaGaps.hSm,
          if (onSnoozeAll != null)
            Expanded(
              child: BotanicaButton(
                variant: BotanicaButtonVariant.outlined,
                icon: Icons.snooze_rounded,
                label: l10n.gardenRoomsSnoozeAll,
                onPressed: onSnoozeAll,
              ),
            ),
        ],
      ),
    );
  }
}

String _weatherLabel(AppLocalizations l10n, WeatherKind kind) => switch (kind) {
      WeatherKind.clear => l10n.weatherClear,
      WeatherKind.partlyCloudy => l10n.weatherPartlyCloudy,
      WeatherKind.cloudy => l10n.weatherCloudy,
      WeatherKind.fog => l10n.weatherFog,
      WeatherKind.drizzle => l10n.weatherDrizzle,
      WeatherKind.rain => l10n.weatherRain,
      WeatherKind.snow => l10n.weatherSnow,
      WeatherKind.thunder => l10n.weatherThunder,
      WeatherKind.unknown => l10n.weatherUnknown,
    };

String? _weatherCareTip(AppLocalizations l10n, WeatherKind kind, double tempC, {int humidity = 50}) {
  if (kind == WeatherKind.rain || kind == WeatherKind.drizzle) {
    return l10n.weatherTipRainy;
  }
  if (kind == WeatherKind.thunder) {
    return l10n.weatherTipStormy;
  }
  if (tempC >= 35) {
    return l10n.weatherTipExtremeHeat;
  }
  if (tempC >= 30 && kind == WeatherKind.clear) {
    return l10n.weatherTipHotSunny;
  }
  if (tempC <= 5) {
    return l10n.weatherTipNearFreezing;
  }
  if (kind == WeatherKind.snow) {
    return l10n.weatherTipSnow;
  }
  if (tempC <= 10) {
    return l10n.weatherTipCool;
  }
  if (humidity <= 30) {
    return l10n.weatherTipLowHumidity;
  }
  if (humidity >= 80) {
    return l10n.weatherTipHighHumidity;
  }
  final month = DateTime.now().month;
  if (month >= 3 && month <= 5) return l10n.seasonalTipSpring;
  if (month >= 6 && month <= 8) return l10n.seasonalTipSummer;
  if (month >= 9 && month <= 11) return l10n.seasonalTipAutumn;
  return l10n.seasonalTipWinter;
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.cardMode,
    required this.viewMode,
    required this.onCardModeChanged,
    required this.onViewModeChanged,
  });

  final PlantCardMode cardMode;
  final GardenViewMode viewMode;
  final ValueChanged<PlantCardMode> onCardModeChanged;
  final ValueChanged<GardenViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewMode == GardenViewMode.list)
          IconButton(
            icon: Icon(
              cardMode == PlantCardMode.careFirst
                  ? Icons.view_agenda_rounded
                  : cardMode == PlantCardMode.gallery
                      ? Icons.grid_view_rounded
                      : Icons.view_list_rounded,
              color: scheme.onSurface,
            ),
            onPressed: () {
              final next = switch (cardMode) {
                PlantCardMode.careFirst => PlantCardMode.gallery,
                PlantCardMode.gallery => PlantCardMode.compact,
                PlantCardMode.compact => PlantCardMode.careFirst,
              };
              onCardModeChanged(next);
            },
            tooltip: AppLocalizations.of(context).gardenToggleCardMode,
          ),
        IconButton(
          icon: Icon(
            viewMode == GardenViewMode.list
                ? Icons.map_rounded
                : Icons.list_rounded,
            color: scheme.onSurface,
          ),
          onPressed: () {
            onViewModeChanged(
              viewMode == GardenViewMode.list
                  ? GardenViewMode.map
                  : GardenViewMode.list,
            );
          },
          tooltip: AppLocalizations.of(context).gardenToggleViewMode,
        ),
      ],
    );
  }
}

class _GardenMapView extends StatelessWidget {
  const _GardenMapView({
    required this.plants,
    required this.rooms,
    required this.speciesById,
    required this.ideaById,
    required this.tasks,
    required this.environment,
    required this.localeCode,
    required this.settings,
    required this.onRoomSelected,
  });

  final List<Plant> plants;
  final List<String> rooms;
  final Map<String, Species> speciesById;
  final Map<String, PlantIdea> ideaById;
  final List<TaskInstance> tasks;
  final EnvironmentSnapshot? environment;
  final String localeCode;
  final UserSettings settings;
  final ValueChanged<String> onRoomSelected;

  @override
  Widget build(BuildContext context) {
    // Group plants by room
    final byRoom = <String, List<Plant>>{};
    for (final p in plants) {
      final r = _normalizedRoom(p.room);
      byRoom.putIfAbsent(r, () => []).add(p);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final room in rooms)
          if (byRoom.containsKey(room)) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingLg),
              child: _RoomMapCard(
                roomName: room,
                plantsInRoom: byRoom[room]!,
                speciesById: speciesById,
                ideaById: ideaById,
                tasks: tasks,
                environment: environment,
                settings: settings,
                onTap: () => onRoomSelected(room),
              ),
            ),
          ]
      ],
    ).animateSection(index: 3);
  }
}

class _RoomMapCard extends StatelessWidget {
  const _RoomMapCard({
    required this.roomName,
    required this.plantsInRoom,
    required this.speciesById,
    required this.ideaById,
    required this.tasks,
    required this.environment,
    required this.settings,
    required this.onTap,
  });

  final String roomName;
  final List<Plant> plantsInRoom;
  final Map<String, Species> speciesById;
  final Map<String, PlantIdea> ideaById;
  final List<TaskInstance> tasks;
  final EnvironmentSnapshot? environment;
  final UserSettings settings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hash = roomName.hashCode.abs();
    final double temperatureC =
        environment?.tempC ?? (18.0 + (hash % 100) / 10.0);
    final double humidity = environment != null
        ? (environment!.humidity / 100.0)
        : (0.3 + ((hash ~/ 100) % 50) / 100.0);
    final LightLevel lightLevel = environment?.lightLevel ?? LightLevel.medium;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              scheme.surfaceContainer.withValues(alpha: 0.8),
            ],
          ),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        padding: BotanicaTokens.cardPaddingRelaxed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.meeting_room_rounded, color: scheme.primary),
                BotanicaGaps.hSm,
                Expanded(
                  child: Text(
                    _displayRoomLabel(context, roomName),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)
                      .gardenRoomPlantCount(plantsInRoom.length),
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            BotanicaGaps.vBase,
            RoomEnvironmentCard(
              temperatureC: temperatureC,
              humidity: humidity,
              lightLevel: lightLevel,
              settings: settings,
            ),
            BotanicaGaps.vBase,
            Wrap(
              spacing: BotanicaTokens.spacingSm,
              runSpacing: BotanicaTokens.spacingSm,
              children: plantsInRoom.map((p) {
                final s = speciesById[p.speciesId];
                final i = ideaById[p.speciesId];
                final coverPath = _resolvePlantCoverPath(
                  coverPhotoPath: p.coverPhotoPath,
                  coverAsset: p.coverAsset,
                  speciesImagePath: s?.imagePath ?? i?.imagePath,
                );

                final dueInDays = _nextTask(
                  tasks: tasks,
                  plantId: p.id,
                  type: TaskType.water,
                )?.dueAt.difference(DateTime.now()).inDays;

                return _PlantAvatar(
                  heroTag: p.id,
                  coverPath: coverPath,
                  progress: dueInDays == null
                      ? 0.0
                      : (1 - (dueInDays.clamp(0, 14) / 14.0)).clamp(0.0, 1.0),
                  icon: Icons.spa_rounded,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.logs});

  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final weekLogs = logs.where((l) => l.timestamp.isAfter(weekAgo)).toList();

    if (weekLogs.isEmpty) return const SizedBox.shrink();

    final prevWeekCount = logs
        .where((l) =>
            l.timestamp.isAfter(twoWeeksAgo) &&
            !l.timestamp.isAfter(weekAgo))
        .length;

    final waterCount =
        weekLogs.where((l) => l.type == TaskType.water).length;
    final fertilizeCount =
        weekLogs.where((l) => l.type == TaskType.fertilize).length;
    final totalCount = weekLogs.length;

    final dayActivity = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return weekLogs.any((l) =>
          l.timestamp.year == day.year &&
          l.timestamp.month == day.month &&
          l.timestamp.day == day.day);
    });

    final dayLabels = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return MaterialLocalizations.of(context)
          .narrowWeekdays[day.weekday % 7];
    });

    // Most active weekday from last 30 days
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentLogs = logs.where((l) => l.timestamp.isAfter(thirtyDaysAgo));
    final weekdayCounts = List<int>.filled(7, 0);
    for (final log in recentLogs) {
      weekdayCounts[log.timestamp.weekday % 7]++;
    }
    final maxWeekdayCount = weekdayCounts.fold<int>(0, (m, c) => c > m ? c : m);
    int mostActiveWeekday = -1;
    if (maxWeekdayCount >= 3) {
      mostActiveWeekday = weekdayCounts.indexOf(maxWeekdayCount);
    }

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CustomPaint(
                  painter: _WeeklyRingPainter(
                    progress: (totalCount / 14).clamp(0.0, 1.0),
                    color: scheme.primary,
                    trackColor: scheme.primary.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Text(
                      '$totalCount',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.gardenWeeklySummaryTitle,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (waterCount > 0) l10n.gardenWeeklyWatered(waterCount),
                        if (fertilizeCount > 0)
                          l10n.gardenWeeklyFertilized(fertilizeCount),
                        if (waterCount == 0 && fertilizeCount == 0)
                          l10n.gardenWeeklyCareActions(totalCount),
                      ].join(' · '),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final active = dayActivity[i];
              final isToday = i == 6;
              return Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? scheme.primary
                          : scheme.primary.withValues(alpha: 0.08),
                      border: isToday && !active
                          ? Border.all(
                              color: scheme.primary.withValues(alpha: 0.4),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: active
                        ? Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: scheme.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dayLabels[i],
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: active
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.4),
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
          if (prevWeekCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  totalCount > prevWeekCount
                      ? Icons.trending_up_rounded
                      : totalCount < prevWeekCount
                          ? Icons.trending_down_rounded
                          : Icons.trending_flat_rounded,
                  size: 14,
                  color: totalCount >= prevWeekCount
                      ? scheme.primary.withValues(alpha: 0.7)
                      : scheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  totalCount > prevWeekCount
                      ? l10n.gardenWeeklyTrendUp(totalCount - prevWeekCount)
                      : totalCount < prevWeekCount
                          ? l10n.gardenWeeklyTrendDown(totalCount - prevWeekCount)
                          : l10n.gardenWeeklyTrendSame,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: scheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ],
          if (mostActiveWeekday >= 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 12,
                  color: scheme.tertiary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.gardenWeeklyMostActiveDay(
                    MaterialLocalizations.of(context)
                        .narrowWeekdays[mostActiveWeekday],
                  ),
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyRingPainter extends CustomPainter {
  _WeeklyRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 3;
    const strokeWidth = 3.5;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    const startAngle = -1.5708;
    final sweepAngle = 2 * 3.14159265 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_WeeklyRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _CareForecastCard extends StatelessWidget {
  const _CareForecastCard({
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
    final matL10n = MaterialLocalizations.of(context);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final days = List.generate(7, (i) => today.add(Duration(days: i)));
    final dayCounts = List<int>.filled(7, 0);
    final dayPlants = List<Set<String>>.generate(7, (_) => <String>{});

    for (final t in tasks) {
      if (t.isDismissed || t.status == TaskStatus.snoozed) continue;
      final due = DateTime(t.dueAt.year, t.dueAt.month, t.dueAt.day);
      final diff = due.difference(today).inDays;
      if (diff >= 0 && diff < 7) {
        dayCounts[diff]++;
        final plant = plantsById[t.plantId];
        if (plant != null) dayPlants[diff].add(plant.nickname);
      }
    }

    final totalUpcoming = dayCounts.fold<int>(0, (s, c) => s + c);
    if (totalUpcoming == 0) return const SizedBox.shrink();

    final maxCount = dayCounts.fold<int>(1, (m, c) => c > m ? c : m);

    int busiestIdx = 0;
    for (int i = 1; i < 7; i++) {
      if (dayCounts[i] > dayCounts[busiestIdx]) busiestIdx = i;
    }

    String dayLabel(int idx) {
      if (idx == 0) return l10n.gardenForecastToday;
      if (idx == 1) return l10n.gardenForecastTomorrow;
      return matL10n.narrowWeekdays[days[idx].weekday % 7];
    }

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.gardenForecastTitle,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                l10n.gardenForecastTaskCount(totalUpcoming),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final count = dayCounts[i];
                final fraction = count / maxCount;
                final barHeight = count > 0
                    ? (fraction * 32).clamp(6.0, 32.0)
                    : 3.0;
                final isBusiest = i == busiestIdx && count > 0;
                final names = dayPlants[i].take(3).join(', ');
                final tooltip = count > 0
                    ? '${dayLabel(i)}: $names${dayPlants[i].length > 3 ? '…' : ''}'
                    : dayLabel(i);
                return Expanded(
                  child: Semantics(
                    label: '$tooltip, ${l10n.gardenForecastTaskCount(count)}',
                    child: Tooltip(
                      message: tooltip,
                      preferBelow: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (count > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '$count',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: isBusiest
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: isBusiest
                                        ? scheme.primary
                                        : scheme.onSurface
                                            .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: count > 0
                                    ? scheme.primary.withValues(
                                        alpha: 0.3 + 0.7 * fraction)
                                    : scheme.outlineVariant
                                        .withValues(alpha: 0.25),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dayLabel(i),
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                color: i == 0
                                    ? scheme.primary
                                    : scheme.onSurface.withValues(alpha: 0.45),
                                fontWeight:
                                    i == 0 ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (dayCounts[busiestIdx] > 1) ...[
            const SizedBox(height: 8),
            Text(
              l10n.gardenForecastBusyDay(dayLabel(busiestIdx)),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GardenHealthBar extends StatelessWidget {
  const _GardenHealthBar({
    required this.plants,
    required this.tasks,
    required this.logs,
    required this.onTap,
  });

  final List<Plant> plants;
  final List<TaskInstance> tasks;
  final List<CareLog> logs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final summary = GardenWellnessSummary.compute(
      plants: plants,
      tasks: tasks,
      logs: logs,
      now: DateTime.now(),
    );

    if (summary.isEmpty) return const SizedBox.shrink();

    final score = summary.overallScore;
    final scoreColor = score >= 90
        ? scheme.primary
        : score >= 70
            ? scheme.secondary
            : scheme.error;

    final subtitle = score >= 90
        ? l10n.gardenWellnessScoreFlourishing
        : score >= 70
            ? l10n.gardenWellnessScoreSteady
            : score >= 50
                ? l10n.gardenWellnessScoreNeedsLittleCare
                : l10n.gardenWellnessScoreNeedsAttention;

    return Semantics(
      button: true,
      label: '${l10n.gardenWellnessTitle}, $subtitle, ${l10n.gardenWellnessScoreLabel} $score',
      child: GestureDetector(
        onTap: onTap,
        child: BotanicaGlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: BotanicaTokens.spacingMd,
            vertical: BotanicaTokens.spacingSm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100.0,
                      strokeWidth: 3.5,
                      backgroundColor:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      valueColor: AlwaysStoppedAnimation(scoreColor),
                    ),
                    Text(
                      '$score',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.gardenWellnessTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: 0.5),
                size: BotanicaTokens.iconSizeMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakProgressChip extends StatelessWidget {
  const _StreakProgressChip({
    required this.streakDays,
    this.freezeCount = 0,
  });

  final int streakDays;
  final int freezeCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final nextMilestone = CareActions.streakMilestones
        .cast<int?>()
        .firstWhere((m) => m! > streakDays, orElse: () => null);

    final prevMilestone = CareActions.streakMilestones
        .where((m) => m <= streakDays)
        .lastOrNull ?? 0;

    final progress = nextMilestone != null
        ? (streakDays - prevMilestone) / (nextMilestone - prevMilestone)
        : 1.0;

    final daysToNext = nextMilestone != null ? nextMilestone - streakDays : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 2.5,
                backgroundColor:
                    scheme.outlineVariant.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(scheme.tertiary),
              ),
              Icon(
                Icons.local_fire_department_rounded,
                size: 12,
                color: scheme.tertiary,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          l10n.gardenCareStreakChip(streakDays),
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.tertiary,
          ),
        ),
        if (nextMilestone != null && daysToNext <= 5) ...[
          const SizedBox(width: 4),
          Text(
            '· $daysToNext→$nextMilestone',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (freezeCount > 0) ...[
          const SizedBox(width: 6),
          Semantics(
            label: l10n.gardenStreakFreezeAvailable(freezeCount),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.ac_unit_rounded,
                  size: 11,
                  color: scheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 2),
                Text(
                  '$freezeCount',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GardenHealthChip extends ConsumerWidget {
  const _GardenHealthChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final plants = ref.watch(plantsStreamProvider).valueOrNull ?? const [];
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.isEmpty) return const SizedBox.shrink();

    final score = ref.watch(gardenHealthScoreProvider);

    // Compute care momentum for trend indicator
    final tasks = ref.watch(tasksStreamProvider).valueOrNull ?? const <TaskInstance>[];
    final logs = ref.watch(careLogsStreamProvider).valueOrNull ?? const <CareLog>[];
    final momentum = GardenWellnessSummary.compute(
      plants: activePlants,
      tasks: tasks,
      logs: logs,
      now: DateTime.now(),
    ).careMomentum;

    final color = score >= 80
        ? scheme.primary
        : score >= 50
            ? scheme.tertiary
            : scheme.error;
    final isPerfect = score == 100;

    final IconData? trendIcon = switch (momentum) {
      CareMomentum.increasing => Icons.trending_up_rounded,
      CareMomentum.decreasing => Icons.trending_down_rounded,
      CareMomentum.stable => null,
    };

    final String? trendLabel = switch (momentum) {
      CareMomentum.increasing => l10n.gardenHealthTrendUp,
      CareMomentum.decreasing => l10n.gardenHealthTrendDown,
      CareMomentum.stable => null,
    };

    final Color trendColor = switch (momentum) {
      CareMomentum.increasing => scheme.primary,
      CareMomentum.decreasing => scheme.error.withValues(alpha: 0.7),
      CareMomentum.stable => scheme.onSurface.withValues(alpha: 0.5),
    };

    Widget chip = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: score / 100.0),
                duration: BotanicaTokens.motionSlow,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 2.5,
                  backgroundColor: scheme.outlineVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Icon(
                isPerfect ? Icons.star_rounded : Icons.favorite_rounded,
                size: 10,
                color: color,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$score',
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        if (trendIcon != null) ...[
          const SizedBox(width: 4),
          Icon(trendIcon, size: 12, color: trendColor),
          const SizedBox(width: 2),
          Text(
            trendLabel!,
            style: textTheme.labelSmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    if (isPerfect && !botanicaReduceMotion(context)) {
      chip = _PerfectGardenGlow(color: color, child: chip);
    }

    return Semantics(
      button: true,
      label: 'Garden health $score%${trendLabel != null ? ', $trendLabel' : ''}',
      child: GestureDetector(
        onTap: () {
          BotanicaHaptics.selectionTick();
          context.push('/profile/${GardenWellnessScreen.subLocation}');
        },
        child: chip,
      ),
    );
  }
}

class _PerfectGardenGlow extends StatefulWidget {
  const _PerfectGardenGlow({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  State<_PerfectGardenGlow> createState() => _PerfectGardenGlowState();
}

class _PerfectGardenGlowState extends State<_PerfectGardenGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = 0.15 + (_controller.value * 0.25);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: glow),
                blurRadius: 8 + (_controller.value * 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _TodayProgressChip extends StatelessWidget {
  const _TodayProgressChip({
    required this.completed,
    required this.remaining,
    required this.color,
    this.onTap,
  });

  final int completed;
  final int remaining;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final total = completed + remaining;
    final progress = total > 0 ? completed / total : 0.0;
    final allDone = remaining == 0 && completed > 0;

    return Semantics(
      button: onTap != null,
      label: allDone
          ? l10n.gardenMotivationAllDoneToday
          : '$completed of $total tasks done today',
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BotanicaTokens.spacingSm,
          vertical: BotanicaTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: allDone ? 0.14 : 0.08),
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: BotanicaTokens.motionSlow,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 2.5,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  if (allDone)
                    Icon(Icons.check_rounded, size: 12, color: color),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              allDone ? '$completed✓' : '$completed/$total',
              style: textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _RoomSectionHeader extends StatelessWidget {
  const _RoomSectionHeader({
    required this.room,
    required this.plantCount,
  });

  final String room;
  final int plantCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: BotanicaTokens.spacingLg,
        bottom: BotanicaTokens.spacingSm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.room_outlined,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            room,
            style: textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$plantCount',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantMilestoneBanner extends StatelessWidget {
  const _PlantMilestoneBanner({required this.milestones});

  final List<PlantMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final milestone = milestones.first;
    final title = switch (milestone.type) {
      PlantMilestoneType.oneMonth => l10n.plantMilestoneOneMonth,
      PlantMilestoneType.threeMonths => l10n.plantMilestoneThreeMonths,
      PlantMilestoneType.sixMonths => l10n.plantMilestoneSixMonths,
      PlantMilestoneType.oneYear => l10n.plantMilestoneOneYear,
      PlantMilestoneType.twoYears => l10n.plantMilestoneTwoYears,
    };

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
            ),
            child: const Icon(
              Icons.cake_rounded,
              color: Colors.amber,
              size: 22,
            ),
          ),
          const SizedBox(width: BotanicaTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${milestone.plant.nickname} — $title',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.plantMilestoneSubtitle(
                    milestone.plant.nickname,
                    milestone.daysOwned,
                  ),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.60),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (milestones.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: BotanicaTokens.spacingXxs),
              child: Text(
                '+${milestones.length - 1}',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.50),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SeasonalTipCard extends ConsumerWidget {
  const _SeasonalTipCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(settingsControllerProvider);

    final tip = SeasonalTipsEngine.tipOfTheDay(settings.hemisphere);
    final season = SeasonalTipsEngine.currentSeason(settings.hemisphere);

    final dismissed = settings.dismissedSeasonTipKey;
    if (dismissed == tip.id) return const SizedBox.shrink();

    final seasonColor = switch (season) {
      Season.spring => const Color(0xFF66BB6A),
      Season.summer => const Color(0xFFFFB300),
      Season.autumn => const Color(0xFFFF8A65),
      Season.winter => const Color(0xFF64B5F6),
    };

    final tipIcon = switch (tip.icon) {
      'water' => Icons.water_drop_rounded,
      'fertilize' => Icons.science_rounded,
      'mist' => Icons.blur_on_rounded,
      'sun' => Icons.wb_sunny_rounded,
      'pests' => Icons.bug_report_rounded,
      'growth' => Icons.trending_up_rounded,
      'prune' => Icons.content_cut_rounded,
      'outdoor' => Icons.park_rounded,
      'indoor' => Icons.home_rounded,
      'wipe' => Icons.cleaning_services_rounded,
      'repot' => Icons.local_florist_rounded,
      'rest' => Icons.bedtime_rounded,
      _ => Icons.eco_rounded,
    };

    final title = _resolveSeasonalTipString(l10n, tip.titleKey);
    final body = _resolveSeasonalTipString(l10n, tip.bodyKey);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: seasonColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
                ),
                child: Icon(tipIcon, size: 16, color: seasonColor),
              ),
              const SizedBox(width: BotanicaTokens.spacingSm),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: l10n.commonDismiss,
                child: GestureDetector(
                  onTap: () {
                    ref.read(settingsControllerProvider.notifier).update(
                          settings.copyWith(dismissedSeasonTipKey: tip.id),
                        );
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingXxs),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              body,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.70),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingXxs),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              l10n.seasonalTipTitle,
              style: textTheme.labelSmall?.copyWith(
                color: seasonColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _resolveSeasonalTipString(AppLocalizations l10n, String key) {
  return switch (key) {
    'seasonalTipSpringRepotTitle' => l10n.seasonalTipSpringRepotTitle,
    'seasonalTipSpringRepotBody' => l10n.seasonalTipSpringRepotBody,
    'seasonalTipSpringFertilizeTitle' => l10n.seasonalTipSpringFertilizeTitle,
    'seasonalTipSpringFertilizeBody' => l10n.seasonalTipSpringFertilizeBody,
    'seasonalTipSpringGrowthTitle' => l10n.seasonalTipSpringGrowthTitle,
    'seasonalTipSpringGrowthBody' => l10n.seasonalTipSpringGrowthBody,
    'seasonalTipSpringWaterTitle' => l10n.seasonalTipSpringWaterTitle,
    'seasonalTipSpringWaterBody' => l10n.seasonalTipSpringWaterBody,
    'seasonalTipSpringPestsTitle' => l10n.seasonalTipSpringPestsTitle,
    'seasonalTipSpringPestsBody' => l10n.seasonalTipSpringPestsBody,
    'seasonalTipSummerWaterTitle' => l10n.seasonalTipSummerWaterTitle,
    'seasonalTipSummerWaterBody' => l10n.seasonalTipSummerWaterBody,
    'seasonalTipSummerMistTitle' => l10n.seasonalTipSummerMistTitle,
    'seasonalTipSummerMistBody' => l10n.seasonalTipSummerMistBody,
    'seasonalTipSummerSunburnTitle' => l10n.seasonalTipSummerSunburnTitle,
    'seasonalTipSummerSunburnBody' => l10n.seasonalTipSummerSunburnBody,
    'seasonalTipSummerOutdoorTitle' => l10n.seasonalTipSummerOutdoorTitle,
    'seasonalTipSummerOutdoorBody' => l10n.seasonalTipSummerOutdoorBody,
    'seasonalTipSummerPropagateTitle' => l10n.seasonalTipSummerPropagateTitle,
    'seasonalTipSummerPropagateBody' => l10n.seasonalTipSummerPropagateBody,
    'seasonalTipAutumnWaterTitle' => l10n.seasonalTipAutumnWaterTitle,
    'seasonalTipAutumnWaterBody' => l10n.seasonalTipAutumnWaterBody,
    'seasonalTipAutumnFertilizeTitle' => l10n.seasonalTipAutumnFertilizeTitle,
    'seasonalTipAutumnFertilizeBody' => l10n.seasonalTipAutumnFertilizeBody,
    'seasonalTipAutumnLightTitle' => l10n.seasonalTipAutumnLightTitle,
    'seasonalTipAutumnLightBody' => l10n.seasonalTipAutumnLightBody,
    'seasonalTipAutumnInsideTitle' => l10n.seasonalTipAutumnInsideTitle,
    'seasonalTipAutumnInsideBody' => l10n.seasonalTipAutumnInsideBody,
    'seasonalTipAutumnCleanTitle' => l10n.seasonalTipAutumnCleanTitle,
    'seasonalTipAutumnCleanBody' => l10n.seasonalTipAutumnCleanBody,
    'seasonalTipWinterWaterTitle' => l10n.seasonalTipWinterWaterTitle,
    'seasonalTipWinterWaterBody' => l10n.seasonalTipWinterWaterBody,
    'seasonalTipWinterHumidityTitle' => l10n.seasonalTipWinterHumidityTitle,
    'seasonalTipWinterHumidityBody' => l10n.seasonalTipWinterHumidityBody,
    'seasonalTipWinterDraftsTitle' => l10n.seasonalTipWinterDraftsTitle,
    'seasonalTipWinterDraftsBody' => l10n.seasonalTipWinterDraftsBody,
    'seasonalTipWinterLightTitle' => l10n.seasonalTipWinterLightTitle,
    'seasonalTipWinterLightBody' => l10n.seasonalTipWinterLightBody,
    'seasonalTipWinterRestTitle' => l10n.seasonalTipWinterRestTitle,
    'seasonalTipWinterRestBody' => l10n.seasonalTipWinterRestBody,
    _ => key,
  };
}

class _CoachingInsightCard extends ConsumerWidget {
  const _CoachingInsightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final settings = ref.watch(settingsControllerProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);

    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (tasks.isEmpty && logs.isEmpty) return const SizedBox.shrink();

    final dismissedDate = settings.dismissedCoachingDate;
    if (dismissedDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dismissed = DateTime(
        dismissedDate.year,
        dismissedDate.month,
        dismissedDate.day,
      );
      if (!today.isAfter(dismissed)) return const SizedBox.shrink();
    }

    final insights = CareCoachingEngine.generateInsights(
      allTasks: tasks,
      allLogs: logs,
      settings: settings,
      now: DateTime.now(),
    );

    if (insights.isEmpty) return const SizedBox.shrink();

    final insight = insights.first;
    final title = _resolveCoachingString(l10n, insight.titleKey);
    final body = _resolveCoachingString(l10n, insight.bodyKey);
    final icon = _coachingIcon(insight.icon);
    final color = _coachingColor(scheme, insight.type);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          BotanicaGaps.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                BotanicaGaps.vMicro,
                Text(
                  body,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: l10n.commonDismiss,
            child: GestureDetector(
              onTap: () {
                BotanicaHaptics.selectionTick();
                ref.read(settingsControllerProvider.notifier).update(
                      settings.copyWith(
                        dismissedCoachingDate: DateTime.now(),
                      ),
                    );
              },
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _coachingIcon(String icon) => switch (icon) {
        'schedule' => Icons.schedule_rounded,
        'fire' => Icons.local_fire_department_rounded,
        'alert' => Icons.warning_amber_rounded,
        'trending_up' => Icons.trending_up_rounded,
        'star' => Icons.star_rounded,
        'category' => Icons.category_rounded,
        _ => Icons.lightbulb_outline_rounded,
      };

  static Color _coachingColor(ColorScheme scheme, CoachingInsightType type) =>
      switch (type) {
        CoachingInsightType.streakAtRisk => Colors.orange,
        CoachingInsightType.neglectedPlant => scheme.error,
        CoachingInsightType.lateWaterer => scheme.tertiary,
        CoachingInsightType.improvingHabit => scheme.primary,
        CoachingInsightType.consistentCarer => const Color(0xFFFFD54F),
        CoachingInsightType.diversifyCare => scheme.secondary,
      };
}

class _TimeCapsuleMemory {
  const _TimeCapsuleMemory({
    required this.photo,
    required this.daysAgo,
    required this.plant,
  });

  final PhotoEntry photo;
  final int daysAgo;
  final Plant plant;
}

_TimeCapsuleMemory? _timeCapsuleMemory(
  List<PhotoEntry> photos,
  Map<String, Plant> plantsById,
) {
  if (photos.isEmpty) return null;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  const lookbacks = [365, 90, 30, 7];
  for (final days in lookbacks) {
    final target = today.subtract(Duration(days: days));
    for (final photo in photos) {
      final photoDay = DateTime(
        photo.createdAt.year,
        photo.createdAt.month,
        photo.createdAt.day,
      );
      final diff = (photoDay.difference(target).inDays).abs();
      if (diff <= 1) {
        final plant = plantsById[photo.plantId];
        if (plant != null && !plant.isArchived) {
          return _TimeCapsuleMemory(
            photo: photo,
            daysAgo: days,
            plant: plant,
          );
        }
      }
    }
  }
  return null;
}

({Plant plant, int daysSincePhoto})? _pulseReadyPlant(
  List<PhotoEntry> photos,
  List<Plant> plants,
) {
  if (plants.isEmpty) return null;

  final now = DateTime.now();
  final photosByPlant = <String, List<PhotoEntry>>{};
  for (final p in photos) {
    (photosByPlant[p.plantId] ??= []).add(p);
  }

  Plant? bestPlant;
  int bestDays = 0;

  for (final plant in plants) {
    if (plant.isArchived) continue;
    final plantPhotos = photosByPlant[plant.id];
    if (plantPhotos == null || plantPhotos.isEmpty) continue;

    final latest = plantPhotos.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
    final days = now.difference(latest.createdAt).inDays;
    if (days >= 14 && days > bestDays) {
      bestDays = days;
      bestPlant = plant;
    }
  }

  if (bestPlant == null) return null;
  return (plant: bestPlant, daysSincePhoto: bestDays);
}

class _TimeCapsuleCard extends StatelessWidget {
  const _TimeCapsuleCard({
    required this.memory,
    required this.plantsById,
  });

  final _TimeCapsuleMemory memory;
  final Map<String, Plant> plantsById;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final file = File(memory.photo.filePath);

    return BotanicaGlassCard(
      padding: const EdgeInsets.all(BotanicaTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: BotanicaTokens.spacingXxs),
              Text(
                l10n.timeCapsuleTitle(memory.daysAgo),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover)
                  : Container(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: scheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          Text(
            l10n.timeCapsuleBody(memory.plant.nickname, memory.daysAgo),
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (memory.photo.note != null && memory.photo.note!.isNotEmpty) ...[
            const SizedBox(height: BotanicaTokens.spacingMicro),
            Text(
              '"${memory.photo.note}"',
              style: textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlantPulseCard extends StatelessWidget {
  const _PlantPulseCard({
    required this.plant,
    required this.daysSincePhoto,
    required this.onTap,
  });

  final Plant plant;
  final int daysSincePhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BotanicaGlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(BotanicaTokens.spacingMd),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: scheme.tertiary,
                  size: 22,
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.plantPulseTitle,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.plantPulseBody(plant.nickname, daysSincePhoto),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingXs),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _resolveCoachingString(AppLocalizations l10n, String key) => switch (key) {
  'coachingLateWatererTitle' => l10n.coachingLateWatererTitle,
  'coachingLateWatererBody' => l10n.coachingLateWatererBody,
  'coachingStreakAtRiskTitle' => l10n.coachingStreakAtRiskTitle,
  'coachingStreakAtRiskBody' => l10n.coachingStreakAtRiskBody,
  'coachingNeglectedPlantTitle' => l10n.coachingNeglectedPlantTitle,
  'coachingNeglectedPlantBody' => l10n.coachingNeglectedPlantBody,
  'coachingImprovingTitle' => l10n.coachingImprovingTitle,
  'coachingImprovingBody' => l10n.coachingImprovingBody,
  'coachingConsistentTitle' => l10n.coachingConsistentTitle,
  'coachingConsistentBody' => l10n.coachingConsistentBody,
  'coachingDiversifyTitle' => l10n.coachingDiversifyTitle,
  'coachingDiversifyBody' => l10n.coachingDiversifyBody,
  _ => key,
};

// ---------------------------------------------------------------------------
// Garden Mood Indicator
// ---------------------------------------------------------------------------

enum _GardenMood { thriving, happy, needsLove, thirsty }

class _GardenMoodIndicator extends StatelessWidget {
  const _GardenMoodIndicator({
    required this.overdueTasks,
    required this.avgHealthScore,
  });

  final int overdueTasks;
  final double avgHealthScore;

  _GardenMood get _mood {
    if (overdueTasks == 0 && avgHealthScore >= 80) return _GardenMood.thriving;
    if (overdueTasks == 0 || avgHealthScore >= 60) return _GardenMood.happy;
    if (overdueTasks <= 2 || avgHealthScore >= 40) {
      return _GardenMood.needsLove;
    }
    return _GardenMood.thirsty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mood = _mood;
    final (IconData icon, Color color, String label) = switch (mood) {
      _GardenMood.thriving => (
          Icons.spa_rounded,
          const Color(0xFF4CAF50),
          l10n.gardenMoodThriving,
        ),
      _GardenMood.happy => (
          Icons.sentiment_satisfied_rounded,
          scheme.primary,
          l10n.gardenMoodHappy,
        ),
      _GardenMood.needsLove => (
          Icons.sentiment_neutral_rounded,
          const Color(0xFFFF9800),
          l10n.gardenMoodNeedsLove,
        ),
      _GardenMood.thirsty => (
          Icons.sentiment_dissatisfied_rounded,
          const Color(0xFFE53935),
          l10n.gardenMoodThirsty,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingSm,
        vertical: BotanicaTokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily Briefing Section
// ---------------------------------------------------------------------------

class _DailyBriefingSection extends ConsumerWidget {
  const _DailyBriefingSection({
    required this.plants,
    required this.logs,
    required this.tasks,
    required this.settings,
  });

  final List<Plant> plants;
  final List<CareLog> logs;
  final List<TaskInstance> tasks;
  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final active = plants.where((p) => !p.isArchived).toList();

    final healthScores = <String, double>{};
    for (final plant in active) {
      final plantTasks = tasks.where((t) => t.plantId == plant.id).toList();
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      healthScores[plant.id] = PlantHealthScore.compute(
        allTasks: plantTasks,
        recentLogs: plantLogs,
        now: now,
      ) / 100.0;
    }

    final todayStart = DateTime(now.year, now.month, now.day);
    final missedThisWeek = tasks.where((t) =>
        !t.isDismissed &&
        t.status != TaskStatus.done &&
        t.status != TaskStatus.snoozed &&
        t.dueAt.isBefore(todayStart) &&
        now.difference(t.dueAt).inDays <= 7).length;

    final briefing = DailyBriefingEngine.generate(
      plants: active,
      logs: logs,
      healthScores: healthScores,
      streakDays: settings.careStreakDays,
      plantsAddedThisMonth: active.where((p) =>
          p.createdAt.year == now.year &&
          p.createdAt.month == now.month).length,
      missedTasksThisWeek: missedThisWeek,
      missedTasksLastWeek: 0,
      totalDailyTasks: tasks.where((t) =>
          !t.isDismissed &&
          t.status != TaskStatus.snoozed &&
          t.dueAt.year == now.year &&
          t.dueAt.month == now.month &&
          t.dueAt.day == now.day).length,
      now: now,
    );

    if (briefing.items.isEmpty) return const SizedBox.shrink();

    return BotanicaDailyBriefingCard(briefing: briefing);
  }
}
