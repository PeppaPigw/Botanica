import 'package:flutter/widgets.dart';

class BotanicaTokens {
  const BotanicaTokens._();

  /// Radii that respect the rounded and pill-heavy language of Botanica.
  static const double radiusS = 12;
  static const double radiusM = 16;
  static const double radiusL = 22;
  static const double radiusXL = 28;
  static const double radiusPill = 999;

  /// A tonal spacing scale built on base 4–6 increments. Use the nearest named
  /// step for layout rhythm instead of scattering magic numbers.
  static const double spacingMicro = 4;
  static const double spacingTiny = 6;
  static const double spacingXxs = 8;
  static const double spacingXs = 10;
  static const double spacingSm = 12;
  static const double spacingBase = 14;
  static const double spacingMd = 16;
  static const double spacingRelaxed = 18;
  static const double spacingLg = 20;
  static const double spacingXl = 24;
  static const double spacingXxl = 32;
  static const double spacingHuge = 40;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: spacingLg,
    vertical: spacingMd,
  );

  /// Editorial grid max width used for centered chrome (nav pill, FAB).
  static const double maxContentWidth = 520;

  /// Navigation pill geometry (used to compute bottom clearance for gesture
  /// navigation devices and iPhones with a home indicator).
  static const double navPillHeight = 68;
  // The nav pill should float with breathing room above the system gesture
  // area/home indicator while still feeling grounded. These values are used by
  // both the nav pill and bottom action bars to keep a single chrome rhythm.
  static const double navPillBottomInsetNoSafeArea = 2;
  static const double navPillBottomInsetWithSafeArea = 0;
  // iOS reports a relatively tall bottom safe-area inset due to the home
  // indicator. Botanica's floating pill is allowed to overlap *some* of that
  // region so the chrome feels grounded instead of hovering too high.
  //
  // This value caps how much of the safe-area inset we keep below the pill.
  static const double navPillMaxSafeAreaInsetIOS = 4;
  static const double bottomChromeGap = spacingMd;

  static double bottomNavClearanceFor(BuildContext context) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    if (keyboardInset > 0) {
      // When the software keyboard is visible, Botanica hides the floating nav
      // pill so it doesn't jump into the middle of the screen.
      // Keep a small breathing room above the keyboard for scrollables.
      return bottomChromeGap;
    }
    final extra = safeBottom == 0
        ? navPillBottomInsetNoSafeArea
        : navPillBottomInsetWithSafeArea;
    // Screens typically wrap their content in SafeArea (which already applies
    // the device bottom inset). The clearance here is specifically about
    // avoiding Botanica's floating chrome (nav pill).
    return navPillHeight + extra + bottomChromeGap;
  }

  static EdgeInsets pagePaddingWithBottomNav(BuildContext context) {
    return pagePadding.copyWith(bottom: bottomNavClearanceFor(context));
  }

  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    vertical: spacingMd,
  );

  /// Standard card padding steps (14/16/18 rhythm).
  static const EdgeInsets cardPaddingTight = EdgeInsets.all(spacingSm); // 12
  static const EdgeInsets cardPaddingDense = EdgeInsets.all(spacingBase); // 14
  static const EdgeInsets cardPadding = EdgeInsets.all(spacingMd); // 16
  static const EdgeInsets cardPaddingRelaxed =
      EdgeInsets.all(spacingRelaxed); // 18
  static const EdgeInsets cardPaddingAiry = EdgeInsets.all(spacingLg); // 20
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(
    horizontal: spacingMd,
    vertical: spacingSm,
  );

  static const double iconSizeXs = 14;
  static const double iconSizeSm = 16;
  static const double iconSizeMd = 20;
  static const double iconSizeLg = 24;

  /// Glass tiers (semantic surfaces).
  ///
  /// These values power `BotanicaGlassTheme` so glass styling never drifts
  /// screen-by-screen.
  static const double glassPrimaryBlur = 24;
  static const double glassSecondaryBlur = 14;
  static const double glassSubtleBlur = 6;

  static const double glassPrimaryAlpha = 0.72;
  static const double glassSecondaryAlpha = 0.55;
  static const double glassSubtleAlpha = 0.35;

  /// Motion primitives.
  static const Duration motionFast = Duration(milliseconds: 140);
  static const Duration motionMedium = Duration(milliseconds: 220);
  static const Duration motionSlow = Duration(milliseconds: 360);
  static const Duration motionMicroFast = Duration(milliseconds: 80);
  static const Duration motionStagger = Duration(milliseconds: 60);
  static const Duration motionSpring = Duration(milliseconds: 480);

  static const Curve curveSpring = Curves.elasticOut;
  static const Curve curveReveal = Curves.easeOutCubic;
  static const Curve curveSettle = Curves.easeInOutCubic;

  /// Explicit type scale steps so every screen can reuse the same sizes.
  static const double displayLarge = 46;
  static const double displayMedium = 36;
  static const double displaySmall = 30;
  static const double headlineLarge = 24;
  static const double headlineMedium = 20;
  static const double headlineSmall = 18;
  static const double titleLarge = 18;
  static const double titleMedium = 16;
  static const double labelLarge = 14;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
}

/// Compatibility shim for Flutter versions that don't yet expose `Color.withValues`.
///
/// Botanica uses `.withValues(alpha: x)` across the codebase to avoid deprecated
/// `.withOpacity(x)` calls while keeping the call sites expressive.
extension BotanicaColorWithValues on Color {
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    final normalized = alpha.clamp(0.0, 1.0);
    return withAlpha((normalized * 255).round());
  }
}
