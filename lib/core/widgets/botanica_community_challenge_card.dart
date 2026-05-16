import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/community_challenge_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCommunityChallengeCard extends StatelessWidget {
  const BotanicaCommunityChallengeCard({
    super.key,
    required this.result,
  });

  final CommunityChallengeResult result;

  @override
  Widget build(BuildContext context) {
    if (result.activeChallenges.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.groups_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.secondary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Community Challenges',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${result.completedCount}/${result.activeChallenges.length}',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...result.activeChallenges.take(3).map((c) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (c.isComplete)
                          const Icon(Icons.check_circle_rounded, size: 12,
                              color: Color(0xFF66BB6A))
                        else
                          Icon(Icons.radio_button_unchecked_rounded, size: 12,
                              color: scheme.onSurface.withValues(alpha: 0.3)),
                        BotanicaGaps.hXxs,
                        Expanded(
                          child: Text(
                            c.titleKey.replaceAll('challenge_', '').replaceAll('_', ' '),
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: c.isComplete ? TextDecoration.lineThrough : null,
                              color: c.isComplete
                                  ? scheme.onSurface.withValues(alpha: 0.4)
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${c.currentValue}/${c.targetValue}',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16, top: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: c.progress.clamp(0.0, 1.0),
                          minHeight: 3,
                          backgroundColor: scheme.onSurface.withValues(alpha: 0.06),
                          valueColor: AlwaysStoppedAnimation(
                            c.isComplete
                                ? const Color(0xFF66BB6A)
                                : scheme.secondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
