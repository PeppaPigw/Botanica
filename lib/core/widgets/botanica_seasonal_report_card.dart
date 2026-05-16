import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/seasonal_report_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaSeasonalReportCard extends StatelessWidget {
  const BotanicaSeasonalReportCard({
    super.key,
    required this.report,
  });

  final SeasonalReportCard report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final current = report.currentReport;

    final gradeColor = switch (current.grade) {
      'A' || 'A+' => const Color(0xFF66BB6A),
      'B' || 'B+' => const Color(0xFF42A5F5),
      'C' || 'C+' => const Color(0xFFFFA726),
      _ => const Color(0xFFEF5350),
    };

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  '${current.season} ${current.year}',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  current.grade,
                  style: textTheme.labelSmall?.copyWith(
                    color: gradeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _ReportStat(label: 'actions', value: '${current.totalActions}', scheme: scheme),
              BotanicaGaps.hSm,
              _ReportStat(label: 'plants', value: '${current.plantsActive}', scheme: scheme),
              BotanicaGaps.hSm,
              _ReportStat(label: '/week', value: current.avgActionsPerWeek.toStringAsFixed(1), scheme: scheme),
            ],
          ),
          if (report.improvement != 0) ...[
            BotanicaGaps.vSm,
            Row(
              children: [
                Icon(
                  report.improvement > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 14,
                  color: report.improvement > 0 ? const Color(0xFF66BB6A) : scheme.error,
                ),
                BotanicaGaps.hXxs,
                Text(
                  '${report.improvement > 0 ? '+' : ''}${(report.improvement * 100).round()}% vs last season',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
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

class _ReportStat extends StatelessWidget {
  const _ReportStat({required this.label, required this.value, required this.scheme});
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
