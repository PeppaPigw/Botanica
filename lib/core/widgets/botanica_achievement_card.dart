import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_achievement_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaAchievementCard extends StatelessWidget {
  const BotanicaAchievementCard({
    super.key,
    required this.summary,
  });

  final AchievementSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  size: BotanicaTokens.iconSizeMd, color: Color(0xFFFFD700)),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Achievements',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${summary.unlockedCount}/${summary.totalAchievements}',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          BotanicaGaps.vXxs,
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
            child: LinearProgressIndicator(
              value: summary.completionRate.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD700)),
            ),
          ),
          if (summary.recentUnlocks.isNotEmpty) ...[
            BotanicaGaps.vSm,
            Text(
              'Recent',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
                fontSize: 9,
              ),
            ),
            BotanicaGaps.vXxs,
            ...summary.recentUnlocks.take(2).map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFD700)),
                      BotanicaGaps.hXxs,
                      Expanded(
                        child: Text(
                          a.titleKey.replaceAll('achievement_', '').replaceAll('_', ' '),
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (summary.nearCompletion.isNotEmpty) ...[
            BotanicaGaps.vXxs,
            ...summary.nearCompletion.take(2).map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                  child: Row(
                    children: [
                      Icon(Icons.star_outline_rounded, size: 12,
                          color: scheme.onSurface.withValues(alpha: 0.4)),
                      BotanicaGaps.hXxs,
                      Expanded(
                        child: Text(
                          a.titleKey.replaceAll('achievement_', '').replaceAll('_', ' '),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: a.progressPercent,
                            minHeight: 3,
                            backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation(
                                scheme.onSurface.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
