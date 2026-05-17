import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/emotional_bond_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaEmotionalBondCard extends StatelessWidget {
  const BotanicaEmotionalBondCard({
    super.key,
    required this.bonds,
  });

  final List<EmotionalBond> bonds;

  @override
  Widget build(BuildContext context) {
    if (bonds.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.emotionalBondsTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${bonds.length} plants',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...bonds.take(4).map((bond) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 12,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: List.generate(
                          (bond.bondStrength * 5).round().clamp(1, 5),
                          (i) => Positioned(
                            left: i * 5.0,
                            child: Icon(Icons.favorite_rounded,
                                size: 10,
                                color: scheme.tertiary.withValues(alpha: 0.4 + i * 0.12)),
                          ),
                        ),
                      ),
                    ),
                    BotanicaGaps.hXs,
                    Expanded(
                      child: Text(
                        bond.plantNickname,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BotanicaTokens.spacingXxs,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                      ),
                      child: Text(
                        bond.bondType.replaceAll('bond', ''),
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.tertiary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
