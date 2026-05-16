import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/botanica_shimmer.dart';
import '../../domain/models/plant_idea.dart';
import '../../domain/models/species.dart';
import '../../gen/l10n/app_localizations.dart';
import '../garden/garden_screen.dart';

class SpeciesDetailScreen extends ConsumerWidget {
  const SpeciesDetailScreen({super.key, required this.speciesId});

  static const String subLocation = 'species/:id';

  final String speciesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final localeCode = ref.watch(settingsControllerProvider).localeCode ??
        Localizations.localeOf(context).languageCode;

    final speciesAsync = ref.watch(speciesListProvider);
    final ideaAsync = ref.watch(plantIdeaByIdProvider(speciesId));

    return speciesAsync.when(
      loading: () => const BotanicaPageScaffold(
        body: SafeArea(
          child: Padding(
            padding: BotanicaTokens.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BotanicaShimmer.card(height: 200),
                SizedBox(height: BotanicaTokens.spacingRelaxed),
                BotanicaShimmer(width: 200, height: 24),
                SizedBox(height: BotanicaTokens.spacingSm),
                BotanicaShimmer(width: 140, height: 14),
                SizedBox(height: BotanicaTokens.spacingXxl),
                BotanicaShimmer.card(height: 80),
                SizedBox(height: BotanicaTokens.spacingBase),
                BotanicaShimmer.card(height: 80),
              ],
            ),
          ),
        ),
      ),
      error: (_, __) => BotanicaPageScaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: BotanicaTokens.pagePadding,
            child: BotanicaStateCard(
              icon: Icons.cloud_off_rounded,
              title: l10n.stateLoadFailedTitle,
              body: l10n.stateLoadFailedBody,
              primaryAction: BotanicaButton(
                variant: BotanicaButtonVariant.outlined,
                onPressed: () => ref.invalidate(speciesListProvider),
                icon: Icons.refresh_rounded,
                label: l10n.commonTryAgain,
              ),
              secondaryAction: BotanicaButton(
                variant: BotanicaButtonVariant.text,
                onPressed: () => context.pop(),
                label: l10n.commonClose,
              ),
            ),
          ),
        ),
      ),
      data: (list) {
        Species? species;
        for (final s in list) {
          if (s.id == speciesId) {
            species = s;
            break;
          }
        }

        if (species == null) {
          return ideaAsync.when(
            loading: () => const BotanicaPageScaffold(
              body: SafeArea(
                child: Padding(
                  padding: BotanicaTokens.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BotanicaShimmer.card(height: 200),
                      SizedBox(height: BotanicaTokens.spacingRelaxed),
                      BotanicaShimmer(width: 200, height: 24),
                      SizedBox(height: BotanicaTokens.spacingSm),
                      BotanicaShimmer(width: 140, height: 14),
                    ],
                  ),
                ),
              ),
            ),
            error: (_, __) => BotanicaPageScaffold(
              appBar: AppBar(),
              body: Center(
                child: Padding(
                  padding: BotanicaTokens.pagePadding,
                  child: BotanicaStateCard(
                    icon: Icons.cloud_off_rounded,
                    title: l10n.stateLoadFailedTitle,
                    body: l10n.stateLoadFailedBody,
                    primaryAction: BotanicaButton(
                      variant: BotanicaButtonVariant.outlined,
                      onPressed: () {
                        ref.invalidate(plantIdeaMapProvider);
                        ref.invalidate(plantIdeaListProvider);
                        ref.invalidate(plantIdeaByIdProvider(speciesId));
                      },
                      icon: Icons.refresh_rounded,
                      label: l10n.commonTryAgain,
                    ),
                    secondaryAction: BotanicaButton(
                      variant: BotanicaButtonVariant.text,
                      onPressed: () => context.pop(),
                      label: l10n.commonClose,
                    ),
                  ),
                ),
              ),
            ),
            data: (idea) {
              if (idea == null) {
                return BotanicaPageScaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: Padding(
                      padding: BotanicaTokens.pagePadding,
                      child: BotanicaStateCard(
                        icon: Icons.spa_rounded,
                        title: l10n.stateNotAvailableTitle,
                        body: l10n.stateNotAvailableBody,
                        primaryAction: BotanicaButton(
                          variant: BotanicaButtonVariant.outlined,
                          onPressed: () => context.pop(),
                          icon: Icons.close_rounded,
                          label: l10n.commonClose,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final title = idea.bestCommonName(localeCode);
              final habit = idea.habit(localeCode);
              final history = idea.history(localeCode);
              final image = idea.imagePath.trim().isEmpty
                  ? 'assets/images/placeholder_plant.jpg'
                  : idea.imagePath.trim();

              return BotanicaPageScaffold(
                appBar: AppBar(title: Text(title)),
                body: SafeArea(
                  child: ListView(
                    padding: BotanicaTokens.pagePadding.copyWith(bottom: 26),
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(BotanicaTokens.radiusXL),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                image,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/placeholder_plant.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.0, 0.45, 1.0],
                                    colors: [
                                      Colors.transparent,
                                      scheme.surface.withValues(alpha: 0.35),
                                      scheme.surface.withValues(alpha: 0.95),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    14,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style:
                                            textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.6,
                                        ),
                                      ),
                                      BotanicaGaps.vTiny,
                                      Text(
                                        idea.scientificName,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: scheme.onSurface
                                              .withValues(alpha: 0.72),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (habit != null &&
                                          habit.trim().isNotEmpty) ...[
                                        BotanicaGaps.vXs,
                                        Text(
                                          habit.trim(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurface
                                                .withValues(alpha: 0.72),
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animateSection(index: 0),
                      BotanicaGaps.vSm,
                      BotanicaGlassCard(
                        padding: BotanicaTokens.cardPaddingDense,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if ((idea.difficulty ?? '').trim().isNotEmpty)
                              _Tag(
                                icon: Icons.school_rounded,
                                label: difficultyLabel(
                                  l10n,
                                  idea.difficulty!.trim(),
                                ),
                              ),
                            if ((idea.light ?? '').trim().isNotEmpty)
                              _Tag(
                                icon: Icons.wb_sunny_rounded,
                                label: lightLabel(l10n, idea.light!.trim()),
                              ),
                            _Tag(
                              icon: Icons.pets_rounded,
                              label: idea.petSafe
                                  ? l10n.discoverTagPetSafe
                                  : l10n.discoverTagToxic,
                            ),
                            _Tag(
                              icon: Icons.water_drop_rounded,
                              label: l10n.speciesDetailWaterEvery(
                                idea.careDefaults.waterBaseDays,
                              ),
                            ),
                          ],
                        ),
                      ).animateSection(index: 1),
                      BotanicaGaps.vSm,
                      if (habit != null && habit.trim().isNotEmpty) ...[
                        _SectionHeader(title: l10n.speciesDetailHabit),
                        BotanicaGaps.vSm,
                        BotanicaGlassCard(
                          child: Text(
                            habit.trim(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.74),
                              height: 1.5,
                            ),
                          ),
                        ).animateSection(index: 2),
                        BotanicaGaps.vSm,
                      ],
                      if (history != null && history.trim().isNotEmpty) ...[
                        _SectionHeader(title: l10n.speciesDetailHistory),
                        BotanicaGaps.vSm,
                        BotanicaGlassCard(
                          child: Text(
                            history.trim(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.74),
                              height: 1.5,
                            ),
                          ),
                        ).animateSection(index: 3),
                        BotanicaGaps.vSm,
                      ],
                      _SectionHeader(title: l10n.speciesDetailCareAtAGlance),
                      BotanicaGaps.vSm,
                      _CareFactsGrid(
                        facts: [
                          _CareFact(
                            icon: Icons.water_drop_rounded,
                            title: l10n.taskTypeWater,
                            value: l10n.speciesDetailWaterEvery(
                              idea.careDefaults.waterBaseDays,
                            ),
                          ),
                          _CareFact(
                            icon: Icons.wb_sunny_rounded,
                            title: l10n.careKeyLight,
                            value: (idea.light ?? '').trim().isEmpty
                                ? l10n.speciesDetailUnknown
                                : lightLabel(l10n, idea.light!.trim()),
                          ),
                          _CareFact(
                            icon: Icons.school_rounded,
                            title: l10n.discoverFilterDifficulty,
                            value: (idea.difficulty ?? '').trim().isEmpty
                                ? l10n.speciesDetailUnknown
                                : difficultyLabel(
                                    l10n,
                                    idea.difficulty!.trim(),
                                  ),
                          ),
                          _CareFact(
                            icon: Icons.pets_rounded,
                            title: l10n.speciesDetailToxicity,
                            value: idea.petSafe
                                ? l10n.discoverTagPetSafe
                                : l10n.discoverTagToxic,
                          ),
                          _CareFact(
                            icon: Icons.trending_up_rounded,
                            title: l10n.speciesDetailGrowth,
                            value: (idea.growth?.rate ?? '').trim().isEmpty
                                ? l10n.speciesDetailUnknown
                                : _growthRateLabel(
                                    l10n,
                                    idea.growth!.rate!.trim(),
                                  ),
                          ),
                          _CareFact(
                            icon: Icons.straighten_rounded,
                            title: l10n.speciesDetailDetails,
                            value: idea.growth?.matureSizeCm == null
                                ? l10n.speciesDetailUnknown
                                : _ideaMatureSizeLabel(
                                    l10n,
                                    idea.growth!.matureSizeCm!,
                                  ),
                            ),
                        ],
                      ).animateSection(index: 4),
                      if (idea.tags.isNotEmpty) ...[
                        BotanicaGaps.vSm,
                        _GoodForTags(tags: idea.tags).animateSection(index: 5),
                      ],
                      BotanicaGaps.vSm,
                      _ResourcesSection(idea: idea),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const ValueKey('add-to-garden'),
                          onPressed: () => context.push(
                            '${GardenScreen.location}/add?speciesId=${idea.plantId}',
                          ),
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.scanAddToGarden),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                BotanicaTokens.radiusXL,
                              ),
                            ),
                          ),
                        ),
                      ).animateSection(index: 5),
                    ],
                  ),
                ),
              );
            },
          );
        }

        final resolvedSpecies = species;
        final title = resolvedSpecies.bestCommonName(localeCode);
        final habit = resolvedSpecies.habit(localeCode);
        final history = resolvedSpecies.history(localeCode);
        final origin = resolvedSpecies.originNativeRange(localeCode);
        final toxicity = resolvedSpecies.toxicity;
        final toxicityNote = resolvedSpecies.toxicityNotes(localeCode);
        final careWarning = resolvedSpecies.careWarnings(localeCode);
        final growth = resolvedSpecies.growth;
        final size = resolvedSpecies.matureSize;
        final image = (resolvedSpecies.imagePath ?? '').trim().isEmpty
            ? 'assets/images/placeholder_plant.jpg'
            : resolvedSpecies.imagePath!.trim();

        return BotanicaPageScaffold(
          appBar: AppBar(title: Text(title)),
          body: SafeArea(
            child: ListView(
              padding: BotanicaTokens.pagePadding.copyWith(bottom: 26),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          image,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/placeholder_plant.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.45, 1.0],
                              colors: [
                                Colors.transparent,
                                scheme.surface.withValues(alpha: 0.35),
                                scheme.surface.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                BotanicaGaps.vTiny,
                                Text(
                                  species.scientificName,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (habit != null &&
                                    habit.trim().isNotEmpty) ...[
                                  BotanicaGaps.vXs,
                                  Text(
                                    habit.trim(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.72),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animateSection(index: 0),
                BotanicaGaps.vSm,
                BotanicaGlassCard(
                  padding: BotanicaTokens.cardPaddingDense,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Tag(
                        icon: Icons.school_rounded,
                        label: difficultyLabel(l10n, species.difficulty),
                      ),
                      _Tag(
                        icon: Icons.wb_sunny_rounded,
                        label: lightLabel(l10n, species.light),
                      ),
                      _Tag(
                        icon: Icons.pets_rounded,
                        label: species.petSafe
                            ? l10n.discoverTagPetSafe
                            : l10n.discoverTagToxic,
                      ),
                      _Tag(
                        icon: Icons.water_drop_rounded,
                        label: l10n.speciesDetailWaterEvery(
                            species.careDefaults.waterBaseDays),
                      ),
                    ],
                  ),
                ).animateSection(index: 1),
                BotanicaGaps.vSm,
                if (habit != null && habit.trim().isNotEmpty) ...[
                  _SectionHeader(title: l10n.speciesDetailHabit),
                  BotanicaGaps.vSm,
                  BotanicaGlassCard(
                    child: Text(
                      habit.trim(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.74),
                        height: 1.5,
                      ),
                    ),
                  ).animateSection(index: 2),
                  BotanicaGaps.vSm,
                ],
                if (history != null && history.trim().isNotEmpty) ...[
                  _SectionHeader(title: l10n.speciesDetailHistory),
                  BotanicaGaps.vSm,
                  BotanicaGlassCard(
                    child: Text(
                      history.trim(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.74),
                        height: 1.5,
                      ),
                    ),
                  ).animateSection(index: 3),
                  BotanicaGaps.vSm,
                ],
                if (origin != null ||
                    toxicity != null ||
                    growth != null ||
                    size != null) ...[
                  _SectionHeader(title: l10n.speciesDetailDetails),
                  BotanicaGaps.vSm,
                  BotanicaGlassCard(
                    padding: BotanicaTokens.cardPaddingDense,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FactRow(
                          icon: Icons.public_rounded,
                          title: l10n.speciesDetailOrigin,
                          value: origin ?? l10n.speciesDetailUnknown,
                        ),
                        if (toxicity != null) ...[
                          BotanicaGaps.vSm,
                          _FactRow(
                            icon: Icons.pets_rounded,
                            title: l10n.speciesDetailToxicity,
                            value: _toxicityPetsLabel(l10n, toxicity),
                          ),
                        ],
                        if (growth != null) ...[
                          BotanicaGaps.vSm,
                          _FactRow(
                            icon: Icons.trending_up_rounded,
                            title: l10n.speciesDetailGrowth,
                            value: _growthLabel(l10n, growth),
                          ),
                        ],
                        if (size != null) ...[
                          BotanicaGaps.vSm,
                          _FactRow(
                            icon: Icons.straighten_rounded,
                            title: l10n.speciesDetailSizeHeight,
                            value: _rangeCm(l10n, size.heightCm),
                          ),
                          BotanicaGaps.vSm,
                          _FactRow(
                            icon: Icons.open_in_full_rounded,
                            title: l10n.speciesDetailSizeSpread,
                            value: _rangeCm(l10n, size.spreadCm),
                          ),
                          if (size.vineLengthCm != null) ...[
                            BotanicaGaps.vSm,
                            _FactRow(
                              icon: Icons.ssid_chart_rounded,
                              title: l10n.speciesDetailSizeVineLength,
                              value: _rangeCm(l10n, size.vineLengthCm!),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ).animateSection(index: 4),
                  if (careWarning != null &&
                      careWarning.trim().isNotEmpty) ...[
                    BotanicaGaps.vSm,
                    BotanicaGlassCard(
                      padding: BotanicaTokens.cardPaddingDense,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: BotanicaTokens.iconSizeMd,
                            color: scheme.error.withValues(alpha: 0.86),
                          ),
                          BotanicaGaps.hSm,
                          Expanded(
                            child: Text(
                              careWarning.trim(),
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.78),
                                height: 1.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animateSection(index: 5),
                  ],
                  if (toxicityNote != null &&
                      toxicityNote.trim().isNotEmpty) ...[
                    BotanicaGaps.vSm,
                    BotanicaGlassCard(
                      padding: BotanicaTokens.cardPaddingDense,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: BotanicaTokens.iconSizeMd,
                            color: scheme.onSurface.withValues(alpha: 0.78),
                          ),
                          BotanicaGaps.hSm,
                          Expanded(
                            child: Text(
                              toxicityNote.trim(),
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.72),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animateSection(index: 5),
                  ],
                  BotanicaGaps.vSm,
                ],
                _SectionHeader(title: l10n.speciesDetailCareAtAGlance),
                BotanicaGaps.vSm,
                _CareFactsGrid(
                  facts: [
                    _CareFact(
                      icon: Icons.water_drop_rounded,
                      title: l10n.taskTypeWater,
                      value: l10n.speciesDetailWaterEvery(
                        species.careDefaults.waterBaseDays,
                      ),
                    ),
                    _CareFact(
                      icon: Icons.wb_sunny_rounded,
                      title: l10n.careKeyLight,
                      value: lightLabel(l10n, species.light),
                    ),
                    _CareFact(
                      icon: Icons.school_rounded,
                      title: l10n.discoverFilterDifficulty,
                      value: difficultyLabel(l10n, species.difficulty),
                    ),
                    _CareFact(
                      icon: Icons.pets_rounded,
                      title: l10n.speciesDetailToxicity,
                      value: species.petSafe
                          ? l10n.discoverTagPetSafe
                          : l10n.discoverTagToxic,
                    ),
                    _CareFact(
                      icon: Icons.trending_up_rounded,
                      title: l10n.speciesDetailGrowth,
                      value: growth == null
                          ? l10n.speciesDetailUnknown
                          : _growthRateLabel(l10n, growth.rate),
                    ),
                    _CareFact(
                      icon: Icons.straighten_rounded,
                      title: l10n.speciesDetailDetails,
                      value: size == null
                          ? l10n.speciesDetailUnknown
                          : _speciesMatureSizeLabel(l10n, size),
                    ),
                  ],
                ).animateSection(index: 6),
                if (species.tags.isNotEmpty) ...[
                  BotanicaGaps.vSm,
                  _GoodForTags(tags: species.tags).animateSection(index: 7),
                ],
                BotanicaGaps.vSm,
                ideaAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (idea) => _ResourcesSection(idea: idea),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('add-to-garden'),
                    onPressed: () => context.push(
                      '${GardenScreen.location}/add?speciesId=${resolvedSpecies.id}',
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.scanAddToGarden),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(BotanicaTokens.radiusXL),
                      ),
                    ),
                  ),
                ).animateSection(index: 7),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
        color: scheme.surface.withValues(alpha: 0.55),
        border:
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: BotanicaTokens.iconSizeSm, color: scheme.onSurface.withValues(alpha: 0.72)),
          BotanicaGaps.hXxs,
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.74),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourcesSection extends StatelessWidget {
  const _ResourcesSection({required this.idea});

  final PlantIdea? idea;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final wiki = idea?.externalResources.wikipedia?.trim() ?? '';
    final baike = idea?.externalResources.baiduBaikeSearch?.trim() ?? '';
    final yt = idea?.externalResources.youtubeSearch?.trim() ?? '';
    final bili = idea?.externalResources.bilibiliSearch?.trim() ?? '';
    final gbif = idea?.externalResources.gbif?.trim() ?? '';
    final guide = idea?.externalResources.careGuide?.trim() ?? '';

    final isChineseLocale =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'zh';

    final rows = <Widget>[];
    void addRow({
      required String url,
      required IconData icon,
      required String title,
    }) {
      if (url.trim().isEmpty) return;
      rows.add(_ResourceRow(icon: icon, title: title, url: url));
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.resourcesTitle),
        BotanicaGaps.vSm,
        BotanicaGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i != rows.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.28),
                  ),
              ],
            ],
          ),
        ),
        BotanicaGaps.vSm,
      ],
    );
  }
}

class _CareFact {
  const _CareFact({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class _CareFactsGrid extends StatelessWidget {
  const _CareFactsGrid({required this.facts});

  final List<_CareFact> facts;

  @override
  Widget build(BuildContext context) {
    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - BotanicaTokens.spacingSm) / 2;
          return Wrap(
            spacing: BotanicaTokens.spacingSm,
            runSpacing: BotanicaTokens.spacingSm,
            children: [
              for (final fact in facts)
                SizedBox(
                  width: itemWidth,
                  child: _CareFactTile(fact: fact),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CareFactTile extends StatelessWidget {
  const _CareFactTile({required this.fact});

  final _CareFact fact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(BotanicaTokens.spacingSm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        color: scheme.surface.withValues(alpha: 0.45),
        border:
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            fact.icon,
            size: BotanicaTokens.iconSizeSm,
            color: scheme.onSurface.withValues(alpha: 0.72),
          ),
          BotanicaGaps.vXs,
          Text(
            fact.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
          BotanicaGaps.vMicro,
          Text(
            fact.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.82),
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoodForTags extends StatelessWidget {
  const _GoodForTags({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final normalized = tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
    if (normalized.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: BotanicaTokens.spacingXs,
      runSpacing: BotanicaTokens.spacingXs,
      children: [
        for (final tag in normalized)
          BotanicaChip(
            label: _goodForTagLabel(l10n, tag),
            icon: _goodForTagIcon(tag),
            tint: scheme.tertiary,
            selected: true,
          ),
      ],
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({
    required this.icon,
    required this.title,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingMd,
        vertical: BotanicaTokens.spacingTiny,
      ),
      leading: Icon(icon, color: scheme.onSurface.withValues(alpha: 0.80)),
      title: Text(title),
      subtitle: Text(
        url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        tooltip: l10n.resourceCopyLink,
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: url));
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
        },
        icon: Icon(
          Icons.content_copy_rounded,
          color: scheme.onSurface.withValues(alpha: 0.70),
        ),
      ),
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: url));
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
      },
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: BotanicaTokens.iconSizeMd, color: scheme.onSurface.withValues(alpha: 0.78)),
        BotanicaGaps.hSm,
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.72),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String _toxicityPetsLabel(AppLocalizations l10n, SpeciesToxicity toxicity) {
  final value = toxicity.pets.trim().toLowerCase();
  return switch (value) {
    'pet_safe' => l10n.discoverTagPetSafe,
    'toxic' => l10n.discoverTagToxic,
    _ => l10n.speciesDetailUnknown,
  };
}

String _growthLabel(AppLocalizations l10n, SpeciesGrowth growth) {
  final form = _growthFormLabel(l10n, growth.form);
  final rate = _growthRateLabel(l10n, growth.rate);
  if (form == l10n.speciesDetailUnknown) return rate;
  if (rate == l10n.speciesDetailUnknown) return form;
  return '$form · $rate';
}

String _growthRateLabel(AppLocalizations l10n, String raw) {
  return switch (raw.trim().toLowerCase()) {
    'slow' => l10n.growthRateSlow,
    'moderate' => l10n.growthRateModerate,
    'fast' => l10n.growthRateFast,
    _ => l10n.growthRateUnknown,
  };
}

String _growthFormLabel(AppLocalizations l10n, String raw) {
  return switch (raw.trim().toLowerCase()) {
    'upright' => l10n.growthFormUpright,
    'trailing' => l10n.growthFormTrailing,
    'climbing' => l10n.growthFormClimbing,
    'rosette' => l10n.growthFormRosette,
    'tree_like' => l10n.growthFormTreeLike,
    'clumping' => l10n.growthFormClumping,
    'epiphytic' => l10n.growthFormEpiphytic,
    'succulent' => l10n.growthFormSucculent,
    'fern' => l10n.growthFormFern,
    'orchid' => l10n.growthFormOrchid,
    'other' => l10n.growthFormOther,
    _ => l10n.speciesDetailUnknown,
  };
}

String _speciesMatureSizeLabel(AppLocalizations l10n, SpeciesMatureSize size) {
  final height = _rangeCm(l10n, size.heightCm);
  final spread = _rangeCm(l10n, size.spreadCm);
  return '$height · $spread';
}

String _ideaMatureSizeLabel(
  AppLocalizations l10n,
  PlantIdeaMatureSizeCm size,
) {
  final height = size.heightCm == null
      ? l10n.speciesDetailUnknown
      : _ideaRangeCm(l10n, size.heightCm!);
  final spread = size.spreadCm == null
      ? l10n.speciesDetailUnknown
      : _ideaRangeCm(l10n, size.spreadCm!);
  if (height == l10n.speciesDetailUnknown) return spread;
  if (spread == l10n.speciesDetailUnknown) return height;
  return '$height · $spread';
}

String _ideaRangeCm(AppLocalizations l10n, PlantIdeaIntRange range) {
  if (range.min == range.max) {
    return l10n.speciesDetailCmValue(range.min);
  }
  return l10n.speciesDetailRangeCm(range.min, range.max);
}

String _rangeCm(AppLocalizations l10n, SizeRangeCm range) {
  if (range.min == range.max) {
    return l10n.speciesDetailCmValue(range.min);
  }
  return l10n.speciesDetailRangeCm(range.min, range.max);
}

String _goodForTagLabel(AppLocalizations l10n, String raw) {
  return switch (raw.trim().toLowerCase()) {
    'pet-safe' || 'pet_safe' => l10n.discoverTagPetSafe,
    'beginner' => 'Beginner',
    'low-light' || 'low_light' => 'Low light',
    'air-purifying' || 'air_purifying' => 'Air-purifying',
    final value => value
        .split(RegExp('[-_]'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' '),
  };
}

IconData _goodForTagIcon(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'pet-safe' || 'pet_safe' => Icons.pets_rounded,
    'beginner' => Icons.school_rounded,
    'low-light' || 'low_light' => Icons.nights_stay_rounded,
    'air-purifying' || 'air_purifying' => Icons.air_rounded,
    _ => Icons.local_florist_rounded,
  };
}
