import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/services/garden_wellness_priorities.dart';
import '../../domain/services/garden_wellness_room_pulse.dart';
import '../../domain/services/garden_wellness_summary.dart';
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
                              Text(
                                '${summary.overallScore}',
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
                      value: '${summary.plantCount}',
                      icon: Icons.local_florist_rounded,
                    ),
                  ),
                  const SizedBox(width: BotanicaTokens.spacingSm),
                  Expanded(
                    child: _StatCard(
                      label: l10n.gardenWellnessStatRecentCare,
                      value: '${summary.recentlyCaredPlants}',
                      icon: Icons.history_rounded,
                    ),
                  ),
                  const SizedBox(width: BotanicaTokens.spacingSm),
                  Expanded(
                    child: _StatCard(
                      label: l10n.gardenWellnessStatAtRisk,
                      value: '${summary.atRiskPlants}',
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                ],
              ),
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
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
          Text(
            value,
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
