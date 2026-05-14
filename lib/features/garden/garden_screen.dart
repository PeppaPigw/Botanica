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
import '../../core/widgets/botanica_celebration.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_press_scale.dart';
import '../../core/widgets/botanica_search_field.dart';
import '../../core/widgets/botanica_shimmer.dart';
import '../../core/widgets/botanica_water_level.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/screen_title.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/environment_snapshot.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_idea.dart';
import '../../domain/models/species.dart';
import '../../domain/models/task_instance.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/care/care_actions.dart';
import 'widgets/room_environment_card.dart';
import '../calendar/calendar_screen.dart';
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

enum GardenSortMode { name, needsCare, newest }

class _GardenScreenState extends ConsumerState<GardenScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedRoom;
  PlantCardMode _cardMode = PlantCardMode.careFirst;
  GardenViewMode _viewMode = GardenViewMode.list;
  bool _isBatchActionRunning = false;

  String _searchQuery = '';
  bool _showArchived = false;
  GardenSortMode _sortMode = GardenSortMode.needsCare;

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

    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];

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
          CustomScrollView(
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
                        BotanicaScreenTitle(l10n.navGarden),
                        if (settings.careStreakDays >= 2) ...[
                          BotanicaGaps.vTiny,
                          BotanicaChip(
                            icon: Icons.local_fire_department_rounded,
                            label: l10n.gardenCareStreakChip(
                              settings.careStreakDays,
                            ),
                            tint: scheme.tertiary,
                            selected: true,
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
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.push(
                        '${GardenScreen.location}/${TasksScreen.subLocation}'),
                    icon: Icon(Icons.today_rounded, color: scheme.onSurface),
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
                plantsById: plantsById,
                weatherIcon: iconForWeatherKind(conditionKind),
                weatherLabel: l10n.gardenWeatherChip(
                  conditionLabel,
                  displayTemp,
                  unitSymbol,
                  environment.humidity,
                ),
                onOpenTasks: () => context.push(
                    '${GardenScreen.location}/${TasksScreen.subLocation}'),
                onOpenCalendar: () => context.go(CalendarScreen.location),
                onAddPlant: () => context.push('${GardenScreen.location}/add'),
              ).animateSection(index: 2),
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

              plants.sort((a, b) {
                if (_sortMode == GardenSortMode.name) {
                  return a.nickname
                      .toLowerCase()
                      .compareTo(b.nickname.toLowerCase());
                } else if (_sortMode == GardenSortMode.newest) {
                  return b.createdAt.compareTo(a.createdAt);
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
                      SliverList.separated(
                        itemCount: visiblePlants.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: BotanicaTokens.spacingBase),
                        itemBuilder: (context, index) {
                          final plant = visiblePlants[index];
                          final nextWater = _nextTask(
                            tasks: tasks,
                            plantId: plant.id,
                            type: TaskType.water,
                          );

                          return RepaintBoundary(
                            child: _PlantCard(
                              plant: plant,
                              species: speciesById[plant.speciesId],
                              idea: ideaById[plant.speciesId],
                              nextWaterTask: nextWater,
                              localeCode: localeCode,
                              index: index,
                              mode: _cardMode,
                            ),
                          );
                        },
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
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.todayDueTasks,
    required this.plantsById,
    required this.weatherIcon,
    required this.weatherLabel,
    required this.onOpenTasks,
    required this.onOpenCalendar,
    required this.onAddPlant,
  });

  final List<TaskInstance> todayDueTasks;
  final Map<String, Plant> plantsById;
  final IconData weatherIcon;
  final String weatherLabel;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenCalendar;
  final VoidCallback onAddPlant;

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
                                    l10n.gardenTodayCardTitle,
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
                        BotanicaGaps.vMd,
                        Wrap(
                          spacing: BotanicaTokens.spacingXs,
                          runSpacing: BotanicaTokens.spacingXs,
                          children: [
                            if (hasTasks)
                              BotanicaChip(
                                icon: Icons.check_circle_rounded,
                                label: l10n
                                    .gardenTasksDueToday(todayDueTasks.length),
                                tint: scheme.primary,
                                onTap: onOpenTasks,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: BotanicaTokens.spacingBase,
                                  vertical: BotanicaTokens.spacingSm,
                                ),
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

class _PlantCard extends ConsumerStatefulWidget {
  const _PlantCard({
    required this.plant,
    required this.species,
    required this.idea,
    required this.nextWaterTask,
    required this.localeCode,
    required this.index,
    required this.mode,
  });

  final Plant plant;
  final Species? species;
  final PlantIdea? idea;
  final TaskInstance? nextWaterTask;
  final String localeCode;
  final int index;
  final PlantCardMode mode;

  @override
  ConsumerState<_PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends ConsumerState<_PlantCard> {
  bool _watering = false;

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

      await CareActions.waterNow(
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
      BotanicaHaptics.completion();
      BotanicaCelebration.show(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  size: BotanicaTokens.iconSizeSm,
                  color: Theme.of(context).colorScheme.inversePrimary),
              BotanicaGaps.hSm,
              Text('${l10n.taskTypeWater} · ${l10n.commonDone}'),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _watering = false);
    }
  }

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
            onPressed: (_) async {},
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
        child: BotanicaGlassCard(
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
                      dueInDays),
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
                      dueInDays),
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
                      dueInDays),
                },
              ),
            ),
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
      int? dueInDays) {
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
                      ],
                    ),
                  ),
                  _StatusLine(dueInDays: dueInDays),
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
      int? dueInDays) {
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
            _StatusLine(dueInDays: dueInDays),
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
      int? dueInDays) {
    return Row(
      children: [
        _PlantAvatar(
          heroTag: widget.plant.id,
          coverPath: coverPath,
          progress: progress,
          icon: Icons.spa_rounded,
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
              _StatusLine(dueInDays: dueInDays),
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
  });

  final String coverPath;
  final double progress;
  final IconData icon;
  final String heroTag;
  final double? width;
  final double? height;

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
        child: image,
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
  const _StatusLine({required this.dueInDays});

  final int? dueInDays;

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
        : '${l10n.taskTypeWater} · ${l10n.plantDetailNextWateringInDays(due)}';

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.labelMedium?.copyWith(
        color: isOverdue
            ? scheme.error.withValues(alpha: 0.85)
            : scheme.onSurface.withValues(alpha: 0.62),
        fontWeight: FontWeight.w600,
      ),
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

String _unitSymbol(TemperatureUnit unit) =>
    unit == TemperatureUnit.celsius ? 'C' : 'F';

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
