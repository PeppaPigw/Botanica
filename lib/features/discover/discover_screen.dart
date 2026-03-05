import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/plant_idea_search.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/i18n/species_search.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/botanica_section.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/botanica_search_field.dart';
import '../../core/widgets/screen_title.dart';
import '../../domain/models/species.dart';
import '../../domain/models/plant_idea.dart';
import '../../gen/l10n/app_localizations.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  static const String location = '/discover';

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _petSafeOnly = false;
  String? _difficultyFilter;
  String? _lightFilter;

  bool get _hasActiveFilters =>
      _petSafeOnly || _difficultyFilter != null || _lightFilter != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDifficulty() async {
    final l10n = AppLocalizations.of(context);

    final value = await _showSingleSelectSheet(
      context: context,
      title: l10n.discoverFilterDifficulty,
      currentValue: _difficultyFilter,
      kindKey: 'difficulty',
      options: <(String? value, IconData icon, String label)>[
        (
          _kFilterSheetClearSentinel,
          Icons.filter_alt_off_rounded,
          l10n.commonClear
        ),
        ('easy', Icons.school_rounded, l10n.difficultyEasy),
        ('medium', Icons.school_rounded, l10n.difficultyMedium),
        ('hard', Icons.school_rounded, l10n.difficultyHard),
      ],
    );
    if (!mounted) return;
    if (value == null) return;
    setState(() {
      _difficultyFilter = value == _kFilterSheetClearSentinel ? null : value;
    });
  }

  Future<void> _pickLight() async {
    final l10n = AppLocalizations.of(context);

    final value = await _showSingleSelectSheet(
      context: context,
      title: l10n.discoverFilterLight,
      currentValue: _lightFilter,
      kindKey: 'light',
      options: <(String? value, IconData icon, String label)>[
        (
          _kFilterSheetClearSentinel,
          Icons.filter_alt_off_rounded,
          l10n.commonClear
        ),
        ('bright_direct', Icons.wb_sunny_rounded, l10n.lightBrightDirect),
        ('bright_indirect', Icons.wb_sunny_rounded, l10n.lightBrightIndirect),
        ('medium_indirect', Icons.wb_sunny_rounded, l10n.lightMediumIndirect),
        (
          'low_to_bright_indirect',
          Icons.wb_sunny_rounded,
          l10n.lightLowToBrightIndirect,
        ),
        ('low_to_bright', Icons.wb_sunny_rounded, l10n.lightLowToBright),
      ],
    );
    if (!mounted) return;
    if (value == null) return;
    setState(() {
      _lightFilter = value == _kFilterSheetClearSentinel ? null : value;
    });
  }

  void _clearFilters() {
    setState(() {
      _petSafeOnly = false;
      _difficultyFilter = null;
      _lightFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final localeCode = ref.watch(settingsControllerProvider).localeCode ??
        Localizations.localeOf(context).languageCode;
    final speciesAsync = ref.watch(speciesListProvider);
    final ideasAsync = ref.watch(plantIdeaListProvider);

    return SafeArea(
      child: ListView(
        padding: BotanicaTokens.pagePaddingWithBottomNav(context),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          BotanicaScreenTitle(l10n.navDiscover)
              .animate()
              .fadeIn(duration: 380.ms),
          BotanicaGaps.vSm,
          BotanicaSearchField(
            controller: _searchController,
            hintText: l10n.discoverSearchHint,
            onChanged: (_) => setState(() {}),
          )
              .animate()
              .fadeIn(delay: 80.ms, duration: 420.ms)
              .slideY(begin: 0.06),
          BotanicaGaps.vBase,
          Wrap(
            spacing: BotanicaTokens.spacingXs,
            runSpacing: BotanicaTokens.spacingXs,
            children: [
              BotanicaChip(
                key: const ValueKey('discover-filter-pets'),
                icon: Icons.pets_rounded,
                label: l10n.discoverFilterPetSafe,
                tint: scheme.tertiary,
                selected: _petSafeOnly,
                onTap: () => setState(() => _petSafeOnly = !_petSafeOnly),
              ),
              BotanicaChip(
                key: const ValueKey('discover-filter-light'),
                icon: Icons.wb_sunny_rounded,
                label: _lightFilter == null
                    ? l10n.discoverFilterLight
                    : '${l10n.discoverFilterLight}: ${lightLabel(l10n, _lightFilter!)}',
                tint: scheme.secondary,
                selected: _lightFilter != null,
                onTap: _pickLight,
              ),
              BotanicaChip(
                key: const ValueKey('discover-filter-difficulty'),
                icon: Icons.school_rounded,
                label: _difficultyFilter == null
                    ? l10n.discoverFilterDifficulty
                    : '${l10n.discoverFilterDifficulty}: ${difficultyLabel(l10n, _difficultyFilter!)}',
                tint: scheme.primary,
                selected: _difficultyFilter != null,
                onTap: _pickDifficulty,
              ),
              if (_hasActiveFilters)
                BotanicaChip(
                  key: const ValueKey('discover-filter-clear'),
                  icon: Icons.filter_alt_off_rounded,
                  label: l10n.commonClear,
                  tint: scheme.onSurface,
                  selected: true,
                  onTap: _clearFilters,
                ),
            ],
          ).animate().fadeIn(delay: 120.ms, duration: 420.ms),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          BotanicaSection(
            title: l10n.discoverSectionCurated,
            children: [
              speciesAsync.when(
                data: (species) {
                  final query = _searchController.text;
                  final trimmedQuery = query.trim();
                  final filteredByControls = species
                      .where(
                        (s) =>
                            (!_petSafeOnly || s.petSafe) &&
                            (_difficultyFilter == null ||
                                s.difficulty == _difficultyFilter) &&
                            (_lightFilter == null || s.light == _lightFilter),
                      )
                      .toList(growable: false);

                  final filteredBySearch = trimmedQuery.isEmpty
                      ? filteredByControls
                      : filteredByControls
                          .where(
                            (s) =>
                                speciesMatchesQuery(s, trimmedQuery) ||
                                _matchesCardDetails(s, trimmedQuery),
                          )
                          .toList(growable: false);

                  // Curated mode: show a compact set by default.
                  //
                  // But when the user is actively filtering (even with an empty
                  // query), show the full filtered list so the controls feel
                  // truthful and predictable.
                  final results = (trimmedQuery.isEmpty && !_hasActiveFilters)
                      ? filteredBySearch.take(6).toList()
                      : filteredBySearch;

                  if (results.isEmpty) {
                    return BotanicaStateCard(
                      key: const ValueKey('discover-no-results-curated'),
                      icon: Icons.search_off_rounded,
                      title: l10n.discoverNoResultsTitle,
                      body: l10n.discoverNoResultsBody,
                      illustrationAsset:
                          'assets/illustrations/empty_discover_search.jpg',
                      tier: GlassTier.subtle,
                    );
                  }

                  return Column(
                    children: [
                      ...results.toList(growable: false).asMap().entries.map(
                        (entry) {
                          final index = entry.key;
                          final s = entry.value;
                          final habit = _plantCardSnippet(s, localeCode);
                          final imagePath = _plantImagePath(s);
                          final isPlaceholder =
                              imagePath.endsWith('/unknown.png') ||
                                  imagePath.endsWith('unknown.png');
                          return Padding(
                            key: ValueKey('discover-species-${s.id}'),
                            padding: const EdgeInsets.only(
                              bottom: BotanicaTokens.spacingSm,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  BotanicaTokens.radiusXL),
                              onTap: () => context.push(
                                '${DiscoverScreen.location}/species/${s.id}',
                              ),
                              child: BotanicaGlassCard(
                                padding: BotanicaTokens.cardPaddingDense,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          BotanicaTokens.radiusL,
                                        ),
                                        border: Border.all(
                                          color: scheme.outlineVariant
                                              .withValues(alpha: 0.45),
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          BotanicaTokens.radiusL,
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(
                                              imagePath,
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                              gaplessPlayback: true,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                'assets/placeholders/species/unknown.png',
                                                fit: BoxFit.cover,
                                                gaplessPlayback: true,
                                              ),
                                            ),
                                            if (isPlaceholder) ...[
                                              DecoratedBox(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      scheme.primaryContainer
                                                          .withValues(
                                                              alpha: 0.28),
                                                      scheme.tertiaryContainer
                                                          .withValues(
                                                              alpha: 0.18),
                                                      scheme.surface.withValues(
                                                          alpha: 0.06),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Icon(
                                                  Icons.spa_rounded,
                                                  size: 22,
                                                  color: scheme.onSurface
                                                      .withValues(alpha: 0.78),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    BotanicaGaps.hSm,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.bestCommonName(localeCode),
                                            style:
                                                textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            s.scientificName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                textTheme.bodySmall?.copyWith(
                                              color: scheme.onSurface
                                                  .withValues(alpha: 0.65),
                                            ),
                                          ),
                                          if (habit != null) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              habit,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  textTheme.bodySmall?.copyWith(
                                                color: scheme.onSurface
                                                    .withValues(alpha: 0.70),
                                                height: 1.25,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _MiniTag(
                                                label: difficultyLabel(
                                                    l10n, s.difficulty),
                                                icon: Icons.school_rounded,
                                              ),
                                              _MiniTag(
                                                label: s.petSafe
                                                    ? l10n.discoverTagPetSafe
                                                    : l10n.discoverTagToxic,
                                                icon: Icons.pets_rounded,
                                              ),
                                              _MiniTag(
                                                label:
                                                    lightLabel(l10n, s.light),
                                                icon: Icons.wb_sunny_rounded,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(
                                    delay: (index * 45).ms, duration: 420.ms)
                                .slideY(
                                    begin: 0.06, curve: Curves.easeOutCubic),
                          );
                        },
                      ),
                    ],
                  );
                },
                error: (_, __) => BotanicaStateCard(
                  icon: Icons.cloud_off_rounded,
                  title: l10n.stateLoadFailedTitle,
                  body: l10n.stateLoadFailedBody,
                  primaryAction: BotanicaButton(
                    variant: BotanicaButtonVariant.outlined,
                    icon: Icons.refresh_rounded,
                    label: l10n.commonTryAgain,
                    onPressed: () => ref.invalidate(speciesListProvider),
                  ),
                ),
                loading: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          scheme.primary.withValues(alpha: 0.7)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          BotanicaSection(
            title: l10n.discoverSectionLibrary,
            children: [
              ideasAsync.when(
                data: (ideas) {
                  final query = _searchController.text;
                  final trimmedQuery = query.trim();
                  final filteredByControls = ideas
                      .where(
                        (idea) =>
                            (!_petSafeOnly || idea.petSafe) &&
                            (_difficultyFilter == null ||
                                idea.difficulty == _difficultyFilter) &&
                            (_lightFilter == null ||
                                idea.light == _lightFilter),
                      )
                      .toList(growable: false);

                  final filteredBySearch = trimmedQuery.isEmpty
                      ? filteredByControls
                      : filteredByControls
                          .where(
                            (idea) =>
                                plantIdeaMatchesQuery(idea, trimmedQuery) ||
                                _matchesIdeaCardDetails(idea, trimmedQuery),
                          )
                          .toList(growable: false);

                  final results = (trimmedQuery.isEmpty && !_hasActiveFilters)
                      ? filteredBySearch.take(10).toList()
                      : filteredBySearch;

                  if (results.isEmpty) {
                    return BotanicaStateCard(
                      key: const ValueKey('discover-no-results-library'),
                      icon: Icons.search_off_rounded,
                      title: l10n.discoverNoResultsTitle,
                      body: l10n.discoverNoResultsBody,
                    );
                  }

                  return Column(
                    children: [
                      ...results.toList(growable: false).asMap().entries.map(
                        (entry) {
                          final index = entry.key;
                          final idea = entry.value;
                          final habit = _plantIdeaCardSnippet(idea, localeCode);
                          final imagePath = _plantIdeaImagePath(idea);
                          final isPlaceholder =
                              imagePath.endsWith('/unknown.png') ||
                                  imagePath.endsWith('unknown.png');

                          return Padding(
                            key: ValueKey('discover-idea-${idea.plantId}'),
                            padding: const EdgeInsets.only(
                              bottom: BotanicaTokens.spacingSm,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  BotanicaTokens.radiusXL),
                              onTap: () => context.push(
                                '${DiscoverScreen.location}/species/${idea.plantId}',
                              ),
                              child: BotanicaGlassCard(
                                padding: BotanicaTokens.cardPaddingDense,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          BotanicaTokens.radiusL,
                                        ),
                                        border: Border.all(
                                          color: scheme.outlineVariant
                                              .withValues(alpha: 0.45),
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          BotanicaTokens.radiusL,
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(
                                              imagePath,
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                              gaplessPlayback: true,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                'assets/placeholders/species/unknown.png',
                                                fit: BoxFit.cover,
                                                gaplessPlayback: true,
                                              ),
                                            ),
                                            if (isPlaceholder) ...[
                                              DecoratedBox(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      scheme.primaryContainer
                                                          .withValues(
                                                              alpha: 0.28),
                                                      scheme.tertiaryContainer
                                                          .withValues(
                                                              alpha: 0.18),
                                                      scheme.surface.withValues(
                                                          alpha: 0.06),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Icon(
                                                  Icons.spa_rounded,
                                                  size: 22,
                                                  color: scheme.onSurface
                                                      .withValues(alpha: 0.78),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    BotanicaGaps.hSm,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            idea.bestCommonName(localeCode),
                                            style:
                                                textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            idea.scientificName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                textTheme.bodySmall?.copyWith(
                                              color: scheme.onSurface
                                                  .withValues(alpha: 0.65),
                                            ),
                                          ),
                                          if (habit != null) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              habit,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  textTheme.bodySmall?.copyWith(
                                                color: scheme.onSurface
                                                    .withValues(alpha: 0.70),
                                                height: 1.25,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              if ((idea.difficulty ?? '')
                                                  .trim()
                                                  .isNotEmpty)
                                                _MiniTag(
                                                  label: difficultyLabel(
                                                    l10n,
                                                    idea.difficulty!.trim(),
                                                  ),
                                                  icon: Icons.school_rounded,
                                                ),
                                              _MiniTag(
                                                label: idea.petSafe
                                                    ? l10n.discoverTagPetSafe
                                                    : l10n.discoverTagToxic,
                                                icon: Icons.pets_rounded,
                                              ),
                                              if ((idea.light ?? '')
                                                  .trim()
                                                  .isNotEmpty)
                                                _MiniTag(
                                                  label: lightLabel(
                                                    l10n,
                                                    idea.light!.trim(),
                                                  ),
                                                  icon: Icons.wb_sunny_rounded,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(
                                    delay: (index * 30).ms, duration: 420.ms)
                                .slideY(
                                    begin: 0.06, curve: Curves.easeOutCubic),
                          );
                        },
                      ),
                    ],
                  );
                },
                error: (_, __) => BotanicaStateCard(
                  icon: Icons.cloud_off_rounded,
                  title: l10n.stateLoadFailedTitle,
                  body: l10n.stateLoadFailedBody,
                  primaryAction: BotanicaButton(
                    variant: BotanicaButtonVariant.outlined,
                    icon: Icons.refresh_rounded,
                    label: l10n.commonTryAgain,
                    onPressed: () {
                      ref.invalidate(plantIdeaMapProvider);
                      ref.invalidate(plantIdeaListProvider);
                    },
                  ),
                ),
                loading: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                          scheme.primary.withValues(alpha: 0.7)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          BotanicaSection(
            title: l10n.discoverSectionGuides,
            children: [
              _GuideCard(
                title: l10n.discoverGuideWateringTitle,
                body: l10n.discoverGuideWateringBody,
                icon: Icons.water_drop_rounded,
              ),
              BotanicaGaps.vSm,
              _GuideCard(
                title: l10n.discoverGuideSoilTitle,
                body: l10n.discoverGuideSoilBody,
                icon: Icons.grass_rounded,
              ),
              BotanicaGaps.vSm,
              _GuideCard(
                title: l10n.discoverGuidePestTitle,
                body: l10n.discoverGuidePestBody,
                icon: Icons.bug_report_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Returned from filter sheets when the user explicitly selects "Clear".
///
/// `showModalBottomSheet` returns `null` when dismissed (tap outside / drag),
/// so we need a non-null sentinel to disambiguate "clear" vs "dismiss".
const String _kFilterSheetClearSentinel = '__botanica_clear_filter__';

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.construction_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.inversePrimary),
                const SizedBox(width: 10),
                Text(l10n.commonComingSoon),
              ],
            ),
          ),
        );
      },
      child: BotanicaGlassCard(
        padding: BotanicaTokens.cardPaddingDense,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer.withValues(alpha: 0.35),
                border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.45)),
              ),
              child:
                  Icon(icon, color: scheme.onSurface.withValues(alpha: 0.80)),
            ),
            BotanicaGaps.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: 0.55)),
          ],
        ),
      ),
    );
  }
}

bool _matchesCardDetails(Species species, String rawQuery) {
  final query = normalizeSearchText(rawQuery);
  if (query.isEmpty) return false;
  return _textEntriesContain(species.historyByLocale.values, query) ||
      _textEntriesContain(species.habitByLocale.values, query);
}

bool _textEntriesContain(Iterable<String> entries, String query) {
  for (final entry in entries) {
    if (normalizeSearchText(entry).contains(query)) return true;
  }
  return false;
}

String? _plantCardSnippet(Species species, String localeCode) {
  final habit = species.habit(localeCode);
  if (habit != null && habit.trim().isNotEmpty) {
    return habit.trim();
  }
  final history = species.history(localeCode);
  if (history != null && history.trim().isNotEmpty) {
    return history.trim();
  }
  return null;
}

String _plantImagePath(Species species) {
  final candidate = species.imagePath?.trim();
  if (candidate == null || candidate.isEmpty) {
    return 'assets/placeholders/species/unknown.png';
  }
  return candidate;
}

bool _matchesIdeaCardDetails(PlantIdea idea, String rawQuery) {
  final query = normalizeSearchText(rawQuery);
  if (query.isEmpty) return false;
  return _textEntriesContain(idea.historyByLocale.values, query) ||
      _textEntriesContain(idea.habitByLocale.values, query);
}

String? _plantIdeaCardSnippet(PlantIdea idea, String localeCode) {
  final habit = idea.habit(localeCode);
  if (habit != null && habit.trim().isNotEmpty) {
    return habit.trim();
  }
  final history = idea.history(localeCode);
  if (history != null && history.trim().isNotEmpty) {
    return history.trim();
  }
  return null;
}

String _plantIdeaImagePath(PlantIdea idea) {
  final candidate = idea.imagePath.trim();
  if (candidate.isEmpty) {
    return 'assets/placeholders/species/unknown.png';
  }
  return candidate;
}

Future<String?> _showSingleSelectSheet({
  required BuildContext context,
  required String title,
  required String? currentValue,
  required String kindKey,
  required List<(String? value, IconData icon, String label)> options,
}) {
  final l10n = AppLocalizations.of(context);

  return showBotanicaModalSheet<String?>(
    context: context,
    useSafeArea: false,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;

      return BotanicaSheetBody(
        top: 10,
        bottom: 18,
        includeKeyboardInset: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.80,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(currentValue),
                    child: Text(l10n.commonClose),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final selected = option.$1 == currentValue ||
                        (option.$1 == _kFilterSheetClearSentinel &&
                            currentValue == null);
                    final optionKeyValue =
                        option.$1 == _kFilterSheetClearSentinel
                            ? 'any'
                            : (option.$1 ?? 'any');

                    return BotanicaGlassCard(
                      padding: BotanicaTokens.cardPaddingTight,
                      child: ListTile(
                        key: ValueKey(
                          'discover-filter-$kindKey-$optionKeyValue',
                        ),
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          option.$2,
                          color: scheme.onSurface.withValues(alpha: 0.80),
                        ),
                        title: Text(
                          option.$3,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                        ),
                        trailing: selected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: scheme.primary.withValues(alpha: 0.85),
                              )
                            : Icon(
                                Icons.chevron_right_rounded,
                                color: scheme.onSurface.withValues(alpha: 0.55),
                              ),
                        onTap: () => Navigator.of(context).pop(option.$1),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
