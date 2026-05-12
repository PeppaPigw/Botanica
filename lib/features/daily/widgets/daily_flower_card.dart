import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/botanica_glass_theme.dart';
import '../../../app/theme/botanica_text_styles.dart';
import '../../../app/theme/botanica_tokens.dart';
import '../../../core/utils/motion_preferences.dart';
import '../../../core/widgets/botanica_press_scale.dart';
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
    final reduceMotion = botanicaReduceMotion(context);

    final normalizedVariant = variantLabel.trim();
    final canShowVariant = entry.beliefMode != BeliefMode.unselected &&
        entry.beliefMode != BeliefMode.justFlower &&
        normalizedVariant.isNotEmpty &&
        normalizedVariant != l10n.profileDailyProfileNotSet &&
        normalizedVariant != l10n.profileDailyProfileNotNeeded &&
        normalizedVariant != l10n.dailyTarotNotDrawn;

    return BotanicaPressScale(
      child: BotanicaGlassCard(
        tier: GlassTier.primary,
        padding: BotanicaTokens.cardPadding,
        child: AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : BotanicaTokens.motionSlow,
          switchInCurve: BotanicaTokens.curveReveal,
          switchOutCurve: BotanicaTokens.curveSettle,
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
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    BotanicaGaps.vSm,
                  ],
                  Row(
                    children: [
                      Icon(
                        beliefModeIcon(entry.beliefMode),
                        color: scheme.onSurface.withValues(alpha: 0.80),
                      ),
                      BotanicaGaps.hSm,
                      Expanded(
                        child: Text(
                          entry.content.name,
                          style: context.tsHeadline,
                        ),
                      ),
                    ],
                  ),
                  if (canShowVariant) ...[
                    BotanicaGaps.vXs,
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
                  BotanicaGaps.vSm,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.content.meaningKeywords
                        .take(6)
                        .map(
                          (k) => Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            alignment: Alignment.center,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.tsChip.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.78),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  BotanicaGaps.vSm,
                  Text(
                    entry.content.symbolism,
                    style: context.tsBodyMuted.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.74),
                    ),
                  ),
                  BotanicaGaps.vSm,
                  Text(
                    l10n.dailyCareToday,
                    style:
                        context.tsTitle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  BotanicaGaps.vXs,
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
                  BotanicaGaps.vSm,
                  Text(
                    l10n.dailyHowToAppreciate,
                    style:
                        context.tsTitle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  BotanicaGaps.vXs,
                  Text(
                    entry.content.appreciation,
                    style: context.tsBodyMuted.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.74),
                    ),
                  ),
                ],
              ).animateIfAllowed(
                  context,
                  (child) => child
                      .animate()
                      .fadeIn(
                        duration: BotanicaTokens.motionMedium,
                        curve: BotanicaTokens.curveReveal,
                      )
                      .slideY(
                        begin: 0.02,
                        end: 0,
                        duration: BotanicaTokens.motionMedium,
                        curve: BotanicaTokens.curveReveal,
                      ),
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
