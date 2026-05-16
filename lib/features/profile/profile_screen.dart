import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/utils/motion_preferences.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_streak_badge.dart';
import '../../core/widgets/botanica_care_persona_card.dart';
import '../../core/widgets/botanica_care_impact_card.dart';
import '../../core/widgets/botanica_care_pattern_card.dart';
import '../../core/widgets/botanica_achievement_card.dart';
import '../../core/widgets/botanica_garden_goal_card.dart';
import '../../core/widgets/botanica_habit_predictor_card.dart';
import '../../core/widgets/botanica_care_consistency_card.dart';
import '../../core/widgets/botanica_garden_legacy_card.dart';
import '../../core/widgets/botanica_garden_stats_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_title.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/photo_entry.dart';
import '../../domain/models/task_instance.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/care/care_data_exporter.dart';
import '../../domain/services/plant_whisperer_score.dart';
import '../../domain/services/garden_stats_engine.dart';
import '../../domain/services/care_impact_analyzer.dart';
import '../../domain/services/care_pattern_analyzer.dart';
import '../../domain/services/care_habit_predictor.dart';
import '../../domain/services/care_consistency_scorer.dart';
import '../../domain/services/garden_achievement_engine.dart';
import '../../domain/services/garden_goal_engine.dart';
import '../../domain/services/garden_legacy_engine.dart';
import '../../domain/services/user_care_persona_engine.dart';
import 'ai_settings_section.dart';
import 'credits_screen.dart';
import 'daily_profile_section.dart';
import 'garden_wellness_screen.dart';
import 'permissions_section.dart';
import 'preferences_section.dart';
import 'storage_health_screen.dart';
import 'streak_share_card_screen.dart';
import 'widgets/profile_section_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String location = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final settings = ref.watch(settingsControllerProvider);
    final plantsAsync = ref.watch(plantsStreamProvider);
    final plants = plantsAsync.valueOrNull ?? const [];
    final plantCount = plants.length;

    final gardenAgeDays = plants.isEmpty
        ? 0
        : DateTime.now()
            .difference(plants
                .map((p) => p.createdAt)
                .reduce((a, b) => a.isBefore(b) ? a : b))
            .inDays;

    return SafeArea(
      child: ListView(
        padding: BotanicaTokens.pagePaddingWithBottomNav(context),
        children: [
          BotanicaScreenTitle(l10n.navProfile)
              .animateSection(index: 0),
          const SizedBox(height: BotanicaTokens.spacingBase),
          if (settings.careStreakDays > 0 || plantCount > 0)
            Semantics(
              button: true,
              label: '${l10n.gardenCareStreakChip(settings.careStreakDays)}, $plantCount plants. ${l10n.gardenWellnessTitle}',
              child: GestureDetector(
                onTap: () => context.push(
                  '${ProfileScreen.location}/${GardenWellnessScreen.subLocation}',
                ),
                onLongPress: settings.careStreakDays > 0
                    ? () => StreakShareCardScreen.open(
                          context,
                          streakDays: settings.careStreakDays,
                          plantCount: plantCount,
                        )
                    : null,
                child: BotanicaGlassCard(
                  child: Row(
                    children: [
                      BotanicaStreakBadge(
                        streakDays: settings.careStreakDays,
                        size: 52,
                      ),
                      const SizedBox(width: BotanicaTokens.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.gardenCareStreakChip(settings.careStreakDays),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.profilePlantsInGarden(plantCount),
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            if (settings.longestStreak > settings.careStreakDays) ...[
                              const SizedBox(height: 2),
                              Text(
                                l10n.profileLongestStreak(settings.longestStreak),
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.tertiary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (gardenAgeDays > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                l10n.profileGardenAge(gardenAgeDays),
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                            if (settings.streakFreezeCount > 0) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.ac_unit_rounded,
                                    size: 12,
                                    color: scheme.primary.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.profileStreakFreezes(settings.streakFreezeCount),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.primary.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ).animateSection(index: 1),
          if (settings.careStreakDays > 0 || plantCount > 0)
            const SizedBox(height: BotanicaTokens.spacingSm),
          if (settings.careStreakDays > 0 || plantCount > 0)
            _CareStatsRow().animateSection(index: 2),
          if (settings.careStreakDays > 0 || plantCount > 0)
            const SizedBox(height: BotanicaTokens.spacingSm),
          if (settings.careStreakDays > 0 || plantCount > 0)
            const _CareScoreCard().animateSection(index: 3),
          if (settings.careStreakDays > 0 || plantCount > 0)
            const SizedBox(height: BotanicaTokens.spacingSm),
          if (settings.careStreakDays > 0 || plantCount > 0)
            const _WhispererLevelCard().animateSection(index: 4),
          if (settings.careStreakDays > 0 || plantCount > 0)
            const SizedBox(height: BotanicaTokens.spacingSm),
          const _GardenerTypeCard().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingSm),
          const _CarePersonaSection().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingSm),
          const _GardenStatsSection().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingSm),
          const _CareImpactSection().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingSm),
          const _GardenLegacySection().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingSm),
          const _CarePatternSection().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingSm),
          const _AchievementSection().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingSm),
          const _GardenGoalSection().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingSm),
          const _HabitPredictorSection().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingSm),
          const _CareConsistencySection().animateSection(index: 5),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const PreferencesSection().animateSection(index: 6),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const DailyProfileSection().animateSection(index: 7),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const AiSettingsSection().animateSection(index: 8),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          const PermissionsSection().animateSection(index: 9),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSectionLabel(label: l10n.profileSectionData),
              const SizedBox(height: BotanicaTokens.spacingSm),
              BotanicaGlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ProfileTile(
                      icon: Icons.storage_rounded,
                      title: l10n.storageHealthTitle,
                      subtitle: l10n.storageHealthSubtitle,
                      onTap: () => context.push(
                        '${ProfileScreen.location}/${StorageHealthScreen.subLocation}',
                      ),
                    ),
                    ProfileDivider(
                        color:
                            scheme.outlineVariant.withValues(alpha: 0.35)),
                    ProfileTile(
                      icon: Icons.ios_share_rounded,
                      title: l10n.exportDataTitle,
                      subtitle: l10n.exportDataSubtitle,
                      onTap: () => _exportCareData(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          ).animateSection(index: 10),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSectionLabel(label: l10n.profileSectionAbout),
              const SizedBox(height: BotanicaTokens.spacingSm),
              BotanicaGlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ProfileTile(
                      icon: Icons.monitor_heart_rounded,
                      title: l10n.gardenWellnessTitle,
                      subtitle: l10n.gardenWellnessSubtitle,
                      onTap: () => context.push(
                        '${ProfileScreen.location}/${GardenWellnessScreen.subLocation}',
                      ),
                    ),
                    ProfileDivider(
                        color:
                            scheme.outlineVariant.withValues(alpha: 0.35)),
                    ProfileTile(
                      icon: Icons.favorite_rounded,
                      title: l10n.profileCredits,
                      subtitle: l10n.creditsOpenSource,
                      onTap: () => context.push(
                        '${ProfileScreen.location}/${CreditsScreen.subLocation}',
                      ),
                    ),
                    ProfileDivider(
                        color:
                            scheme.outlineVariant.withValues(alpha: 0.35)),
                    ProfileTile(
                      icon: Icons.info_rounded,
                      title: l10n.commonAbout,
                      subtitle: l10n.appName,
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
              ),
            ],
          ).animateSection(index: 11),
        ],
      ),
    );
  }
}

void _showAbout(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showAboutDialog(
    context: context,
    applicationName: l10n.appName,
    applicationVersion: '1.0.0',
    applicationIcon: Icon(
      Icons.local_florist_rounded,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    ),
    children: [
      Text(
        l10n.appTagline,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );
}

Future<void> _exportCareData(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final plants = ref.read(plantsRepositoryProvider).getAll();
  final logs = ref.read(logsRepositoryProvider).all();
  final tasks = ref.read(tasksRepositoryProvider).getAll();

  if (plants.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.exportDataEmpty),
      ),
    );
    return;
  }

  // Show confirmation dialog before exporting.
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.exportDataConfirmTitle),
      content: Text(l10n.exportDataConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.exportDataConfirmAction),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  if (!context.mounted) return;

  final success = await CareDataExporter.export(
    plants: plants,
    logs: logs,
    tasks: tasks,
  );

  if (!context.mounted) return;
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.exportDataSuccess)),
          ],
        ),
      ),
    );
  }
}

class _CareStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logsAsync = ref.watch(careLogsStreamProvider);
    final logs = logsAsync.valueOrNull ?? [];

    final totalCount = logs.length;
    final waterCount =
        logs.where((l) => l.type == TaskType.water).length;
    final fertilizeCount =
        logs.where((l) => l.type == TaskType.fertilize).length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.eco_rounded,
            label: l10n.profileStatsTotalCare,
            count: totalCount,
            formatter: (n) => l10n.profileStatsActions(n),
          ),
        ),
        const SizedBox(width: BotanicaTokens.spacingSm),
        Expanded(
          child: _StatCard(
            icon: Icons.water_drop_rounded,
            label: l10n.profileStatsWatered,
            count: waterCount,
            formatter: (n) => l10n.profileStatsActions(n),
          ),
        ),
        const SizedBox(width: BotanicaTokens.spacingSm),
        Expanded(
          child: _StatCard(
            icon: Icons.grass_rounded,
            label: l10n.profileStatsFertilized,
            count: fertilizeCount,
            formatter: (n) => l10n.profileStatsActions(n),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.formatter,
  });

  final IconData icon;
  final String label;
  final int count;
  final String Function(int) formatter;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasAnimated && !botanicaReduceMotion(context)) {
      _hasAnimated = true;
      _controller.forward();
    } else if (!_hasAnimated) {
      _hasAnimated = true;
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count && !botanicaReduceMotion(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
      child: Column(
        children: [
          Icon(widget.icon, size: 20, color: scheme.primary),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final displayCount =
                  (_animation.value * widget.count).round();
              return Text(
                widget.formatter(displayCount),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            widget.label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CareScoreCard extends ConsumerWidget {
  const _CareScoreCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tasksAsync = ref.watch(tasksStreamProvider);
    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final fifteenDaysAgo = now.subtract(const Duration(days: 15));

    final recentTasks = tasks.where((t) {
      return t.dueAt.isAfter(thirtyDaysAgo) && t.dueAt.isBefore(now);
    }).toList();

    final totalDue = recentTasks.length;
    final completedOnTime = recentTasks.where((t) {
      if (t.status != TaskStatus.done || t.completedAt == null) return false;
      final dueDay = DateTime(t.dueAt.year, t.dueAt.month, t.dueAt.day);
      final doneDay = DateTime(
        t.completedAt!.year,
        t.completedAt!.month,
        t.completedAt!.day,
      );
      return !doneDay.isAfter(dueDay);
    }).length;

    final score = totalDue == 0 ? 0 : (completedOnTime * 100 ~/ totalDue);
    final progress = totalDue == 0 ? 0.0 : completedOnTime / totalDue;

    if (totalDue == 0) return const SizedBox.shrink();

    // Compute trend: compare last 15 days vs previous 15 days
    int onTimeRate(List<TaskInstance> subset) {
      if (subset.isEmpty) return -1;
      final onTime = subset.where((t) {
        if (t.status != TaskStatus.done || t.completedAt == null) return false;
        final dueDay = DateTime(t.dueAt.year, t.dueAt.month, t.dueAt.day);
        final doneDay = DateTime(
          t.completedAt!.year,
          t.completedAt!.month,
          t.completedAt!.day,
        );
        return !doneDay.isAfter(dueDay);
      }).length;
      return onTime * 100 ~/ subset.length;
    }

    final recentHalf = recentTasks.where((t) => t.dueAt.isAfter(fifteenDaysAgo)).toList();
    final olderHalf = recentTasks.where((t) => !t.dueAt.isAfter(fifteenDaysAgo)).toList();
    final recentRate = onTimeRate(recentHalf);
    final olderRate = onTimeRate(olderHalf);

    final trendDelta = (recentRate >= 0 && olderRate >= 0) ? recentRate - olderRate : 0;

    final ringColor = score >= 80
        ? const Color(0xFF4CAF50)
        : score >= 50
            ? const Color(0xFFFF9800)
            : const Color(0xFFE53935);

    return BotanicaGlassCard(
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: _AnimatedScoreRing(
              progress: progress,
              color: ringColor,
              score: score,
            ),
          ),
          const SizedBox(width: BotanicaTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.profileCareScore,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (trendDelta != 0) ...[
                      const SizedBox(width: 6),
                      Icon(
                        trendDelta > 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 16,
                        color: trendDelta > 0
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.profileCareScoreSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                if (totalDue > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$completedOnTime / $totalDue',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedScoreRing extends StatefulWidget {
  const _AnimatedScoreRing({
    required this.progress,
    required this.color,
    required this.score,
  });

  final double progress;
  final Color color;
  final int score;

  @override
  State<_AnimatedScoreRing> createState() => _AnimatedScoreRingState();
}

class _AnimatedScoreRingState extends State<_AnimatedScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!botanicaReduceMotion(context)) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedProgress = _animation.value * widget.progress;
        final animatedScore = (_animation.value * widget.score).round();
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                value: animatedProgress,
                strokeWidth: 5,
                backgroundColor: widget.color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(widget.color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '$animatedScore%',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _GardenerType { devoted, consistent, explorer, photographer, nurturer, budding }

_GardenerType _determineGardenerType({
  required int streakDays,
  required int onTimePercent,
  required int uniqueSpecies,
  required int photoCount,
  required int totalLogs,
}) {
  if (streakDays >= 30) return _GardenerType.devoted;
  if (onTimePercent >= 80) return _GardenerType.consistent;
  if (uniqueSpecies >= 5) return _GardenerType.explorer;
  if (photoCount >= 10) return _GardenerType.photographer;
  if (totalLogs >= 50) return _GardenerType.nurturer;
  return _GardenerType.budding;
}

class _WhispererLevelCard extends ConsumerWidget {
  const _WhispererLevelCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final score = ref.watch(plantWhispererScoreProvider);

    final tierName = switch (score.tier) {
      WhispererTier.seedling => l10n.whispererTierSeedling,
      WhispererTier.sprout => l10n.whispererTierSprout,
      WhispererTier.gardener => l10n.whispererTierGardener,
      WhispererTier.botanist => l10n.whispererTierBotanist,
      WhispererTier.whisperer => l10n.whispererTierWhisperer,
    };

    final tierIcon = switch (score.tier) {
      WhispererTier.seedling => Icons.grass_rounded,
      WhispererTier.sprout => Icons.spa_rounded,
      WhispererTier.gardener => Icons.yard_rounded,
      WhispererTier.botanist => Icons.park_rounded,
      WhispererTier.whisperer => Icons.auto_awesome_rounded,
    };

    final nextTier = score.tier.next;
    final nextXp = nextTier?.xpThreshold ?? score.xp;

    return BotanicaGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tierIcon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tierName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${score.xp} XP',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
            child: LinearProgressIndicator(
              value: score.progressToNext,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
          if (nextTier != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.whispererNextLevel(nextXp - score.xp),
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GardenerTypeCard extends ConsumerWidget {
  const _GardenerTypeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final settings = ref.watch(settingsControllerProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];
    final plantsAsync = ref.watch(plantsStreamProvider);
    final plants = plantsAsync.valueOrNull ?? const [];
    final photosAsync = ref.watch(photoEntriesStreamProvider);
    final photos = photosAsync.valueOrNull ?? const <PhotoEntry>[];
    final logsAsync = ref.watch(careLogsStreamProvider);
    final logs = logsAsync.valueOrNull ?? const [];

    // On-time rate calculation
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentTasks = tasks
        .where((t) => t.dueAt.isAfter(thirtyDaysAgo) && t.dueAt.isBefore(now))
        .toList();
    final totalDue = recentTasks.length;
    final completedOnTime = recentTasks.where((t) {
      if (t.status != TaskStatus.done || t.completedAt == null) return false;
      final dueDay = DateTime(t.dueAt.year, t.dueAt.month, t.dueAt.day);
      final doneDay = DateTime(
        t.completedAt!.year,
        t.completedAt!.month,
        t.completedAt!.day,
      );
      return !doneDay.isAfter(dueDay);
    }).length;
    final onTimePercent =
        totalDue == 0 ? 0 : (completedOnTime * 100 ~/ totalDue);

    final uniqueSpecies = plants.map((p) => p.speciesId).toSet().length;

    final type = _determineGardenerType(
      streakDays: settings.careStreakDays,
      onTimePercent: onTimePercent,
      uniqueSpecies: uniqueSpecies,
      photoCount: photos.length,
      totalLogs: logs.length,
    );

    final IconData typeIcon;
    final String typeName;
    final String typeDesc;

    switch (type) {
      case _GardenerType.devoted:
        typeIcon = Icons.favorite_rounded;
        typeName = l10n.gardenerTypeDevoted;
        typeDesc = l10n.gardenerTypeDevotedDesc;
      case _GardenerType.consistent:
        typeIcon = Icons.verified_rounded;
        typeName = l10n.gardenerTypeConsistent;
        typeDesc = l10n.gardenerTypeConsistentDesc;
      case _GardenerType.explorer:
        typeIcon = Icons.explore_rounded;
        typeName = l10n.gardenerTypeExplorer;
        typeDesc = l10n.gardenerTypeExplorerDesc;
      case _GardenerType.photographer:
        typeIcon = Icons.photo_library_rounded;
        typeName = l10n.gardenerTypePhotographer;
        typeDesc = l10n.gardenerTypePhotographerDesc;
      case _GardenerType.nurturer:
        typeIcon = Icons.spa_rounded;
        typeName = l10n.gardenerTypeNurturer;
        typeDesc = l10n.gardenerTypeNurturerDesc;
      case _GardenerType.budding:
        typeIcon = Icons.eco_rounded;
        typeName = l10n.gardenerTypeBudding;
        typeDesc = l10n.gardenerTypeBuddingDesc;
    }

    return BotanicaGlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primaryContainer,
                  scheme.tertiaryContainer,
                ],
              ),
            ),
            child: Icon(typeIcon, size: 24, color: scheme.primary),
          ),
          const SizedBox(width: BotanicaTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.gardenerTypeTitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  typeName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  typeDesc,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
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

// ---------------------------------------------------------------------------
// Care Persona Section
// ---------------------------------------------------------------------------

class _CarePersonaSection extends ConsumerWidget {
  const _CarePersonaSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final plantsAsync = ref.watch(plantsStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);

    final plants = plantsAsync.valueOrNull ?? const <Plant>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (plants.isEmpty || logs.length < 5) return const SizedBox.shrink();

    final now = DateTime.now();
    final firstPlant = plants
        .map((p) => p.createdAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final totalDaysActive = now.difference(firstPlant).inDays;

    final persona = UserCarePersonaEngine.analyze(
      plants: plants,
      logs: logs,
      streakDays: settings.careStreakDays,
      totalDaysActive: totalDaysActive,
      now: now,
    );

    return BotanicaCarePersonaCard(persona: persona);
  }
}

class _GardenStatsSection extends ConsumerWidget {
  const _GardenStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (plants.where((p) => !p.isArchived).length < 2 || logs.length < 5) {
      return const SizedBox.shrink();
    }

    final stats = GardenStatsEngine.compute(
      plants: plants,
      logs: logs,
      now: DateTime.now(),
    );

    if (stats.isEmpty) return const SizedBox.shrink();

    return BotanicaGardenStatsCard(stats: stats);
  }
}

class _CareImpactSection extends ConsumerWidget {
  const _CareImpactSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];

    if (logs.length < 10) return const SizedBox.shrink();

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

class _GardenLegacySection extends ConsumerWidget {
  const _GardenLegacySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (plants.where((p) => !p.isArchived).length < 2) {
      return const SizedBox.shrink();
    }

    final report = GardenLegacyEngine.compute(
      plants: plants,
      logs: logs,
      now: DateTime.now(),
    );

    String nameResolver(String id) {
      final plant = plants.where((p) => p.id == id).firstOrNull;
      return plant?.nickname ?? id.substring(0, 8);
    }

    return BotanicaGardenLegacyCard(
      report: report,
      plantNameResolver: nameResolver,
    );
  }
}

class _CarePatternSection extends ConsumerWidget {
  const _CarePatternSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (logs.length < 15) return const SizedBox.shrink();

    final patterns = CarePatternAnalyzer.analyze(
      plants: plants,
      logs: logs,
      now: DateTime.now(),
    );

    return BotanicaCarePatternCard(patterns: patterns);
  }
}

class _AchievementSection extends ConsumerWidget {
  const _AchievementSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);
    final photosAsync = ref.watch(photoEntriesStreamProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final photos = photosAsync.valueOrNull ?? const <PhotoEntry>[];
    final settings = settingsAsync;

    if (plants.isEmpty || logs.length < 5) return const SizedBox.shrink();

    final summary = GardenAchievementEngine.compute(
      plants: plants,
      logs: logs,
      photos: photos,
      streakDays: settings.careStreakDays,
      longestStreak: settings.longestStreak,
      now: DateTime.now(),
    );

    if (summary.unlockedCount == 0) return const SizedBox.shrink();

    return BotanicaAchievementCard(summary: summary);
  }
}

class _GardenGoalSection extends ConsumerWidget {
  const _GardenGoalSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final settings = settingsAsync;

    if (plants.isEmpty) return const SizedBox.shrink();

    final goals = GardenGoalEngine.suggestGoals(
      plants: plants,
      logs: logs,
      streakDays: settings.careStreakDays,
      now: DateTime.now(),
    );

    if (goals.isEmpty) return const SizedBox.shrink();

    return BotanicaGardenGoalCard(goals: goals);
  }
}

class _HabitPredictorSection extends ConsumerWidget {
  const _HabitPredictorSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(careLogsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];

    if (logs.length < 14) return const SizedBox.shrink();

    final profile = CareHabitPredictor.predict(
      logs: logs,
      tasks: tasks,
      now: DateTime.now(),
    );

    return BotanicaHabitPredictorCard(profile: profile);
  }
}

class _CareConsistencySection extends ConsumerWidget {
  const _CareConsistencySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsStreamProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final tasks = tasksAsync.valueOrNull ?? const <TaskInstance>[];

    final active = plants.where((p) => !p.isArchived).toList();
    if (active.length < 2 || logs.length < 10) return const SizedBox.shrink();

    final results = CareConsistencyScorer.scoreAll(
      plants: active,
      tasks: tasks,
      logs: logs,
      now: DateTime.now(),
    );

    if (results.isEmpty) return const SizedBox.shrink();

    return BotanicaCareConsistencyCard(results: results);
  }
}

