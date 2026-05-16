import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_social_graph_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaSocialGraphCard extends StatelessWidget {
  const BotanicaSocialGraphCard({
    super.key,
    required this.graph,
  });

  final GardenSocialGraph graph;

  @override
  Widget build(BuildContext context) {
    if (graph.siblingGroups.isEmpty && graph.relationships.isEmpty) {
      return const SizedBox.shrink();
    }

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
              Icon(Icons.hub_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Plant Social Graph',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (graph.socialButterfly != null)
                const Text(
                  '\u{1F33B}',
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
          BotanicaGaps.vSm,
          ...graph.siblingGroups.take(3).map((g) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: scheme.tertiary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        '${g.groupName} (${g.plants.length})',
                        style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      g.sharedTrait,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )),
          if (graph.lonelyPlants.isNotEmpty) ...[
            BotanicaGaps.vXxs,
            Text(
              '${graph.lonelyPlants.length} solo plants',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
