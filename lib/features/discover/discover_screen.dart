import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/plant_idea_search.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/i18n/species_search.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_chip.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/botanica_state_card.dart';
import '../../core/widgets/botanica_section.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/botanica_search_field.dart';
import '../../core/widgets/screen_title.dart';
import '../../domain/models/plant.dart';
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
  bool _searchFocused = false;
  String? _difficultyFilter;
  String? _lightFilter;
  String? _tagFilter;
  final List<String> _recentlyViewedSpeciesIds = <String>[];

  bool get _hasActiveFilters =>
      _petSafeOnly ||
      _difficultyFilter != null ||
      _lightFilter != null ||
      _tagFilter != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDifficulty() async {
    final l10n = AppLocalizations.of(context);
    final species = ref.read(speciesListProvider).valueOrNull ??
        const <Species>[];
    final ideas =
        ref.read(plantIdeaListProvider).valueOrNull ?? const <PlantIdea>[];

    final value = await _showSingleSelectSheet(
      context: context,
      title: l10n.discoverFilterDifficulty,
      currentValue: _difficultyFilter,
      kindKey: 'difficulty',
      onResetAll: _clearFilters,
      options: <_FilterSheetOption>[
        (
          value: _kFilterSheetClearSentinel,
          icon: Icons.filter_alt_off_rounded,
          label: l10n.commonClear,
          count: species.length + ideas.length,
        ),
        for (final value in const ['easy', 'medium', 'hard'])
          (
            value: value,
            icon: Icons.school_rounded,
            label: difficultyLabel(l10n, value),
            count: _previewFilterCount(
              species: species,
              ideas: ideas,
              difficultyFilter: value,
              lightFilter: _lightFilter,
              petSafeOnly: _petSafeOnly,
              tagFilter: _tagFilter,
            ),
          ),
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
    final species = ref.read(speciesListProvider).valueOrNull ??
        const <Species>[];
    final ideas =
        ref.read(plantIdeaListProvider).valueOrNull ?? const <PlantIdea>[];

    final value = await _showSingleSelectSheet(
      context: context,
      title: l10n.discoverFilterLight,
      currentValue: _lightFilter,
      kindKey: 'light',
      onResetAll: _clearFilters,
      options: <_FilterSheetOption>[
        (
          value: _kFilterSheetClearSentinel,
          icon: Icons.filter_alt_off_rounded,
          label: l10n.commonClear,
          count: species.length + ideas.length,
        ),
        (
          value: 'low',
          icon: Icons.nights_stay_rounded,
          label: l10n.scanRefineLowLight,
          count: _previewFilterCount(
            species: species,
            ideas: ideas,
            difficultyFilter: _difficultyFilter,
            lightFilter: 'low',
            petSafeOnly: _petSafeOnly,
            tagFilter: _tagFilter,
          ),
        ),
        for (final value in const [
          'bright_direct',
          'bright_indirect',
          'medium_indirect',
          'low_to_bright_indirect',
          'low_to_bright',
        ])
          (
            value: value,
            icon: Icons.wb_sunny_rounded,
            label: lightLabel(l10n, value),
            count: _previewFilterCount(
              species: species,
              ideas: ideas,
              difficultyFilter: _difficultyFilter,
              lightFilter: value,
              petSafeOnly: _petSafeOnly,
              tagFilter: _tagFilter,
            ),
          ),
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
      _tagFilter = null;
    });
  }

  void _applyBeginnerTag() {
    setState(() => _difficultyFilter = 'easy');
  }

  void _applyLowLightTag() {
    setState(() => _lightFilter = 'low');
  }

  void _applyPetSafeTag() {
    setState(() => _petSafeOnly = true);
  }

  void _applyAirPurifyingTag() {
    setState(() => _tagFilter = 'air-purifying');
  }

  void _applySearchSuggestion(String term) {
    _searchController.value = TextEditingValue(
      text: term,
      selection: TextSelection.collapsed(offset: term.length),
    );
    setState(() {});
  }

  Future<void> _openSpeciesDetail(String speciesId) async {
    await context.push('${DiscoverScreen.location}/species/$speciesId');
    if (!mounted) return;
    _markRecentlyViewed(speciesId);
  }

  void _markRecentlyViewed(String speciesId) {
    setState(() {
      _recentlyViewedSpeciesIds.remove(speciesId);
      _recentlyViewedSpeciesIds.insert(0, speciesId);
      if (_recentlyViewedSpeciesIds.length > 10) {
        _recentlyViewedSpeciesIds.removeRange(
          10,
          _recentlyViewedSpeciesIds.length,
        );
      }
    });
  }

  Future<void> _toggleFavorite(String speciesId) async {
    await ref.read(speciesFavoritesRepositoryProvider).toggle(speciesId);
  }

  bool _speciesMatchesFilters(Species species) {
    return (!_petSafeOnly || species.petSafe) &&
        (_difficultyFilter == null ||
            species.difficulty == _difficultyFilter) &&
        (_lightFilter == null || _speciesMatchesLightFilter(species)) &&
        (_tagFilter == null || _speciesHasTag(species, _tagFilter!));
  }

  bool _plantIdeaMatchesFilters(PlantIdea idea) {
    return (!_petSafeOnly || idea.petSafe) &&
        (_difficultyFilter == null || idea.difficulty == _difficultyFilter) &&
        (_lightFilter == null || _plantIdeaMatchesLightFilter(idea)) &&
        (_tagFilter == null || _plantIdeaHasTag(idea, _tagFilter!));
  }

  bool _speciesMatchesLightFilter(Species species) {
    final filter = _lightFilter;
    if (filter == null) return true;
    return _speciesMatchesLightValue(species, filter);
  }

  bool _plantIdeaMatchesLightFilter(PlantIdea idea) {
    final filter = _lightFilter;
    if (filter == null) return true;
    return _plantIdeaMatchesLightValue(idea, filter);
  }

  List<Species> _recommendedSpecies({
    required List<Species> species,
    required List<Plant> plants,
  }) {
    final activePlants = plants.where((plant) => !plant.isArchived).toList();
    if (activePlants.isEmpty) {
      final recommendations = species
          .where((s) => _speciesHasTag(s, 'beginner'))
          .take(6)
          .toList(growable: true);
      for (final s in species) {
        if (recommendations.length >= 6) break;
        if (recommendations.contains(s)) continue;
        if (s.difficulty == 'easy') recommendations.add(s);
      }
      return recommendations.toList(growable: false);
    }

    final speciesById = {
      for (final s in species) s.id: s,
    };
    final ownedSpeciesIds = activePlants
        .map((plant) => plant.speciesId)
        .where((id) => speciesById.containsKey(id))
        .toSet();
    final ownedSpecies = activePlants
        .map((plant) => speciesById[plant.speciesId])
        .whereType<Species>()
        .toList(growable: false);
    final ownedDifficulties =
        ownedSpecies.map((s) => s.difficulty).where((v) => v.isNotEmpty).toSet();
    final ownedLights =
        ownedSpecies.map((s) => s.light).where((v) => v.isNotEmpty).toSet();

    final scored = species
        .where((s) => !ownedSpeciesIds.contains(s.id))
        .map(
          (s) => (
            species: s,
            score: _recommendationScore(
              s,
              difficulties: ownedDifficulties,
              lights: ownedLights,
            ),
          ),
        )
        .where((entry) => entry.score > 0)
        .toList(growable: true)
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        final byDifficulty = _difficultyRank(a.species.difficulty)
            .compareTo(_difficultyRank(b.species.difficulty));
        if (byDifficulty != 0) return byDifficulty;
        return a.species.id.compareTo(b.species.id);
      });

    final recommendations =
        scored.map((entry) => entry.species).take(6).toList(growable: true);
    if (recommendations.length >= 4) return recommendations;

    for (final s in species) {
      if (recommendations.length >= 6) break;
      if (ownedSpeciesIds.contains(s.id) || recommendations.contains(s)) {
        continue;
      }
      if (s.difficulty == 'easy' || _speciesHasTag(s, 'beginner')) {
        recommendations.add(s);
      }
    }

    for (final s in species) {
      if (recommendations.length >= 6) break;
      if (!recommendations.contains(s)) recommendations.add(s);
    }

    return recommendations.toList(growable: false);
  }

  int _recommendationScore(
    Species species, {
    required Set<String> difficulties,
    required Set<String> lights,
  }) {
    var score = 0;
    if (difficulties.contains(species.difficulty)) score += 3;
    if (lights.contains(species.light)) score += 3;
    if (species.difficulty == 'easy') score += 1;
    if (_speciesHasTag(species, 'beginner')) score += 1;
    return score;
  }

  List<_CompactPlantCardData> _recentlyViewedItems({
    required List<Species> species,
    required List<PlantIdea> ideas,
    required String localeCode,
  }) {
    final speciesById = {
      for (final s in species) s.id: s,
    };
    final ideasById = {
      for (final idea in ideas) idea.plantId: idea,
    };
    final items = <_CompactPlantCardData>[];
    for (final id in _recentlyViewedSpeciesIds) {
      final speciesMatch = speciesById[id];
      if (speciesMatch != null) {
        items.add(_CompactPlantCardData.species(speciesMatch, localeCode));
        continue;
      }

      final ideaMatch = ideasById[id];
      if (ideaMatch != null) {
        items.add(_CompactPlantCardData.idea(ideaMatch, localeCode));
      }
    }
    return items;
  }

  List<_CompactPlantCardData> _favoriteItems({
    required List<Species> species,
    required List<PlantIdea> ideas,
    required List<String> ids,
    required String localeCode,
  }) {
    final speciesById = {
      for (final s in species) s.id: s,
    };
    final ideasById = {
      for (final idea in ideas) idea.plantId: idea,
    };
    final items = <_CompactPlantCardData>[];
    for (final id in ids) {
      final speciesMatch = speciesById[id];
      if (speciesMatch != null) {
        items.add(_CompactPlantCardData.species(speciesMatch, localeCode));
        continue;
      }

      final ideaMatch = ideasById[id];
      if (ideaMatch != null) {
        items.add(_CompactPlantCardData.idea(ideaMatch, localeCode));
      }
    }
    return items;
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
    final plantsAsync = ref.watch(plantsStreamProvider);
    final favoriteIds =
        ref.watch(speciesFavoriteIdsProvider).valueOrNull ?? const <String>[];
    final favoriteIdSet = favoriteIds.toSet();
    final showSearchSuggestions =
        _searchFocused && _searchController.text.trim().isEmpty;

    return SafeArea(
      child: ListView(
        padding: BotanicaTokens.pagePaddingWithBottomNav(context),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          BotanicaScreenTitle(l10n.navDiscover)
              .animateSection(index: 0),
          BotanicaGaps.vSm,
          Focus(
            onFocusChange: (focused) {
              if (_searchFocused == focused) return;
              setState(() => _searchFocused = focused);
            },
            child: BotanicaSearchField(
              controller: _searchController,
              hintText: l10n.discoverSearchHint,
              onChanged: (_) => setState(() {}),
            ),
          ).animateSection(index: 1),
          if (showSearchSuggestions) ...[
            BotanicaGaps.vSm,
            Wrap(
              spacing: BotanicaTokens.spacingXs,
              runSpacing: BotanicaTokens.spacingXs,
              children: _searchSuggestions
                  .map(
                    (term) => BotanicaChip(
                      key: ValueKey('discover-search-suggestion-$term'),
                      label: term,
                      icon: Icons.search_rounded,
                      tint: scheme.primary,
                      onTap: () => _applySearchSuggestion(term),
                    ),
                  )
                  .toList(growable: false),
            ).animateSection(index: 2),
          ],
          BotanicaGaps.vBase,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _TrendingTagChip(
                  key: const ValueKey('discover-trending-beginner'),
                  label: 'Beginner',
                  icon: Icons.school_rounded,
                  tint: scheme.primary,
                  selected: _difficultyFilter == 'easy',
                  onTap: _applyBeginnerTag,
                ),
                _TrendingTagChip(
                  key: const ValueKey('discover-trending-low-light'),
                  label: 'Low light',
                  icon: Icons.nights_stay_rounded,
                  tint: scheme.secondary,
                  selected: _lightFilter == 'low',
                  onTap: _applyLowLightTag,
                ),
                _TrendingTagChip(
                  key: const ValueKey('discover-trending-pet-safe'),
                  label: 'Pet-safe',
                  icon: Icons.pets_rounded,
                  tint: scheme.tertiary,
                  selected: _petSafeOnly,
                  onTap: _applyPetSafeTag,
                ),
                _TrendingTagChip(
                  key: const ValueKey('discover-trending-air-purifying'),
                  label: 'Air-purifying',
                  icon: Icons.air_rounded,
                  tint: scheme.primary,
                  selected: _tagFilter == 'air-purifying',
                  onTap: _applyAirPurifyingTag,
                ),
              ],
            ),
          ).animateSection(index: 2),
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
                    : '${l10n.discoverFilterLight}: ${_lightFilterLabel(l10n, _lightFilter!)}',
                tint: scheme.secondary,
                selected: _lightFilter != null,
                onTap: _pickLight,
              ),
              BotanicaChip(
                key: const ValueKey('discover-filter-difficulty'),
                icon: Icons.school_rounded,
                label: _difficultyFilter == null
                    ? l10n.discoverFilterDifficulty
                    : '${l10n.discoverFilterDifficulty}: '
                        '${difficultyLabel(l10n, _difficultyFilter!)}',
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
          ).animateSection(index: 3),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          speciesAsync.when(
            data: (species) {
              final plants = plantsAsync.valueOrNull ?? const <Plant>[];
              final ideas = ideasAsync.valueOrNull ?? const <PlantIdea>[];
              final recommended = _recommendedSpecies(
                species: species,
                plants: plants,
              )
                  .map((s) => _CompactPlantCardData.species(s, localeCode))
                  .toList(growable: false);
              final recent = _recentlyViewedItems(
                species: species,
                ideas: ideas,
                localeCode: localeCode,
              );
              final favorites = _favoriteItems(
                species: species,
                ideas: ideas,
                ids: favoriteIds,
                localeCode: localeCode,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (favorites.isNotEmpty) ...[
                    _HorizontalPlantCardsSection(
                      title: 'Favorites',
                      keyPrefix: 'discover-favorites',
                      items: favorites,
                      onTap: _openSpeciesDetail,
                    ).animateSection(index: 4),
                    const SizedBox(height: BotanicaTokens.spacingRelaxed),
                  ],
                  _HorizontalPlantCardsSection(
                    title: 'Recommended for you',
                    keyPrefix: 'discover-recommended',
                    items: recommended,
                    onTap: _openSpeciesDetail,
                  ).animateSection(index: 4),
                  if (recent.isNotEmpty) ...[
                    const SizedBox(height: BotanicaTokens.spacingRelaxed),
                    _HorizontalPlantCardsSection(
                      title: 'Recently viewed',
                      keyPrefix: 'discover-recent',
                      items: recent,
                      onTap: _openSpeciesDetail,
                    ).animateSection(index: 5),
                  ],
                ],
              );
            },
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          BotanicaSection(
            title: l10n.discoverSectionCurated,
            children: [
              speciesAsync.when(
                data: (species) {
                  final query = _searchController.text;
                  final trimmedQuery = query.trim();
                  final filteredByControls = species
                      .where(_speciesMatchesFilters)
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
                                  imagePath.endsWith('unknown.png') ||
                                  imagePath.endsWith('placeholder_plant.jpg');
                          return Padding(
                            key: ValueKey('discover-species-${s.id}'),
                            padding: const EdgeInsets.only(
                              bottom: BotanicaTokens.spacingSm,
                            ),
                            child: RepaintBoundary(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    BotanicaTokens.radiusXL),
                                onTap: () => _openSpeciesDetail(s.id),
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
                                                filterQuality:
                                                    FilterQuality.high,
                                                gaplessPlayback: true,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.asset(
                                                  'assets/images/placeholder_plant.jpg',
                                                  fit: BoxFit.cover,
                                                  gaplessPlayback: true,
                                                ),
                                              ),
                                              if (isPlaceholder) ...[
                                                DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        scheme.primaryContainer
                                                            .withValues(
                                                                alpha: 0.28),
                                                        scheme.tertiaryContainer
                                                            .withValues(
                                                                alpha: 0.18),
                                                        scheme.surface
                                                            .withValues(
                                                                alpha: 0.06),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Icon(
                                                    Icons.spa_rounded,
                                                    size: BotanicaTokens
                                                        .iconSizeLg,
                                                    color: scheme.onSurface
                                                        .withValues(
                                                            alpha: 0.78),
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
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                            BotanicaGaps.vMicro,
                                            Text(
                                              s.scientificName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                color: scheme.onSurface
                                                    .withValues(alpha: 0.65),
                                              ),
                                            ),
                                            if (habit != null) ...[
                                              BotanicaGaps.vXxs,
                                              Text(
                                                habit,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: scheme.onSurface
                                                      .withValues(alpha: 0.70),
                                                  height: 1.25,
                                                ),
                                              ),
                                            ],
                                            BotanicaGaps.vXs,
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
                                      BotanicaGaps.hSm,
                                      IconButton(
                                        onPressed: () => _toggleFavorite(s.id),
                                        icon: Icon(
                                          favoriteIdSet.contains(s.id)
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                        ),
                                        color: favoriteIdSet.contains(s.id)
                                            ? scheme.error
                                            : scheme.onSurface
                                                .withValues(alpha: 0.62),
                                        tooltip: favoriteIdSet.contains(s.id)
                                            ? 'Remove favorite'
                                            : 'Add favorite',
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        matchTextDirection: true,
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.55),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animateSection(index: index),
                            ),
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
                loading: () => const BotanicaListSkeleton(
                  itemCount: 4,
                  showHero: false,
                ),
              ),
            ],
          ).animateSection(index: 6),
          const SizedBox(height: BotanicaTokens.spacingRelaxed),
          BotanicaSection(
            title: l10n.discoverSectionLibrary,
            children: [
              ideasAsync.when(
                data: (ideas) {
                  final query = _searchController.text;
                  final trimmedQuery = query.trim();
                  final filteredByControls = ideas
                      .where(_plantIdeaMatchesFilters)
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
                                  imagePath.endsWith('unknown.png') ||
                                  imagePath.endsWith('placeholder_plant.jpg');

                          return Padding(
                            key: ValueKey('discover-idea-${idea.plantId}'),
                            padding: const EdgeInsets.only(
                              bottom: BotanicaTokens.spacingSm,
                            ),
                            child: RepaintBoundary(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    BotanicaTokens.radiusXL),
                                onTap: () => _openSpeciesDetail(idea.plantId),
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
                                                filterQuality:
                                                    FilterQuality.high,
                                                gaplessPlayback: true,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.asset(
                                                  'assets/images/placeholder_plant.jpg',
                                                  fit: BoxFit.cover,
                                                  gaplessPlayback: true,
                                                ),
                                              ),
                                              if (isPlaceholder) ...[
                                                DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        scheme.primaryContainer
                                                            .withValues(
                                                                alpha: 0.28),
                                                        scheme.tertiaryContainer
                                                            .withValues(
                                                                alpha: 0.18),
                                                        scheme.surface
                                                            .withValues(
                                                                alpha: 0.06),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Icon(
                                                    Icons.spa_rounded,
                                                    size: BotanicaTokens
                                                        .iconSizeLg,
                                                    color: scheme.onSurface
                                                        .withValues(
                                                            alpha: 0.78),
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
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                            BotanicaGaps.vMicro,
                                            Text(
                                              idea.scientificName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                color: scheme.onSurface
                                                    .withValues(alpha: 0.65),
                                              ),
                                            ),
                                            if (habit != null) ...[
                                              BotanicaGaps.vXxs,
                                              Text(
                                                habit,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: scheme.onSurface
                                                      .withValues(alpha: 0.70),
                                                  height: 1.25,
                                                ),
                                              ),
                                            ],
                                            BotanicaGaps.vXs,
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
                                                    icon:
                                                        Icons.wb_sunny_rounded,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      BotanicaGaps.hSm,
                                      IconButton(
                                        onPressed: () =>
                                            _toggleFavorite(idea.plantId),
                                        icon: Icon(
                                          favoriteIdSet.contains(idea.plantId)
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                        ),
                                        color: favoriteIdSet
                                                .contains(idea.plantId)
                                            ? scheme.error
                                            : scheme.onSurface
                                                .withValues(alpha: 0.62),
                                        tooltip: favoriteIdSet
                                                .contains(idea.plantId)
                                            ? 'Remove favorite'
                                            : 'Add favorite',
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        matchTextDirection: true,
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.55),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animateSection(index: index),
                            ),
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
                loading: () => const BotanicaListSkeleton(
                  itemCount: 6,
                  showHero: false,
                ),
              ),
            ],
          ).animateSection(index: 7),
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
          ).animateSection(index: 8),
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

typedef _FilterSheetOption = ({
  String? value,
  IconData icon,
  String label,
  int count,
});

const List<String> _searchSuggestions = <String>[
  'Monstera',
  'Pothos',
  'Snake plant',
  'Indoor',
  'Succulent',
  'Fern',
];

class _TrendingTagChip extends StatelessWidget {
  const _TrendingTagChip({
    super.key,
    required this.label,
    required this.icon,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        end: BotanicaTokens.spacingSm,
      ),
      child: BotanicaChip(
        label: label,
        icon: icon,
        tint: tint,
        selected: selected,
        onTap: onTap,
      ),
    );
  }
}

class _CompactPlantCardData {
  const _CompactPlantCardData({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.imagePath,
  });

  factory _CompactPlantCardData.species(Species species, String localeCode) {
    return _CompactPlantCardData(
      id: species.id,
      name: species.bestCommonName(localeCode),
      difficulty: species.difficulty,
      imagePath: _plantImagePath(species),
    );
  }

  factory _CompactPlantCardData.idea(PlantIdea idea, String localeCode) {
    return _CompactPlantCardData(
      id: idea.plantId,
      name: idea.bestCommonName(localeCode),
      difficulty: idea.difficulty?.trim() ?? '',
      imagePath: _plantIdeaImagePath(idea),
    );
  }

  final String id;
  final String name;
  final String difficulty;
  final String imagePath;
}

class _HorizontalPlantCardsSection extends StatelessWidget {
  const _HorizontalPlantCardsSection({
    required this.title,
    required this.keyPrefix,
    required this.items,
    required this.onTap,
  });

  final String title;
  final String keyPrefix;
  final List<_CompactPlantCardData> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return BotanicaSection(
      title: title,
      padding: BotanicaTokens.sectionPadding,
      children: [
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: BotanicaTokens.spacingSm),
            itemBuilder: (context, index) {
              final item = items[index];
              return RepaintBoundary(
                child: _CompactPlantCard(
                  key: ValueKey('$keyPrefix-${item.id}'),
                  item: item,
                  onTap: () => onTap(item.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CompactPlantCard extends StatelessWidget {
  const _CompactPlantCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final _CompactPlantCardData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final imagePath = item.imagePath;
    final isPlaceholder = _isPlaceholderImagePath(imagePath);

    return SizedBox(
      width: 140,
      child: InkWell(
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
        onTap: onTap,
        child: BotanicaGlassCard(
          padding: BotanicaTokens.cardPaddingDense,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(BotanicaTokens.radiusL),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/placeholder_plant.jpg',
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
                                scheme.primaryContainer.withValues(alpha: 0.28),
                                scheme.tertiaryContainer
                                    .withValues(alpha: 0.18),
                                scheme.surface.withValues(alpha: 0.06),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.spa_rounded,
                            size: BotanicaTokens.iconSizeLg,
                            color: scheme.onSurface.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              BotanicaGaps.vXs,
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              BotanicaGaps.vXs,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: item.difficulty.isEmpty
                    ? const SizedBox.shrink()
                    : _MiniTag(
                        label: difficultyLabel(l10n, item.difficulty),
                        icon: Icons.school_rounded,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          Icon(
            icon,
            size: BotanicaTokens.iconSizeXs,
            color: scheme.onSurface.withValues(alpha: 0.70),
          ),
          BotanicaGaps.hXxs,
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
                    size: BotanicaTokens.iconSizeSm,
                    color: Theme.of(context).colorScheme.inversePrimary),
                BotanicaGaps.hSm,
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
                  BotanicaGaps.vTiny,
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
            BotanicaGaps.hSm,
            Icon(
              Icons.chevron_right_rounded,
              matchTextDirection: true,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
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
      _textEntriesContain(species.habitByLocale.values, query) ||
      _textEntriesContain(species.careWarningsByLocale.values, query) ||
      _textEntriesContain(species.tags, query) ||
      (species.origin != null &&
          (_textEntriesContain(species.origin!.nativeRangeByLocale.values,
                  query) ||
              _textEntriesContain(species.origin!.notesByLocale.values,
                  query))) ||
      (species.toxicity != null &&
          _textEntriesContain(species.toxicity!.notesByLocale.values, query));
}

bool _speciesHasTag(Species species, String tag) {
  final normalized = normalizeSearchText(tag);
  return species.tags.any((value) => normalizeSearchText(value) == normalized);
}

bool _plantIdeaHasTag(PlantIdea idea, String tag) {
  final normalized = normalizeSearchText(tag);
  return idea.tags.any((value) => normalizeSearchText(value) == normalized);
}

int _previewFilterCount({
  required List<Species> species,
  required List<PlantIdea> ideas,
  required String? difficultyFilter,
  required String? lightFilter,
  required bool petSafeOnly,
  required String? tagFilter,
}) {
  final speciesCount = species.where(
    (item) {
      return (!petSafeOnly || item.petSafe) &&
          (difficultyFilter == null || item.difficulty == difficultyFilter) &&
          (lightFilter == null ||
              _speciesMatchesLightValue(item, lightFilter)) &&
          (tagFilter == null || _speciesHasTag(item, tagFilter));
    },
  ).length;
  final ideaCount = ideas.where(
    (item) {
      return (!petSafeOnly || item.petSafe) &&
          (difficultyFilter == null || item.difficulty == difficultyFilter) &&
          (lightFilter == null ||
              _plantIdeaMatchesLightValue(item, lightFilter)) &&
          (tagFilter == null || _plantIdeaHasTag(item, tagFilter));
    },
  ).length;
  return speciesCount + ideaCount;
}

bool _speciesMatchesLightValue(Species species, String filter) {
  if (filter == 'low') {
    return _isLowLightValue(species.light) ||
        _speciesHasTag(species, 'low-light');
  }
  return species.light == filter;
}

bool _plantIdeaMatchesLightValue(PlantIdea idea, String filter) {
  final light = idea.light;
  if (filter == 'low') {
    return _isLowLightValue(light) || _plantIdeaHasTag(idea, 'low-light');
  }
  return light == filter;
}

bool _isLowLightValue(String? value) {
  final normalized = normalizeSearchText(value ?? '');
  return normalized.startsWith('low') || normalized.contains('lowlight');
}

int _difficultyRank(String value) => switch (value) {
      'easy' => 0,
      'medium' => 1,
      'hard' => 2,
      _ => 3,
    };

String _lightFilterLabel(AppLocalizations l10n, String code) {
  if (code == 'low') return l10n.scanRefineLowLight;
  return lightLabel(l10n, code);
}

bool _isPlaceholderImagePath(String imagePath) {
  return imagePath.endsWith('/unknown.png') ||
      imagePath.endsWith('unknown.png') ||
      imagePath.endsWith('placeholder_plant.jpg');
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
    return 'assets/images/placeholder_plant.jpg';
  }
  return candidate;
}

bool _matchesIdeaCardDetails(PlantIdea idea, String rawQuery) {
  final query = normalizeSearchText(rawQuery);
  if (query.isEmpty) return false;
  return _textEntriesContain(idea.historyByLocale.values, query) ||
      _textEntriesContain(idea.habitByLocale.values, query) ||
      _textEntriesContain(idea.tags, query) ||
      (idea.botanical != null &&
          _textEntriesContain(
            <String>[
              idea.botanical!.nativeRange ?? '',
              idea.botanical!.nativeHabitat ?? '',
            ],
            query,
          )) ||
      (idea.toxicity != null &&
          _textEntriesContain(idea.toxicity!.notesByLocale.values, query));
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
    return 'assets/images/placeholder_plant.jpg';
  }
  return candidate;
}

Future<String?> _showSingleSelectSheet({
  required BuildContext context,
  required String title,
  required String? currentValue,
  required String kindKey,
  required List<_FilterSheetOption> options,
  required VoidCallback onResetAll,
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
                          letterSpacing: 0,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      onResetAll();
                      Navigator.of(context).pop(_kFilterSheetClearSentinel);
                    },
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Reset all'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(currentValue),
                    child: Text(l10n.commonClose),
                  ),
                ],
              ),
              BotanicaGaps.vSm,
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => BotanicaGaps.vSm,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final selected = option.value == currentValue ||
                        (option.value == _kFilterSheetClearSentinel &&
                            currentValue == null);
                    final optionKeyValue =
                        option.value == _kFilterSheetClearSentinel
                            ? 'any'
                            : (option.value ?? 'any');

                    return BotanicaGlassCard(
                      padding: BotanicaTokens.cardPaddingTight,
                      child: ListTile(
                        key: ValueKey(
                          'discover-filter-$kindKey-$optionKeyValue',
                        ),
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          option.icon,
                          color: scheme.onSurface.withValues(alpha: 0.80),
                        ),
                        title: Text(
                          option.label,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0,
                                  ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${option.count}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.62),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            BotanicaGaps.hXs,
                            selected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: scheme.primary
                                        .withValues(alpha: 0.85),
                                  )
                                : Icon(
                                    Icons.chevron_right_rounded,
                                    matchTextDirection: true,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                          ],
                        ),
                        onTap: () => Navigator.of(context).pop(option.value),
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
