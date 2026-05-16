import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_health_forecast_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaHealthForecastCard extends StatelessWidget {
  const BotanicaHealthForecastCard({
    super.key,
    required this.forecasts,
  });

  final List<PlantHealthForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final atRisk = forecasts.where((f) => f.riskLevel == 'high').length;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Health Forecast',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (atRisk > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BotanicaTokens.spacingXxs,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                  ),
                  child: Text(
                    '$atRisk at risk',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.error,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          BotanicaGaps.vSm,
          ...forecasts.take(4).map((f) {
            final trendIcon = switch (f.trendDirection) {
              'improving' => Icons.trending_up_rounded,
              'declining' => Icons.trending_down_rounded,
              _ => Icons.trending_flat_rounded,
            };
            final trendColor = switch (f.trendDirection) {
              'improving' => const Color(0xFF66BB6A),
              'declining' => scheme.error,
              _ => scheme.onSurface.withValues(alpha: 0.5),
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
              child: Row(
                children: [
                  Icon(trendIcon, size: 14, color: trendColor),
                  BotanicaGaps.hXxs,
                  Expanded(
                    child: Text(
                      f.primaryFactor,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${(f.currentHealth * 100).round()}%',
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
