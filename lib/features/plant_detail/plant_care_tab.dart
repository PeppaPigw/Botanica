import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_idea.dart';
import '../../domain/models/task_instance.dart';
import '../../domain/models/enums.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/ai/ai_providers.dart';

class PlantCareTab extends ConsumerWidget {
  const PlantCareTab({
    super.key,
    required this.plant,
    required this.tasks,
  });

  final Plant plant;
  final List<TaskInstance> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeFallback = Localizations.localeOf(context).languageCode;
    final localeCode =
        ref.watch(settingsControllerProvider).localeCode ?? localeFallback;

    final ideaAsync = ref.watch(plantIdeaByIdProvider(plant.speciesId));

    return ideaAsync.when(
      loading: () => _GenericCareTab(
        plant: plant,
        leading: _AiCareTipSection(
          plant: plant,
          tasks: tasks,
          localeCode: localeCode,
          speciesName: plant.speciesId,
          scientificName: null,
        ),
      ),
      error: (_, __) => _GenericCareTab(
        plant: plant,
        leading: _AiCareTipSection(
          plant: plant,
          tasks: tasks,
          localeCode: localeCode,
          speciesName: plant.speciesId,
          scientificName: null,
        ),
      ),
      data: (idea) {
        if (idea == null) {
          return _GenericCareTab(
            plant: plant,
            leading: _AiCareTipSection(
              plant: plant,
              tasks: tasks,
              localeCode: localeCode,
              speciesName: plant.speciesId,
              scientificName: null,
            ),
          );
        }
        return _IdeaCareTab(
          idea: idea,
          localeCode: localeCode,
          leading: _AiCareTipSection(
            plant: plant,
            tasks: tasks,
            localeCode: localeCode,
            speciesName: idea.bestCommonName(localeCode),
            scientificName: idea.scientificName,
          ),
        );
      },
    );
  }
}

class _GenericCareTab extends StatelessWidget {
  const _GenericCareTab({
    required this.plant,
    this.leading,
  });

  final Plant plant;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: BotanicaTokens.pagePadding.copyWith(bottom: 120),
      children: [
        if (leading != null) ...[
          leading!,
          BotanicaGaps.vSm,
        ],
        _CareCard(
          icon: Icons.water_drop_rounded,
          title: l10n.taskTypeWater,
          body: l10n.plantDetailCareWaterBody,
        ),
        BotanicaGaps.vSm,
        _CareCard(
          icon: Icons.wb_sunny_rounded,
          title: l10n.careKeyLight,
          body: l10n.plantDetailCareLightBody,
        ),
        BotanicaGaps.vSm,
        _CareCard(
          icon: Icons.thermostat_rounded,
          title: l10n.plantDetailCareTempTitle,
          body: l10n.plantDetailCareTempBody,
        ),
      ],
    );
  }
}

class _IdeaCareTab extends StatelessWidget {
  const _IdeaCareTab({
    required this.idea,
    required this.localeCode,
    this.leading,
  });

  final PlantIdea idea;
  final String localeCode;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final watering = idea.care?.watering;
    final fertilizing = idea.care?.fertilizing;
    final pruning = idea.care?.pruning;
    final pests = idea.care?.pestsAndDiseases;
    final extreme = idea.care?.extremeWeather;
    final strategies = idea.care?.climateStrategies;
    final temp = idea.care?.temperatureC;
    final humidity = idea.care?.humidityPct;
    final soil = idea.care?.soil;

    final waterWhy = watering?.notes(localeCode);
    final fertilizeWhy = fertilizing?.notes(localeCode);
    final pruneWhen = pruning?.when(localeCode);
    final pruneHow = pruning?.how(localeCode);

    final idealTemp = temp?.ideal;
    final toleratesTemp = temp?.tolerates;
    final idealHumidity = humidity?.ideal;

    final tempLine = (idealTemp == null && toleratesTemp == null)
        ? null
        : [
            if (idealTemp != null)
              '${l10n.commonIdeal}: ${idealTemp.min}–${idealTemp.max}°C',
            if (toleratesTemp != null)
              '${l10n.commonTolerates}: ${toleratesTemp.min}–${toleratesTemp.max}°C',
          ].join(' · ');

    final humidityLine = idealHumidity == null
        ? null
        : '${l10n.commonIdeal}: ${idealHumidity.min}–${idealHumidity.max}%';

    final soilLine =
        (soil?.mix ?? '').trim().isEmpty ? null : (soil!.mix!).trim();
    final phRange = soil?.ph;
    final phLine = phRange == null
        ? null
        : '${l10n.commonSoilPh}: ${phRange.min.toStringAsFixed(1)}–${phRange.max.toStringAsFixed(1)}';

    final lightCode = (idea.light ?? '').trim();
    final lightLine = lightCode.isEmpty ? null : lightLabel(l10n, lightCode);

    final baseWater =
        l10n.speciesDetailWaterEvery(idea.careDefaults.waterBaseDays);
    final baseFertilize =
        l10n.speciesDetailFertilizeEvery(idea.careDefaults.fertilizeBaseDays);
    final baseMist = idea.careDefaults.mistBaseDays > 0
        ? l10n.speciesDetailMistEvery(idea.careDefaults.mistBaseDays)
        : null;

    final blocks = <Widget>[
      if (leading != null) ...[
        leading!,
        const SizedBox(height: 12),
      ],
      _CareCard(
        icon: Icons.water_drop_rounded,
        title: l10n.taskTypeWater,
        subtitle: baseWater,
        body: [
          l10n.plantDetailCareWaterBody,
          if (waterWhy != null && waterWhy.trim().isNotEmpty) waterWhy.trim(),
        ].join('\n\n'),
      ),
      const SizedBox(height: 12),
      _CareCard(
        icon: Icons.science_rounded,
        title: l10n.taskTypeFertilize,
        subtitle: baseFertilize,
        body: [
          if (fertilizeWhy != null && fertilizeWhy.trim().isNotEmpty)
            fertilizeWhy.trim()
          else
            l10n.commonComingSoon,
        ].join('\n\n'),
      ),
      const SizedBox(height: 12),
      _CareCard(
        icon: Icons.wb_sunny_rounded,
        title: l10n.careKeyLight,
        subtitle: lightLine,
        body: l10n.plantDetailCareLightBody,
      ),
      const SizedBox(height: 12),
      _CareCard(
        icon: Icons.thermostat_rounded,
        title: l10n.plantDetailCareTempTitle,
        subtitle: [tempLine, humidityLine].whereType<String>().join('\n'),
        body: [
          l10n.plantDetailCareTempBody,
          if (soilLine != null) '${l10n.commonSoil}: $soilLine',
          if (phLine != null) phLine,
        ].join('\n\n'),
      ),
    ];

    if (baseMist != null) {
      blocks.add(const SizedBox(height: 12));
      blocks.add(
        _CareCard(
          icon: Icons.blur_on_rounded,
          title: l10n.taskTypeMist,
          subtitle: baseMist,
          body: l10n.commonWhy,
        ),
      );
    }

    final pestLines = <String>[
      ...?pests?.commonPests.map((e) => '• $e'),
      ...?pests?.commonDiseases.map((e) => '• $e'),
    ];
    final preventionLines =
        pests?.prevention.map((e) => '• $e').toList(growable: false) ??
            const <String>[];

    if (pruneWhen != null ||
        pruneHow != null ||
        pestLines.isNotEmpty ||
        preventionLines.isNotEmpty) {
      blocks.add(const SizedBox(height: 12));
      blocks.add(
        _CareCard(
          icon: Icons.content_cut_rounded,
          title: l10n.taskTypePrune,
          body: [
            if (pruneWhen != null && pruneWhen.trim().isNotEmpty)
              '${l10n.commonWhen}: ${pruneWhen.trim()}',
            if (pruneHow != null && pruneHow.trim().isNotEmpty)
              '${l10n.commonHow}: ${pruneHow.trim()}',
            if (pestLines.isNotEmpty) ...[
              l10n.commonPestsAndDiseases,
              pestLines.join('\n'),
            ],
            if (preventionLines.isNotEmpty) ...[
              l10n.commonPrevention,
              preventionLines.join('\n'),
            ],
          ].join('\n\n'),
        ),
      );
    }

    final extremeLines = <String>[];
    if (extreme?.heatwave case final heat?) {
      final header = heat.riskAboveC == null
          ? l10n.commonHeatwave
          : '${l10n.commonHeatwave} ≥ ${heat.riskAboveC}°C';
      extremeLines.add(header);
      for (final a in heat.actions) {
        extremeLines.add('• $a');
      }
      extremeLines.add('');
    }
    if (extreme?.frost case final frost?) {
      final header = frost.riskBelowC == null
          ? l10n.commonFrost
          : '${l10n.commonFrost} ≤ ${frost.riskBelowC}°C';
      extremeLines.add(header);
      for (final a in frost.actions) {
        extremeLines.add('• $a');
      }
      extremeLines.add('');
    }
    if ((extreme?.stormActions ?? const <String>[]).isNotEmpty) {
      extremeLines.add(l10n.commonStorm);
      for (final a in extreme!.stormActions) {
        extremeLines.add('• $a');
      }
      extremeLines.add('');
    }
    if ((extreme?.heavyRainActions ?? const <String>[]).isNotEmpty) {
      extremeLines.add(l10n.commonHeavyRain);
      for (final a in extreme!.heavyRainActions) {
        extremeLines.add('• $a');
      }
      extremeLines.add('');
    }
    if ((strategies?.hotDry ?? const <String>[]).isNotEmpty) {
      extremeLines.add(l10n.commonClimateHotDry);
      for (final a in strategies!.hotDry) {
        extremeLines.add('• $a');
      }
      extremeLines.add('');
    }
    if ((strategies?.coolWet ?? const <String>[]).isNotEmpty) {
      extremeLines.add(l10n.commonClimateCoolWet);
      for (final a in strategies!.coolWet) {
        extremeLines.add('• $a');
      }
      extremeLines.add('');
    }

    if (extremeLines.isNotEmpty) {
      blocks.add(const SizedBox(height: 12));
      blocks.add(
        _CareCard(
          icon: Icons.thunderstorm_rounded,
          title: l10n.commonClimateStrategies,
          body: extremeLines.join('\n').trim(),
        ),
      );
    }

    return ListView(
      padding: BotanicaTokens.pagePadding.copyWith(bottom: 120),
      children: blocks,
    );
  }
}

class _CareCard extends StatelessWidget {
  const _CareCard({
    required this.icon,
    required this.title,
    required this.body,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BotanicaGlassCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 10),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon, color: scheme.onSurface.withValues(alpha: 0.80)),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: (subtitle == null || subtitle!.trim().isEmpty)
            ? Text(
                l10n.commonWhy,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.65),
                ),
              )
            : Text(
                subtitle!.trim(),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCareTipSection extends ConsumerWidget {
  const _AiCareTipSection({
    required this.plant,
    required this.tasks,
    required this.localeCode,
    required this.speciesName,
    required this.scientificName,
  });

  final Plant plant;
  final List<TaskInstance> tasks;
  final String localeCode;
  final String speciesName;
  final String? scientificName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    if (!settings.enableAiInsights) return const SizedBox.shrink();

    final ai = ref.read(botanicaAiServiceProvider);
    if (!ai.isConfigured) return const SizedBox.shrink();

    final pending = tasks.where((t) => !t.isDone).toList(growable: false)
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    final l10n = AppLocalizations.of(context);
    final pendingLabels = <String>[];
    final seen = <TaskType>{};
    for (final t in pending) {
      if (!seen.add(t.type)) continue;
      pendingLabels.add(_taskTypeLabel(l10n, t.type));
      if (pendingLabels.length >= 3) break;
    }

    if (pendingLabels.isEmpty) return const SizedBox.shrink();

    final env = ref.watch(environmentSnapshotProvider);
    final request = PlantCareTipRequest(
      date: DateTime.now(),
      localeCode: localeCode,
      plantId: plant.id,
      plantNickname: plant.nickname,
      speciesId: plant.speciesId,
      speciesName: speciesName,
      scientificName: scientificName,
      environmentMode: plant.environmentMode,
      tempC: env.tempC,
      humidityPercent: env.humidity,
      pendingTasks: pendingLabels,
    );

    final tipAsync = ref.watch(plantCareTipProvider(request));
    final scheme = Theme.of(context).colorScheme;

    return tipAsync.when(
      loading: () => BotanicaGlassCard(
        tier: GlassTier.subtle,
        padding: BotanicaTokens.cardPaddingDense,
        child: _AiTipSkeleton(color: scheme.onSurface.withValues(alpha: 0.10)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (text) {
        final value = text?.trim();
        if (value == null || value.isEmpty) return const SizedBox.shrink();

        return BotanicaGlassCard(
          tier: GlassTier.subtle,
          padding: BotanicaTokens.cardPaddingDense,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: scheme.onSurface.withValues(alpha: 0.78),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.plantCareAiTipTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.76),
                            height: 1.42,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AiTipSkeleton extends StatelessWidget {
  const _AiTipSkeleton({required this.color});

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
        line(0.42),
        const SizedBox(height: 12),
        line(0.95),
        const SizedBox(height: 10),
        line(0.70),
      ],
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
          duration: 1200.ms,
          color: scheme.onSurface.withValues(alpha: 0.08),
        );
  }
}

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
