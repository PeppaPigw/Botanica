import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/seasonal_care_advisor.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaSeasonalAdvisorCard extends StatelessWidget {
  const BotanicaSeasonalAdvisorCard({
    super.key,
    required this.tips,
  });

  final List<SeasonalTip> tips;

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.wb_sunny_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.seasonalTipsTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${tips.length} tips',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...tips.take(4).map((t) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    Icon(_adviceIcon(t.advice), size: 12,
                        color: scheme.tertiary.withValues(alpha: 0.7)),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        '${t.plantNickname}: ${t.advice.name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m.group(0)!.toLowerCase()}')}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static IconData _adviceIcon(SeasonalAdvice advice) {
    return switch (advice) {
      SeasonalAdvice.increaseWatering => Icons.water_drop_rounded,
      SeasonalAdvice.decreaseWatering => Icons.water_drop_outlined,
      SeasonalAdvice.startFertilizing => Icons.eco_rounded,
      SeasonalAdvice.stopFertilizing => Icons.eco_outlined,
      SeasonalAdvice.watchForPests => Icons.bug_report_rounded,
      SeasonalAdvice.increaseHumidity => Icons.cloud_rounded,
      SeasonalAdvice.reduceSunExposure => Icons.wb_shade_rounded,
      SeasonalAdvice.moveFromDrafts => Icons.air_rounded,
      SeasonalAdvice.normalCare => Icons.check_circle_outline_rounded,
    };
  }
}
