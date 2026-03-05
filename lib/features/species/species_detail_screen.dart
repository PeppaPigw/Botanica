import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/glass_card.dart';
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
      loading: () => BotanicaPageScaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation(scheme.primary.withValues(alpha: 0.7)),
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
              primaryAction: OutlinedButton.icon(
                onPressed: () => ref.invalidate(speciesListProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.commonTryAgain),
              ),
              secondaryAction: TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.commonClose),
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
            loading: () => BotanicaPageScaffold(
              appBar: AppBar(),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    scheme.primary.withValues(alpha: 0.7),
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
                    primaryAction: OutlinedButton.icon(
                      onPressed: () {
                        ref.invalidate(plantIdeaMapProvider);
                        ref.invalidate(plantIdeaListProvider);
                        ref.invalidate(plantIdeaByIdProvider(speciesId));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.commonTryAgain),
                    ),
                    secondaryAction: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.commonClose),
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
                        primaryAction: OutlinedButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close_rounded),
                          label: Text(l10n.commonClose),
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
                  ? 'assets/placeholders/species/unknown.png'
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
                                  'assets/placeholders/species/unknown.png',
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
                                      scheme.surface.withValues(alpha: 0.15),
                                      scheme.surface.withValues(alpha: 0.72),
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
                                      const SizedBox(height: 4),
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
                                        const SizedBox(height: 8),
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
                      ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.04),
                      const SizedBox(height: 14),
                      BotanicaGlassCard(
                        padding: const EdgeInsets.all(14),
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
                      ).animate().fadeIn(delay: 120.ms, duration: 420.ms),
                      const SizedBox(height: 14),
                      if (habit != null && habit.trim().isNotEmpty) ...[
                        _SectionHeader(title: l10n.speciesDetailHabit),
                        const SizedBox(height: 10),
                        BotanicaGlassCard(
                          child: Text(
                            habit.trim(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.74),
                              height: 1.5,
                            ),
                          ),
                        ).animate().fadeIn(delay: 150.ms, duration: 420.ms),
                        const SizedBox(height: 14),
                      ],
                      if (history != null && history.trim().isNotEmpty) ...[
                        _SectionHeader(title: l10n.speciesDetailHistory),
                        const SizedBox(height: 10),
                        BotanicaGlassCard(
                          child: Text(
                            history.trim(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.74),
                              height: 1.5,
                            ),
                          ),
                        ).animate().fadeIn(delay: 170.ms, duration: 420.ms),
                        const SizedBox(height: 14),
                      ],
                      _SectionHeader(title: l10n.speciesDetailCareAtAGlance),
                      const SizedBox(height: 10),
                      BotanicaGlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FactRow(
                              icon: Icons.water_drop_rounded,
                              title: l10n.taskTypeWater,
                              value: l10n.speciesDetailWaterEvery(
                                idea.careDefaults.waterBaseDays,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _FactRow(
                              icon: Icons.science_rounded,
                              title: l10n.taskTypeFertilize,
                              value: l10n.speciesDetailFertilizeEvery(
                                idea.careDefaults.fertilizeBaseDays,
                              ),
                            ),
                            if (idea.careDefaults.mistBaseDays > 0) ...[
                              const SizedBox(height: 10),
                              _FactRow(
                                icon: Icons.blur_on_rounded,
                                title: l10n.taskTypeMist,
                                value: l10n.speciesDetailMistEvery(
                                  idea.careDefaults.mistBaseDays,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 420.ms),
                      const SizedBox(height: 14),
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
                      ).animate().fadeIn(delay: 240.ms, duration: 420.ms),
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
        final growth = resolvedSpecies.growth;
        final size = resolvedSpecies.matureSize;
        final image = (resolvedSpecies.imagePath ?? '').trim().isEmpty
            ? 'assets/placeholders/species/unknown.png'
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
                            'assets/placeholders/species/unknown.png',
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
                                scheme.surface.withValues(alpha: 0.15),
                                scheme.surface.withValues(alpha: 0.72),
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
                                const SizedBox(height: 4),
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
                                  const SizedBox(height: 8),
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
                ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.04),
                const SizedBox(height: 14),
                BotanicaGlassCard(
                  padding: const EdgeInsets.all(14),
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
                ).animate().fadeIn(delay: 120.ms, duration: 420.ms),
                const SizedBox(height: 14),
                if (habit != null && habit.trim().isNotEmpty) ...[
                  _SectionHeader(title: l10n.speciesDetailHabit),
                  const SizedBox(height: 10),
                  BotanicaGlassCard(
                    child: Text(
                      habit.trim(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.74),
                        height: 1.5,
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 420.ms),
                  const SizedBox(height: 14),
                ],
                if (history != null && history.trim().isNotEmpty) ...[
                  _SectionHeader(title: l10n.speciesDetailHistory),
                  const SizedBox(height: 10),
                  BotanicaGlassCard(
                    child: Text(
                      history.trim(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.74),
                        height: 1.5,
                      ),
                    ),
                  ).animate().fadeIn(delay: 180.ms, duration: 420.ms),
                  const SizedBox(height: 14),
                ],
                if (origin != null ||
                    toxicity != null ||
                    growth != null ||
                    size != null) ...[
                  _SectionHeader(title: l10n.speciesDetailDetails),
                  const SizedBox(height: 10),
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
                          const SizedBox(height: 10),
                          _FactRow(
                            icon: Icons.pets_rounded,
                            title: l10n.speciesDetailToxicity,
                            value: _toxicityPetsLabel(l10n, toxicity),
                          ),
                        ],
                        if (growth != null) ...[
                          const SizedBox(height: 10),
                          _FactRow(
                            icon: Icons.trending_up_rounded,
                            title: l10n.speciesDetailGrowth,
                            value: _growthLabel(l10n, growth),
                          ),
                        ],
                        if (size != null) ...[
                          const SizedBox(height: 10),
                          _FactRow(
                            icon: Icons.straighten_rounded,
                            title: l10n.speciesDetailSizeHeight,
                            value: _rangeCm(l10n, size.heightCm),
                          ),
                          const SizedBox(height: 10),
                          _FactRow(
                            icon: Icons.open_in_full_rounded,
                            title: l10n.speciesDetailSizeSpread,
                            value: _rangeCm(l10n, size.spreadCm),
                          ),
                          if (size.vineLengthCm != null) ...[
                            const SizedBox(height: 10),
                            _FactRow(
                              icon: Icons.ssid_chart_rounded,
                              title: l10n.speciesDetailSizeVineLength,
                              value: _rangeCm(l10n, size.vineLengthCm!),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 190.ms, duration: 420.ms),
                  if (toxicityNote != null &&
                      toxicityNote.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    BotanicaGlassCard(
                      padding: BotanicaTokens.cardPaddingDense,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: scheme.onSurface.withValues(alpha: 0.78),
                          ),
                          const SizedBox(width: 10),
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
                    ).animate().fadeIn(delay: 205.ms, duration: 420.ms),
                  ],
                  const SizedBox(height: 14),
                ],
                _SectionHeader(title: l10n.speciesDetailCareAtAGlance),
                const SizedBox(height: 10),
                BotanicaGlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FactRow(
                        icon: Icons.water_drop_rounded,
                        title: l10n.taskTypeWater,
                        value: l10n.speciesDetailWaterEvery(
                          species.careDefaults.waterBaseDays,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _FactRow(
                        icon: Icons.science_rounded,
                        title: l10n.taskTypeFertilize,
                        value: l10n.speciesDetailFertilizeEvery(
                          species.careDefaults.fertilizeBaseDays,
                        ),
                      ),
                      if (species.careDefaults.mistBaseDays > 0) ...[
                        const SizedBox(height: 10),
                        _FactRow(
                          icon: Icons.blur_on_rounded,
                          title: l10n.taskTypeMist,
                          value: l10n.speciesDetailMistEvery(
                            species.careDefaults.mistBaseDays,
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 420.ms),
                const SizedBox(height: 14),
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
                ).animate().fadeIn(delay: 240.ms, duration: 420.ms),
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
            letterSpacing: -0.3,
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
          Icon(icon, size: 16, color: scheme.onSurface.withValues(alpha: 0.72)),
          const SizedBox(width: 6),
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 14),
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
                      size: 18,
                      color: Theme.of(context).colorScheme.inversePrimary),
                  const SizedBox(width: 10),
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
                    size: 18,
                    color: Theme.of(context).colorScheme.inversePrimary),
                const SizedBox(width: 10),
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
        Icon(icon, size: 20, color: scheme.onSurface.withValues(alpha: 0.78)),
        const SizedBox(width: 10),
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

String _rangeCm(AppLocalizations l10n, SizeRangeCm range) {
  if (range.min == range.max) {
    return l10n.speciesDetailCmValue(range.min);
  }
  return l10n.speciesDetailRangeCm(range.min, range.max);
}
