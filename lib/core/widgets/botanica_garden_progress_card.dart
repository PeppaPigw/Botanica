import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaGardenProgressCard extends StatelessWidget {
  const BotanicaGardenProgressCard({
    super.key,
    required this.plantCount,
    required this.logCount,
    required this.unlockedFeatures,
    required this.totalFeatures,
  });

  final int plantCount;
  final int logCount;
  final int unlockedFeatures;
  final int totalFeatures;

  @override
  Widget build(BuildContext context) {
    if (unlockedFeatures >= totalFeatures) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final progress = unlockedFeatures / totalFeatures;

    final nextMilestone = _nextMilestone(l10n);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.rocket_launch_outlined,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.gardenProgressTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                l10n.gardenProgressUnlocked(unlockedFeatures, totalFeatures),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
          if (nextMilestone != null) ...[
            BotanicaGaps.vXs,
            Text(
              nextMilestone,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _nextMilestone(AppLocalizations l10n) {
    if (plantCount < 2) return l10n.gardenProgressMilestonePlant('diversity insights');
    if (plantCount < 3) return l10n.gardenProgressMilestonePlant('room optimization');
    if (plantCount < 4) return l10n.gardenProgressMilestonePlant('batch planning');
    if (logCount < 5) return l10n.gardenProgressMilestoneLogs(5 - logCount, 'efficiency tracking');
    if (logCount < 7) return l10n.gardenProgressMilestoneLogs(7 - logCount, 'momentum analysis');
    if (logCount < 10) return l10n.gardenProgressMilestoneLogs(10 - logCount, 'skill progression');
    return null;
  }
}
