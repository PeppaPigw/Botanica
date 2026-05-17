import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_personality_engine.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaPlantPersonalityCard extends StatelessWidget {
  const BotanicaPlantPersonalityCard({
    super.key,
    required this.personality,
  });

  final PlantPersonality personality;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final (IconData icon, Color color) = _traitVisual(personality.primaryTrait, scheme);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personality.plantNickname,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.plantPersonalityThe(_capitalize(personality.primaryTrait)),
                      style: textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _MoodBadge(mood: personality.moodKey, scheme: scheme),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _TraitPill(
                label: personality.primaryTrait,
                isPrimary: true,
                color: color,
                scheme: scheme,
              ),
              BotanicaGaps.hXs,
              _TraitPill(
                label: personality.secondaryTrait,
                isPrimary: false,
                color: color,
                scheme: scheme,
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Text(
            _careStyleLabel(personality.careStyle, l10n),
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static (IconData, Color) _traitVisual(String trait, ColorScheme scheme) {
    return switch (trait) {
      'resilient' => (Icons.shield_rounded, scheme.tertiary),
      'needy' => (Icons.favorite_rounded, const Color(0xFFE91E63)),
      'independent' => (Icons.self_improvement_rounded, scheme.primary),
      'dramatic' => (Icons.theater_comedy_rounded, const Color(0xFFFF9800)),
      'zen' => (Icons.spa_rounded, const Color(0xFF66BB6A)),
      'social' => (Icons.groups_rounded, scheme.secondary),
      'shy' => (Icons.visibility_off_rounded, scheme.outline),
      _ => (Icons.eco_rounded, scheme.primary),
    };
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String _careStyleLabel(String style, AppLocalizations l10n) {
    return switch (style) {
      'careStyleDedicated' => l10n.plantPersonalityDedicated,
      'careStyleBalanced' => l10n.plantPersonalityBalanced,
      'careStyleCasual' => l10n.plantPersonalityCasual,
      'careStyleMinimalist' => l10n.plantPersonalityMinimalist,
      _ => style,
    };
  }
}

class _TraitPill extends StatelessWidget {
  const _TraitPill({
    required this.label,
    required this.isPrimary,
    required this.color,
    required this.scheme,
  });

  final String label;
  final bool isPrimary;
  final Color color;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingXs,
        vertical: BotanicaTokens.spacingMicro,
      ),
      decoration: BoxDecoration(
        color: isPrimary
            ? color.withValues(alpha: 0.12)
            : scheme.outlineVariant.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isPrimary ? color : scheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({required this.mood, required this.scheme});

  final String mood;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final (String emoji, Color color) = switch (mood) {
      'personalityThriving' => ('✨', scheme.tertiary),
      'personalityHappy' => ('😊', scheme.primary),
      'personalityContent' => ('🌿', const Color(0xFF66BB6A)),
      'personalityLonely' => ('🥺', scheme.outline),
      'personalityThirsty' => ('💧', const Color(0xFF42A5F5)),
      _ => ('🌱', scheme.primary),
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 14)),
    );
  }
}
