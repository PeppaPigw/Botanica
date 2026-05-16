import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_insights_aggregator.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaGardenInsightsCard extends StatelessWidget {
  const BotanicaGardenInsightsCard({
    super.key,
    required this.feed,
  });

  final GardenInsightsFeed feed;

  @override
  Widget build(BuildContext context) {
    if (feed.insights.isEmpty) return const SizedBox.shrink();

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
              Icon(
                Icons.insights_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.tertiary.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Garden Insights',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...feed.insights.take(3).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _insightIcon(insight.type),
                      size: 14,
                      color: _insightColor(insight.type, scheme)
                          .withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface.withValues(alpha: 0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            insight.body,
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: scheme.onSurface.withValues(alpha: 0.55),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static IconData _insightIcon(GardenInsightType type) {
    switch (type) {
      case GardenInsightType.greeting:
        return Icons.waving_hand_outlined;
      case GardenInsightType.nextAction:
        return Icons.play_arrow_rounded;
      case GardenInsightType.stressAlert:
        return Icons.warning_amber_rounded;
      case GardenInsightType.seasonalTip:
        return Icons.wb_sunny_outlined;
      case GardenInsightType.weeklyHighlight:
        return Icons.star_outline_rounded;
    }
  }

  static Color _insightColor(GardenInsightType type, ColorScheme scheme) {
    switch (type) {
      case GardenInsightType.greeting:
        return scheme.tertiary;
      case GardenInsightType.nextAction:
        return scheme.primary;
      case GardenInsightType.stressAlert:
        return scheme.error;
      case GardenInsightType.seasonalTip:
        return scheme.secondary;
      case GardenInsightType.weeklyHighlight:
        return scheme.tertiary;
    }
  }
}
