import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/micro_season_detector.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaMicroSeasonCard extends StatelessWidget {
  const BotanicaMicroSeasonCard({
    super.key,
    required this.report,
  });

  final MicroSeasonReport report;

  @override
  Widget build(BuildContext context) {
    if (report.currentMicroSeason == null && report.detectedSeasons.isEmpty) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final current = report.currentMicroSeason;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Micro Seasons',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                report.dataQuality,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          if (current != null) ...[
            BotanicaGaps.vSm,
            Container(
              padding: const EdgeInsets.all(BotanicaTokens.spacingXs),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.name,
                          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Water x${current.wateringMultiplier.toStringAsFixed(1)}',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(current.confidence * 100).round()}%',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (report.detectedSeasons.length > 1) ...[
            BotanicaGaps.vXxs,
            Text(
              '${report.detectedSeasons.length} micro-seasons detected',
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
