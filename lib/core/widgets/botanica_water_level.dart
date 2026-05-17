import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/motion_preferences.dart';

class BotanicaWaterLevel extends StatefulWidget {
  const BotanicaWaterLevel({
    super.key,
    required this.progress,
    this.size = 42,
    this.strokeWidth = 3.0,
    this.showWave = true,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final bool showWave;

  @override
  State<BotanicaWaterLevel> createState() => _BotanicaWaterLevelState();
}

class _BotanicaWaterLevelState extends State<BotanicaWaterLevel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (botanicaReduceMotion(context)) {
      _waveController.stop();
    } else if (!_waveController.isAnimating) {
      _waveController.repeat();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = botanicaReduceMotion(context);

    final waterColor = _colorForProgress(widget.progress, scheme);
    final bgColor = scheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return Semantics(
      label: 'Water level ${(widget.progress * 100).round()} percent',
      child: SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(widget.size),
            painter: _RingPainter(
              progress: widget.progress,
              color: waterColor,
              backgroundColor: bgColor,
              strokeWidth: widget.strokeWidth,
            ),
          ),
          if (widget.showWave && widget.progress > 0)
            ClipOval(
              child: SizedBox(
                width: widget.size - widget.strokeWidth * 2 - 4,
                height: widget.size - widget.strokeWidth * 2 - 4,
                child: reduceMotion
                    ? CustomPaint(
                        painter: _WavePainter(
                          t: 0,
                          fillLevel: widget.progress,
                          color: waterColor.withValues(alpha: 0.25),
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, _) => CustomPaint(
                          painter: _WavePainter(
                            t: _waveController.value,
                            fillLevel: widget.progress,
                            color: waterColor.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
              ),
            ),
          Icon(
            Icons.water_drop_rounded,
            size: widget.size * 0.38,
            color: waterColor.withValues(alpha: 0.85),
          ),
        ],
      ),
    ),
    );
  }

  Color _colorForProgress(double progress, ColorScheme scheme) {
    if (progress >= 0.85) return const Color(0xFFDC2626);
    if (progress >= 0.6) return const Color(0xFFD97706);
    if (progress >= 0.3) return const Color(0xFF3B82C4);
    return const Color(0xFF2E7D4F);
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.t,
    required this.fillLevel,
    required this.color,
  });

  final double t;
  final double fillLevel;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final waterHeight = h * (1 - fillLevel);

    final path = Path();
    path.moveTo(0, h);

    for (double x = 0; x <= w; x += 1) {
      final y = waterHeight +
          sin((x / w * 2 * pi) + (t * 2 * pi)) * 3 +
          cos((x / w * 3 * pi) + (t * 2 * pi * 1.3)) * 2;
      path.lineTo(x, y);
    }

    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.fillLevel != fillLevel;
  }
}
