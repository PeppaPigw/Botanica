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
  });

  final Widget child;
  final GlassTier tier;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: recipe.shadowOpacity),
            blurRadius: recipe.shadowBlurRadius,
            offset: Offset(0, recipe.shadowOffsetY),
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
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  topTint.withValues(alpha: topOpacity),
                  scheme.surface.withValues(alpha: recipe.backgroundOpacity),
                ],
              ),
              border: Border.all(
                color: scheme.outlineVariant
                    .withValues(alpha: recipe.borderOpacity),
                width: 1,
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
    );
  }
}
