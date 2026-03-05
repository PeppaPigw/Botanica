import 'package:flutter/material.dart';

import '../../app/theme/botanica_semantics.dart';
import '../../app/theme/botanica_tokens.dart';

class BotanicaChip extends StatelessWidget {
  const BotanicaChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.tint,
    this.onTap,
    this.tooltip,
    this.padding,
    this.iconSize = 18,
    this.textStyle,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final Color? tint;
  final VoidCallback? onTap;
  final String? tooltip;
  final EdgeInsets? padding;
  final double iconSize;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final resolvedTint = tint ?? scheme.primary;
    final blendedTint = selected
        ? Color.lerp(resolvedTint, scheme.onSurface, 0.18) ?? resolvedTint
        : resolvedTint;

    final bg = selected
        ? blendedTint.withValues(alpha: 0.18)
        : blendedTint.withValues(alpha: 0.12);
    final border = selected
        ? blendedTint.withValues(alpha: 0.50)
        : scheme.outlineVariant.withValues(alpha: 0.45);
    final iconColor = scheme.onSurface.withValues(alpha: 0.82);

    final resolvedTextStyle = textStyle ??
        BotanicaSemantics.textStyle(context, BotanicaTextRole.chip);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: BotanicaTokens.spacingXxs),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: resolvedTextStyle,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      label: tooltip ?? label,
      child: Tooltip(
        message: tooltip ?? label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
          child: Container(
            alignment: Alignment.center,
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingSm,
                  vertical: BotanicaTokens.spacingXs,
                ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
              color: bg,
              border: Border.all(color: border),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
