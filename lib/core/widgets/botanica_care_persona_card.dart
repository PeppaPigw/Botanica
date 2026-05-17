import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/user_care_persona_engine.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_care_persona_badge.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCarePersonaCard extends StatelessWidget {
  const BotanicaCarePersonaCard({
    super.key,
    required this.persona,
  });

  final CarePersona persona;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BotanicaGlassCard(
      tier: GlassTier.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                color: scheme.primary.withValues(alpha: 0.8),
                size: BotanicaTokens.iconSizeLg,
              ),
              BotanicaGaps.hXs,
              Text(
                l10n.carePersonaTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          BotanicaCarePersonaBadge(persona: persona),
          if (persona.strengths.isNotEmpty) ...[
            BotanicaGaps.vSm,
            Text(
              l10n.carePersonaStrengths,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            BotanicaGaps.vXxs,
            Wrap(
              spacing: BotanicaTokens.spacingXxs,
              runSpacing: BotanicaTokens.spacingXxs,
              children: persona.strengths.map((s) => _TraitChip(
                    label: _formatTrait(s),
                    color: scheme.tertiary,
                  )).toList(),
            ),
          ],
          if (persona.growthAreas.isNotEmpty) ...[
            BotanicaGaps.vSm,
            Text(
              l10n.carePersonaGrowthAreas,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            BotanicaGaps.vXxs,
            Wrap(
              spacing: BotanicaTokens.spacingXxs,
              runSpacing: BotanicaTokens.spacingXxs,
              children: persona.growthAreas.map((g) => _TraitChip(
                    label: _formatTrait(g),
                    color: scheme.secondary,
                  )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatTrait(String raw) {
    final cleaned = raw
        .replaceAll('strength_', '')
        .replaceAll('growth_', '');
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}

class _TraitChip extends StatelessWidget {
  const _TraitChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingXs,
        vertical: BotanicaTokens.spacingMicro,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
