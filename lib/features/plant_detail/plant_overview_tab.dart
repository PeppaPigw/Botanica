import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_text_styles.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/widgets/botanica_ai_note_card.dart';
import '../../core/widgets/botanica_animated_counter.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_emotional_bond_indicator.dart';
import '../../core/widgets/botanica_predictive_needs_card.dart';
import '../../core/widgets/botanica_plant_story_card.dart';
import '../../core/widgets/botanica_plant_personality_card.dart';
import '../../core/widgets/botanica_health_breakdown_sheet.dart';
import '../../core/haptics/botanica_haptics.dart';
import '../../core/utils/motion_preferences.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/photo_entry.dart';
import '../../domain/services/plant_care_streak.dart';
import '../../domain/services/care_prediction_engine.dart';
import '../../domain/services/emotional_bond_engine.dart';
import '../../domain/services/predictive_needs_engine.dart';
import '../../domain/services/plant_story_engine.dart';
import '../../domain/services/plant_personality_engine.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_idea.dart';
import '../../domain/models/species.dart';
import '../../domain/models/task_instance.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/ai/ai_providers.dart';
import '../../core/i18n/task_labels.dart';
import '../../core/widgets/care_transparency_card.dart';
import 'widgets/manage_care_sheet.dart';
import 'widgets/plant_detail_pill.dart';
import 'widgets/plant_forecast_card.dart';

class PlantOverviewTab extends ConsumerWidget {
  const PlantOverviewTab({
    super.key,
    required this.plant,
    required this.nextTasks,
  });

  final Plant plant;
  final List<TaskInstance> nextTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final healthScoreAsync = ref.watch(plantHealthScoreProvider(plant.id));

    final speciesRepo = ref.read(speciesRepositoryProvider);
    final ideaRepo = ref.read(plantIdeaRepositoryProvider);
    final localeCode = ref.watch(settingsControllerProvider).localeCode ?? 'en';

    return ListView(
      padding: BotanicaTokens.pagePadding.copyWith(bottom: 120),
      children: [
        FutureBuilder(
          future: () async {
            final species = await speciesRepo.byId(plant.speciesId);
            final idea = await ideaRepo.byId(plant.speciesId);
            return (species, idea);
          }(),
          builder: (context, snapshot) {
            final species = snapshot.data?.$1;
            final idea = snapshot.data?.$2;
            final title = species?.bestCommonName(localeCode) ??
                idea?.bestCommonName(localeCode) ??
                plant.speciesId;
            final scientific = species?.scientificName ?? idea?.scientificName;
            final habit = species?.habit(localeCode) ?? idea?.habit(localeCode);
            final history =
                species?.history(localeCode) ?? idea?.history(localeCode);
            final imageCandidate =
                (species?.imagePath ?? idea?.imagePath ?? '').trim();
            final image = imageCandidate.isEmpty
                ? 'assets/images/placeholder_plant.jpg'
                : imageCandidate;

            final canOpenSpecies = species != null || idea != null;

            final healthGauge = Semantics(
              button: true,
              label: l10n.plantDetailHealthScore,
              child: GestureDetector(
                onTap: () {
                  BotanicaHaptics.selectionTick();
                  BotanicaHealthBreakdownSheet.show(
                    context,
                    plantId: plant.id,
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: healthScoreAsync.when(
                  data: (score) => _HealthScoreGauge(score: score),
                  loading: () => const _HealthScoreGauge(score: null),
                  error: (_, __) => const _HealthScoreGauge(score: null),
                ),
              ),
            );

            final header = InkWell(
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
              onTap: canOpenSpecies
                  ? () => context.push('/discover/species/${plant.speciesId}')
                  : null,
              child: BotanicaGlassCard(
                padding: BotanicaTokens.cardPaddingDense,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(BotanicaTokens.radiusL),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Image.asset(
                              image,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/placeholder_plant.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        BotanicaGaps.hSm,
                        healthGauge,
                        BotanicaGaps.hSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: context.tsTitle,
                              ),
                              if (scientific != null &&
                                  scientific.trim().isNotEmpty) ...[
                                BotanicaGaps.vMicro,
                                Text(
                                  scientific.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.tsBodyMuted.copyWith(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.65,
                                    ),
                                  ),
                                ),
                              ],
                              if (habit != null && habit.trim().isNotEmpty) ...[
                                BotanicaGaps.vTiny,
                                Text(
                                  habit.trim(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.tsBodyMuted.copyWith(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.72,
                                    ),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (canOpenSpecies) ...[
                          BotanicaGaps.hXs,
                          Icon(
                            Icons.chevron_right_rounded,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ],
                      ],
                    ),
                    if (species != null) ...[
                      BotanicaGaps.vXs,
                      Wrap(
                        spacing: BotanicaTokens.spacingXxs,
                        runSpacing: BotanicaTokens.spacingXxs,
                        children: [
                          PlantDetailPill(
                            icon: Icons.wb_sunny_rounded,
                            label: lightLabel(l10n, species.light),
                          ),
                          PlantDetailPill(
                            icon: Icons.school_rounded,
                            label: difficultyLabel(l10n, species.difficulty),
                          ),
                          PlantDetailPill(
                            icon: Icons.water_drop_rounded,
                            label: l10n.speciesDetailWaterEvery(
                              species.careDefaults.waterBaseDays,
                            ),
                          ),
                          PlantDetailPill(
                            icon: Icons.science_rounded,
                            label: l10n.speciesDetailFertilizeEvery(
                              species.careDefaults.fertilizeBaseDays,
                            ),
                          ),
                          if (species.careDefaults.mistBaseDays > 0)
                            PlantDetailPill(
                              icon: Icons.blur_on_rounded,
                              label: l10n.speciesDetailMistEvery(
                                species.careDefaults.mistBaseDays,
                              ),
                            ),
                        ],
                      ),
                      if (history != null && history.trim().isNotEmpty) ...[
                        BotanicaGaps.vXs,
                        Text(
                          history.trim(),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: context.tsBodyMuted.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.70),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                    if (species == null && idea != null) ...[
                      BotanicaGaps.vXs,
                      Wrap(
                        spacing: BotanicaTokens.spacingXxs,
                        runSpacing: BotanicaTokens.spacingXxs,
                        children: [
                          if ((idea.light ?? '').trim().isNotEmpty)
                            PlantDetailPill(
                              icon: Icons.wb_sunny_rounded,
                              label: lightLabel(l10n, idea.light!.trim()),
                            ),
                          if ((idea.difficulty ?? '').trim().isNotEmpty)
                            PlantDetailPill(
                              icon: Icons.school_rounded,
                              label: difficultyLabel(
                                  l10n, idea.difficulty!.trim()),
                            ),
                          PlantDetailPill(
                            icon: Icons.water_drop_rounded,
                            label: l10n.speciesDetailWaterEvery(
                              idea.careDefaults.waterBaseDays,
                            ),
                          ),
                          PlantDetailPill(
                            icon: Icons.science_rounded,
                            label: l10n.speciesDetailFertilizeEvery(
                              idea.careDefaults.fertilizeBaseDays,
                            ),
                          ),
                          if (idea.careDefaults.mistBaseDays > 0)
                            PlantDetailPill(
                              icon: Icons.blur_on_rounded,
                              label: l10n.speciesDetailMistEvery(
                                idea.careDefaults.mistBaseDays,
                              ),
                            ),
                        ],
                      ),
                      if (history != null && history.trim().isNotEmpty) ...[
                        BotanicaGaps.vXs,
                        Text(
                          history.trim(),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: context.tsBodyMuted.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.70),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );

            final resources = idea?.externalResources;
            final hasResources = resources != null &&
                [
                  resources.wikipedia,
                  resources.youtubeSearch,
                  resources.baiduBaikeSearch,
                  resources.bilibiliSearch,
                  resources.gbif,
                  resources.careGuide,
                ].any((e) => (e ?? '').trim().isNotEmpty);

            if (!hasResources || idea == null) return header;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                BotanicaGaps.vSm,
                _ResourcesCard(idea: idea, localeCode: localeCode),
              ],
            );
          },
        ),
        BotanicaGaps.vSm,
        _PlantQuickInfoRow(plant: plant),
        BotanicaGaps.vSm,
        _LastCareRow(plantId: plant.id),
        BotanicaGaps.vSm,
        _CareStatsCard(plantId: plant.id),
        BotanicaGaps.vSm,
        _CareRhythmCard(plantId: plant.id),
        BotanicaGaps.vSm,
        PlantForecastCard(plantId: plant.id),
        BotanicaGaps.vSm,
        _GrowthTimelineCard(plantId: plant.id),
        BotanicaGaps.vSm,
        _PlantJourneyCard(plant: plant),
        BotanicaGaps.vSm,
        _EmotionalBondSection(plant: plant),
        BotanicaGaps.vSm,
        _PredictiveNeedsSection(plant: plant),
        BotanicaGaps.vSm,
        _PlantStorySection(plant: plant),
        BotanicaGaps.vSm,
        _PlantPersonalitySection(plant: plant),
        BotanicaGaps.vSm,
        BotanicaGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.tasksTitle,
                    style: context.tsTitle.copyWith(
                      fontSize: BotanicaTokens.titleLarge,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/garden/tasks'),
                    child: Text(l10n.commonContinue),
                  ),
                ],
              ),
              BotanicaGaps.vTiny,
              if (nextTasks.isEmpty)
                Text(
                  l10n.tasksEmptySoon,
                  style: context.tsBodyMuted.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                  ),
                )
              else
                Column(
                  children: nextTasks
                      .map((t) => _TaskRow(task: t))
                      .toList(growable: false),
                ),
            ],
          ),
        ),
        _PlantAiInsightCard(
          plant: plant,
          nextTasks: nextTasks,
        ),
        BotanicaGaps.vSm,
        _ManageCareRow(plant: plant),
        BotanicaGaps.vSm,
        _EnvironmentImpactCard(plant: plant),
        BotanicaGaps.vSm,
        _CommonProblemsCard(plant: plant),
      ],
    );
  }
}

class _HealthScoreGauge extends StatefulWidget {
  const _HealthScoreGauge({required this.score});

  final int? score;

  @override
  State<_HealthScoreGauge> createState() => _HealthScoreGaugeState();
}

class _HealthScoreGaugeState extends State<_HealthScoreGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _progressAnim;
  int? _lastScore;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _lastScore = widget.score;
    final target = widget.score == null ? 0.0 : widget.score! / 100.0;
    _progressAnim = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  bool _didFirstBuild = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFirstBuild && widget.score != null) {
      _didFirstBuild = true;
      if (botanicaReduceMotion(context)) {
        _controller.value = 1.0;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void didUpdateWidget(covariant _HealthScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != _lastScore) {
      final from = _lastScore == null ? 0.0 : _lastScore! / 100.0;
      final to = widget.score == null ? 0.0 : widget.score! / 100.0;
      _lastScore = widget.score;
      _progressAnim = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
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
    final resolvedScore = widget.score;

    final Color tint = resolvedScore == null
        ? scheme.outlineVariant.withValues(alpha: 0.60)
        : switch (resolvedScore) {
            >= 70 => scheme.primary,
            >= 40 => scheme.tertiary,
            _ => scheme.error,
          };

    final track = scheme.outlineVariant.withValues(alpha: 0.25);

    return SizedBox(
      width: 56,
      height: 56,
      child: AnimatedBuilder(
        animation: _progressAnim,
        builder: (context, _) {
          final animatedScore = resolvedScore == null
              ? null
              : (_progressAnim.value * 100).round();
          return CustomPaint(
            painter: _HealthArcPainter(
              progress: _progressAnim.value.clamp(0.0, 1.0),
              trackColor: track,
              progressColor: tint,
            ),
            child: Center(
              child: Text(
                animatedScore == null ? '—' : animatedScore.toString(),
                style: context.tsLabel.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.78),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HealthArcPainter extends CustomPainter {
  const _HealthArcPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  static const double _strokeWidth = 5.5;
  static const double _startDeg = 160;
  static const double _sweepDeg = 220;
  static const double _startRad = _startDeg * math.pi / 180.0;
  static const double _sweepRad = _sweepDeg * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = const Offset(
          _strokeWidth / 2,
          _strokeWidth / 2,
        ) &
        Size(
          size.width - _strokeWidth,
          size.height - _strokeWidth,
        );

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, _startRad, _sweepRad, false, trackPaint);
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      _startRad,
      _sweepRad * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_HealthArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

  final TaskInstance task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final label = taskTypeLabel(l10n, task.type);

    final dateLabel =
        MaterialLocalizations.of(context).formatShortMonthDay(task.dueAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(iconForTask(task.type),
              color: scheme.onSurface.withValues(alpha: 0.78)),
          BotanicaGaps.hSm,
          Expanded(
            child: Text(
              label,
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            dateLabel,
            style: textTheme.labelLarge?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.60),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantQuickInfoRow extends ConsumerWidget {
  const _PlantQuickInfoRow({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logsAsync = ref.watch(careLogsForPlantProvider(plant.id));
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    final waterLogs = logs.where((l) => l.type == TaskType.water).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    String lastWateredLabel;
    if (waterLogs.isEmpty) {
      lastWateredLabel = l10n.plantNeverWatered;
    } else {
      final lastDate = waterLogs.first.timestamp;
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        lastWateredLabel = l10n.plantLastWateredToday;
      } else if (diff == 1) {
        lastWateredLabel = l10n.plantLastWateredYesterday;
      } else {
        lastWateredLabel = l10n.plantLastWateredDaysAgo(diff);
      }
    }

    final ageDays = today.difference(
      DateTime(plant.createdAt.year, plant.createdAt.month, plant.createdAt.day),
    ).inDays;

    final isAnniversary = ageDays > 0 && ageDays % 365 == 0;
    final plantStreak = PlantCareStreak.compute(logs);

    return Wrap(
      spacing: BotanicaTokens.spacingXxs,
      runSpacing: BotanicaTokens.spacingXxs,
      children: [
        PlantDetailPill(
          icon: Icons.water_drop_outlined,
          label: lastWateredLabel,
        ),
        if (isAnniversary)
          PlantDetailPill(
            icon: Icons.cake_rounded,
            label: l10n.plantAnniversaryLabel(ageDays ~/ 365),
          )
        else if (ageDays > 0)
          PlantDetailPill(
            icon: Icons.calendar_today_rounded,
            label: l10n.plantAgeLabel(ageDays),
          ),
        if (plantStreak >= 3)
          PlantDetailPill(
            icon: Icons.local_fire_department_rounded,
            label: l10n.plantCareStreakLabel(plantStreak),
          ),
        _buildPredictionPill(logs, plant.id, now, l10n),
      ].whereType<Widget>().toList(),
    );
  }
}

Widget? _buildPredictionPill(
    List<CareLog> logs, String plantId, DateTime now, AppLocalizations l10n) {
  final prediction = CarePredictionEngine.predictNextWatering(
    plantId: plantId,
    logs: logs,
    now: now,
  );
  if (prediction == null || prediction.confidence < 0.5) return null;

  final days = CarePredictionEngine.daysUntil(prediction, now);
  if (days < 0) return null;

  final label = days == 0
      ? l10n.plantDetailNextWateringToday
      : days == 1
          ? l10n.plantDetailNextWateringTomorrow
          : l10n.plantDetailNextWateringInDays(days);

  return PlantDetailPill(
    icon: Icons.auto_awesome_rounded,
    label: label,
  );
}

class _CareStatsCard extends ConsumerWidget {
  const _CareStatsCard({required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final logsAsync = ref.watch(careLogsForPlantProvider(plantId));
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (logs.length < 2) {
      return BotanicaGlassCard(
        padding: BotanicaTokens.cardPaddingDense,
        child: Row(
          children: [
            Icon(
              Icons.insights_rounded,
              size: 16,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.plantOverviewNoCareStats,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final waterLogs = logs
        .where((l) => l.type == TaskType.water)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (waterLogs.length < 2) return const SizedBox.shrink();

    final intervals = <int>[];
    for (int i = 1; i < waterLogs.length; i++) {
      intervals.add(
        waterLogs[i].timestamp.difference(waterLogs[i - 1].timestamp).inDays,
      );
    }

    final avgInterval =
        intervals.fold<int>(0, (s, v) => s + v) / intervals.length;
    final totalWaterings = waterLogs.length;

    final consistentCount = intervals.where((d) {
      return (d - avgInterval).abs() <= 2;
    }).length;
    final consistency =
        intervals.isEmpty ? 0 : (consistentCount * 100 ~/ intervals.length);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 16,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.careStatsTitle,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          Row(
            children: [
              Expanded(
                child: _AnimatedStatItem(
                  label: l10n.careStatsTotalWaterings,
                  numericValue: totalWaterings,
                  scheme: scheme,
                  textTheme: textTheme,
                ),
              ),
              Expanded(
                child: _AnimatedStatItem(
                  label: l10n.careStatsAvgInterval,
                  numericValue: avgInterval.round(),
                  suffix: 'd',
                  scheme: scheme,
                  textTheme: textTheme,
                ),
              ),
              Expanded(
                child: _AnimatedStatItem(
                  label: l10n.careStatsConsistency,
                  numericValue: consistency,
                  suffix: '%',
                  scheme: scheme,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
          if (consistency < 50 && intervals.length >= 3) ...[
            const SizedBox(height: BotanicaTokens.spacingSm),
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  size: 14,
                  color: scheme.tertiary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.careStatsTip,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
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

class _AnimatedStatItem extends StatelessWidget {
  const _AnimatedStatItem({
    required this.label,
    required this.numericValue,
    required this.scheme,
    required this.textTheme,
    this.suffix = '',
  });

  final String label;
  final int numericValue;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BotanicaAnimatedCounter(
          value: numericValue,
          suffix: suffix,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _ResourcesCard extends StatelessWidget {
  const _ResourcesCard({
    required this.idea,
    required this.localeCode,
  });

  final PlantIdea idea;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final resources = idea.externalResources;
    final wiki = resources.wikipedia?.trim() ?? '';
    final baike = resources.baiduBaikeSearch?.trim() ?? '';
    final yt = resources.youtubeSearch?.trim() ?? '';
    final bili = resources.bilibiliSearch?.trim() ?? '';
    final gbif = resources.gbif?.trim() ?? '';
    final guide = resources.careGuide?.trim() ?? '';

    final isChineseLocale = _normalizeLocale(localeCode) == 'zh';

    final rows = <_ResourceRowData>[];
    void addRow({
      required String url,
      required IconData icon,
      required String title,
    }) {
      if (url.trim().isEmpty) return;
      rows.add(_ResourceRowData(icon: icon, title: title, url: url));
    }

    if (isChineseLocale) {
      addRow(
        url: baike,
        icon: Icons.article_outlined,
        title: l10n.resourceBaiduBaike,
      );
      addRow(
        url: bili,
        icon: Icons.play_circle_outline_rounded,
        title: l10n.resourceBilibili,
      );
      addRow(
          url: wiki, icon: Icons.public_rounded, title: l10n.resourceWikipedia);
      addRow(
        url: yt,
        icon: Icons.play_circle_outline_rounded,
        title: l10n.resourceYouTube,
      );
      addRow(
        url: gbif,
        icon: Icons.account_tree_rounded,
        title: l10n.resourceGbif,
      );
      addRow(
        url: guide,
        icon: Icons.menu_book_rounded,
        title: l10n.resourceCareGuide,
      );
    } else {
      addRow(
          url: wiki, icon: Icons.public_rounded, title: l10n.resourceWikipedia);
      addRow(
        url: gbif,
        icon: Icons.account_tree_rounded,
        title: l10n.resourceGbif,
      );
      addRow(
        url: yt,
        icon: Icons.play_circle_outline_rounded,
        title: l10n.resourceYouTube,
      );
      addRow(
        url: guide,
        icon: Icons.menu_book_rounded,
        title: l10n.resourceCareGuide,
      );
      addRow(
        url: baike,
        icon: Icons.article_outlined,
        title: l10n.resourceBaiduBaike,
      );
      addRow(
        url: bili,
        icon: Icons.play_circle_outline_rounded,
        title: l10n.resourceBilibili,
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.resourcesTitle,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          BotanicaGaps.vXs,
          for (var i = 0; i < rows.length; i++) ...[
            _ResourceRow(data: rows[i]),
            if (i != rows.length - 1)
              Divider(
                height: 12,
                thickness: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.22),
              ),
          ],
        ],
      ),
    );
  }
}

@immutable
class _ResourceRowData {
  const _ResourceRowData({
    required this.icon,
    required this.title,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String url;
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.data});

  final _ResourceRowData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Future<void> copyLink() async {
      await Clipboard.setData(ClipboardData(text: data.url));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.content_copy_rounded,
                  size: BotanicaTokens.iconSizeSm,
                  color: Theme.of(context).colorScheme.inversePrimary),
              BotanicaGaps.hSm,
              Text(l10n.resourceLinkCopied),
            ],
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: data.title,
      value: data.url,
      child: InkWell(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        onTap: copyLink,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(data.icon, color: scheme.onSurface.withValues(alpha: 0.78)),
              BotanicaGaps.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    BotanicaGaps.vMicro,
                    Text(
                      data.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.resourceCopyLink,
                onPressed: copyLink,
                icon: Icon(
                  Icons.content_copy_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageCareRow extends StatelessWidget {
  const _ManageCareRow({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final disabledCount = TaskType.values
        .where(
            (t) => plant.careOverrideFor(t) == CareTypeOverride.disabled)
        .length;
    final activeCount = TaskType.values.length - disabledCount;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: InkWell(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        onTap: () {
          BotanicaHaptics.selectionTick();
          showManageCareSheet(context: context, plant: plant);
        },
        child: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              size: BotanicaTokens.iconSizeMd,
              color: scheme.primary.withValues(alpha: 0.8),
            ),
            BotanicaGaps.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.manageCareTitle,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.manageCareSubtitle(activeCount, disabledCount),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                BotanicaHaptics.selectionTick();
                showManageCareSheet(context: context, plant: plant);
              },
              child: Text(l10n.manageCareButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentImpactCard extends ConsumerWidget {
  const _EnvironmentImpactCard({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesRepo = ref.read(speciesRepositoryProvider);
    final ideaRepo = ref.read(plantIdeaRepositoryProvider);
    final seasonalEngine = ref.read(seasonalCareEngineProvider);
    final env = ref.watch(environmentSnapshotProvider);
    final hemisphere =
        ref.watch(settingsControllerProvider.select((s) => s.hemisphere));

    return FutureBuilder(
      future: Future.wait([
        speciesRepo.byId(plant.speciesId),
        ideaRepo.byId(plant.speciesId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final species = snapshot.data![0] as Species?;
        final idea = snapshot.data![1] as PlantIdea?;

        final baseDays = species?.careDefaults.waterBaseDays ?? 7;
        final decision = seasonalEngine.computeSchedule(
          taskType: TaskType.water,
          now: DateTime.now(),
          environment: env,
          hemisphere: hemisphere,
          environmentMode: plant.environmentMode,
          plantIdea: idea,
          fallbackBaseDays: baseDays,
        );

        return CareTransparencyCard(
          snapshot: decision.snapshot,
          baseDays: baseDays,
        );
      },
    );
  }
}

class _PlantAiInsightCard extends ConsumerWidget {
  const _PlantAiInsightCard({
    required this.plant,
    required this.nextTasks,
  });

  final Plant plant;
  final List<TaskInstance> nextTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    if (!settings.enableAiInsights) {
      final emptyScheme = Theme.of(context).colorScheme;
      final emptyTextTheme = Theme.of(context).textTheme;
      final emptyL10n = AppLocalizations.of(context);
      return Column(
        children: [
          BotanicaGaps.vSm,
          BotanicaGlassCard(
            padding: BotanicaTokens.cardPaddingDense,
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: emptyScheme.tertiary.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    emptyL10n.plantOverviewNoAiInsights,
                    style: emptyTextTheme.bodySmall?.copyWith(
                      color: emptyScheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final ai = ref.read(botanicaAiServiceProvider);
    if (!ai.isConfigured) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    final env = ref.watch(environmentSnapshotProvider);
    final localeCode =
        settings.localeCode ?? Localizations.localeOf(context).languageCode;

    final taskLabels = nextTasks
        .where((t) => !t.isDismissed)
        .take(4)
        .map(
          (t) => '${taskTypeLabel(l10n, t.type)} · '
              '${MaterialLocalizations.of(context).formatShortMonthDay(t.dueAt)}',
        )
        .toList(growable: false);

    final speciesRepo = ref.read(speciesRepositoryProvider);

    Widget cardChildForText(String text) {
      return BotanicaAiNoteCard(
        title: l10n.dailyAiNoteTitle,
        textToCopy: text,
        copyTooltip: l10n.aiNoteCopyAction,
        copiedMessage: l10n.aiNoteCopied,
        child: _ExpandableAiText(
          text: text,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.76),
            height: 1.45,
          ),
          collapsedMaxLines: 3,
        ),
      );
    }

    return FutureBuilder(
      future: speciesRepo.byId(plant.speciesId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              BotanicaGaps.vSm,
              BotanicaGlassCard(
                padding: BotanicaTokens.cardPaddingDense,
                child: _AiSkeleton(
                    color: scheme.onSurface.withValues(alpha: 0.10)),
              ),
            ],
          );
        }

        final species = snapshot.data;
        final speciesName =
            species?.bestCommonName(localeCode) ?? plant.speciesId;

        final request = PlantAiInsightRequest(
          date: day,
          localeCode: localeCode,
          plantId: plant.id,
          plantNickname: plant.nickname,
          speciesId: plant.speciesId,
          speciesName: speciesName,
          scientificName: species?.scientificName,
          environmentMode: plant.environmentMode,
          tempC: env.tempC,
          humidityPercent: env.humidity,
          nextTasks: taskLabels,
        );

        final insightAsync = ref.watch(plantAiInsightProvider(request));

        return insightAsync.when(
          loading: () => Column(
            children: [
              BotanicaGaps.vSm,
              BotanicaGlassCard(
                padding: BotanicaTokens.cardPaddingDense,
                child: _AiSkeleton(
                    color: scheme.onSurface.withValues(alpha: 0.10)),
              ),
            ],
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (text) {
            final value = text?.trim();
            if (value == null || value.isEmpty) return const SizedBox.shrink();
            final noteCard = BotanicaGlassCard(
              padding: BotanicaTokens.cardPaddingDense,
              child: cardChildForText(value),
            );

            return Column(
              children: [
                BotanicaGaps.vSm,
                noteCard.animateIfAllowed(
                  context,
                  (child) => child
                      .animate()
                      .fadeIn(
                        duration: BotanicaTokens.motionMedium,
                        curve: BotanicaTokens.curveReveal,
                      )
                      .slideY(
                        begin: 0.02,
                        end: 0,
                        duration: BotanicaTokens.motionMedium,
                        curve: BotanicaTokens.curveReveal,
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AiSkeleton extends StatelessWidget {
  const _AiSkeleton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget line(double w) {
      return FractionallySizedBox(
        widthFactor: w,
        child: Container(
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
          ),
        ),
      );
    }

    final reduceMotion = botanicaReduceMotion(context);

    final skeleton = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line(0.44),
        BotanicaGaps.vSm,
        line(0.92),
        BotanicaGaps.vSm,
        line(0.80),
        BotanicaGaps.vSm,
        line(0.66),
      ],
    );

    if (reduceMotion) return skeleton;

    return skeleton
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: BotanicaTokens.motionSlow * 3,
          color: scheme.onSurface.withValues(alpha: 0.08),
        );
  }
}

class _ExpandableAiText extends StatefulWidget {
  const _ExpandableAiText({
    required this.text,
    required this.style,
    this.collapsedMaxLines = 2,
  });

  final String text;
  final TextStyle? style;
  final int collapsedMaxLines;

  @override
  State<_ExpandableAiText> createState() => _ExpandableAiTextState();
}

class _ExpandableAiTextState extends State<_ExpandableAiText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: _expanded
          ? l10n.plantDetailCollapseText
          : l10n.plantDetailExpandText,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
        child: Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: AnimatedSize(
            duration: BotanicaTokens.motionMedium,
            curve: BotanicaTokens.curveSettle,
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: widget.style,
                  maxLines: _expanded ? null : widget.collapsedMaxLines,
                  overflow:
                      _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                BotanicaGaps.vXxs,
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: BotanicaTokens.iconSizeSm,
                    color: scheme.onSurface.withValues(alpha: 0.60),
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

class _CommonProblemsCard extends ConsumerWidget {
  const _CommonProblemsCard({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideaRepo = ref.read(plantIdeaRepositoryProvider);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder(
      future: ideaRepo.byId(plant.speciesId),
      builder: (context, snapshot) {
        final idea = snapshot.data;
        if (idea == null || idea.commonProblems.isEmpty) {
          return const SizedBox.shrink();
        }

        return BotanicaGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.healing_rounded,
                    size: 20,
                    color: scheme.error.withValues(alpha: 0.7),
                  ),
                  BotanicaGaps.hXxs,
                  Text(
                    l10n.commonProblemsTitle,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              BotanicaGaps.vMicro,
              Text(
                l10n.commonProblemsSubtitle(plant.nickname),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              BotanicaGaps.vSm,
              ...idea.commonProblems.map(
                (problem) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: BotanicaTokens.spacingXxs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.error.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      BotanicaGaps.hXxs,
                      Expanded(
                        child: Text(
                          problem,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.75),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _normalizeLocale(String localeCode) {
  return localeCode.trim().toLowerCase().split('_').first.split('-').first;
}

// ---------------------------------------------------------------------------
// Care Rhythm Sparkline Card
// ---------------------------------------------------------------------------

class _CareRhythmCard extends ConsumerWidget {
  const _CareRhythmCard({required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final logsAsync = ref.watch(careLogsForPlantProvider(plantId));
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    final waterLogs = logs
        .where((l) => l.type == TaskType.water)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (waterLogs.length < 4) {
      return BotanicaGlassCard(
        padding: BotanicaTokens.cardPaddingDense,
        child: Row(
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 16,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: BotanicaTokens.spacingXxs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.careRhythmTitle,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.careRhythmNoData,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Compute intervals in days between consecutive waterings
    final intervals = <double>[];
    for (int i = 1; i < waterLogs.length; i++) {
      final days = waterLogs[i]
          .timestamp
          .difference(waterLogs[i - 1].timestamp)
          .inHours / 24.0;
      intervals.add(days);
    }

    // Take last 12 intervals max for the sparkline
    final displayIntervals = intervals.length > 12
        ? intervals.sublist(intervals.length - 12)
        : intervals;

    // Compute average
    final sum = displayIntervals.fold<double>(0, (s, v) => s + v);
    final avg = sum / displayIntervals.length;

    // Compute standard deviation
    final variance = displayIntervals.fold<double>(
          0,
          (s, v) => s + (v - avg) * (v - avg),
        ) /
        displayIntervals.length;
    final stdDev = math.sqrt(variance);

    // Determine consistency label
    String consistencyLabel;
    if (stdDev < 1.5) {
      consistencyLabel = l10n.careRhythmConsistent;
    } else {
      // Check if recent half is more consistent than older half
      final half = displayIntervals.length ~/ 2;
      if (half >= 2) {
        final olderHalf = displayIntervals.sublist(0, half);
        final recentHalf = displayIntervals.sublist(half);
        final olderAvg =
            olderHalf.fold<double>(0, (s, v) => s + v) / olderHalf.length;
        final recentAvg =
            recentHalf.fold<double>(0, (s, v) => s + v) / recentHalf.length;
        final olderVar = olderHalf.fold<double>(
              0,
              (s, v) => s + (v - olderAvg) * (v - olderAvg),
            ) /
            olderHalf.length;
        final recentVar = recentHalf.fold<double>(
              0,
              (s, v) => s + (v - recentAvg) * (v - recentAvg),
            ) /
            recentHalf.length;
        if (recentVar < olderVar) {
          consistencyLabel = l10n.careRhythmImproving;
        } else {
          consistencyLabel = l10n.careRhythmImproving;
        }
      } else {
        consistencyLabel = l10n.careRhythmImproving;
      }
    }

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 16,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: BotanicaTokens.spacingTiny),
              Text(
                l10n.careRhythmTitle,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: CustomPaint(
              painter: _CareRhythmSparklinePainter(
                intervals: displayIntervals,
                lineColor: scheme.primary,
                fillColor: scheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.careRhythmAvgInterval(avg.round()),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXxs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(BotanicaTokens.radiusM),
                ),
                child: Text(
                  consistencyLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
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

class _CareRhythmSparklinePainter extends CustomPainter {
  const _CareRhythmSparklinePainter({
    required this.intervals,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> intervals;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (intervals.isEmpty) return;

    final maxVal =
        intervals.reduce((a, b) => a > b ? a : b) * 1.15; // add headroom
    const minVal = 0.0;
    final range = maxVal - minVal;
    if (range <= 0) return;

    final points = <Offset>[];
    for (int i = 0; i < intervals.length; i++) {
      final x = intervals.length == 1
          ? size.width / 2
          : (i / (intervals.length - 1)) * size.width;
      final y = size.height - ((intervals[i] - minVal) / range) * size.height;
      points.add(Offset(x, y));
    }

    // Draw fill
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_CareRhythmSparklinePainter oldDelegate) {
    return oldDelegate.intervals != intervals ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

// ---------------------------------------------------------------------------
// Last Care Row
// ---------------------------------------------------------------------------

class _LastCareRow extends ConsumerWidget {
  const _LastCareRow({required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final logsAsync = ref.watch(careLogsForPlantProvider(plantId));
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final photosAsync = ref.watch(photoEntriesStreamProvider);
    final allPhotos = photosAsync.valueOrNull ?? const <PhotoEntry>[];
    final plantPhotos = allPhotos.where((p) => p.plantId == plantId).toList();

    final now = DateTime.now();

    // Find last water
    final waterLogs = logs.where((l) => l.type == TaskType.water).toList();
    final lastWater = waterLogs.isEmpty
        ? null
        : waterLogs
            .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b)
            .timestamp;

    // Find last fertilize
    final fertilizeLogs =
        logs.where((l) => l.type == TaskType.fertilize).toList();
    final lastFertilize = fertilizeLogs.isEmpty
        ? null
        : fertilizeLogs
            .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b)
            .timestamp;

    // Find last photo
    final lastPhoto = plantPhotos.isEmpty
        ? null
        : plantPhotos
            .reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
            .createdAt;

    String timeAgo(DateTime? date) {
      if (date == null) return l10n.lastCareNever;
      final days = now.difference(date).inDays;
      if (days == 0) return l10n.lastCareToday;
      return l10n.lastCareDaysAgo(days);
    }

    // Don't show if no data at all
    if (waterLogs.isEmpty && fertilizeLogs.isEmpty && plantPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: _LastCareChip(
            icon: Icons.water_drop_rounded,
            label: l10n.lastCareWater,
            value: timeAgo(lastWater),
            color: Colors.blue,
            scheme: scheme,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: BotanicaTokens.spacingXs),
        Expanded(
          child: _LastCareChip(
            icon: Icons.grass_rounded,
            label: l10n.lastCareFertilize,
            value: timeAgo(lastFertilize),
            color: Colors.green,
            scheme: scheme,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: BotanicaTokens.spacingXs),
        Expanded(
          child: _LastCareChip(
            icon: Icons.camera_alt_rounded,
            label: l10n.lastCarePhoto,
            value: timeAgo(lastPhoto),
            color: Colors.purple,
            scheme: scheme,
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }
}

class _LastCareChip extends StatelessWidget {
  const _LastCareChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.scheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingSm,
        vertical: BotanicaTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plant Journey Card
// ---------------------------------------------------------------------------

enum _JourneyMilestoneType {
  firstWater,
  firstPhoto,
  sevenDays,
  firstFertilize,
  tenWaters,
  thirtyDays,
  twentyFiveWaters,
  hundredDays,
  oneYear,
}

class _JourneyMilestone {
  const _JourneyMilestone({
    required this.type,
    required this.label,
    required this.completed,
  });

  final _JourneyMilestoneType type;
  final String label;
  final bool completed;
}

class _PlantJourneyCard extends ConsumerWidget {
  const _PlantJourneyCard({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final logsAsync = ref.watch(careLogsForPlantProvider(plant.id));
    final photosAsync = ref.watch(photoEntriesStreamProvider);

    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final allPhotos = photosAsync.valueOrNull ?? const <PhotoEntry>[];
    final photos = allPhotos.where((p) => p.plantId == plant.id).toList();

    final waterLogs = logs.where((l) => l.type == TaskType.water).length;
    final fertilizeLogs =
        logs.where((l) => l.type == TaskType.fertilize).length;
    final daysOwned = DateTime.now().difference(plant.createdAt).inDays;

    final milestones = <_JourneyMilestone>[
      _JourneyMilestone(
        type: _JourneyMilestoneType.firstWater,
        label: l10n.plantJourneyMilestoneFirstWater,
        completed: waterLogs >= 1,
      ),
      _JourneyMilestone(
        type: _JourneyMilestoneType.firstPhoto,
        label: l10n.plantJourneyMilestoneFirstPhoto,
        completed: photos.isNotEmpty,
      ),
      _JourneyMilestone(
        type: _JourneyMilestoneType.sevenDays,
        label: l10n.plantJourneyMilestone7Days,
        completed: daysOwned >= 7,
      ),
      _JourneyMilestone(
        type: _JourneyMilestoneType.firstFertilize,
        label: l10n.plantJourneyMilestoneFirstFertilize,
        completed: fertilizeLogs >= 1,
      ),
      _JourneyMilestone(
        type: _JourneyMilestoneType.tenWaters,
        label: l10n.plantJourneyMilestone10Waters,
        completed: waterLogs >= 10,
      ),
      _JourneyMilestone(
        type: _JourneyMilestoneType.thirtyDays,
        label: l10n.plantJourneyMilestone30Days,
        completed: daysOwned >= 30,
      ),
      _JourneyMilestone(
        type: _JourneyMilestoneType.twentyFiveWaters,
        label: l10n.plantJourneyMilestone25Waters,
        completed: waterLogs >= 25,
      ),
      _JourneyMilestone(
        type: _JourneyMilestoneType.hundredDays,
        label: l10n.plantJourneyMilestone100Days,
        completed: daysOwned >= 100,
      ),
      _JourneyMilestone(
        type: _JourneyMilestoneType.oneYear,
        label: l10n.plantJourneyMilestone365Days,
        completed: daysOwned >= 365,
      ),
    ];

    final nextMilestone = milestones
        .cast<_JourneyMilestone?>()
        .firstWhere((m) => !m!.completed, orElse: () => null);
    final allCompleted = nextMilestone == null;

    return BotanicaGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco_rounded,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.plantJourneyTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          SizedBox(
            height: 32,
            child: Row(
              children: [
                for (int i = 0; i < milestones.length; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: milestones[i].completed
                            ? scheme.primary.withValues(alpha: 0.4)
                            : scheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                  _MilestoneDot(
                    milestone: milestones[i],
                    isNext: !allCompleted &&
                        milestones[i].type == nextMilestone.type,
                    scheme: scheme,
                  ),
                ],
              ],
            ),
          ),
          BotanicaGaps.vSm,
          if (allCompleted)
            Row(
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 16,
                  color: scheme.tertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  '🌟',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Text(
              l10n.plantJourneyNextMilestone(nextMilestone.label),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _MilestoneDot extends StatelessWidget {
  const _MilestoneDot({
    required this.milestone,
    required this.isNext,
    required this.scheme,
  });

  final _JourneyMilestone milestone;
  final bool isNext;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    const size = 24.0;

    if (milestone.completed) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primary,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }

    if (isNext) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.tertiary, width: 2),
          boxShadow: [
            BoxShadow(
              color: scheme.tertiary.withValues(alpha: 0.3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
    );
  }
}

class _GrowthTimelineCard extends ConsumerWidget {
  const _GrowthTimelineCard({required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final photosAsync = ref.watch(photoEntriesStreamProvider);
    final allPhotos = photosAsync.valueOrNull ?? const <PhotoEntry>[];
    final photos = allPhotos.where((p) => p.plantId == plantId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (photos.isEmpty) {
      return BotanicaGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.growthTimelineTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            BotanicaGaps.vSm,
            Text(
              l10n.growthTimelineEmpty,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return BotanicaGlassCard(
      padding: const EdgeInsets.only(
        top: BotanicaTokens.spacingMd,
        bottom: BotanicaTokens.spacingMd,
        left: BotanicaTokens.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: BotanicaTokens.spacingMd),
            child: Row(
              children: [
                Icon(Icons.timeline_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.growthTimelineTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${photos.length}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          BotanicaGaps.vSm,
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              padding: const EdgeInsets.only(right: BotanicaTokens.spacingMd),
              itemBuilder: (context, index) {
                final photo = photos[index];
                return _GrowthTimelineThumbnail(photo: photo);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthTimelineThumbnail extends StatelessWidget {
  const _GrowthTimelineThumbnail({required this.photo});

  final PhotoEntry photo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final diff = now.difference(photo.createdAt).inDays;
    final label = diff == 0
        ? 'Today'
        : diff == 1
            ? '1d'
            : diff < 30
                ? '${diff}d'
                : diff < 365
                    ? '${(diff / 30).round()}mo'
                    : '${(diff / 365).round()}y';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
          child: SizedBox(
            width: 72,
            height: 72,
            child: _buildImage(scheme),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(ColorScheme scheme) {
    final file = File(photo.filePath);
    if (!file.existsSync()) {
      return Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 24,
          color: scheme.onSurface.withValues(alpha: 0.3),
        ),
      );
    }
    return Image.file(
      file,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(
          Icons.broken_image_rounded,
          size: 24,
          color: scheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Emotional Bond Section
// ---------------------------------------------------------------------------

class _EmotionalBondSection extends ConsumerWidget {
  const _EmotionalBondSection({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(careLogsStreamProvider);
    final plantsAsync = ref.watch(plantsStreamProvider);

    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];

    if (logs.isEmpty) return const SizedBox.shrink();

    final bonds = EmotionalBondEngine.compute(
      plants: plants,
      logs: logs,
      now: DateTime.now(),
    );

    final bond = bonds.where((b) => b.plantId == plant.id).firstOrNull;
    if (bond == null) return const SizedBox.shrink();

    return BotanicaEmotionalBondIndicator(bond: bond);
  }
}

// ---------------------------------------------------------------------------
// Predictive Needs Section
// ---------------------------------------------------------------------------

class _PredictiveNeedsSection extends ConsumerWidget {
  const _PredictiveNeedsSection({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(careLogsStreamProvider);
    final plantsAsync = ref.watch(plantsStreamProvider);

    final logs = logsAsync.valueOrNull ?? const <CareLog>[];
    final plants = plantsAsync.valueOrNull ?? const <Plant>[];

    if (logs.where((l) => l.plantId == plant.id).length < 5) {
      return const SizedBox.shrink();
    }

    final report = PredictiveNeedsEngine.predict(
      plants: plants,
      logs: logs,
      now: DateTime.now(),
    );

    final plantPredictions = report.predictions
        .where((p) => p.plantId == plant.id)
        .toList();

    if (plantPredictions.isEmpty) return const SizedBox.shrink();

    return BotanicaPredictiveNeedsCard(predictions: plantPredictions);
  }
}

// ---------------------------------------------------------------------------
// Plant Story Section
// ---------------------------------------------------------------------------

class _PlantStorySection extends ConsumerWidget {
  const _PlantStorySection({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(careLogsForPlantProvider(plant.id));
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (logs.length < 3) return const SizedBox.shrink();

    final story = PlantStoryEngine.generate(
      plant: plant,
      logs: logs,
      now: DateTime.now(),
    );

    return BotanicaPlantStoryCard(story: story);
  }
}

// ---------------------------------------------------------------------------
// Plant Personality Section
// ---------------------------------------------------------------------------

class _PlantPersonalitySection extends ConsumerWidget {
  const _PlantPersonalitySection({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(careLogsForPlantProvider(plant.id));
    final logs = logsAsync.valueOrNull ?? const <CareLog>[];

    if (logs.length < 3) return const SizedBox.shrink();

    final now = DateTime.now();
    final personality = PlantPersonalityEngine.analyze(
      plant: plant,
      logs: logs,
      healthScore: 0.7,
      now: now,
    );

    return BotanicaPlantPersonalityCard(personality: personality);
  }
}
