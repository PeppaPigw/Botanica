import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_health_timeline.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaHealthTimelineCard extends StatelessWidget {
  const BotanicaHealthTimelineCard({
    super.key,
    required this.timelines,
  });

  final List<HealthTimeline> timelines;

  @override
  Widget build(BuildContext context) {
    if (timelines.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final improving = timelines.where((t) => t.trend > 0.1).length;
    final declining = timelines.where((t) => t.trend < -0.1).length;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Health Timeline',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          BotanicaGaps.vXxs,
          Row(
            children: [
              if (improving > 0)
                Text(
                  '$improving improving',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF66BB6A),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (improving > 0 && declining > 0) BotanicaGaps.hXs,
              if (declining > 0)
                Text(
                  '$declining declining',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.error,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          BotanicaGaps.vSm,
          ...timelines.take(4).map((t) {
            final trendColor = t.trend > 0.1
                ? const Color(0xFF66BB6A)
                : t.trend < -0.1
                    ? scheme.error
                    : scheme.onSurface.withValues(alpha: 0.5);
            final trendIcon = t.trend > 0.1
                ? Icons.trending_up_rounded
                : t.trend < -0.1
                    ? Icons.trending_down_rounded
                    : Icons.trending_flat_rounded;

            return Padding(
              padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
              child: Row(
                children: [
                  Icon(trendIcon, size: 12, color: trendColor),
                  BotanicaGaps.hXxs,
                  Expanded(
                    child: Text(
                      t.plantNickname,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (t.snapshots.isNotEmpty)
                    Text(
                      '${(t.snapshots.last.score * 100).round()}%',
                      style: textTheme.labelSmall?.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
