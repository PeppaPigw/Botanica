import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_momentum_engine.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaMomentumCard extends StatelessWidget {
  const BotanicaMomentumCard({
    super.key,
    required this.momentum,
  });

  final GardenMomentum momentum;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final scoreColor = momentum.score >= 0.7
        ? scheme.tertiary
        : momentum.score >= 0.4
            ? scheme.primary
            : scheme.error;

    final trendDirection = momentum.trend > 0.1
        ? l10n.momentumUp
        : momentum.trend < -0.1
            ? l10n.momentumDown
            : l10n.momentumSteady;

    final trendIcon = momentum.trend > 0.1
        ? Icons.trending_up_rounded
        : momentum.trend < -0.1
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scoreColor.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Text(
                l10n.momentumTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(trendIcon, size: 16, color: scoreColor),
              const SizedBox(width: 4),
              Text(
                l10n.momentumTrending(trendDirection),
                style: textTheme.labelSmall?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: momentum.score.clamp(0.0, 1.0),
              backgroundColor: scheme.outlineVariant.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(scoreColor.withValues(alpha: 0.8)),
              minHeight: 8,
            ),
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _ContributionChip(
                label: l10n.momentumStreak,
                value: momentum.streakContribution,
                color: scheme.primary,
              ),
              BotanicaGaps.hXs,
              _ContributionChip(
                label: l10n.momentumActivity,
                value: momentum.activityContribution,
                color: scheme.tertiary,
              ),
              BotanicaGaps.hXs,
              _ContributionChip(
                label: l10n.momentumGrowth,
                value: momentum.growthContribution,
                color: scheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContributionChip extends StatelessWidget {
  const _ContributionChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
        ),
        child: Column(
          children: [
            Text(
              '${(value * 100).round()}%',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.55),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
