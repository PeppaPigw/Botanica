import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/weekly_report_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaWeeklyReportCard extends StatelessWidget {
  const BotanicaWeeklyReportCard({
    super.key,
    required this.report,
  });

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final trendColor = report.comparedToLastWeek >= 0
        ? const Color(0xFF66BB6A)
        : const Color(0xFFFFA726);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.summarize_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.weeklyReportTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(
                report.comparedToLastWeek >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 16,
                color: trendColor,
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _WStat(label: 'actions', value: '${report.totalActions}', scheme: scheme),
              BotanicaGaps.hSm,
              _WStat(label: 'plants', value: '${report.plantsCaresFor}', scheme: scheme),
              BotanicaGaps.hSm,
              _WStat(label: 'vs last', value: '${report.comparedToLastWeek >= 0 ? '+' : ''}${report.comparedToLastWeek}', scheme: scheme),
            ],
          ),
          if (report.highlights.isNotEmpty) ...[
            BotanicaGaps.vSm,
            ...report.highlights.take(2).map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, size: 12,
                          color: scheme.tertiary.withValues(alpha: 0.7)),
                      BotanicaGaps.hXxs,
                      Expanded(
                        child: Text(
                          h.messageKey,
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
        ],
      ),
    );
  }
}

class _WStat extends StatelessWidget {
  const _WStat({required this.label, required this.value, required this.scheme});
  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5), fontSize: 9)),
        ],
      ),
    );
  }
}
