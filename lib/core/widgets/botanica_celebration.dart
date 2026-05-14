import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/motion_preferences.dart';

class BotanicaCelebration extends StatefulWidget {
  const BotanicaCelebration({
    super.key,
    required this.trigger,
    this.particleCount = 24,
    this.colors,
    this.child,
  });

  final bool trigger;
  final int particleCount;
  final List<Color>? colors;
  final Widget? child;

  static void show(BuildContext context) {
    if (botanicaReduceMotion(context)) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _CelebrationOverlay(
        onComplete: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<BotanicaCelebration> createState() => _BotanicaCelebrationState();
}

class _BotanicaCelebrationState extends State<BotanicaCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Particle> _particles;
  bool _wasTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _particles = [];
  }

  @override
  void didUpdateWidget(covariant BotanicaCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !_wasTriggered) {
      _fire();
    }
    _wasTriggered = widget.trigger;
  }

  void _fire() {
    if (botanicaReduceMotion(context)) return;

    final rng = Random();
    final colors = widget.colors ??
        const [
          Color(0xFF4CAF50),
          Color(0xFF81C784),
          Color(0xFF66BB6A),
          Color(0xFFA5D6A7),
          Color(0xFF43A047),
          Color(0xFF2E7D32),
          Color(0xFFFFD54F),
          Color(0xFF4DB6AC),
        ];

    _particles = List.generate(widget.particleCount, (i) {
      final angle = (i / widget.particleCount) * 2 * pi + rng.nextDouble() * 0.5;
      final speed = 0.5 + rng.nextDouble() * 1.5;
      final size = 4.0 + rng.nextDouble() * 6.0;
      return _Particle(
        angle: angle,
        speed: speed,
        size: size,
        color: colors[rng.nextInt(colors.length)],
        rotationSpeed: (rng.nextDouble() - 0.5) * 4,
        shape: rng.nextBool() ? _ParticleShape.circle : _ParticleShape.leaf,
      );
    });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (widget.child != null) widget.child!,
        if (_particles.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _CelebrationPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum _ParticleShape { circle, leaf }

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.shape,
  });

  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
  final _ParticleShape shape;
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter({
    required this.particles,
    required this.progress,
  });

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = size.width * 0.8;

    for (final particle in particles) {
      final distance = maxRadius * progress * particle.speed;
      final gravity = progress * progress * 40;
      final x = centerX + cos(particle.angle) * distance;
      final y = centerY + sin(particle.angle) * distance + gravity;

      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final scale = 1.0 - (progress * 0.3);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotationSpeed * progress * pi);
      canvas.scale(scale);

      if (particle.shape == _ParticleShape.circle) {
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      } else {
        final path = Path();
        final s = particle.size;
        path.moveTo(0, -s / 2);
        path.quadraticBezierTo(s / 2, -s / 4, s / 3, s / 4);
        path.quadraticBezierTo(0, s / 2, -s / 3, s / 4);
        path.quadraticBezierTo(-s / 2, -s / 4, 0, -s / 2);
        path.close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward().then((_) => widget.onComplete());

    final rng = Random();
    const colors = [
      Color(0xFF4CAF50),
      Color(0xFF81C784),
      Color(0xFF66BB6A),
      Color(0xFFA5D6A7),
      Color(0xFF43A047),
      Color(0xFFFFD54F),
      Color(0xFF4DB6AC),
      Color(0xFF80DEEA),
    ];

    _particles = List.generate(30, (i) {
      final angle = (i / 30) * 2 * pi + rng.nextDouble() * 0.4;
      return _Particle(
        angle: angle,
        speed: 0.4 + rng.nextDouble() * 1.6,
        size: 4.0 + rng.nextDouble() * 7.0,
        color: colors[rng.nextInt(colors.length)],
        rotationSpeed: (rng.nextDouble() - 0.5) * 5,
        shape: rng.nextBool() ? _ParticleShape.circle : _ParticleShape.leaf,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _CelebrationPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}
