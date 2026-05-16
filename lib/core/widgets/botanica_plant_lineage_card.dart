import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_lineage_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaPlantLineageCard extends StatelessWidget {
  const BotanicaPlantLineageCard({
    super.key,
    required this.legacy,
  });

  final GardenLegacy legacy;

  @override
  Widget build(BuildContext context) {
    if (legacy.lineageTree.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.account_tree_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Plant Lineage',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${legacy.totalGenerations} gen',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _LineageStat(label: 'Founders', value: '${legacy.founderCount}', scheme: scheme),
              BotanicaGaps.hSm,
              _LineageStat(label: 'Propagated', value: '${legacy.propagatedCount}', scheme: scheme),
              BotanicaGaps.hSm,
              _LineageStat(label: 'Longest', value: '${legacy.longestLineage}', scheme: scheme),
            ],
          ),
          if (legacy.oldestPlant != null) ...[
            BotanicaGaps.vSm,
            Text(
              'Oldest: ${legacy.oldestPlant!.nickname} (${legacy.oldestPlant!.daysOwned}d)',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
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

class _LineageStat extends StatelessWidget {
  const _LineageStat({required this.label, required this.value, required this.scheme});

  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
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
    );
  }
}
