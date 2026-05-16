import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/water_efficiency_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaWaterEfficiencyCard extends StatelessWidget {
  const BotanicaWaterEfficiencyCard({
    super.key,
    required this.result,
    required this.plantName,
  });

  final WaterEfficiencyResult result;
  final String plantName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final effColor = switch (result.efficiency) {
      WaterEfficiency.optimal => const Color(0xFF66BB6A),
      WaterEfficiency.overwatering => const Color(0xFF42A5F5),
      WaterEfficiency.underwatering => const Color(0xFFFFA726),
      WaterEfficiency.insufficient => scheme.error,
    };

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  size: BotanicaTokens.iconSizeMd, color: effColor),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Water Efficiency',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: effColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  result.efficiency.name,
                  style: textTheme.labelSmall?.copyWith(
                    color: effColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Text(
            plantName,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          BotanicaGaps.vXxs,
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
            child: LinearProgressIndicator(
              value: result.score.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(effColor),
            ),
          ),
          BotanicaGaps.vXxs,
          Row(
            children: [
              Text(
                'Every ${result.actualIntervalDays.toStringAsFixed(1)}d',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Text(
                'Ideal: ${result.recommendedIntervalDays}d',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
