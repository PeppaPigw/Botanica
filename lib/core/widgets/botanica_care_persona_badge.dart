import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/user_care_persona_engine.dart';
import 'botanica_gaps.dart';

class BotanicaCarePersonaBadge extends StatelessWidget {
  const BotanicaCarePersonaBadge({
    super.key,
    required this.persona,
    this.compact = false,
  });

  final CarePersona persona;
  final bool compact;

  IconData _iconFor(String type) => switch (type) {
        'Devotee' => Icons.favorite_rounded,
        'Explorer' => Icons.explore_rounded,
        'Perfectionist' => Icons.auto_awesome_rounded,
        'Nurturer' => Icons.spa_rounded,
        'Veteran' => Icons.military_tech_rounded,
        'EarlyBird' => Icons.wb_twilight_rounded,
        _ => Icons.eco_rounded,
      };

  Color _colorFor(String type, ColorScheme scheme) => switch (type) {
        'Devotee' => scheme.error,
        'Explorer' => scheme.tertiary,
        'Perfectionist' => scheme.secondary,
        'Nurturer' => scheme.primary,
        'Veteran' => scheme.inversePrimary,
        'EarlyBird' => scheme.tertiary,
        _ => scheme.outline,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = _colorFor(persona.primaryType, scheme);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BotanicaTokens.spacingXs,
          vertical: BotanicaTokens.spacingMicro,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(persona.primaryType), size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              persona.primaryType,
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: BotanicaTokens.cardPaddingDense,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusL),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
            ),
            child: Icon(
              _iconFor(persona.primaryType),
              color: color,
              size: BotanicaTokens.iconSizeLg,
            ),
          ),
          BotanicaGaps.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  persona.primaryType,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  '${(persona.matchPercentage * 100).round()}% match',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (persona.secondaryType != null)
            Icon(
              _iconFor(persona.secondaryType!),
              size: BotanicaTokens.iconSizeSm,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
        ],
      ),
    );
  }
}
