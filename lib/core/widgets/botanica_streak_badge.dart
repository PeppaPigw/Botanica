import 'package:flutter/material.dart';

import '../utils/motion_preferences.dart';

class BotanicaStreakBadge extends StatelessWidget {
  const BotanicaStreakBadge({
    super.key,
    required this.streakDays,
    this.size = 56,
    this.showLabel = true,
  });

  final int streakDays;
  final double size;
  final bool showLabel;

  static const _milestones = [7, 30, 90, 365];

  _StreakTier get _tier {
    if (streakDays >= 365) return _StreakTier.legendary;
    if (streakDays >= 90) return _StreakTier.gold;
    if (streakDays >= 30) return _StreakTier.silver;
    if (streakDays >= 7) return _StreakTier.bronze;
    return _StreakTier.starter;
  }

  bool get _nearMilestone {
    for (final m in _milestones) {
      final diff = m - streakDays;
      if (diff > 0 && diff <= 2) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tier = _tier;
    final reduceMotion = botanicaReduceMotion(context);

    final gradient = switch (tier) {
      _StreakTier.legendary => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFFFF1744)],
        ),
      _StreakTier.gold => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
        ),
      _StreakTier.silver => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
        ),
      _StreakTier.bronze => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBCAAA4), Color(0xFF8D6E63)],
        ),
      _StreakTier.starter => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.primary.withValues(alpha: 0.7),
          ],
        ),
    };

    final icon = switch (tier) {
      _StreakTier.legendary => Icons.auto_awesome_rounded,
      _StreakTier.gold => Icons.emoji_events_rounded,
      _StreakTier.silver => Icons.workspace_premium_rounded,
      _StreakTier.bronze => Icons.local_fire_department_rounded,
      _StreakTier.starter => Icons.local_fire_department_rounded,
    };

    Widget badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: (tier == _StreakTier.legendary
                    ? const Color(0xFFFF6B35)
                    : scheme.primary)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.48,
          color: tier == _StreakTier.silver
              ? const Color(0xFF424242)
              : Colors.white,
        ),
      ),
    );

    if (_nearMilestone && !reduceMotion) {
      badge = _PulsingBadge(child: badge);
    }

    return Semantics(
      label: '$streakDays day care streak, ${tier.name} tier',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge,
          if (showLabel) ...[
            const SizedBox(height: 6),
            Text(
              '$streakDays',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _StreakTier { starter, bronze, silver, gold, legendary }

class _PulsingBadge extends StatefulWidget {
  const _PulsingBadge({required this.child});
  final Widget child;

  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + 0.05 * _controller.value;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

/// A horizontal row showing streak milestones with progress.
class BotanicaStreakProgress extends StatelessWidget {
  const BotanicaStreakProgress({
    super.key,
    required this.currentStreak,
  });

  final int currentStreak;

  static const _milestones = [7, 30, 90, 365];

  bool get _nearMilestone {
    for (final m in _milestones) {
      final diff = m - currentStreak;
      if (diff > 0 && diff <= 2) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = botanicaReduceMotion(context);

    final nextMilestone = _milestones.firstWhere(
      (m) => m > currentStreak,
      orElse: () => _milestones.last,
    );
    final progress = currentStreak >= nextMilestone
        ? 1.0
        : currentStreak / nextMilestone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 18,
              color: currentStreak > 0
                  ? const Color(0xFFFF6B35)
                  : scheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 6),
            Text(
              '$currentStreak day${currentStreak == 1 ? '' : 's'}',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (currentStreak < nextMilestone)
              Text(
                '${nextMilestone - currentStreak} to next',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(
                  color: scheme.outlineVariant.withValues(alpha: 0.3),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: child,
                    );
                  },
                  child: _nearMilestone && !reduceMotion
                      ? const _ShimmerBar()
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFFD54F)],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _milestones.map((m) {
            final reached = currentStreak >= m;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  reached ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 14,
                  color: reached
                      ? const Color(0xFFFF6B35)
                      : scheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 3),
                Text(
                  m >= 365 ? '1y' : '${m}d',
                  style: textTheme.labelSmall?.copyWith(
                    color: reached
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: reached ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ShimmerBar extends StatefulWidget {
  const _ShimmerBar();

  @override
  State<_ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<_ShimmerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFFFF6B35),
                Color(0xFFFFD54F),
                Color(0xFFFFFFFF),
                Color(0xFFFFD54F),
                Color(0xFFFF6B35),
              ],
              stops: [
                0.0,
                (_controller.value - 0.2).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.2).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
