import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaTimelineCard extends StatelessWidget {
  const BotanicaTimelineCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
    this.body,
    this.trailingIcon,
    this.onTrailingTap,
    this.trailingTooltip,
    this.onTap,
    this.leading,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;
  final Widget? body;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final String? trailingTooltip;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final lineColor = scheme.outlineVariant.withValues(alpha: 0.45);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 24,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surface.withValues(alpha: 0.85),
                    border: Border.all(color: lineColor),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: BotanicaTokens.iconSizeXs,
                      color: scheme.primary.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),
          BotanicaGaps.hSm,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMd),
              child: BotanicaGlassCard(
                padding: BotanicaTokens.cardPaddingDense,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (leading != null) ...[
                            leading!,
                            BotanicaGaps.hSm,
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                BotanicaGaps.vMicro,
                                Text(
                                  subtitle,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                                if (body != null && leading != null) ...[
                                  BotanicaGaps.vXs,
                                  body!,
                                ],
                              ],
                            ),
                          ),
                          if (trailingIcon != null) ...[
                            BotanicaGaps.hSm,
                            IconButton(
                              onPressed: onTrailingTap,
                              icon: Icon(trailingIcon),
                              color: scheme.onSurface.withValues(alpha: 0.70),
                              tooltip: trailingTooltip ??
                                  MaterialLocalizations.of(context)
                                      .showMenuTooltip,
                            ),
                          ],
                        ],
                      ),
                      if (body != null && leading == null) ...[
                        BotanicaGaps.vXs,
                        body!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
