import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_difficulty_progression.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaSkillProgressionCard extends StatelessWidget {
  const BotanicaSkillProgressionCard({
    super.key,
    required this.progression,
  });

  final SkillProgression progression;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final levelColor = switch (progression.level) {
      SkillLevel.beginner => const Color(0xFF66BB6A),
      SkillLevel.intermediate => const Color(0xFF42A5F5),
      SkillLevel.advanced => const Color(0xFFAB47BC),
      SkillLevel.expert => const Color(0xFFFFD700),
    };

    final progress = progression.nextLevelScore > 0
        ? (progression.score / progression.nextLevelScore).clamp(0.0, 1.0)
        : 1.0;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded,
                  size: BotanicaTokens.iconSizeMd, color: levelColor),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Skill Level',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  progression.level.name.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: levelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(levelColor),
            ),
          ),
          BotanicaGaps.vXxs,
          Text(
            '${progression.score.toStringAsFixed(0)} / ${progression.nextLevelScore.toStringAsFixed(0)} XP',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (progression.strengths.isNotEmpty) ...[
            BotanicaGaps.vSm,
            Wrap(
              spacing: BotanicaTokens.spacingXxs,
              runSpacing: BotanicaTokens.spacingXxs,
              children: progression.strengths.take(4).map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BotanicaTokens.spacingXs,
                      vertical: BotanicaTokens.spacingMicro,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                    ),
                    child: Text(
                      s,
                      style: textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                  )).toList(),
            ),
          ],
          if (progression.readyForHarder) ...[
            BotanicaGaps.vSm,
            Row(
              children: [
                Icon(Icons.rocket_launch_rounded,
                    size: BotanicaTokens.iconSizeSm, color: scheme.tertiary),
                BotanicaGaps.hXxs,
                Text(
                  'Ready for harder plants!',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
