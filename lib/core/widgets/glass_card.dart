import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';

class BotanicaGlassCard extends StatelessWidget {
  const BotanicaGlassCard({
    super.key,
    required this.child,
    this.tier = GlassTier.secondary,
    this.padding = BotanicaTokens.cardPadding,
    this.borderRadius = BotanicaTokens.radiusXL,
    this.accentColor,
  });

  final Widget child;
  final GlassTier tier;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glass = Theme.of(context).extension<BotanicaGlassTheme>();
    final recipe = glass?.recipeFor(tier) ??
        const BotanicaGlassRecipe(
          blurSigma: 16,
          backgroundOpacity: 0.72,
          borderOpacity: 0.45,
          shadowOpacity: 0.10,
          shadowBlurRadius: 26,
          shadowOffsetY: 16,
        );

    final topOpacity = (recipe.backgroundOpacity + 0.18).clamp(0.0, 0.95);

    final topTint = Color.lerp(scheme.primaryContainer, scheme.surface, 0.85) ??
        scheme.surface;

    final innerGlowColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.45);

    final borderGradientTop = accentColor != null
        ? accentColor!.withValues(alpha: isDark ? 0.4 : 0.3)
        : (isDark
            ? Colors.white.withValues(alpha: recipe.borderOpacity * 0.7)
            : Colors.white.withValues(alpha: recipe.borderOpacity));

    final borderGradientBottom = accentColor != null
        ? accentColor!.withValues(alpha: isDark ? 0.12 : 0.08)
        : scheme.outlineVariant.withValues(alpha: recipe.borderOpacity * 0.5);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: recipe.shadowOpacity * 0.4),
            blurRadius: recipe.shadowBlurRadius * 1.2,
            offset: Offset(0, recipe.shadowOffsetY),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: scheme.shadow.withValues(alpha: recipe.shadowOpacity * 0.6),
            blurRadius: recipe.shadowBlurRadius * 0.5,
            offset: Offset(0, recipe.shadowOffsetY * 0.4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: recipe.blurSigma,
            sigmaY: recipe.blurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  topTint.withValues(alpha: topOpacity),
                  scheme.surface.withValues(alpha: recipe.backgroundOpacity),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.12, 1.0],
                  colors: [
                    innerGlowColor,
                    innerGlowColor.withValues(alpha: 0.0),
                    Colors.transparent,
                  ],
                ),
                border: _GradientBorder(
                  width: 1.0,
                  topColor: borderGradientTop,
                  bottomColor: borderGradientBottom,
                  borderRadius: borderRadius,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientBorder extends BoxBorder {
  const _GradientBorder({
    required this.width,
    required this.topColor,
    required this.bottomColor,
    required this.borderRadius,
  });

  final double width;
  final Color topColor;
  final Color bottomColor;
  final double borderRadius;

  @override
  BorderSide get top => BorderSide(color: topColor, width: width);

  @override
  BorderSide get bottom => BorderSide(color: bottomColor, width: width);

  @override
  bool get isUniform => false;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) => null;

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) => null;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(width),
          Radius.circular(borderRadius - width),
        ),
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      );
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(width / 2),
      Radius.circular(this.borderRadius - width / 2),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  ShapeBorder scale(double t) => _GradientBorder(
        width: width * t,
        topColor: topColor,
        bottomColor: bottomColor,
        borderRadius: borderRadius,
      );
}
