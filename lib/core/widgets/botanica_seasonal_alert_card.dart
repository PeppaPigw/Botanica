import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/seasonal_transition_advisor.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaSeasonalAlertCard extends StatelessWidget {
  const BotanicaSeasonalAlertCard({
    super.key,
    required this.report,
  });

  final SeasonalTransitionReport report;

  @override
  Widget build(BuildContext context) {
    if (report.advice.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final seasonColor = switch (report.nextSeason) {
      Season.spring => const Color(0xFF66BB6A),
      Season.summer => const Color(0xFFFFA726),
      Season.autumn => const Color(0xFFFF7043),
      Season.winter => const Color(0xFF42A5F5),
    };

    final seasonIcon = switch (report.nextSeason) {
      Season.spring => Icons.local_florist_rounded,
      Season.summer => Icons.wb_sunny_rounded,
      Season.autumn => Icons.park_rounded,
      Season.winter => Icons.ac_unit_rounded,
    };

    return BotanicaGlassCard(
      accentColor: seasonColor,
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                seasonIcon,
                size: BotanicaTokens.iconSizeMd,
                color: seasonColor,
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.seasonalAlertTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: seasonColor.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  l10n.seasonalAlertDays(report.daysUntilTransition),
                  style: textTheme.labelSmall?.copyWith(
                    color: seasonColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Text(
            l10n.seasonalAlertComing('${report.nextSeason.name[0].toUpperCase()}${report.nextSeason.name.substring(1)}'),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (report.urgentCount > 0) ...[
            BotanicaGaps.vXxs,
            Row(
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  size: 14,
                  color: scheme.error,
                ),
                BotanicaGaps.hXs,
                Text(
                  l10n.seasonalAlertUrgent(report.urgentCount),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          BotanicaGaps.vSm,
          ...report.advice.take(3).map((a) => Padding(
                padding: const EdgeInsets.only(
                    bottom: BotanicaTokens.spacingMicro),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: seasonColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    BotanicaGaps.hXs,
                    Expanded(
                      child: Text(
                        a.adviceKey,
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
}
