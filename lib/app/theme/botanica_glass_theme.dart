import 'dart:ui';

import 'package:flutter/material.dart';

enum GlassTier {
  primary,
  secondary,
  subtle;

  String get id => switch (this) {
        GlassTier.primary => 'primary',
        GlassTier.secondary => 'secondary',
        GlassTier.subtle => 'subtle',
      };
}

@immutable
class BotanicaGlassRecipe {
  const BotanicaGlassRecipe({
    required this.blurSigma,
    required this.backgroundOpacity,
    required this.borderOpacity,
    required this.shadowOpacity,
    required this.shadowBlurRadius,
    required this.shadowOffsetY,
  });

  final double blurSigma;
  final double backgroundOpacity;
  final double borderOpacity;
  final double shadowOpacity;
  final double shadowBlurRadius;
  final double shadowOffsetY;

  BotanicaGlassRecipe copyWith({
    double? blurSigma,
    double? backgroundOpacity,
    double? borderOpacity,
    double? shadowOpacity,
    double? shadowBlurRadius,
    double? shadowOffsetY,
  }) {
    return BotanicaGlassRecipe(
      blurSigma: blurSigma ?? this.blurSigma,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
    );
  }

  BotanicaGlassRecipe lerp(BotanicaGlassRecipe other, double t) {
    return BotanicaGlassRecipe(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
      backgroundOpacity:
          lerpDouble(backgroundOpacity, other.backgroundOpacity, t) ??
              backgroundOpacity,
      borderOpacity:
          lerpDouble(borderOpacity, other.borderOpacity, t) ?? borderOpacity,
      shadowOpacity:
          lerpDouble(shadowOpacity, other.shadowOpacity, t) ?? shadowOpacity,
      shadowBlurRadius:
          lerpDouble(shadowBlurRadius, other.shadowBlurRadius, t) ??
              shadowBlurRadius,
      shadowOffsetY:
          lerpDouble(shadowOffsetY, other.shadowOffsetY, t) ?? shadowOffsetY,
    );
  }
}

@immutable
class BotanicaGlassTheme extends ThemeExtension<BotanicaGlassTheme> {
  const BotanicaGlassTheme({
    required this.primary,
    required this.secondary,
    required this.subtle,
  });

  final BotanicaGlassRecipe primary;
  final BotanicaGlassRecipe secondary;
  final BotanicaGlassRecipe subtle;

  BotanicaGlassRecipe recipeFor(GlassTier tier) => switch (tier) {
        GlassTier.primary => primary,
        GlassTier.secondary => secondary,
        GlassTier.subtle => subtle,
      };

  @override
  BotanicaGlassTheme copyWith({
    BotanicaGlassRecipe? primary,
    BotanicaGlassRecipe? secondary,
    BotanicaGlassRecipe? subtle,
  }) {
    return BotanicaGlassTheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      subtle: subtle ?? this.subtle,
    );
  }

  @override
  BotanicaGlassTheme lerp(ThemeExtension<BotanicaGlassTheme>? other, double t) {
    if (other is! BotanicaGlassTheme) return this;
    return BotanicaGlassTheme(
      primary: primary.lerp(other.primary, t),
      secondary: secondary.lerp(other.secondary, t),
      subtle: subtle.lerp(other.subtle, t),
    );
  }
}
