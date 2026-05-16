import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_diversity_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaDiversityCard extends StatelessWidget {
  const BotanicaDiversityCard({
    super.key,
    required this.metrics,
  });

  final DiversityMetrics metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.speciesCount == 0) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final indexColor = metrics.overallIndex >= 0.7
        ? scheme.tertiary
        : metrics.overallIndex >= 0.4
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
                Icons.diversity_3_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: indexColor.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Text(
                'Biodiversity Index',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(metrics.overallIndex * 100).round()}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: indexColor,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          _DiversityBar(
            label: 'Species',
            value: metrics.uniqueSpeciesRatio,
            color: scheme.primary,
          ),
          BotanicaGaps.vXxs,
          _DiversityBar(
            label: 'Light needs',
            value: metrics.lightSpread,
            color: scheme.tertiary,
          ),
          BotanicaGaps.vXxs,
          _DiversityBar(
            label: 'Difficulty',
            value: metrics.difficultySpread,
            color: scheme.secondary,
          ),
          BotanicaGaps.vXxs,
          _DiversityBar(
            label: 'Environment',
            value: metrics.environmentSpread,
            color: const Color(0xFF4CAF50),
          ),
          if (metrics.suggestions.isNotEmpty) ...[
            BotanicaGaps.vSm,
            Text(
              metrics.suggestions.first,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiversityBar extends StatelessWidget {
  const _DiversityBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: scheme.outlineVariant.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.7)),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '${(value * 100).round()}%',
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
