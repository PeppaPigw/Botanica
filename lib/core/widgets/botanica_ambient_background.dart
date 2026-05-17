import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/motion_preferences.dart';

class BotanicaAmbientBackground extends StatefulWidget {
  const BotanicaAmbientBackground({
    super.key,
    this.color,
    this.secondaryColor,
    this.intensity = 0.15,
    this.speed = 1.0,
  });

  final Color? color;
  final Color? secondaryColor;
  final double intensity;
  final double speed;

  @override
  State<BotanicaAmbientBackground> createState() =>
      _BotanicaAmbientBackgroundState();
}

class _BotanicaAmbientBackgroundState extends State<BotanicaAmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (12000 / widget.speed).round()),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (botanicaReduceMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = widget.color ?? scheme.tertiary.withValues(alpha: widget.intensity);
    final secondary = widget.secondaryColor ??
        scheme.primary.withValues(alpha: widget.intensity * 0.6);

    if (botanicaReduceMotion(context)) {
      return ExcludeSemantics(
        child: CustomPaint(
          painter: _OrganicBlobPainter(
            t: 0.0,
            primary: primary,
            secondary: secondary,
          ),
          size: Size.infinite,
        ),
      );
    }

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _OrganicBlobPainter(
            t: _controller.value,
            primary: primary,
            secondary: secondary,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _OrganicBlobPainter extends CustomPainter {
  const _OrganicBlobPainter({
    required this.t,
    required this.primary,
    required this.secondary,
  });

  final double t;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawBlob(
      canvas,
      center: Offset(w * 0.25 + sin(t * 2 * pi) * w * 0.08, h * 0.2 + cos(t * 2 * pi) * h * 0.05),
      radius: w * 0.35,
      color: primary,
      phase: t,
      complexity: 6,
    );

    _drawBlob(
      canvas,
      center: Offset(w * 0.75 + cos(t * 2 * pi + 1.2) * w * 0.06, h * 0.55 + sin(t * 2 * pi + 0.8) * h * 0.04),
      radius: w * 0.28,
      color: secondary,
      phase: t + 0.33,
      complexity: 5,
    );

    _drawBlob(
      canvas,
      center: Offset(w * 0.5 + sin(t * 2 * pi + 2.4) * w * 0.05, h * 0.82 + cos(t * 2 * pi + 1.6) * h * 0.03),
      radius: w * 0.3,
      color: Color.lerp(primary, secondary, 0.5)!,
      phase: t + 0.66,
      complexity: 7,
    );
  }

  void _drawBlob(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double phase,
    required int complexity,
  }) {
    final path = Path();
    final points = <Offset>[];

    for (var i = 0; i < complexity; i++) {
      final angle = (i / complexity) * 2 * pi;
      final noise = sin(phase * 2 * pi + i * 1.7) * 0.2 +
          cos(phase * 2 * pi * 0.7 + i * 2.3) * 0.15;
      final r = radius * (1.0 + noise);
      points.add(Offset(
        center.dx + cos(angle) * r,
        center.dy + sin(angle) * r,
      ));
    }

    if (points.isEmpty) return;

    path.moveTo(
      (points.last.dx + points.first.dx) / 2,
      (points.last.dy + points.first.dy) / 2,
    );

    for (var i = 0; i < points.length; i++) {
      final next = points[(i + 1) % points.length];
      final midX = (points[i].dx + next.dx) / 2;
      final midY = (points[i].dy + next.dy) / 2;
      path.quadraticBezierTo(points[i].dx, points[i].dy, midX, midY);
    }

    path.close();

    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OrganicBlobPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary;
  }
}
