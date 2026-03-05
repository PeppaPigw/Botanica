import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/species_labels.dart';
import '../../core/widgets/botanica_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/species.dart';
import '../../domain/services/plant_id/plant_identifier.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/permissions/permissions_service.dart';
import 'scan_capture_screen.dart';

class ScanResult {
  const ScanResult({
    required this.speciesId,
    required this.imagePath,
  });

  final String speciesId;
  final String imagePath;
}

class ScanFlowScreen extends ConsumerStatefulWidget {
  const ScanFlowScreen({super.key});

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

  bool _petSafeOnly = false;
  bool _easyOnly = false;
  bool _lowLightOnly = false;

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

    final l10n = AppLocalizations.of(context);
    final permissions = ref.read(permissionsServiceProvider);
    final decision = await permissions.requestCamera();
    if (!mounted) {
      return;
    }
    if (decision != AppPermissionDecision.granted &&
        decision != AppPermissionDecision.limited &&
        decision != AppPermissionDecision.provisional) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.no_photography_rounded, size: 18, color: Theme.of(context).colorScheme.inversePrimary),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.scanCameraPermissionNeeded)),
            ],
          ),
        ),
      );
      Navigator.of(context).pop(null);
      return;
    }

    await _captureAndIdentify();
  }

  Future<void> _captureAndIdentify() async {
    final l10n = AppLocalizations.of(context);

    final file = await ScanCaptureScreen.capture(
      context,
      title: l10n.scanCaptureTitle,
    );
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
    });

    final speciesRepo = ref.read(speciesRepositoryProvider);
    final speciesPool = await speciesRepo.getAll();
    final bytes = await File(file.path).readAsBytes();

    final identifier = ref.read(plantIdentifierProvider);
    final candidates = identifier.identify(
      imageBytes: bytes,
      speciesPool: speciesPool,
      maxResults: 6,
    );

    if (!mounted) {
      return;
    }
    if (candidates.isNotEmpty) {
      HapticFeedback.mediumImpact();
    }
    setState(() => _candidates = candidates);
  }

  List<PlantIdCandidate> _filteredCandidates(List<PlantIdCandidate> all) {
    final filtered = all.where((c) {
      if (_petSafeOnly && !c.species.petSafe) {
        return false;
      }
      if (_easyOnly && c.species.difficulty.toLowerCase() != 'easy') {
        return false;
      }
      if (_lowLightOnly && !c.species.light.toLowerCase().contains('low')) {
        return false;
      }
      return true;
    }).toList(growable: false);

    if (filtered.isEmpty) {
      return all.take(3).toList(growable: false);
    }
    return filtered.take(3).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localeCode = ref.watch(settingsControllerProvider).localeCode ?? 'en';

    final imagePath = _imagePath;
    final candidates = _candidates;

    return BotanicaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.scanTitle),
          actions: [
            IconButton(
              onPressed: _captureAndIdentify,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: l10n.scanTryAgain,
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: BotanicaTokens.pagePadding.copyWith(bottom: 18),
            children: [
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
                      const SizedBox(width: 12),
                      Text(
                        l10n.commonLoading,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              if (candidates == null)
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
                      const SizedBox(width: 12),
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
                ).animate().fadeIn(duration: 220.ms),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FilterChip(
                      selected: _petSafeOnly,
                      label: l10n.scanRefinePetSafe,
                      onTap: () => setState(() => _petSafeOnly = !_petSafeOnly),
                    ),
                    _FilterChip(
                      selected: _easyOnly,
                      label: l10n.scanRefineEasy,
                      onTap: () => setState(() => _easyOnly = !_easyOnly),
                    ),
                    _FilterChip(
                      selected: _lowLightOnly,
                      label: l10n.scanRefineLowLight,
                      onTap: () =>
                          setState(() => _lowLightOnly = !_lowLightOnly),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._filteredCandidates(candidates).map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CandidateCard(
                      species: c.species,
                      localeCode: localeCode,
                      confidence: c.confidence,
                      selected: _selectedSpeciesId == c.species.id,
                      onTap: () => setState(() {
                        _selectedSpeciesId = c.species.id;
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: (_selectedSpeciesId == null || imagePath == null)
                        ? null
                        : () {
                            Navigator.of(context).pop(
                              ScanResult(
                                speciesId: _selectedSpeciesId!,
                                imagePath: imagePath,
                              ),
                            );
                          },
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.scanAddToGarden),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.scanDeterministicNote,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
          style: textTheme.labelLarge?.copyWith(
            color: fg.withValues(alpha: 0.92),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
      child: AnimatedContainer(
        duration: BotanicaTokens.motionFast,
        padding: const EdgeInsets.all(14),
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
                const SizedBox(width: 10),
                Text(
                  '$pct%',
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              species.scientificName,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: confidence.clamp(0.05, 1.0),
                minHeight: 8,
                backgroundColor: scheme.outlineVariant.withValues(alpha: 0.35),
                valueColor: AlwaysStoppedAnimation(
                  selected
                      ? scheme.primary.withValues(alpha: 0.85)
                      : scheme.secondary.withValues(alpha: 0.70),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
          Icon(icon, size: 16, color: scheme.onSurface.withValues(alpha: 0.70)),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
