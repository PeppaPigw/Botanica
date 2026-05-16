import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_confidence_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareConfidenceCard extends StatelessWidget {
  const BotanicaCareConfidenceCard({
    super.key,
    required this.report,
  });

  final CareConfidenceReport report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final levelColor = _levelColor(report.level, scheme);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology_rounded, size: 16, color: levelColor),
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _levelLabel(report.level),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      report.nextMilestone.isNotEmpty
                          ? 'Next: ${_milestoneLabel(report.nextMilestone)}'
                          : '',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              _ConfidenceRing(
                value: report.overallConfidence,
                color: levelColor,
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...report.dimensions.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: _DimensionRow(
                  dimension: d,
                  scheme: scheme,
                  textTheme: textTheme,
                ),
              )),
        ],
      ),
    );
  }

  static Color _levelColor(String level, ColorScheme scheme) {
    return switch (level) {
      'confidenceMaster' => const Color(0xFF9C27B0),
      'confidenceConfident' => const Color(0xFF66BB6A),
      'confidenceLearning' => const Color(0xFFFF9800),
      _ => scheme.primary,
    };
  }

  static String _levelLabel(String level) {
    return switch (level) {
      'confidenceMaster' => 'Plant Master',
      'confidenceConfident' => 'Confident Carer',
      'confidenceLearning' => 'Growing Learner',
      _ => 'Plant Novice',
    };
  }

  static String _milestoneLabel(String milestone) {
    return switch (milestone) {
      'confidenceMilestoneKeepGoing' => 'Keep the streak alive',
      'confidenceMilestoneMaster' => 'Reach Master level',
      'confidenceMilestoneConfident' => 'Reach Confident level',
      _ => 'Build your routine',
    };
  }
}

class _ConfidenceRing extends StatelessWidget {
  const _ConfidenceRing({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 3,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text(
            '${(value * 100).round()}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _DimensionRow extends StatelessWidget {
  const _DimensionRow({
    required this.dimension,
    required this.scheme,
    required this.textTheme,
  });

  final ConfidenceDimension dimension;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            _dimensionLabel(dimension.name),
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: dimension.score,
              minHeight: 4,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(
                _barColor(dimension.score, scheme),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 24,
          child: Text(
            '${(dimension.score * 100).round()}',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontSize: 9,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  static String _dimensionLabel(String name) {
    return switch (name) {
      'confidenceConsistency' => 'Consistency',
      'confidenceDiversity' => 'Diversity',
      'confidenceHealth' => 'Health',
      'confidenceExperience' => 'Experience',
      'confidenceVariety' => 'Variety',
      _ => name,
    };
  }

  static Color _barColor(double score, ColorScheme scheme) {
    if (score >= 0.7) return const Color(0xFF66BB6A);
    if (score >= 0.4) return const Color(0xFFFF9800);
    return scheme.error;
  }
}
