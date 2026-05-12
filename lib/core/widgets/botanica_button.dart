import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import 'glass_card.dart';

enum BotanicaButtonVariant {
  filled,
  outlined,
  text,
  glass,
}

class BotanicaButton extends StatelessWidget {
  const BotanicaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = BotanicaButtonVariant.filled,
    this.expand = false,
    this.semanticsLabel,
    this.matchTextDirection = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final BotanicaButtonVariant variant;
  final bool expand;
  final String? semanticsLabel;
  final bool matchTextDirection;

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final buttonChild = icon == null
        ? labelText
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: BotanicaTokens.iconSizeMd,
                matchTextDirection: matchTextDirection,
              ),
              const SizedBox(width: BotanicaTokens.spacingXs),
              Flexible(
                child: labelText,
              ),
            ],
          );

    Widget built = switch (variant) {
      BotanicaButtonVariant.filled => FilledButton(
          onPressed: onPressed,
          child: buttonChild,
        ),
      BotanicaButtonVariant.outlined => OutlinedButton(
          onPressed: onPressed,
          child: buttonChild,
        ),
      BotanicaButtonVariant.text => TextButton(
          onPressed: onPressed,
          child: buttonChild,
        ),
      BotanicaButtonVariant.glass => _GlassButton(
          onPressed: onPressed,
          child: buttonChild,
        ),
    };

    built = Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticsLabel ?? label,
      child: built,
    );

    if (expand) {
      built = SizedBox(width: double.infinity, child: built);
    }

    return built;
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.55 : 1.0,
      child: BotanicaGlassCard(
        tier: GlassTier.subtle,
        padding: EdgeInsets.zero,
        borderRadius: BotanicaTokens.radiusXL,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BotanicaTokens.spacingLg,
                vertical: BotanicaTokens.spacingMd,
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: scheme.onSurface),
                child: IconTheme.merge(
                  data: IconThemeData(color: scheme.onSurface),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
