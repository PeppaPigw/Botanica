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
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_idea.dart';
import '../../domain/models/task_instance.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/ai/ai_providers.dart';
import 'widgets/plant_detail_pill.dart';

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
                ? 'assets/placeholders/species/unknown.png'
                : imageCandidate;

            final canOpenSpecies = species != null || idea != null;

            final healthGauge = healthScoreAsync.when(
              data: (score) => _HealthScoreGauge(score: score),
              loading: () => const _HealthScoreGauge(score: null),
              error: (_, __) => const _HealthScoreGauge(score: null),
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
                                'assets/placeholders/species/unknown.png',
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
                                const SizedBox(height: 2),
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
                const SizedBox(height: 12),
                _ResourcesCard(idea: idea, localeCode: localeCode),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
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
              const SizedBox(height: 4),
              if (nextTasks.isEmpty)
                Text(
                  l10n.tasksEmptyUpcoming,
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
        const SizedBox(height: 14),
        _EnvironmentImpactCard(plant: plant),
      ],
    );
  }
}

class _HealthScoreGauge extends StatelessWidget {
  const _HealthScoreGauge({required this.score});

  final int? score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final resolvedScore = score;
    final progress = resolvedScore == null ? 0.0 : resolvedScore / 100.0;

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
      child: CustomPaint(
        painter: _HealthArcPainter(
          progress: progress.clamp(0.0, 1.0),
          trackColor: track,
          progressColor: tint,
        ),
        child: Center(
          child: Text(
            resolvedScore == null ? '—' : resolvedScore.toString(),
            style: context.tsLabel.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ),
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

    final label = _taskTypeLabel(l10n, task.type);

    final dateLabel =
        MaterialLocalizations.of(context).formatShortMonthDay(task.dueAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(_iconForTask(task.type),
              color: scheme.onSurface.withValues(alpha: 0.78)),
          const SizedBox(width: 10),
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
      padding: const EdgeInsets.all(14),
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
          const SizedBox(height: 8),
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
              Icon(Icons.content_copy_rounded, size: 18, color: Theme.of(context).colorScheme.inversePrimary),
              const SizedBox(width: 10),
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
              const SizedBox(width: 12),
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
                    const SizedBox(height: 2),
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

class _EnvironmentImpactCard extends ConsumerWidget {
  const _EnvironmentImpactCard({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final speciesRepo = ref.read(speciesRepositoryProvider);
    final engine = ref.read(carePlanEngineProvider);
    final env = ref.watch(environmentSnapshotProvider);
    final hemisphere =
        ref.watch(settingsControllerProvider.select((s) => s.hemisphere));

    return FutureBuilder(
      future: speciesRepo.byId(plant.speciesId),
      builder: (context, snapshot) {
        final baseDays = snapshot.data?.careDefaults.waterBaseDays ?? 7;
        final adjustment = engine.adjustWatering(
          baseDays: baseDays,
          environment: env,
          environmentMode: plant.environmentMode,
          hemisphere: hemisphere,
        );

        final reasons = adjustment.reasons
            .map((r) => _localizeReason(l10n, r))
            .toList(growable: false);

        return BotanicaGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.plantDetailEnvironmentImpactTitle,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  PlantDetailPill(
                    icon: Icons.opacity_rounded,
                    label: '${env.humidity}%',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.plantDetailEnvironmentImpactBaseAdjusted(
                  baseDays,
                  adjustment.adjustedDays,
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.commonWhy,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface.withValues(alpha: 0.74),
                ),
              ),
              const SizedBox(height: 8),
              if (reasons.isEmpty)
                Text(
                  l10n.plantDetailEnvironmentStable,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.70),
                    height: 1.35,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reasons
                      .map(
                        (r) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            '• $r',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.72),
                              height: 1.35,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
            ],
          ),
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
    if (!settings.enableAiInsights) return const SizedBox.shrink();

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
        .where((t) => !t.isDone)
        .take(4)
        .map(
          (t) => '${_taskTypeLabel(l10n, t.type)} · '
              '${MaterialLocalizations.of(context).formatShortMonthDay(t.dueAt)}',
        )
        .toList(growable: false);

    final speciesRepo = ref.read(speciesRepositoryProvider);

    Widget cardChildForText(String text) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: scheme.onSurface.withValues(alpha: 0.80),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.dailyAiNoteTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ExpandableAiText(
            text: text,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.76),
              height: 1.45,
            ),
            collapsedMaxLines: 3,
          ),
        ],
      );
    }

    return FutureBuilder(
      future: speciesRepo.byId(plant.speciesId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              const SizedBox(height: 14),
              BotanicaGlassCard(
                padding: const EdgeInsets.all(14),
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
              const SizedBox(height: 14),
              BotanicaGlassCard(
                padding: const EdgeInsets.all(14),
                child: _AiSkeleton(
                    color: scheme.onSurface.withValues(alpha: 0.10)),
              ),
            ],
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (text) {
            final value = text?.trim();
            if (value == null || value.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                const SizedBox(height: 14),
                BotanicaGlassCard(
                  padding: const EdgeInsets.all(14),
                  child: cardChildForText(value),
                )
                    .animate()
                    .fadeIn(duration: 420.ms)
                    .slideY(begin: 0.03, curve: Curves.easeOutCubic),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line(0.44),
        const SizedBox(height: 12),
        line(0.92),
        const SizedBox(height: 10),
        line(0.80),
        const SizedBox(height: 10),
        line(0.66),
      ],
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1200.ms,
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

    return InkWell(
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
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 18,
                  color: scheme.onSurface.withValues(alpha: 0.60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

String _localizeReason(AppLocalizations l10n, CareAdjustmentReason reason) {
  return switch (reason) {
    CareAdjustmentReason.humidityLow => l10n.reasonHumidityLow,
    CareAdjustmentReason.humidityHigh => l10n.reasonHumidityHigh,
    CareAdjustmentReason.hotTemperature => l10n.reasonHot,
    CareAdjustmentReason.winterSeason => l10n.reasonWinter,
    CareAdjustmentReason.outdoorMode => l10n.reasonOutdoor,
  };
}

String _normalizeLocale(String localeCode) {
  return localeCode.trim().toLowerCase().split('_').first.split('-').first;
}
