import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/botanica_tokens.dart';
import '../utils/motion_preferences.dart';

/// A premium shimmer skeleton widget for Botanica loading states.
///
/// Use this whenever async content is loading to provide a calm, editorial
/// loading indicator instead of blank space or spinners.
class BotanicaShimmer extends StatelessWidget {
  const BotanicaShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.child,
  });

  /// A card-shaped shimmer for list items.
  const factory BotanicaShimmer.card({
    Key? key,
    double height,
  }) = _BotanicaShimmerCard;

  /// A circular shimmer for avatars.
  const factory BotanicaShimmer.circle({
    Key? key,
    double size,
  }) = _BotanicaShimmerCircle;

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseColor = scheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final highlightColor =
        scheme.surfaceContainerHighest.withValues(alpha: 0.6);

    final base = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius:
            borderRadius ?? BorderRadius.circular(BotanicaTokens.radiusS),
      ),
      child: child,
    );

    if (botanicaReduceMotion(context)) return base;

    return base
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: BotanicaTokens.motionSpring * 3,
          color: highlightColor,
        );
  }
}

class _BotanicaShimmerCard extends BotanicaShimmer {
  const _BotanicaShimmerCard({
    super.key,
    super.height = 80,
  }) : super(
          borderRadius: const BorderRadius.all(
            Radius.circular(BotanicaTokens.radiusL),
          ),
        );
}

class _BotanicaShimmerCircle extends BotanicaShimmer {
  const _BotanicaShimmerCircle({
    super.key,
    double size = 48,
  }) : super(
          width: size,
          height: size,
          borderRadius: const BorderRadius.all(
            Radius.circular(BotanicaTokens.radiusPill),
          ),
        );
}

/// A pre-built skeleton layout for list screens (Garden, Tasks, Discover).
class BotanicaListSkeleton extends StatelessWidget {
  const BotanicaListSkeleton({
    super.key,
    this.itemCount = 5,
    this.showHero = true,
  });

  final int itemCount;
  final bool showHero;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: BotanicaTokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHero) ...[
            const BotanicaShimmer.card(height: 140),
            const SizedBox(height: BotanicaTokens.spacingRelaxed),
          ],
          for (int i = 0; i < itemCount; i++) ...[
            _SkeletonListItem(index: i),
            if (i < itemCount - 1)
              const SizedBox(height: BotanicaTokens.spacingBase),
          ],
        ],
      ),
    );
  }
}

class _SkeletonListItem extends StatelessWidget {
  const _SkeletonListItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final item = Row(
      children: [
        const BotanicaShimmer.circle(size: 48),
        const SizedBox(width: BotanicaTokens.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BotanicaShimmer(
                width: 120.0 + (index * 20 % 80),
                height: 14,
              ),
              const SizedBox(height: BotanicaTokens.spacingXxs),
              BotanicaShimmer(
                width: 80.0 + (index * 15 % 60),
                height: 12,
              ),
            ],
          ),
        ),
      ],
    );

    if (botanicaReduceMotion(context)) return item;

    return item
        .animate()
        .fadeIn(
          delay: BotanicaTokens.motionStagger * index,
          duration: BotanicaTokens.motionMedium,
        )
        .slideY(begin: 0.02, end: 0, curve: BotanicaTokens.curveReveal);
  }
}
