import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/services/plant_health_forecast_engine.dart';
import 'botanica_gaps.dart';

class BotanicaHealthForecastMini extends StatelessWidget {
  const BotanicaHealthForecastMini({
    super.key,
    required this.forecast,
    this.height = 48,
  });

  final PlantHealthForecast forecast;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final trendColor = switch (forecast.trendDirection) {
      'improving' => scheme.tertiary,
      'declining' => scheme.error,
      _ => scheme.primary,
    };

    final trendIcon = switch (forecast.trendDirection) {
      'improving' => Icons.trending_up_rounded,
      'declining' => Icons.trending_down_rounded,
      _ => Icons.trending_flat_rounded,
    };

    return Row(
      children: [
        SizedBox(
          width: 80,
          height: height,
          child: CustomPaint(
            painter: _SparklinePainter(
              points: forecast.forecastPoints
                  .map((p) => p.predictedHealth)
                  .toList(),
              color: trendColor,
              fillColor: trendColor.withValues(alpha: 0.1),
            ),
          ),
        ),
        BotanicaGaps.hSm,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(trendIcon, size: 14, color: trendColor),
                const SizedBox(width: 4),
                Text(
                  forecast.trendDirection,
                  style: textTheme.labelSmall?.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              forecast.primaryFactor,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.points,
    required this.color,
    required this.fillColor,
  });

  final List<double> points;
  final Color color;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minVal = points.reduce(math.min);
    final maxVal = points.reduce(math.max);
    final range = maxVal - minVal;
    final effectiveRange = range < 0.01 ? 1.0 : range;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height -
          ((points[i] - minVal) / effectiveRange) * size.height * 0.8 -
          size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
