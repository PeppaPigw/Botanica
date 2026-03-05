import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_text_styles.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/environment/weather_code.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/screen_title.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_idea.dart';
import '../../domain/models/species.dart';
import '../../domain/models/task_instance.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/care/care_actions.dart';
import '../calendar/calendar_screen.dart';
import '../tasks/tasks_screen.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  static const String location = '/garden';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final todayDueCount = _countDueToday(tasks);
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
              ),
            ),
          ),
          SliverPadding(
            padding: BotanicaTokens.pagePadding.copyWith(top: 0),
            sliver: SliverToBoxAdapter(
              child: _TodayCard(
                taskCount: todayDueCount,
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
              )
                  .animate()
                  .fadeIn(duration: BotanicaTokens.motionSlow)
                  .slideY(begin: 0.05, curve: BotanicaTokens.curveReveal),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: BotanicaTokens.spacingRelaxed),
          ),
          plantsAsync.when(
            data: (plants) {
              if (plants.isEmpty) {
                return SliverPadding(
                  padding: BotanicaTokens.pagePaddingWithBottomNav(context),
                  sliver: SliverToBoxAdapter(
                    child: _GardenEmptyState(
                      onAdd: () => context.push('${GardenScreen.location}/add'),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: BotanicaTokens.pagePaddingWithBottomNav(context),
                sliver: SliverList.separated(
                  itemCount: plants.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: BotanicaTokens.spacingBase),
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    final nextWater = _nextTask(
                      tasks: tasks,
                      plantId: plant.id,
                      type: TaskType.water,
                    );

                    return _PlantCard(
                      plant: plant,
                      species: speciesById[plant.speciesId],
                      idea: ideaById[plant.speciesId],
                      nextWaterTask: nextWater,
                      localeCode: localeCode,
                      index: index,
                    );
                  },
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
            loading: () => SliverPadding(
              padding: BotanicaTokens.pagePadding,
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: BotanicaTokens.spacingXxl,
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          scheme.primary.withValues(alpha: 0.7)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.taskCount,
    required this.weatherIcon,
    required this.weatherLabel,
    required this.onOpenTasks,
    required this.onOpenCalendar,
    required this.onAddPlant,
  });

  final int taskCount;
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

    final hasTasks = taskCount > 0;

    return BotanicaGlassCard(
      tier: GlassTier.primary,
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
                      style: context.tsHeadline,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      MaterialLocalizations.of(context)
                          .formatFullDate(DateTime.now()),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
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
                iconSize: 16,
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          Row(
            children: [
              if (hasTasks)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary.withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$taskCount',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (hasTasks) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.gardenTasksDueToday(taskCount),
                  style: context.tsBody.copyWith(
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          Wrap(
            spacing: BotanicaTokens.spacingXs,
            runSpacing: BotanicaTokens.spacingXs,
            children: [
              BotanicaChip(
                icon: Icons.check_circle_rounded,
                label: l10n.tasksTitle,
                tint: scheme.primary,
                onTap: onOpenTasks,
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingBase,
                  vertical: BotanicaTokens.spacingSm,
                ),
              ),
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
    );
  }
}

class _PlantCard extends ConsumerStatefulWidget {
  const _PlantCard({
    required this.plant,
    required this.species,
    required this.idea,
    required this.nextWaterTask,
    required this.localeCode,
    required this.index,
  });

  final Plant plant;
  final Species? species;
  final PlantIdea? idea;
  final TaskInstance? nextWaterTask;
  final String localeCode;
  final int index;

  @override
  ConsumerState<_PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends ConsumerState<_PlantCard> {
  bool _watering = false;

  Future<void> _waterNow() async {
    if (_watering) return;

    setState(() => _watering = true);
    try {
      HapticFeedback.lightImpact();

      final l10n = AppLocalizations.of(context);
      final now = DateTime.now();

      final tasksRepo = ref.read(tasksRepositoryProvider);
      final logsRepo = ref.read(logsRepositoryProvider);
      final speciesRepo = ref.read(speciesRepositoryProvider);
      final ideaRepo = ref.read(plantIdeaRepositoryProvider);
      final env = ref.read(environmentSnapshotProvider);
      final engine = ref.read(carePlanEngineProvider);
      final settings = ref.read(settingsControllerProvider);

      await CareActions.waterNow(
        plant: widget.plant,
        now: now,
        pendingWaterTask: widget.nextWaterTask,
        tasksRepository: tasksRepo,
        logsRepository: logsRepo,
        speciesRepository: speciesRepo,
        plantIdeaRepository: ideaRepo,
        engine: engine,
        environment: env,
        settings: settings,
        updateSettings: (next) =>
            ref.read(settingsControllerProvider.notifier).update(next),
      );

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.inversePrimary),
              const SizedBox(width: 10),
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

    await ref.read(plantsRepositoryProvider).upsert(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 18, color: Theme.of(context).colorScheme.inversePrimary),
            const SizedBox(width: 10),
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
      coverAsset: widget.plant.coverAsset,
      speciesImagePath: species?.imagePath ?? idea?.imagePath,
    );

    final semanticLabel = speciesName.trim().isEmpty
        ? widget.plant.nickname
        : '${widget.plant.nickname}, $speciesName';
    final semanticValue = switch (dueInDays) {
      null => l10n.gardenNoScheduleYet,
      <= 0 => '${l10n.taskTypeWater} · ${l10n.tasksTabOverdue}',
      final days =>
        '${l10n.taskTypeWater} · ${l10n.plantDetailNextWateringInDays(days)}',
    };

    final card = Slidable(
      key: ValueKey('plant-${widget.plant.id}'),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.32,
        children: [
          SlidableAction(
            onPressed: (_) => _waterNow(),
            backgroundColor: scheme.primary.withValues(alpha: 0.25),
            foregroundColor: scheme.onSurface,
            icon: Icons.water_drop_rounded,
            label: l10n.plantDetailWaterNow,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.40,
        children: [
          SlidableAction(
            onPressed: (_) => _editPlant(),
            backgroundColor: scheme.secondary.withValues(alpha: 0.22),
            foregroundColor: scheme.onSurface,
            icon: Icons.edit_rounded,
            label: l10n.commonEdit,
          ),
          SlidableAction(
            onPressed: (_) => context.push(
              '${GardenScreen.location}/plant/${widget.plant.id}?tab=journal&action=add_photo',
            ),
            backgroundColor: scheme.tertiary.withValues(alpha: 0.22),
            foregroundColor: scheme.onSurface,
            icon: Icons.photo_camera_rounded,
            label: l10n.plantDetailAddPhoto,
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
          child: Row(
            children: [
              _PlantAvatar(
                coverPath: coverPath,
                progress: progress,
                icon: Icons.spa_rounded,
              ),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 2),
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
                    if (species case final s?) ...[
                      const SizedBox(height: BotanicaTokens.spacingXs),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaTag(
                            icon: Icons.wb_sunny_rounded,
                            label: lightLabel(l10n, s.light),
                          ),
                          _MetaTag(
                            icon: Icons.school_rounded,
                            label: difficultyLabel(l10n, s.difficulty),
                          ),
                          _MetaTag(
                            icon: Icons.pets_rounded,
                            label: s.petSafe
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
                              label: difficultyLabel(
                                  l10n, idea.difficulty!.trim()),
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
    )
        .animate()
        .fadeIn(
          delay: (widget.index * 45).ms,
          duration: BotanicaTokens.motionSlow,
        )
        .slideY(begin: 0.06, curve: BotanicaTokens.curveReveal);
  }
}

class _PlantAvatar extends StatelessWidget {
  const _PlantAvatar({
    required this.coverPath,
    required this.progress,
    required this.icon,
  });

  final String coverPath;
  final double progress;
  final IconData icon;

  bool get _hasRealImage {
    final p = coverPath.trim();
    return p.isNotEmpty &&
        !p.endsWith('unknown.png') &&
        !p.endsWith('white.png');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 62,
      height: 62,
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
          _CoverImage(path: coverPath),
          if (_hasRealImage) ...[
            Positioned(
              right: 3,
              bottom: 3,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surface.withValues(alpha: 0.72),
                ),
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.5,
                  backgroundColor:
                      scheme.outlineVariant.withValues(alpha: 0.35),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    scheme.primary.withValues(alpha: 0.85),
                  ),
                ),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor:
                          scheme.outlineVariant.withValues(alpha: 0.35),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scheme.primary.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  Icon(
                    icon,
                    color: scheme.onSurface.withValues(alpha: 0.78),
                  ),
                ],
              ),
            ),
          ],
        ],
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
          'assets/placeholders/species/unknown.png',
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
  required String? coverAsset,
  required String? speciesImagePath,
}) {
  final cover = (coverAsset ?? '').trim();
  final species = (speciesImagePath ?? '').trim();

  final isGenericPlaceholder = cover.isEmpty ||
      cover.endsWith('/white.png') ||
      cover.endsWith('white.png') ||
      cover == 'assets/placeholders/species/unknown.png';

  if (!isGenericPlaceholder) return cover;
  if (species.isNotEmpty) return species;
  return 'assets/placeholders/species/unknown.png';
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
          Icon(icon, size: 14, color: scheme.onSurface.withValues(alpha: 0.70)),
          const SizedBox(width: 6),
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
        ? '${l10n.taskTypeWater} · ${l10n.tasksTabOverdue}'
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.55),
                scheme.tertiaryContainer.withValues(alpha: 0.25),
              ],
            ),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/illustrations/empty_garden_seedling.jpg',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  excludeFromSemantics: true,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.55, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        scheme.surface.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: BotanicaTokens.spacingRelaxed),
        Text(
          l10n.gardenEmptyTitle,
          style: context.tsHeadline,
        ),
        BotanicaGaps.vXxs,
        Text(
          l10n.gardenEmptyBody,
          style: context.tsBodyMuted,
        ),
        BotanicaGaps.vMd,
        BotanicaButton(
          icon: Icons.add_rounded,
          label: l10n.gardenEmptyCta,
          onPressed: onAdd,
          expand: true,
        ),
      ],
    ).animate().fadeIn(duration: BotanicaTokens.motionSlow).slideY(begin: 0.06);
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
              const SizedBox(width: 10),
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
          const SizedBox(height: 12),
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
                const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
                const SizedBox(height: 10),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(l10n.commonCancel),
                ),
              ),
              const SizedBox(width: 12),
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

int _countDueToday(List<TaskInstance> tasks) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return tasks
      .where(
          (t) => !t.isDone && t.dueAt.isAfter(start) && t.dueAt.isBefore(end))
      .length;
}

TaskInstance? _nextTask({
  required List<TaskInstance> tasks,
  required String plantId,
  required TaskType type,
}) {
  final pending = tasks
      .where((t) => !t.isDone && t.plantId == plantId && t.type == type)
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
