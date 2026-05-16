import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_confidence_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareConfidenceRadar extends StatelessWidget {
  const BotanicaCareConfidenceRadar({
    super.key,
    required this.report,
  });

  final CareConfidenceReport report;

  @override
  Widget build(BuildContext context) {
    if (report.dimensions.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final levelColor = switch (report.level) {
      'confidenceMaster' => scheme.tertiary,
      'confidenceConfident' => scheme.primary,
      'confidenceLearning' => const Color(0xFFFFA726),
      _ => scheme.outline,
    };

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: levelColor,
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Care Confidence',
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
                  color: levelColor.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${(report.overallConfidence * 100).round()}%',
                  style: textTheme.labelSmall?.copyWith(
                    color: levelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _RadarPainter(
                  dimensions: report.dimensions,
                  color: levelColor,
                  gridColor: scheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          BotanicaGaps.vSm,
          ...report.dimensions.map((d) => Padding(
                padding:
                    const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        _dimensionLabel(d.name),
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(BotanicaTokens.radiusPill),
                        child: LinearProgressIndicator(
                          value: d.score,
                          minHeight: 4,
                          backgroundColor:
                              scheme.outlineVariant.withValues(alpha: 0.2),
                          valueColor:
                              AlwaysStoppedAnimation(levelColor),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          BotanicaGaps.vXxs,
          Text(
            report.nextMilestone
                .replaceAll('confidenceMilestone', '')
                .replaceAllMapped(
                    RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
                .trim(),
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static String _dimensionLabel(String name) {
    return name
        .replaceAll('confidence', '')
        .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
        .trim();
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.dimensions,
    required this.color,
    required this.gridColor,
  });

  final List<ConfidenceDimension> dimensions;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final count = dimensions.length;
    if (count < 3) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var ring = 1; ring <= 3; ring++) {
      final r = radius * ring / 3;
      final path = Path();
      for (var i = 0; i < count; i++) {
        final angle = -math.pi / 2 + (2 * math.pi * i / count);
        final point = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / count);
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, end, gridPaint);
    }

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dataPath = Path();
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / count);
      final r = radius * dimensions[i].score;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / count);
      final r = radius * dimensions[i].score;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.dimensions != dimensions || oldDelegate.color != color;
}
