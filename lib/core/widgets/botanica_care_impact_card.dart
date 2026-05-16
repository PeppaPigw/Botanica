import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_impact_analyzer.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareImpactCard extends StatelessWidget {
  const BotanicaCareImpactCard({
    super.key,
    required this.summary,
  });

  final CareImpactSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final impactColor = summary.impactScore > 0.7
        ? scheme.tertiary
        : summary.impactScore > 0.4
            ? scheme.primary
            : const Color(0xFFFFA726);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded,
                  size: BotanicaTokens.iconSizeMd, color: impactColor),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Your Care Impact',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: impactColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${(summary.impactScore * 100).round()}%',
                  style: textTheme.labelSmall?.copyWith(
                    color: impactColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _ImpactStat(
                icon: Icons.water_drop_rounded,
                value: '${summary.totalWateringEvents}',
                label: 'waterings',
                scheme: scheme,
              ),
              BotanicaGaps.hSm,
              _ImpactStat(
                icon: Icons.healing_rounded,
                value: '${summary.plantsSavedFromDecline}',
                label: 'saved',
                scheme: scheme,
              ),
              BotanicaGaps.hSm,
              _ImpactStat(
                icon: Icons.category_rounded,
                value: '${summary.uniqueCareTypes}',
                label: 'types',
                scheme: scheme,
              ),
            ],
          ),
          BotanicaGaps.vSm,
          if (summary.longestCaredPlantName.isNotEmpty)
            Text(
              'Longest companion: ${summary.longestCaredPlantName} (${summary.longestCaredPlantDays}d)',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (summary.averageResponseTimeHours != null) ...[
            BotanicaGaps.vXxs,
            Text(
              'Avg response: ${summary.averageResponseTimeHours!.toStringAsFixed(1)}h',
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

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.scheme,
  });

  final IconData icon;
  final String value;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: scheme.primary.withValues(alpha: 0.7)),
          const SizedBox(height: 2),
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
