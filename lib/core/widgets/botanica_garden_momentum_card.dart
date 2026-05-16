import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_momentum_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaGardenMomentumCard extends StatelessWidget {
  const BotanicaGardenMomentumCard({
    super.key,
    required this.momentum,
  });

  final GardenMomentum momentum;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final scoreColor = momentum.score >= 0.7
        ? const Color(0xFF66BB6A)
        : momentum.score >= 0.4
            ? const Color(0xFFFF9800)
            : scheme.error;

    final trendIcon = momentum.trend > 0.05
        ? Icons.trending_up_rounded
        : momentum.trend < -0.05
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
              Icon(Icons.speed_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Garden Momentum',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(trendIcon, size: 16, color: scoreColor),
              BotanicaGaps.hXxs,
              Text(
                '${(momentum.score * 100).round()}%',
                style: textTheme.labelSmall?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: momentum.score.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(scoreColor),
            ),
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _ContributionChip(
                icon: Icons.local_fire_department_rounded,
                value: momentum.streakContribution,
                scheme: scheme,
                textTheme: textTheme,
              ),
              BotanicaGaps.hXxs,
              _ContributionChip(
                icon: Icons.bolt_rounded,
                value: momentum.activityContribution,
                scheme: scheme,
                textTheme: textTheme,
              ),
              BotanicaGaps.hXxs,
              _ContributionChip(
                icon: Icons.spa_rounded,
                value: momentum.growthContribution,
                scheme: scheme,
                textTheme: textTheme,
              ),
            ],
          ),
          if (momentum.encouragement.isNotEmpty) ...[
            BotanicaGaps.vXxs,
            Text(
              momentum.encouragement,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _ContributionChip extends StatelessWidget {
  const _ContributionChip({
    required this.icon,
    required this.value,
    required this.scheme,
    required this.textTheme,
  });

  final IconData icon;
  final double value;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingXxs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: scheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 2),
          Text(
            '${(value * 100).round()}%',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
