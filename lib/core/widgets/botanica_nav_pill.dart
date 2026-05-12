import 'dart:ui';

import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../utils/motion_preferences.dart';

@immutable
class BotanicaNavDestination {
  const BotanicaNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.tooltip,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? tooltip;
}

class BotanicaNavPill extends StatelessWidget {
  const BotanicaNavPill({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.onSelect,
  }) : assert(destinations.length >= 2, 'Need at least two destinations.');

  final int currentIndex;
  final List<BotanicaNavDestination> destinations;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = botanicaReduceMotion(context);

    final glass = Theme.of(context).extension<BotanicaGlassTheme>();
    final recipe = glass?.subtle ??
        const BotanicaGlassRecipe(
          blurSigma: 18,
          backgroundOpacity: 0.66,
          borderOpacity: 0.38,
          shadowOpacity: 0.08,
          shadowBlurRadius: 24,
          shadowOffsetY: 14,
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: recipe.blurSigma + 4,
          sigmaY: recipe.blurSigma + 4,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: BotanicaTokens.spacingXxs,
            vertical: BotanicaTokens.spacingTiny,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surface.withValues(
                  alpha: recipe.backgroundOpacity + 0.08,
                ),
                scheme.surface.withValues(alpha: recipe.backgroundOpacity),
              ],
            ),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.32),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: recipe.shadowOpacity),
                blurRadius: recipe.shadowBlurRadius,
                offset: Offset(0, recipe.shadowOffsetY),
              ),
            ],
          ),
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: SizedBox(
                  height: 56,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final count = destinations.length;
                      final safeIndex = currentIndex.clamp(0, count - 1);
                      const minHitWidth = 48.0;

                      const selectedFlex = 2;
                      final expandedUnitWidth =
                          constraints.maxWidth / (count + 1);
                      final canExpandSelected =
                          expandedUnitWidth >= minHitWidth;

                      final unitWidth = canExpandSelected
                          ? expandedUnitWidth
                          : constraints.maxWidth / count;
                      final selectedWidth = canExpandSelected
                          ? unitWidth * selectedFlex
                          : unitWidth;

                      final showInlineLabel = canExpandSelected
                          ? selectedWidth >= 104
                          : unitWidth >= 92;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedPositionedDirectional(
                            duration: reduceMotion
                                ? Duration.zero
                                : BotanicaTokens.motionMedium,
                            curve: Curves.easeOutCubic,
                            start: unitWidth * safeIndex,
                            top: 0,
                            bottom: 0,
                            width: selectedWidth,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                BotanicaTokens.spacingTiny,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    BotanicaTokens.radiusPill,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      scheme.primaryContainer
                                          .withValues(alpha: 0.62),
                                      scheme.surface.withValues(alpha: 0.25),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: scheme.outlineVariant
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              for (var index = 0;
                                  index < destinations.length;
                                  index++)
                                AnimatedContainer(
                                  duration: reduceMotion
                                      ? Duration.zero
                                      : BotanicaTokens.motionMedium,
                                  curve: Curves.easeOutCubic,
                                  width: canExpandSelected
                                      ? (safeIndex == index
                                          ? selectedWidth
                                          : unitWidth)
                                      : unitWidth,
                                  child: _NavItem(
                                    destination: destinations[index],
                                    selected: safeIndex == index,
                                    showInlineLabel: showInlineLabel,
                                    labelStyle: (textTheme.labelLarge ??
                                            textTheme.labelMedium ??
                                            const TextStyle())
                                        .copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.86),
                                    ),
                                    iconColor: scheme.onSurface.withValues(
                                      alpha: safeIndex == index ? 0.92 : 0.72,
                                    ),
                                    onTap: () => onSelect(index),
                                    reduceMotion: reduceMotion,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              PositionedDirectional(
                top: 0,
                start: BotanicaTokens.spacingMd,
                end: BotanicaTokens.spacingMd,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(
                      BotanicaTokens.radiusPill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.showInlineLabel,
    required this.labelStyle,
    required this.iconColor,
    required this.reduceMotion,
  });

  final BotanicaNavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final bool showInlineLabel;
  final TextStyle labelStyle;
  final Color iconColor;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final tooltip = destination.tooltip ?? destination.label;

    Widget icon() {
      final resolved = selected ? destination.selectedIcon : destination.icon;

      return AnimatedScale(
        duration: reduceMotion ? Duration.zero : BotanicaTokens.motionFast,
        curve: Curves.easeOutCubic,
        scale: selected ? 1.06 : 1,
        child: AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : BotanicaTokens.motionFast,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            if (reduceMotion) return child;
            return FadeTransition(opacity: animation, child: child);
          },
          child: Icon(
            resolved,
            key: ValueKey<IconData>(resolved),
            color: iconColor,
            size: BotanicaTokens.iconSizeLg,
          ),
        ),
      );
    }

    Widget label() {
      final compactStyle = labelStyle.copyWith(
        fontSize: 11,
        height: 1.0,
      );

      return AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : BotanicaTokens.motionMedium,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          if (reduceMotion) return child;
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: selected
            ? Text(
                destination.label,
                key: const ValueKey('label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: showInlineLabel ? labelStyle : compactStyle,
              )
            : const SizedBox(
                key: ValueKey('no-label'),
                width: 0,
                height: 0,
              ),
      );
    }

    Widget selectedContent() {
      if (showInlineLabel) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon(),
            const SizedBox(width: BotanicaTokens.spacingXxs),
            Flexible(child: label()),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon(),
          BotanicaGaps.vTiny,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: label(),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
            child: Center(
              child: AnimatedContainer(
                duration:
                    reduceMotion ? Duration.zero : BotanicaTokens.motionMedium,
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? BotanicaTokens.spacingTiny : 0,
                  vertical: showInlineLabel
                      ? BotanicaTokens.spacingXs
                      : BotanicaTokens.spacingXxs,
                ),
                child: selected ? selectedContent() : icon(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
