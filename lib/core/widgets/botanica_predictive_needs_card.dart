import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/predictive_needs_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaPredictiveNeedsCard extends StatelessWidget {
  const BotanicaPredictiveNeedsCard({
    super.key,
    required this.predictions,
  });

  final List<PlantNeedPrediction> predictions;

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) return const SizedBox.shrink();

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
              Icon(
                Icons.auto_graph_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Text(
                'Predicted Needs',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          BotanicaGaps.vXxs,
          ...predictions.take(3).map((p) => _PredictionRow(prediction: p)),
        ],
      ),
    );
  }
}

class _PredictionRow extends StatelessWidget {
  const _PredictionRow({required this.prediction});

  final PlantNeedPrediction prediction;

  IconData _iconFor(TaskType type) => switch (type) {
        TaskType.water => Icons.water_drop_rounded,
        TaskType.fertilize => Icons.science_rounded,
        TaskType.mist => Icons.blur_on_rounded,
        TaskType.rotate => Icons.rotate_right_rounded,
        TaskType.prune => Icons.content_cut_rounded,
        TaskType.repot => Icons.yard_rounded,
        TaskType.checkPests => Icons.bug_report_rounded,
        TaskType.wipeLeaves => Icons.cleaning_services_rounded,
        TaskType.sunlightAdjustment => Icons.wb_sunny_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final daysUntil = prediction.daysUntil;
    final urgency = daysUntil <= 1
        ? scheme.error
        : daysUntil <= 3
            ? const Color(0xFFFF9800)
            : scheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BotanicaTokens.spacingMicro),
      child: Row(
        children: [
          Icon(
            _iconFor(prediction.predictedNeed),
            size: BotanicaTokens.iconSizeSm,
            color: urgency,
          ),
          BotanicaGaps.hXs,
          Expanded(
            child: Text(
              prediction.predictedNeed.name,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            daysUntil <= 0
                ? 'today'
                : daysUntil == 1
                    ? 'tomorrow'
                    : 'in $daysUntil days',
            style: textTheme.labelSmall?.copyWith(
              color: urgency,
              fontWeight: FontWeight.w600,
            ),
          ),
          BotanicaGaps.hXxs,
          SizedBox(
            width: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: prediction.confidence,
                backgroundColor: scheme.outlineVariant.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(
                  urgency.withValues(alpha: 0.6),
                ),
                minHeight: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
