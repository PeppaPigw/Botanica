import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/botanica_tokens.dart';
import '../utils/motion_preferences.dart';

/// A wrapper that gives its child a calm, editorial entrance animation.
///
/// Standardizes page section entrance motion across the app so every screen
/// feels like one magazine layout system with consistent reveal timing.
class BotanicaAnimatedSection extends StatelessWidget {
  const BotanicaAnimatedSection({
    super.key,
    required this.child,
    this.index = 0,
    this.slideOffset = 0.02,
    this.duration,
    this.delay,
    this.enabled = true,
  });

  final Widget child;

  /// The stagger index. Higher values introduce an increasing delay so
  /// sections build up top-to-bottom.
  final int index;

  /// Vertical slide offset in fractions of the viewport (0.02 = ~2 %).
  final double slideOffset;

  /// Override the default animation duration.
  final Duration? duration;

  /// Override the default stagger delay.
  final Duration? delay;

  /// Set to false to disable animations (e.g. when reduce-motion is on).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || botanicaReduceMotion(context)) return child;

    final effectiveDuration = duration ?? BotanicaTokens.motionMedium;
    final effectiveDelay = delay ?? BotanicaTokens.motionStagger * index;

    return child
        .animate()
        .fadeIn(
          duration: effectiveDuration,
          delay: effectiveDelay,
          curve: BotanicaTokens.curveReveal,
        )
        .slideY(
          begin: slideOffset,
          end: 0,
          duration: effectiveDuration,
          delay: effectiveDelay,
          curve: BotanicaTokens.curveReveal,
        );
  }
}

/// Extension on Widget for quick inline section animation.
extension BotanicaSectionAnimation on Widget {
  /// Applies the standard Botanica page-section entrance animation.
  Widget animateSection({int index = 0}) {
    return BotanicaAnimatedSection(index: index, child: this);
  }
}
