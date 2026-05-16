import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_prediction_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCarePredictionCard extends StatelessWidget {
  const BotanicaCarePredictionCard({
    super.key,
    required this.predictions,
    required this.plantNames,
  });

  final Map<String, CarePrediction> predictions;
  final Map<String, String> plantNames;

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final sorted = predictions.entries.toList()
      ..sort((a, b) => a.value.predictedDate.compareTo(b.value.predictedDate));

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Next Watering',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...sorted.take(5).map((entry) {
            final name = plantNames[entry.key] ?? entry.key;
            final daysUntil = entry.value.predictedDate
                .difference(DateTime.now()).inDays;
            final urgencyColor = daysUntil <= 0
                ? scheme.error
                : daysUntil <= 1
                    ? const Color(0xFFFF9800)
                    : scheme.onSurface.withValues(alpha: 0.6);

            return Padding(
              padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
              child: Row(
                children: [
                  Icon(Icons.water_drop_rounded, size: 12, color: urgencyColor),
                  BotanicaGaps.hXxs,
                  Expanded(
                    child: Text(
                      name,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    daysUntil <= 0 ? 'now' : '${daysUntil}d',
                    style: textTheme.labelSmall?.copyWith(
                      color: urgencyColor,
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
