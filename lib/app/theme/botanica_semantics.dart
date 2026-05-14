import 'package:flutter/material.dart';

/// Semantic text roles for Botanica.
///
/// This prevents screens from styling by ad-hoc font sizes and helps keep the
/// whole app feeling like one editorial system.
enum BotanicaTextRole {
  displayHero,
  headline,
  title,
  body,
  bodyMuted,
  label,
  chip,
}

class BotanicaSemantics {
  const BotanicaSemantics._();

  static TextStyle textStyle(BuildContext context, BotanicaTextRole role) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = theme.textTheme;

    TextStyle base = switch (role) {
      BotanicaTextRole.displayHero =>
        (t.displaySmall ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.6,
          height: 1.15,
        ),
      BotanicaTextRole.headline =>
        (t.headlineSmall ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          height: 1.25,
        ),
      BotanicaTextRole.title => (t.titleMedium ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          height: 1.25,
        ),
      BotanicaTextRole.body => (t.bodyMedium ?? const TextStyle()).copyWith(
          height: 1.45,
        ),
      BotanicaTextRole.bodyMuted =>
        (t.bodyMedium ?? const TextStyle()).copyWith(
          height: 1.45,
          color: scheme.onSurface.withValues(alpha: 0.70),
        ),
      BotanicaTextRole.label => (t.labelLarge ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.1,
        ),
      BotanicaTextRole.chip => (t.labelLarge ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
    };

    if (base.color == null) {
      base = base.copyWith(color: scheme.onSurface);
    }

    return base;
  }
}

extension BotanicaColorRoles on ColorScheme {
  Color get botanicaTextPrimary => onSurface;
  Color get botanicaTextSecondary => onSurface.withValues(alpha: 0.72);
  Color get botanicaTextTertiary => onSurface.withValues(alpha: 0.56);

  Color get botanicaBorder => outlineVariant.withValues(alpha: 0.45);
  Color get botanicaDivider => outlineVariant.withValues(alpha: 0.35);

  Color get statusHealthy => const Color(0xFF2E7D4F);
  Color get statusNeedsWater => const Color(0xFF3B82C4);
  Color get statusOverdue => const Color(0xFFD97706);
  Color get statusCritical => const Color(0xFFDC2626);

  Color get statusHealthyBg => const Color(0xFFE8F5E9);
  Color get statusNeedsWaterBg => const Color(0xFFE3F2FD);
  Color get statusOverdueBg => const Color(0xFFFFF8E1);
  Color get statusCriticalBg => const Color(0xFFFFEBEE);

  Color get accentGold => const Color(0xFFD4A853);
  Color get accentLavender => const Color(0xFF9B8EC4);
  Color get accentCoral => const Color(0xFFE8836B);
  Color get accentMint => const Color(0xFF5CB8A5);
}
