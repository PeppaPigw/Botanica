import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/watering_efficiency_analyzer.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaWateringEfficiencyCard extends StatelessWidget {
  const BotanicaWateringEfficiencyCard({
    super.key,
    required this.analyses,
  });

  final List<WateringAnalysis> analyses;

  @override
  Widget build(BuildContext context) {
    if (analyses.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final optimal = analyses.where((a) => a.efficiency == WateringEfficiency.optimal).length;
    final ratio = optimal / analyses.length;

    final overallColor = ratio >= 0.7
        ? scheme.tertiary
        : ratio >= 0.4
            ? scheme.primary
            : scheme.error;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.water_drop_outlined,
                size: BotanicaTokens.iconSizeMd,
                color: overallColor.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.wateringEfficiencyTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: overallColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  l10n.wateringEfficiencyOptimal(optimal, analyses.length),
                  style: textTheme.labelSmall?.copyWith(
                    color: overallColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...analyses.take(3).map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      _efficiencyIcon(a.efficiency),
                      size: 14,
                      color: _efficiencyColor(a.efficiency, scheme)
                          .withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        a.plantNickname,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${a.avgIntervalDays.round()}d / ${a.idealIntervalDays}d',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              )),
          if (analyses.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n.wateringEfficiencyMore(analyses.length - 3),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _efficiencyIcon(WateringEfficiency eff) {
    switch (eff) {
      case WateringEfficiency.optimal:
        return Icons.check_circle_outline;
      case WateringEfficiency.overwatering:
        return Icons.water_drop;
      case WateringEfficiency.underwatering:
        return Icons.water_drop_outlined;
      case WateringEfficiency.erratic:
        return Icons.shuffle_rounded;
    }
  }

  static Color _efficiencyColor(WateringEfficiency eff, ColorScheme scheme) {
    switch (eff) {
      case WateringEfficiency.optimal:
        return scheme.tertiary;
      case WateringEfficiency.overwatering:
        return scheme.primary;
      case WateringEfficiency.underwatering:
        return scheme.error;
      case WateringEfficiency.erratic:
        return scheme.secondary;
    }
  }
}
