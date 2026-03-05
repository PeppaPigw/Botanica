import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/botanica_glass_theme.dart';
import '../../../app/theme/botanica_text_styles.dart';
import '../../../app/theme/botanica_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../domain/models/daily_flower.dart';
import '../../../domain/models/enums.dart';
import '../../../gen/l10n/app_localizations.dart';
import 'mode_reveal_interaction.dart';
import 'tarot_helpers.dart';

class DailyFlowerCard extends StatelessWidget {
  const DailyFlowerCard({
    super.key,
    required this.entry,
    required this.variantLabel,
    required this.variantKey,
    required this.revealed,
    required this.onReveal,
  });

  final DailyFlowerEntry entry;
  final String variantLabel;
  final String? variantKey;
  final bool revealed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final normalizedVariant = variantLabel.trim();
    final canShowVariant = entry.beliefMode != BeliefMode.unselected &&
        entry.beliefMode != BeliefMode.justFlower &&
        normalizedVariant.isNotEmpty &&
        normalizedVariant != l10n.profileDailyProfileNotSet &&
        normalizedVariant != l10n.profileDailyProfileNotNeeded &&
        normalizedVariant != l10n.dailyTarotNotDrawn;

    return BotanicaGlassCard(
      tier: GlassTier.primary,
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: BotanicaTokens.motionSlow,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: revealed
            ? Column(
                key: const ValueKey('revealed'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((entry.content.imagePath ?? '').trim().isNotEmpty) ...[
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(BotanicaTokens.radiusL),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          entry.content.imagePath!.trim(),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    children: [
                      Icon(
                        beliefModeIcon(entry.beliefMode),
                        color: scheme.onSurface.withValues(alpha: 0.80),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.content.name,
                          style: context.tsHeadline,
                        ),
                      ),
                    ],
                  ),
                  if (canShowVariant) ...[
                    const SizedBox(height: 8),
                    if (entry.beliefMode == BeliefMode.tarot &&
                        (variantKey ?? '').trim().isNotEmpty)
                      TarotVariantBadge(
                        label: normalizedVariant,
                        cardId: variantKey!.trim(),
                      )
                    else
                      ModeVariantBadge(
                        icon: beliefModeIcon(entry.beliefMode),
                        label: normalizedVariant,
                      ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.content.meaningKeywords
                        .take(6)
                        .map(
                          (k) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                BotanicaTokens.radiusPill,
                              ),
                              color: scheme.primaryContainer
                                  .withValues(alpha: 0.35),
                              border: Border.all(
                                color: scheme.outlineVariant
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              k,
                              style: context.tsChip.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.78),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.content.symbolism,
                    style: context.tsBodyMuted.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.74),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.dailyCareToday,
                    style:
                        context.tsTitle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...entry.content.careBasics.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• ${_careKeyLabel(l10n, e.key)}: ${e.value}',
                        style: context.tsBodyMuted.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.dailyHowToAppreciate,
                    style:
                        context.tsTitle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.content.appreciation,
                    style: context.tsBodyMuted.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.74),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 420.ms).slideY(
                  begin: 0.04,
                  curve: Curves.easeOutCubic,
                )
            : SizedBox(
                key: const ValueKey('hidden'),
                height: 280,
                child: ModeRevealInteraction(
                  mode: entry.beliefMode,
                  variantKey: variantKey,
                  variantLabel: variantLabel,
                  onReveal: onReveal,
                ),
              ),
      ),
    );
  }
}

String _careKeyLabel(AppLocalizations l10n, String rawKey) {
  final key = rawKey.trim();
  return switch (key) {
    'light' => l10n.careKeyLight,
    'water' => l10n.careKeyWater,
    'temperature' => l10n.careKeyTemperature,
    'petSafety' || 'pet_safety' => l10n.careKeyPetSafety,
    _ => key,
  };
}
