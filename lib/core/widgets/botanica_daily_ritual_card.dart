import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/daily_rituals.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaDailyRitualCard extends StatelessWidget {
  const BotanicaDailyRitualCard({
    super.key,
    required this.rune,
    required this.ganzhi,
  });

  final RuneEntry rune;
  final Ganzhi ganzhi;

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.auto_awesome_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.dailyRitualTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(BotanicaTokens.spacingXs),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
                  ),
                  child: Column(
                    children: [
                      Text(
                        rune.glyph,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rune.name,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Rune',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(BotanicaTokens.spacingXs),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
                  ),
                  child: Column(
                    children: [
                      Text(
                        ganzhi.labelZh,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ganzhi.labelEn,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Ganzhi',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
