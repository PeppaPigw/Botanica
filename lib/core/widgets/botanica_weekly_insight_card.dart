import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/weekly_insight_engine.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaWeeklyInsightCard extends StatelessWidget {
  const BotanicaWeeklyInsightCard({
    super.key,
    required this.digest,
  });

  final WeeklyInsightDigest digest;

  @override
  Widget build(BuildContext context) {
    if (digest.topInsight == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final insight = digest.topInsight!;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.weeklyInsightTitle,
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
                  color: scheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius:
                      BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${digest.totalCareActions} actions',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Text(
            insight.titleKey
                .replaceAll('insight', '')
                .replaceAllMapped(
                    RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
                .trim(),
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          BotanicaGaps.vXxs,
          Text(
            insight.bodyKey
                .replaceAll('insight', '')
                .replaceAllMapped(
                    RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
                .trim(),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (insight.actionSuggestion != null) ...[
            BotanicaGaps.vSm,
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 14,
                  color: scheme.tertiary,
                ),
                BotanicaGaps.hXs,
                Expanded(
                  child: Text(
                    insight.actionSuggestion!,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
