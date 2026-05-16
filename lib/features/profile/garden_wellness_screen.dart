import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_animated_counter.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/botanica_streak_badge.dart';
import '../../core/widgets/care_patterns_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/botanica_momentum_ring.dart';
import '../../core/widgets/botanica_care_routine_card.dart';
import '../../core/widgets/botanica_diversity_card.dart';
import '../../core/widgets/botanica_care_confidence_radar.dart';
import '../../core/widgets/botanica_garden_legacy_card.dart';
import '../../core/widgets/botanica_watering_batch_card.dart';
import '../../core/widgets/botanica_care_rhythm_card.dart';
import '../../core/widgets/botanica_next_action_card.dart';
import '../../core/widgets/botanica_garden_goal_card.dart';
import '../../core/widgets/botanica_room_profile_card.dart';
import '../../core/widgets/botanica_care_impact_card.dart';
import '../../core/widgets/botanica_streak_leaderboard_card.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/photo_entry.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/services/achievements.dart';
import '../../domain/services/garden_wellness_priorities.dart';
import '../../domain/services/garden_wellness_room_pulse.dart';
import '../../domain/services/garden_wellness_summary.dart';
import '../../domain/services/garden_momentum_engine.dart';
import '../../domain/services/care_routine_detector.dart';
import '../../domain/services/garden_diversity_engine.dart';
import '../../domain/services/care_confidence_engine.dart';
import '../../domain/services/garden_legacy_engine.dart';
import '../../domain/services/watering_batch_planner.dart';
import '../../domain/services/care_rhythm_engine.dart';
import '../../domain/services/next_action_recommender.dart';
import '../../domain/services/garden_goal_engine.dart';
import '../../domain/services/room_microclimate_profiler.dart';
import '../../domain/services/care_impact_analyzer.dart';
import '../../domain/services/streak_leaderboard_engine.dart';
import '../../features/garden/garden_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../gen/l10n/app_localizations.dart';

class GardenWellnessScreen extends ConsumerWidget {
  const GardenWellnessScreen({
    super.key,
    this.now = DateTime.now,
  });

  static const String subLocation = 'wellness';
  final DateTime Function() now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(settingsControllerProvider);
    final plantsAsync = ref.watch(plantsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);

    Widget buildLoading() {
      return Center(
        child: BotanicaGlassCard(
          padding: BotanicaTokens.cardPaddingDense,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation(
                    scheme.primary.withValues(alpha: 0.82),
                  ),
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingSm),
              Text(l10n.commonLoading),
            ],
          ),
        ),
      );
    }

    Widget buildError() {
      return Center(
        child: Padding(
          padding: BotanicaTokens.pagePadding,
          child: BotanicaStateCard(
            icon: Icons.cloud_off_rounded,
            title: l10n.stateLoadFailedTitle,
            body: l10n.stateLoadFailedBody,
            primaryAction: BotanicaButton(
              variant: BotanicaButtonVariant.outlined,
              icon: Icons.refresh_rounded,
              label: l10n.commonTryAgain,
              onPressed: () {
                ref.invalidate(plantsStreamProvider);
                ref.invalidate(tasksStreamProvider);
                ref.invalidate(careLogsStreamProvider);
              },
            ),
          ),
        ),
      );
    }

    final loading =
        plantsAsync.isLoading || tasksAsync.isLoading || logsAsync.isLoading;
    final hasError =
        plantsAsync.hasError || tasksAsync.hasError || logsAsync.hasError;

    Widget body;
    if (loading) {
      body = buildLoading();
    } else if (hasError) {
      body = buildError();
    } else {
      final summary = GardenWellnessSummary.compute(
        plants: plantsAsync.requireValue,
        tasks: tasksAsync.requireValue,
        logs: logsAsync.requireValue,
        now: now(),
      );
      final priorities = GardenWellnessPriorities.build(summary: summary);
      final roomPulse = GardenWellnessRoomPulse.build(summary: summary);

      if (summary.isEmpty) {
        body = SafeArea(
          child: ListView(
            padding: BotanicaTokens.pagePadding.copyWith(bottom: 26),
            children: [
              BotanicaStateCard(
                icon: Icons.spa_rounded,
                title: l10n.gardenWellnessEmptyTitle,
                body: l10n.gardenWellnessEmptyBody,
                illustrationAsset:
                    'assets/illustrations/garden_wellness_hero.jpg',
                primaryAction: BotanicaButton(
                  icon: Icons.add_rounded,
                  label: l10n.gardenQuickAddPlant,
                  onPressed: () => context.push('${GardenScreen.location}/add'),
                ),
              ),
            ],
          ),
        );
      } else {
        body = SafeArea(
          child: ListView(
            padding: BotanicaTokens.pagePadding.copyWith(bottom: 26),
            children: [
              BotanicaGlassCard(
                padding: BotanicaTokens.cardPaddingDense,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(BotanicaTokens.radiusL),
                      child: Image.asset(
                        'assets/illustrations/garden_wellness_hero.jpg',
                        height: 184,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(height: BotanicaTokens.spacingMd),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.gardenWellnessOverallScore,
                                style: textTheme.labelLarge?.copyWith(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.70),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                  height: BotanicaTokens.spacingTiny),
                              BotanicaAnimatedCounter(
                                value: summary.overallScore,
                                style: textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.2,
                                ),
                              ),
                              Text(
                                _scoreDescriptor(l10n, summary.overallScore),
                                style: textTheme.bodyMedium?.copyWith(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.72),
                                ),
                              ),
                              if (summary.careMomentum != CareMomentum.stable)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        summary.careMomentum ==
                                                CareMomentum.increasing
                                            ? Icons.trending_up_rounded
                                            : Icons.trending_down_rounded,
                                        size: 14,
                                        color: summary.careMomentum ==
                                                CareMomentum.increasing
                                            ? scheme.primary
                                            : scheme.error
                                                .withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        summary.careMomentum ==
                                                CareMomentum.increasing
                                            ? l10n
                                                .gardenWellnessMomentumIncreasing
                                            : l10n
                                                .gardenWellnessMomentumDecreasing,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: summary.careMomentum ==
                                                  CareMomentum.increasing
                                              ? scheme.primary
                                              : scheme.error
                                                  .withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: BotanicaTokens.spacingSm),
                        Expanded(
                          child: Wrap(
                            spacing: BotanicaTokens.spacingXs,
                            runSpacing: BotanicaTokens.spacingXs,
                            children: [
                              _MetricChip(
                                  label: l10n.gardenTasksDueToday(
                                      summary.dueTodayTasks)),
                              _MetricChip(
                                  label: l10n.gardenWellnessOverdueChip(
                                      summary.overdueTasks)),
                              _MetricChip(
                                  label: l10n.gardenCareStreakChip(
                                      settings.careStreakDays)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: l10n.gardenWellnessStatPlants,
                      numericValue: summary.plantCount,
                      icon: Icons.local_florist_rounded,
                    ),
                  ),
                  const SizedBox(width: BotanicaTokens.spacingSm),
                  Expanded(
                    child: _StatCard(
                      label: l10n.gardenWellnessStatRecentCare,
                      numericValue: summary.recentlyCaredPlants,
                      icon: Icons.history_rounded,
                    ),
                  ),
                  const SizedBox(width: BotanicaTokens.spacingSm),
                  Expanded(
                    child: _StatCard(
                      label: l10n.gardenWellnessStatAtRisk,
                      numericValue: summary.atRiskPlants,
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BotanicaTokens.spacingSm),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: l10n.gardenWellnessStatPunctuality,
                      numericValue: summary.punctualityPercent,
                      icon: Icons.timer_rounded,
                      suffix: '%',
                    ),
                  ),
                  const SizedBox(width: BotanicaTokens.spacingSm),
                  Expanded(
                    child: _StatCard(
                      label: l10n.gardenWellnessStatWeeklyActive,
                      numericValue: summary.weeklyActivePercent,
                      icon: Icons.calendar_view_week_rounded,
                      suffix: '%',
                    ),
                  ),
                  const SizedBox(width: BotanicaTokens.spacingSm),
                  Expanded(
                    child: _StatCard(
                      label: l10n.gardenWellnessStatBestStreak,
                      numericValue: settings.longestStreak,
                      icon: Icons.emoji_events_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              BotanicaGlassCard(
                child: BotanicaStreakProgress(
                  currentStreak: settings.careStreakDays,
                ),
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _MomentumSection(
                plants: plantsAsync.requireValue,
                logs: logsAsync.requireValue,
                settings: settings,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _CareActivityHeatmap(logs: logsAsync.requireValue),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _AchievementsSection(
                plants: plantsAsync.requireValue,
                tasks: tasksAsync.requireValue,
                logs: logsAsync.requireValue,
                settings: settings,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              const CarePatternsCard(),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _CareRoutineSection(
                plants: plantsAsync.requireValue,
                logs: logsAsync.requireValue,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _DiversitySection(
                plants: plantsAsync.requireValue,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _CareConfidenceSection(
                plants: plantsAsync.requireValue,
                logs: logsAsync.requireValue,
                settings: settings,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _GardenLegacySection(
                plants: plantsAsync.requireValue,
                logs: logsAsync.requireValue,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _WateringBatchSection(
                plants: plantsAsync.requireValue,
                logs: logsAsync.requireValue,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _CareRhythmSection(logs: logsAsync.requireValue),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _NextActionSection(
                plants: plantsAsync.requireValue,
                tasks: tasksAsync.requireValue,
                logs: logsAsync.requireValue,
                settings: settings,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _GardenGoalSection(
                plants: plantsAsync.requireValue,
                logs: logsAsync.requireValue,
                settings: settings,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _CareImpactSection(
                plants: plantsAsync.requireValue,
                tasks: tasksAsync.requireValue,
                logs: logsAsync.requireValue,
              ),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _StreakLeaderboardSection(settings: settings, logs: logsAsync.requireValue),
              const SizedBox(height: BotanicaTokens.spacingBase),
              _RoomProfileSection(plants: plantsAsync.requireValue, logs: logsAsync.requireValue),
              const SizedBox(height: BotanicaTokens.spacingLg),
              if (roomPulse.isNotEmpty) ...[
                Text(
                  l10n.gardenWellnessRoomPulseTitle,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: BotanicaTokens.spacingSm),
                for (final room in roomPulse.take(3)) ...[
                  _RoomPulseCard(
                    key: ValueKey('room-pulse-${room.name}'),
                    room: room,
                    onTap: () => context.go(
                      Uri(
                        path: GardenScreen.location,
                        queryParameters: <String, String>{'room': room.name},
                      ).toString(),
                    ),
                  ),
                  const SizedBox(height: BotanicaTokens.spacingSm),
                ],
                const SizedBox(height: BotanicaTokens.spacingBase),
              ],
              Text(
                l10n.gardenWellnessPrioritiesTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: BotanicaTokens.spacingSm),
              for (final priority in priorities) ...[
                _PriorityCard(priority: priority, summary: summary),
                const SizedBox(height: BotanicaTokens.spacingSm),
              ],
              const SizedBox(height: BotanicaTokens.spacingBase),
              Text(
                l10n.gardenWellnessFocusPlantsTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: BotanicaTokens.spacingSm),
              for (final focus in summary.focusPlants.take(3)) ...[
                _FocusPlantCard(
                  key: ValueKey('focus-plant-${focus.plant.id}'),
                  focus: focus,
                  onTap: () => context.push(
                    '${GardenScreen.location}/plant/${focus.plant.id}',
                  ),
                ),
                const SizedBox(height: BotanicaTokens.spacingSm),
              ],
              const SizedBox(height: BotanicaTokens.spacingSm),
              BotanicaButton(
                expand: true,
                icon: Icons.calendar_month_rounded,
                label: l10n.tasksTitle,
                onPressed: () => context.push(
                    '${GardenScreen.location}/${TasksScreen.subLocation}'),
              ),
              const SizedBox(height: BotanicaTokens.spacingSm),
              BotanicaButton(
                expand: true,
                variant: BotanicaButtonVariant.outlined,
                icon: Icons.add_rounded,
                label: l10n.gardenQuickAddPlant,
                onPressed: () => context.push('${GardenScreen.location}/add'),
              ),
            ],
          ),
        );
      }
    }

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.gardenWellnessTitle),
      ),
      body: body,
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BotanicaTokens.spacingSm,
          vertical: BotanicaTokens.spacingXxs,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _RoomPulseCard extends StatelessWidget {
  const _RoomPulseCard({
    super.key,
    required this.room,
    this.onTap,
  });

  final GardenWellnessRoomPulseEntry room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _localizedRoomName(l10n, room.name),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: BotanicaTokens.spacingMicro),
                  Text(
                    l10n.gardenWellnessRoomPulseSummary(
                      room.plantCount,
                      room.overdueTasks,
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: BotanicaTokens.spacingSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${room.averageScore}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  room.atRiskPlants == 0
                      ? l10n.gardenWellnessRoomPulseStable
                      : l10n.gardenWellnessRoomPulseAtRisk(room.atRiskPlants),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({
    required this.priority,
    required this.summary,
  });

  final GardenWellnessPriority priority;
  final GardenWellnessSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primaryContainer.withValues(alpha: 0.28),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.42),
              ),
            ),
            child: Icon(
              _priorityIcon(priority.kind),
              color: scheme.onSurface.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(width: BotanicaTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _priorityTitle(l10n, priority, summary),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: BotanicaTokens.spacingXxs),
                Text(
                  _priorityBody(l10n, priority, summary),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.74),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.numericValue,
    required this.icon,
    this.suffix = '',
  });

  final String label;
  final int numericValue;
  final IconData icon;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.onSurface.withValues(alpha: 0.80)),
          const SizedBox(height: BotanicaTokens.spacingXs),
          BotanicaAnimatedCounter(
            value: numericValue,
            suffix: suffix,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusPlantCard extends StatelessWidget {
  const _FocusPlantCard({
    super.key,
    required this.focus,
    this.onTap,
  });

  final GardenFocusPlant focus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final coverAsset =
        focus.plant.coverAsset ?? 'assets/images/plant_placeholder.png';

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
              child: Image.asset(
                coverAsset,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
            const SizedBox(width: BotanicaTokens.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    focus.plant.nickname,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: BotanicaTokens.spacingMicro),
                  Text(
                    _localizedRoomName(l10n, focus.plant.room),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.60),
                    ),
                  ),
                  const SizedBox(height: BotanicaTokens.spacingXxs),
                  Text(
                    _focusReason(l10n, focus),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.76),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: BotanicaTokens.spacingSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${focus.score}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l10n.gardenWellnessScoreLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _priorityIcon(GardenWellnessPriorityKind kind) {
  return switch (kind) {
    GardenWellnessPriorityKind.attention => Icons.monitor_heart_rounded,
    GardenWellnessPriorityKind.dueToday => Icons.schedule_rounded,
    GardenWellnessPriorityKind.refreshHistory => Icons.edit_note_rounded,
    GardenWellnessPriorityKind.calm => Icons.spa_rounded,
  };
}

String _scoreDescriptor(AppLocalizations l10n, int score) {
  if (score >= 90) return l10n.gardenWellnessScoreFlourishing;
  if (score >= 80) return l10n.gardenWellnessScoreSteady;
  if (score >= 65) return l10n.gardenWellnessScoreNeedsLittleCare;
  return l10n.gardenWellnessScoreNeedsAttention;
}

String _localizedRoomName(AppLocalizations l10n, String room) {
  final trimmed = room.trim();
  if (trimmed.isEmpty || trimmed == 'Unassigned') {
    return l10n.gardenWellnessRoomUnassigned;
  }
  return trimmed;
}

String _priorityTitle(
  AppLocalizations l10n,
  GardenWellnessPriority priority,
  GardenWellnessSummary summary,
) {
  return switch (priority.kind) {
    GardenWellnessPriorityKind.attention =>
      l10n.gardenWellnessPriorityAttentionTitle(
        summary.focusPlants.first.plant.nickname,
      ),
    GardenWellnessPriorityKind.dueToday =>
      l10n.gardenWellnessPriorityDueTodayTitle,
    GardenWellnessPriorityKind.refreshHistory =>
      l10n.gardenWellnessPriorityRefreshHistoryTitle,
    GardenWellnessPriorityKind.calm => l10n.gardenWellnessPriorityCalmTitle,
  };
}

String _priorityBody(
  AppLocalizations l10n,
  GardenWellnessPriority priority,
  GardenWellnessSummary summary,
) {
  return switch (priority.kind) {
    GardenWellnessPriorityKind.attention => _attentionPriorityBody(
        l10n,
        summary.focusPlants.first,
      ),
    GardenWellnessPriorityKind.dueToday =>
      l10n.gardenWellnessPriorityDueTodayBody(summary.dueTodayTasks),
    GardenWellnessPriorityKind.refreshHistory =>
      l10n.gardenWellnessPriorityRefreshHistoryBody(
        summary.focusPlants
            .where((focusPlant) => !focusPlant.hasRecentLog)
            .length,
      ),
    GardenWellnessPriorityKind.calm => l10n.gardenWellnessPriorityCalmBody,
  };
}

String _attentionPriorityBody(
  AppLocalizations l10n,
  GardenFocusPlant focus,
) {
  if (focus.overdueTasks > 0 && !focus.hasRecentLog) {
    return l10n.gardenWellnessPriorityAttentionBodyOverdueAndNoLog(
      focus.overdueTasks,
    );
  }
  if (focus.overdueTasks > 0) {
    return l10n.gardenWellnessPriorityAttentionBodyOverdue(focus.overdueTasks);
  }
  if (!focus.hasRecentLog) {
    return l10n.gardenWellnessPriorityAttentionBodyNoLog;
  }
  return l10n.gardenWellnessPriorityAttentionBodyCheckIn;
}

String _focusReason(AppLocalizations l10n, GardenFocusPlant focus) {
  if (focus.overdueTasks > 0 && !focus.hasRecentLog) {
    return l10n.gardenWellnessFocusReasonOverdueAndNoLog(focus.overdueTasks);
  }
  if (focus.overdueTasks > 0) {
    return l10n.gardenWellnessFocusReasonOverdue(focus.overdueTasks);
  }
  if (!focus.hasRecentLog) {
    return l10n.gardenWellnessFocusReasonNoLog;
  }
  return l10n.gardenWellnessFocusReasonSteady;
}

class _CareActivityHeatmap extends StatelessWidget {
  const _CareActivityHeatmap({required this.logs});

  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const weeks = 12;
    const daysTotal = weeks * 7;

    final startDay = today.subtract(const Duration(days: daysTotal - 1));

    final dayCounts = <int, int>{};
    for (final log in logs) {
      final logDay = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );
      final diff = logDay.difference(startDay).inDays;
      if (diff >= 0 && diff < daysTotal) {
        dayCounts[diff] = (dayCounts[diff] ?? 0) + 1;
      }
    }

    final totalActions = dayCounts.values.fold<int>(0, (s, c) => s + c);
    final maxCount = dayCounts.values.fold<int>(1, (m, c) => c > m ? c : m);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.wellnessHeatmapTitle,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                l10n.wellnessHeatmapActions(totalActions),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.wellnessHeatmapSubtitle,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          Semantics(
            label: '${l10n.wellnessHeatmapTitle}, ${l10n.wellnessHeatmapSubtitle}, ${l10n.wellnessHeatmapActions(totalActions)}',
            child: SizedBox(
              height: 7 * 11.0 + 6 * 2,
              child: CustomPaint(
                size: const Size(double.infinity, 7 * 11.0 + 6 * 2),
                painter: _HeatmapPainter(
                  dayCounts: dayCounts,
                  maxCount: maxCount,
                  weeks: weeks,
                  startWeekday: startDay.weekday,
                  color: scheme.primary,
                  emptyColor: scheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.dayCounts,
    required this.maxCount,
    required this.weeks,
    required this.startWeekday,
    required this.color,
    required this.emptyColor,
  });

  final Map<int, int> dayCounts;
  final int maxCount;
  final int weeks;
  final int startWeekday;
  final Color color;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 2.0;
    final cellSize = (size.width - (weeks - 1) * gap) / weeks;
    final cellHeight = (size.height - 6 * gap) / 7;
    final radius = Radius.circular(cellSize * 0.25);

    for (int week = 0; week < weeks; week++) {
      for (int day = 0; day < 7; day++) {
        final dayIndex = week * 7 + day;
        final count = dayCounts[dayIndex] ?? 0;
        final fraction = count / maxCount;

        final x = week * (cellSize + gap);
        final y = day * (cellHeight + gap);

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cellSize, cellHeight),
          radius,
        );

        final paint = Paint()
          ..color = count > 0
              ? color.withValues(alpha: 0.2 + 0.8 * fraction)
              : emptyColor;

        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) =>
      dayCounts != oldDelegate.dayCounts || color != oldDelegate.color;
}

class _AchievementsSection extends ConsumerWidget {
  const _AchievementsSection({
    required this.plants,
    required this.tasks,
    required this.logs,
    required this.settings,
  });

  final List<Plant> plants;
  final List<TaskInstance> tasks;
  final List<CareLog> logs;
  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final photosAsync = ref.watch(photoEntriesStreamProvider);
    final photos = photosAsync.valueOrNull ?? const <PhotoEntry>[];

    final achievements = AchievementsEngine.compute(
      plants: plants,
      tasks: tasks,
      logs: logs,
      photos: photos,
      settings: settings,
    );

    final unlocked = achievements.where((a) => a.unlocked).toList();
    final locked = achievements.where((a) => !a.unlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.achievementsTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Text(
              l10n.achievementsUnlocked(unlocked.length, achievements.length),
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.60),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: BotanicaTokens.spacingSm),
        Wrap(
          spacing: BotanicaTokens.spacingXxs,
          runSpacing: BotanicaTokens.spacingXxs,
          children: [
            for (final a in unlocked)
              _AchievementBadge(achievement: a, unlocked: true),
            for (final a in locked)
              _AchievementBadge(achievement: a, unlocked: false),
          ],
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.achievement,
    required this.unlocked,
  });

  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final title = _achievementTitle(l10n, achievement.id);
    final desc = _achievementDesc(l10n, achievement.id);

    final tierColor = switch (achievement.tier) {
      AchievementTier.bronze => const Color(0xFFCD7F32),
      AchievementTier.silver => const Color(0xFFC0C0C0),
      AchievementTier.gold => const Color(0xFFFFD700),
    };

    final tierIcon = switch (achievement.tier) {
      AchievementTier.bronze => Icons.emoji_events_outlined,
      AchievementTier.silver => Icons.emoji_events_rounded,
      AchievementTier.gold => Icons.emoji_events_rounded,
    };

    return Tooltip(
      message: '$title\n$desc',
      child: Semantics(
        label: '$title — $desc — ${unlocked ? "unlocked" : "${(achievement.progressFraction * 100).round()}%"}',
        child: AnimatedOpacity(
          duration: BotanicaTokens.motionMedium,
          opacity: unlocked ? 1.0 : 0.38,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: unlocked
                  ? tierColor.withValues(alpha: 0.18)
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
              border: Border.all(
                color: unlocked
                    ? tierColor.withValues(alpha: 0.50)
                    : scheme.outlineVariant.withValues(alpha: 0.30),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  tierIcon,
                  size: 28,
                  color: unlocked
                      ? tierColor
                      : scheme.onSurface.withValues(alpha: 0.30),
                ),
                if (!unlocked)
                  Positioned(
                    bottom: 4,
                    child: SizedBox(
                      width: 36,
                      height: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: achievement.progressFraction,
                          backgroundColor:
                              scheme.outlineVariant.withValues(alpha: 0.30),
                          valueColor: AlwaysStoppedAnimation(
                            tierColor.withValues(alpha: 0.60),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _achievementTitle(AppLocalizations l10n, String id) {
  return switch (id) {
    'firstPlant' => l10n.achievementFirstPlant,
    'fivePlants' => l10n.achievementFivePlants,
    'tenPlants' => l10n.achievementTenPlants,
    'twentyPlants' => l10n.achievementTwentyPlants,
    'firstCare' => l10n.achievementFirstCare,
    'fiftyCares' => l10n.achievementFiftyCares,
    'hundredCares' => l10n.achievementHundredCares,
    'fiveHundredCares' => l10n.achievementFiveHundredCares,
    'weekStreak' => l10n.achievementWeekStreak,
    'monthStreak' => l10n.achievementMonthStreak,
    'yearStreak' => l10n.achievementYearStreak,
    'firstPhoto' => l10n.achievementFirstPhoto,
    'tenPhotos' => l10n.achievementTenPhotos,
    'fiftyPhotos' => l10n.achievementFiftyPhotos,
    'threeRooms' => l10n.achievementThreeRooms,
    'fiveRooms' => l10n.achievementFiveRooms,
    'diverseCarer' => l10n.achievementDiverseCarer,
    _ => id,
  };
}

String _achievementDesc(AppLocalizations l10n, String id) {
  return switch (id) {
    'firstPlant' => l10n.achievementFirstPlantDesc,
    'fivePlants' => l10n.achievementFivePlantsDesc,
    'tenPlants' => l10n.achievementTenPlantsDesc,
    'twentyPlants' => l10n.achievementTwentyPlantsDesc,
    'firstCare' => l10n.achievementFirstCareDesc,
    'fiftyCares' => l10n.achievementFiftyCaresDesc,
    'hundredCares' => l10n.achievementHundredCaresDesc,
    'fiveHundredCares' => l10n.achievementFiveHundredCaresDesc,
    'weekStreak' => l10n.achievementWeekStreakDesc,
    'monthStreak' => l10n.achievementMonthStreakDesc,
    'yearStreak' => l10n.achievementYearStreakDesc,
    'firstPhoto' => l10n.achievementFirstPhotoDesc,
    'tenPhotos' => l10n.achievementTenPhotosDesc,
    'fiftyPhotos' => l10n.achievementFiftyPhotosDesc,
    'threeRooms' => l10n.achievementThreeRoomsDesc,
    'fiveRooms' => l10n.achievementFiveRoomsDesc,
    'diverseCarer' => l10n.achievementDiverseCarerDesc,
    _ => '',
  };
}

// ---------------------------------------------------------------------------
// Momentum Section
// ---------------------------------------------------------------------------

class _MomentumSection extends StatelessWidget {
  const _MomentumSection({
    required this.plants,
    required this.logs,
    required this.settings,
  });

  final List<Plant> plants;
  final List<CareLog> logs;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();

    final momentum = GardenMomentumEngine.compute(
      plants: plants,
      logs: logs,
      streakDays: settings.careStreakDays,
      plantsAddedThisMonth: plants.where((p) =>
          p.createdAt.year == now.year &&
          p.createdAt.month == now.month).length,
      now: now,
    );

    return BotanicaGlassCard(
      child: Row(
        children: [
          BotanicaMomentumRing(
            score: momentum.score,
            size: 64,
            strokeWidth: 6,
            label: 'momentum',
          ),
          const SizedBox(width: BotanicaTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garden Momentum',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  momentum.encouragement,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
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

// ---------------------------------------------------------------------------
// Care Routine Section
// ---------------------------------------------------------------------------

class _CareRoutineSection extends StatelessWidget {
  const _CareRoutineSection({
    required this.plants,
    required this.logs,
  });

  final List<Plant> plants;
  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.length < 10) return const SizedBox.shrink();

    final result = CareRoutineDetector.analyze(
      plants: plants,
      logs: logs,
      now: DateTime.now(),
    );

    return BotanicaCareRoutineCard(result: result);
  }
}

// ---------------------------------------------------------------------------
// Diversity Section
// ---------------------------------------------------------------------------

class _DiversitySection extends StatelessWidget {
  const _DiversitySection({required this.plants});

  final List<Plant> plants;

  @override
  Widget build(BuildContext context) {
    if (plants.where((p) => !p.isArchived).length < 2) {
      return const SizedBox.shrink();
    }

    final metrics = GardenDiversityEngine.compute(
      plants: plants,
      speciesLight: const {},
      speciesDifficulty: const {},
    );

    return BotanicaDiversityCard(metrics: metrics);
  }
}

// ---------------------------------------------------------------------------
// Care Confidence Section
// ---------------------------------------------------------------------------

class _CareConfidenceSection extends StatelessWidget {
  const _CareConfidenceSection({
    required this.plants,
    required this.logs,
    required this.settings,
  });

  final List<Plant> plants;
  final List<CareLog> logs;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    if (plants.where((p) => !p.isArchived).isEmpty || logs.length < 5) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final healthScores = <String, double>{};
    for (final p in plants.where((p) => !p.isArchived)) {
      final plantLogs = logs.where((l) => l.plantId == p.id).toList();
      healthScores[p.id] = plantLogs.isEmpty ? 0.5 : 0.7;
    }

    final totalDaysActive = plants.isNotEmpty
        ? now.difference(plants.map((p) => p.createdAt).reduce(
            (a, b) => a.isBefore(b) ? a : b)).inDays
        : 0;

    final report = CareConfidenceEngine.assess(
      plants: plants,
      logs: logs,
      healthScores: healthScores,
      streakDays: settings.careStreakDays,
      totalDaysActive: totalDaysActive,
      now: now,
    );

    return BotanicaCareConfidenceRadar(report: report);
  }
}

// ---------------------------------------------------------------------------
// Garden Legacy Section
// ---------------------------------------------------------------------------

class _GardenLegacySection extends StatelessWidget {
  const _GardenLegacySection({
    required this.plants,
    required this.logs,
  });

  final List<Plant> plants;
  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    if (plants.where((p) => !p.isArchived).length < 2) {
      return const SizedBox.shrink();
    }

    final report = GardenLegacyEngine.compute(
      plants: plants,
      logs: logs,
      now: DateTime.now(),
    );

    final nameMap = {for (final p in plants) p.id: p.nickname};

    return BotanicaGardenLegacyCard(
      report: report,
      plantNameResolver: (id) => nameMap[id] ?? id.substring(0, 8),
    );
  }
}

// ---------------------------------------------------------------------------
// Watering Batch Section
// ---------------------------------------------------------------------------

class _WateringBatchSection extends StatelessWidget {
  const _WateringBatchSection({
    required this.plants,
    required this.logs,
  });

  final List<Plant> plants;
  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    if (plants.where((p) => !p.isArchived).length < 3) {
      return const SizedBox.shrink();
    }

    final plan = WateringBatchPlanner.plan(
      plants: plants,
      speciesWaterDays: const {},
      logs: logs,
      now: DateTime.now(),
    );

    final nameMap = {for (final p in plants) p.id: p.nickname};

    return BotanicaWateringBatchCard(
      plan: plan,
      plantNameResolver: (id) => nameMap[id] ?? id.substring(0, 8),
    );
  }
}

// ---------------------------------------------------------------------------
// Care Rhythm Section
// ---------------------------------------------------------------------------

class _CareRhythmSection extends StatelessWidget {
  const _CareRhythmSection({required this.logs});

  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    final rhythm = CareRhythmEngine.detect(
      logs: logs,
      now: DateTime.now(),
    );

    if (rhythm == null) return const SizedBox.shrink();

    return BotanicaCareRhythmCard(rhythm: rhythm);
  }
}

// ---------------------------------------------------------------------------
// Next Action Section
// ---------------------------------------------------------------------------

class _NextActionSection extends StatelessWidget {
  const _NextActionSection({
    required this.plants,
    required this.tasks,
    required this.logs,
    required this.settings,
  });

  final List<Plant> plants;
  final List<TaskInstance> tasks;
  final List<CareLog> logs;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final action = NextActionRecommender.recommend(
      plants: plants,
      tasks: tasks,
      logs: logs,
      settings: settings,
      now: DateTime.now(),
    );

    return BotanicaNextActionCard(action: action);
  }
}

// ---------------------------------------------------------------------------
// Garden Goal Section
// ---------------------------------------------------------------------------

class _GardenGoalSection extends StatelessWidget {
  const _GardenGoalSection({
    required this.plants,
    required this.logs,
    required this.settings,
  });

  final List<Plant> plants;
  final List<CareLog> logs;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final goals = GardenGoalEngine.suggestGoals(
      plants: plants,
      logs: logs,
      streakDays: settings.careStreakDays,
      now: DateTime.now(),
    );

    return BotanicaGardenGoalCard(goals: goals);
  }
}

// ---------------------------------------------------------------------------
// Care Impact Section
// ---------------------------------------------------------------------------

class _CareImpactSection extends StatelessWidget {
  const _CareImpactSection({
    required this.plants,
    required this.tasks,
    required this.logs,
  });

  final List<Plant> plants;
  final List<TaskInstance> tasks;
  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    final summary = CareImpactAnalyzer.analyze(
      plants: plants,
      logs: logs,
      tasks: tasks,
      now: DateTime.now(),
    );

    if (summary == null) return const SizedBox.shrink();

    return BotanicaCareImpactCard(summary: summary);
  }
}

// ---------------------------------------------------------------------------
// Streak Leaderboard Section
// ---------------------------------------------------------------------------

class _StreakLeaderboardSection extends StatelessWidget {
  const _StreakLeaderboardSection({
    required this.settings,
    required this.logs,
  });

  final UserSettings settings;
  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    if (settings.careStreakDays < 3) return const SizedBox.shrink();

    final result = StreakLeaderboardEngine.compute(
      userStreakDays: settings.careStreakDays,
      userCareActions: logs.length,
      userDisplayName: 'You',
      simulatedParticipants: 50,
    );

    return BotanicaStreakLeaderboardCard(result: result);
  }
}

// ---------------------------------------------------------------------------
// Room Profile Section
// ---------------------------------------------------------------------------

class _RoomProfileSection extends StatelessWidget {
  const _RoomProfileSection({
    required this.plants,
    required this.logs,
  });

  final List<Plant> plants;
  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 2) return const SizedBox.shrink();

    final profiles = RoomMicroclimateProfiler.profile(
      plants: plants,
      species: const [],
      logs: logs,
      healthScores: {for (final p in activePlants) p.id: 0.7},
      now: DateTime.now(),
    );

    return BotanicaRoomProfileCard(profiles: profiles);
  }
}
