import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_whisperer_score.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaWhispererScoreCard extends StatelessWidget {
  const BotanicaWhispererScoreCard({
    super.key,
    required this.score,
  });

  final WhispererScore score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tierColor = switch (score.tier) {
      WhispererTier.seedling => const Color(0xFF8D6E63),
      WhispererTier.sprout => const Color(0xFF66BB6A),
      WhispererTier.gardener => const Color(0xFF42A5F5),
      WhispererTier.botanist => const Color(0xFFAB47BC),
      WhispererTier.whisperer => const Color(0xFFFFD700),
    };

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded,
                  size: BotanicaTokens.iconSizeMd, color: tierColor),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Plant Whisperer',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${score.xp} XP',
                  style: textTheme.labelSmall?.copyWith(
                    color: tierColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              Text(
                score.tier.name.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: tierColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (score.tier.next != null)
                Text(
                  'Next: ${score.tier.next!.name}',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          BotanicaGaps.vXxs,
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
            child: LinearProgressIndicator(
              value: score.progressToNext.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(tierColor),
            ),
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _XpChip(label: 'Streak', value: score.breakdown.streakXp, scheme: scheme),
              BotanicaGaps.hXxs,
              _XpChip(label: 'Punctual', value: score.breakdown.punctualityXp, scheme: scheme),
              BotanicaGaps.hXxs,
              _XpChip(label: 'Diverse', value: score.breakdown.diversityXp, scheme: scheme),
            ],
          ),
        ],
      ),
    );
  }
}

class _XpChip extends StatelessWidget {
  const _XpChip({required this.label, required this.value, required this.scheme});

  final String label;
  final int value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: BotanicaTokens.spacingMicro),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
        ),
        child: Column(
          children: [
            Text(
              '+$value',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 9,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
