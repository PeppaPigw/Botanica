import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/intelligence_providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_pattern_analyzer.dart';
import '../../gen/l10n/app_localizations.dart';
import '../widgets/glass_card.dart';

class CarePatternsCard extends ConsumerWidget {
  const CarePatternsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patterns = ref.watch(carePatternProvider);
    if (patterns.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BotanicaGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                color: scheme.primary,
                size: 20,
              ),
              const SizedBox(width: BotanicaTokens.spacingXs),
              Text(
                l10n.patternTitle,
                style: textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingMd),
          ...patterns.map((p) => _PatternTile(pattern: p)),
        ],
      ),
    );
  }
}

class _PatternTile extends StatelessWidget {
  const _PatternTile({required this.pattern});

  final CarePattern pattern;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final (icon, label) = _patternVisuals(pattern.type, l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingSm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
            ),
            child: Icon(icon, size: 18, color: scheme.primary),
          ),
          const SizedBox(width: BotanicaTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodyMedium),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: pattern.confidence,
                  backgroundColor:
                      scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(
                    scheme.primary.withValues(alpha: 0.6),
                  ),
                  minHeight: 3,
                  borderRadius:
                      BorderRadius.circular(BotanicaTokens.radiusM),
                ),
              ],
            ),
          ),
          const SizedBox(width: BotanicaTokens.spacingXs),
          Text(
            '${(pattern.confidence * 100).round()}%',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String) _patternVisuals(PatternType type, AppLocalizations l10n) {
    return switch (type) {
      PatternType.batchCarer => (Icons.layers_rounded, l10n.patternBatchCarer),
      PatternType.morningRitual => (Icons.wb_sunny_rounded, l10n.patternMorningRitual),
      PatternType.eveningRitual => (Icons.nightlight_rounded, l10n.patternEveningRitual),
      PatternType.weekendWarrior => (Icons.weekend_rounded, l10n.patternWeekendWarrior),
      PatternType.seasonalDip => (Icons.trending_down_rounded, l10n.patternSeasonalDip),
      PatternType.seasonalSurge => (Icons.trending_up_rounded, l10n.patternSeasonalSurge),
      PatternType.favoriteFirst => (Icons.favorite_rounded, l10n.patternFavoriteFirst),
      PatternType.neglectedChild => (Icons.visibility_off_rounded, l10n.patternNeedsLove),
      PatternType.diverseRoutine => (Icons.auto_awesome_rounded, l10n.patternDiverseRoutine),
      PatternType.focusedCarer => (Icons.center_focus_strong_rounded, l10n.patternFocusedCarer),
    };
  }
}
