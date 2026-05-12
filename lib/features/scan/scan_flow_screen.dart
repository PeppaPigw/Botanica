import 'dart:async';
import 'dart:io';

import 'package:botanica/core/haptics/botanica_haptics.dart';
import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../app/theme/botanica_glass_theme.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/widgets/botanica_animated_section.dart';
import '../../core/widgets/botanica_bottom_action_bar.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/species.dart';
import '../../domain/services/plant_id/plant_identifier.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/permissions/permissions_service.dart';
import '../discover/discover_screen.dart';
import 'scan_capture_screen.dart';

typedef ScanCaptureImage = Future<XFile?> Function(
  BuildContext context, {
  required String title,
});

typedef ScanCandidateResolver = FutureOr<List<PlantIdCandidate>> Function(
  XFile imageFile,
  List<Species> speciesPool,
);

class ScanResult {
  const ScanResult({
    required this.speciesId,
    required this.imagePath,
  });

  final String speciesId;
  final String imagePath;
}

class ScanFlowScreen extends ConsumerStatefulWidget {
  const ScanFlowScreen({
    super.key,
    this.captureImage,
    this.candidateResolver,
  });

  final ScanCaptureImage? captureImage;
  final ScanCandidateResolver? candidateResolver;

  static Future<ScanResult?> open(BuildContext context) {
    return Navigator.of(context).push<ScanResult?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ScanFlowScreen(),
      ),
    );
  }

  @override
  ConsumerState<ScanFlowScreen> createState() => _ScanFlowScreenState();
}

class _ScanFlowScreenState extends ConsumerState<ScanFlowScreen> {
  String? _imagePath;
  List<PlantIdCandidate>? _candidates;
  String? _selectedSpeciesId;
  double? _selectedConfidence;

  bool _floweringOnly = false;
  bool _indoorOutdoorOnly = false;
  bool _succulentOnly = false;
  bool _timedOut = false;
  bool _scanFailed = false;
  bool _needsCameraPermission = false;

  bool _starting = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  Future<void> _start() async {
    if (!_starting) {
      return;
    }
    setState(() => _starting = false);

    final permissions = ref.read(permissionsServiceProvider);
    final snapshot = await permissions.snapshot();
    if (!mounted) {
      return;
    }
    if (!_isGranted(snapshot.camera)) {
      setState(() => _needsCameraPermission = true);
      return;
    }

    await _captureAndIdentify();
  }

  Future<void> _requestCameraAndStart() async {
    final permissions = ref.read(permissionsServiceProvider);
    final decision = await permissions.requestCamera();
    if (!mounted) return;
    if (!_isGranted(decision)) {
      setState(() => _needsCameraPermission = true);
      return;
    }
    setState(() => _needsCameraPermission = false);
    await _captureAndIdentify();
  }

  Future<void> _captureAndIdentify() async {
    final l10n = AppLocalizations.of(context);

    final file = await (widget.captureImage?.call(
          context,
          title: l10n.scanCaptureTitle,
        ) ??
        ScanCaptureScreen.capture(
          context,
          title: l10n.scanCaptureTitle,
        ));
    if (!mounted) {
      return;
    }
    if (file == null) {
      Navigator.of(context).pop(null);
      return;
    }

    setState(() {
      _imagePath = file.path;
      _candidates = null;
      _selectedSpeciesId = null;
      _selectedConfidence = null;
      _floweringOnly = false;
      _indoorOutdoorOnly = false;
      _succulentOnly = false;
      _timedOut = false;
      _scanFailed = false;
    });

    final speciesRepo = ref.read(speciesRepositoryProvider);
    final speciesPool = await speciesRepo.getAll();

    try {
      final candidates = await _resolveCandidates(file, speciesPool).timeout(
        const Duration(seconds: 10),
      );

      if (!mounted) {
        return;
      }
      if (candidates.isNotEmpty) {
        BotanicaHaptics.completion();
      }
      setState(() => _candidates = candidates);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _timedOut = true;
        _candidates = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _scanFailed = true;
        _candidates = const <PlantIdCandidate>[];
      });
    }
  }

  Future<List<PlantIdCandidate>> _resolveCandidates(
    XFile file,
    List<Species> speciesPool,
  ) async {
    if (widget.candidateResolver != null) {
      return Future<List<PlantIdCandidate>>.value(
        widget.candidateResolver!(file, speciesPool),
      );
    }
    return ref.read(plantIdentifierProvider).identify(
          imageBytes: await file.readAsBytes(),
          speciesPool: speciesPool,
          maxResults: 6,
        );
  }

  ({List<PlantIdCandidate> candidates, bool showingFallback})
      _filteredCandidates(List<PlantIdCandidate> all) {
    final hasActiveFilters =
        _floweringOnly || _indoorOutdoorOnly || _succulentOnly;

    final filtered = all.where((c) {
      if (_floweringOnly && !_matchesAny(c.species, const [
        'flower',
        'flowering',
        'bloom',
        'orchid',
        'anthurium',
        'spathiphyllum',
        'hoya',
      ])) {
        return false;
      }
      if (_indoorOutdoorOnly && !_matchesAny(c.species, const [
        'indoor',
        'outdoor',
        'houseplant',
        'patio',
        'balcony',
        'garden',
        'bright_indirect',
        'low_light',
        'low_to_bright',
      ])) {
        return false;
      }
      if (_succulentOnly && !_matchesAny(c.species, const [
        'succulent',
        'cactus',
        'aloe',
        'echeveria',
        'haworthia',
        'crassula',
        'jade',
        'sedum',
        'drought-tolerant',
      ])) {
        return false;
      }
      return true;
    }).toList(growable: false);

    if (filtered.isEmpty) {
      return (
        candidates: all.take(3).toList(growable: false),
        showingFallback: hasActiveFilters,
      );
    }
    return (
      candidates: filtered.take(3).toList(growable: false),
      showingFallback: false,
    );
  }

  bool _matchesAny(Species species, List<String> terms) {
    final text = _speciesSearchText(species);
    return terms.any((term) => text.contains(term));
  }

  String _speciesSearchText(Species species) {
    final names = species.commonNamesByLocale.values.expand((items) => items);
    return [
      species.id,
      species.scientificName,
      species.difficulty,
      species.light,
      ...species.tags,
      ...names,
      ...species.historyByLocale.values,
      ...species.habitByLocale.values,
      if (species.growth != null) species.growth!.form,
    ].join(' ').toLowerCase();
  }

  void _browseLibrary() {
    final router = GoRouter.maybeOf(context);
    Navigator.of(context).pop(null);
    router?.go(DiscoverScreen.location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localeCode = ref.watch(settingsControllerProvider).localeCode ?? 'en';

    final imagePath = _imagePath;
    final candidates = _candidates;
    final filteredCandidates =
        candidates == null ? null : _filteredCandidates(candidates);

    return BotanicaPageScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.scanTitle),
        actions: [
          IconButton(
            onPressed: _needsCameraPermission
                ? _requestCameraAndStart
                : _captureAndIdentify,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.scanTryAgain,
          ),
        ],
      ),
      bottomNavigationBar: BotanicaBottomActionBar(
        tier: GlassTier.subtle,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: (_selectedSpeciesId == null || imagePath == null)
                ? null
                : () async {
                    await ref.read(scanResultCacheRepositoryProvider).save(
                          speciesId: _selectedSpeciesId!,
                          confidence: _selectedConfidence ?? 0,
                        );
                    if (!context.mounted) return;
                    Navigator.of(context).pop(
                      ScanResult(
                        speciesId: _selectedSpeciesId!,
                        imagePath: imagePath,
                      ),
                    );
                  },
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.scanAddToGarden),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: BotanicaTokens.pagePadding.copyWith(bottom: 18),
          children: [
            _LastScanResultChip(
              onOpen: (speciesId) {
                final router = GoRouter.maybeOf(context);
                Navigator.of(context).pop(null);
                router?.push('${DiscoverScreen.location}/species/$speciesId');
              },
            ),
            if (_needsCameraPermission) ...[
              _ScanRecoveryCard(
                icon: Icons.photo_camera_rounded,
                title: l10n.scanCameraPermissionTitle,
                body: l10n.scanCameraPermissionBody,
                tryAgainLabel: l10n.scanUseCamera,
                browseLabel: l10n.scanBrowseLibrary,
                onTryAgain: _requestCameraAndStart,
                onBrowse: _browseLibrary,
              ),
            ] else ...[
              if (imagePath != null)
                BotanicaGlassCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(BotanicaTokens.radiusXL),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.55),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.photo_rounded,
                              color: scheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                BotanicaGlassCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation(
                            scheme.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      BotanicaGaps.hSm,
                      Text(
                        l10n.commonLoading,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
              BotanicaGaps.vSm,
              if (_timedOut)
                _ScanRecoveryCard(
                  icon: Icons.timer_off_rounded,
                  title: l10n.scanTakingLongerTitle,
                  body: l10n.scanTakingLongerBody,
                  tryAgainLabel: l10n.scanTryAgain,
                  browseLabel: l10n.scanBrowseLibrary,
                  onTryAgain: _captureAndIdentify,
                  onBrowse: _browseLibrary,
                )
              else if (_scanFailed ||
                  (candidates != null && candidates.isEmpty))
                _ScanRecoveryCard(
                  icon: Icons.travel_explore_rounded,
                  title: l10n.scanNoResultTitle,
                  body: l10n.scanNoResultBody,
                  tryAgainLabel: l10n.scanTryAgain,
                  browseLabel: l10n.scanBrowseLibrary,
                  onTryAgain: _captureAndIdentify,
                  onBrowse: _browseLibrary,
                )
              else if (candidates == null)
                BotanicaGlassCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation(
                            scheme.primary.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      BotanicaGaps.hSm,
                      Expanded(
                        child: Text(
                          l10n.scanProcessingBody,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.75),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            else ...[
              Text(
                l10n.scanChooseCandidate,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ).animateSection(index: 0),
              BotanicaGaps.vXxs,
              Text(
                l10n.scanConfidenceGuide,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                  height: 1.35,
                ),
              ).animateSection(index: 1),
              BotanicaGaps.vSm,
              Text(
                l10n.scanRefineTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ).animateSection(index: 2),
              BotanicaGaps.vTiny,
              Text(
                l10n.scanRefineHelper,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                  height: 1.35,
                ),
              ).animateSection(index: 3),
              BotanicaGaps.vSm,
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FilterChip(
                    selected: _floweringOnly,
                    label: l10n.scanRefineFlowering,
                    onTap: () =>
                        setState(() => _floweringOnly = !_floweringOnly),
                  ),
                  _FilterChip(
                    selected: _indoorOutdoorOnly,
                    label: l10n.scanRefineIndoorOutdoor,
                    onTap: () => setState(
                      () => _indoorOutdoorOnly = !_indoorOutdoorOnly,
                    ),
                  ),
                  _FilterChip(
                    selected: _succulentOnly,
                    label: l10n.scanRefineSucculent,
                    onTap: () =>
                        setState(() => _succulentOnly = !_succulentOnly),
                  ),
                ],
              ),
              BotanicaGaps.vSm,
              if (filteredCandidates!.showingFallback)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    l10n.scanRefineFallbackNote,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.72),
                      height: 1.35,
                    ),
                  ),
                ),
              ...filteredCandidates.candidates.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ScanCandidateCard(
                    species: c.species,
                    localeCode: localeCode,
                    confidence: c.confidence,
                    selected: _selectedSpeciesId == c.species.id,
                    onTap: () => setState(() {
                      _selectedSpeciesId = c.species.id;
                      _selectedConfidence = c.confidence;
                    }),
                  ),
                ),
              ),
            ],
            ],
          ],
        ),
      ),
    );
  }
}

bool _isGranted(AppPermissionDecision decision) {
  return decision == AppPermissionDecision.granted ||
      decision == AppPermissionDecision.limited ||
      decision == AppPermissionDecision.provisional;
}

class _ScanRecoveryCard extends StatelessWidget {
  const _ScanRecoveryCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.tryAgainLabel,
    required this.browseLabel,
    required this.onTryAgain,
    required this.onBrowse,
  });

  final IconData icon;
  final String title;
  final String body;
  final String tryAgainLabel;
  final String browseLabel;
  final VoidCallback onTryAgain;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary.withValues(alpha: 0.86)),
              BotanicaGaps.hSm,
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vXs,
          Text(
            body,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
              height: 1.35,
            ),
          ),
          BotanicaGaps.vBase,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.travel_explore_rounded),
              label: Text(browseLabel),
            ),
          ),
          BotanicaGaps.vXs,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTryAgain,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(tryAgainLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastScanResultChip extends ConsumerWidget {
  const _LastScanResultChip({required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cached = ref.watch(lastScanResultProvider).valueOrNull;
    if (cached == null) return const SizedBox.shrink();

    final speciesAsync = ref.watch(speciesListProvider);
    final localeCode = ref.watch(settingsControllerProvider).localeCode ??
        Localizations.localeOf(context).languageCode;

    return speciesAsync.when(
      data: (species) {
        Species? match;
        for (final item in species) {
          if (item.id == cached.speciesId) {
            match = item;
            break;
          }
        }
        final resolved = match;
        if (resolved == null) return const SizedBox.shrink();

        final l10n = AppLocalizations.of(context);
        final scheme = Theme.of(context).colorScheme;
        final pct = (cached.confidence * 100).round().clamp(1, 99);

        return Padding(
          padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingSm),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ActionChip(
              avatar: Icon(
                Icons.history_rounded,
                size: BotanicaTokens.iconSizeSm,
                color: scheme.onSurface.withValues(alpha: 0.76),
              ),
              label: Text(
                'Last result: ${resolved.bestCommonName(localeCode)} · $pct%',
              ),
              tooltip: l10n.scanChooseCandidate,
              onPressed: () => onOpen(resolved.id),
            ),
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurface;
    final bg = selected
        ? scheme.primaryContainer.withValues(alpha: 0.70)
        : scheme.surface.withValues(alpha: 0.55);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: BotanicaTokens.motionFast,
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.35)
                : scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelLarge?.copyWith(
            color: fg.withValues(alpha: 0.92),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

enum ScanConfidenceBand {
  high,
  medium,
  low,
}

ScanConfidenceBand scanConfidenceBandFor(double confidence) {
  if (confidence > 0.80) {
    return ScanConfidenceBand.high;
  }
  if (confidence >= 0.50) {
    return ScanConfidenceBand.medium;
  }
  return ScanConfidenceBand.low;
}

String scanConfidenceBandLabel(
  AppLocalizations l10n,
  ScanConfidenceBand band,
) {
  return switch (band) {
    ScanConfidenceBand.high => l10n.scanConfidenceStrongLabel,
    ScanConfidenceBand.medium => l10n.scanConfidenceLikelyLabel,
    ScanConfidenceBand.low => l10n.scanConfidencePossibleLabel,
  };
}

String scanConfidenceBandBody(
  AppLocalizations l10n,
  ScanConfidenceBand band,
) {
  return switch (band) {
    ScanConfidenceBand.high => l10n.scanConfidenceStrongBody,
    ScanConfidenceBand.medium => l10n.scanConfidenceLikelyBody,
    ScanConfidenceBand.low => l10n.scanConfidencePossibleBody,
  };
}

class ScanCandidateCard extends StatelessWidget {
  const ScanCandidateCard({
    super.key,
    required this.species,
    required this.localeCode,
    required this.confidence,
    required this.selected,
    required this.onTap,
  });

  final Species species;
  final String localeCode;
  final double confidence;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final name = species.bestCommonName(localeCode);
    final pct = (confidence * 100).round().clamp(1, 99);
    final band = scanConfidenceBandFor(confidence);
    final bandLabel = scanConfidenceBandLabel(l10n, band);
    final bandBody = scanConfidenceBandBody(l10n, band);

    final bandColor = switch (band) {
      ScanConfidenceBand.high => Colors.green.shade600,
      ScanConfidenceBand.medium => Colors.amber.shade700,
      ScanConfidenceBand.low => scheme.error,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
      child: AnimatedContainer(
        duration: BotanicaTokens.motionFast,
        padding: BotanicaTokens.cardPaddingDense,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          color: scheme.surface.withValues(alpha: 0.55),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.55)
                : scheme.outlineVariant.withValues(alpha: 0.40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                BotanicaGaps.hSm,
                Text(
                  '$pct%',
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            BotanicaGaps.vMicro,
            Text(
              species.scientificName,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            BotanicaGaps.vXs,
            Text(
              bandLabel,
              style: textTheme.labelLarge?.copyWith(
                color: bandColor.withValues(alpha: 0.90),
                fontWeight: FontWeight.w800,
              ),
            ),
            BotanicaGaps.vMicro,
            Text(
              bandBody,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
                height: 1.35,
              ),
            ),
            BotanicaGaps.vSm,
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: confidence.clamp(0.05, 1.0),
                minHeight: 8,
                backgroundColor: scheme.outlineVariant.withValues(alpha: 0.35),
                valueColor: AlwaysStoppedAnimation(bandColor),
              ),
            ),
            BotanicaGaps.vSm,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TagChip(
                  icon: species.petSafe
                      ? Icons.pets_rounded
                      : Icons.warning_amber_rounded,
                  label: species.petSafe
                      ? l10n.discoverTagPetSafe
                      : l10n.discoverTagToxic,
                ),
                _TagChip(
                  icon: Icons.wb_sunny_rounded,
                  label: lightLabel(l10n, species.light),
                ),
                _TagChip(
                  icon: Icons.auto_awesome_rounded,
                  label: difficultyLabel(l10n, species.difficulty),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: scheme.surface.withValues(alpha: 0.35),
        border:
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: BotanicaTokens.iconSizeSm,
              color: scheme.onSurface.withValues(alpha: 0.70)),
          BotanicaGaps.hXxs,
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
