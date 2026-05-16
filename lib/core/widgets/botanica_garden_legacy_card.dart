import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_legacy_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaGardenLegacyCard extends StatelessWidget {
  const BotanicaGardenLegacyCard({
    super.key,
    required this.report,
    this.plantNameResolver,
  });

  final GardenLegacyReport report;
  final String Function(String plantId)? plantNameResolver;

  @override
  Widget build(BuildContext context) {
    if (report.plantScores.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final statusColor = switch (report.statusKey) {
      'legacyLegendary' => scheme.tertiary,
      'legacyEstablished' => scheme.primary,
      'legacyGrowing' => const Color(0xFF66BB6A),
      _ => scheme.outline,
    };

    final statusIcon = switch (report.statusKey) {
      'legacyLegendary' => Icons.emoji_events_rounded,
      'legacyEstablished' => Icons.park_rounded,
      'legacyGrowing' => Icons.trending_up_rounded,
      _ => Icons.eco_rounded,
    };

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(statusIcon, size: BotanicaTokens.iconSizeMd, color: statusColor),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Garden Legacy',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${report.totalCareActions} actions',
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          _LegacyMeter(score: report.overallScore, color: statusColor, scheme: scheme),
          BotanicaGaps.vSm,
          if (report.longestSurvivor != null) ...[
            Row(
              children: [
                Icon(Icons.timer_rounded, size: 14, color: scheme.primary),
                BotanicaGaps.hXs,
                Expanded(
                  child: Text(
                    'Longest companion: ${plantNameResolver?.call(report.longestSurvivor!) ?? report.longestSurvivor!.substring(0, 8)}',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            BotanicaGaps.vXxs,
          ],
          ...report.plantScores.take(3).map((ps) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    BotanicaGaps.hXs,
                    Expanded(
                      child: Text(
                        plantNameResolver?.call(ps.plantId) ?? ps.plantId.substring(0, 8),
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${ps.ageDays}d',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.5),
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

class _LegacyMeter extends StatelessWidget {
  const _LegacyMeter({
    required this.score,
    required this.color,
    required this.scheme,
  });

  final double score;
  final Color color;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
          child: LinearProgressIndicator(
            value: score,
            minHeight: 6,
            backgroundColor: scheme.outlineVariant.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        BotanicaGaps.vXxs,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budding',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 9,
                  ),
            ),
            Text(
              'Legendary',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 9,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
