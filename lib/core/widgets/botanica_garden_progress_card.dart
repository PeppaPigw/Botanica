import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
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
    final progress = unlockedFeatures / totalFeatures;

    final nextMilestone = _nextMilestone();

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
                  'Garden Intelligence',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$unlockedFeatures/$totalFeatures',
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

  String? _nextMilestone() {
    if (plantCount < 2) return 'Add 1 more plant to unlock diversity insights';
    if (plantCount < 3) return 'Add 1 more plant to unlock room optimization';
    if (plantCount < 4) return 'Add 1 more plant to unlock batch planning';
    if (logCount < 5) return 'Log ${5 - logCount} more care actions for efficiency tracking';
    if (logCount < 7) return 'Log ${7 - logCount} more actions for momentum analysis';
    if (logCount < 10) return 'Log ${10 - logCount} more actions for skill progression';
    return null;
  }
}
