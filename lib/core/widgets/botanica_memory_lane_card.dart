import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_memory_lane_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaMemoryLaneCard extends StatelessWidget {
  const BotanicaMemoryLaneCard({
    super.key,
    required this.result,
  });

  final MemoryLaneResult result;

  @override
  Widget build(BuildContext context) {
    final memories = result.all;
    if (memories.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.photo_album_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Memory Lane',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${memories.length} memories',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...memories.take(3).map((m) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 12,
                        color: scheme.tertiary.withValues(alpha: 0.6)),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        '${m.plantNickname}: ${m.titleKey}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
