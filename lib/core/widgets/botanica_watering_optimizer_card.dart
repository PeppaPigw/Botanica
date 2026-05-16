import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/watering_calendar_optimizer.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaWateringOptimizerCard extends StatelessWidget {
  const BotanicaWateringOptimizerCard({
    super.key,
    required this.optimization,
  });

  final WateringScheduleOptimization optimization;

  @override
  Widget build(BuildContext context) {
    if (optimization.daysSaved <= 0) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  'Schedule Optimizer',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXxs,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  'Save ${optimization.daysSaved}d/wk',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF66BB6A),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _DayCountChip(
                label: 'Current: ${optimization.currentActiveDays}d',
                color: scheme.onSurface.withValues(alpha: 0.5),
                scheme: scheme,
                textTheme: textTheme,
              ),
              BotanicaGaps.hXxs,
              Icon(Icons.arrow_forward_rounded, size: 12,
                  color: scheme.onSurface.withValues(alpha: 0.3)),
              BotanicaGaps.hXxs,
              _DayCountChip(
                label: 'Optimized: ${optimization.optimizedActiveDays}d',
                color: const Color(0xFF66BB6A),
                scheme: scheme,
                textTheme: textTheme,
              ),
            ],
          ),
          if (optimization.optimizedDays.isNotEmpty) ...[
            BotanicaGaps.vSm,
            ...optimization.optimizedDays.take(3).map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          _weekdayLabel(day.weekday),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          day.plantNicknames.take(3).join(', '),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 10,
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

  static String _weekdayLabel(int weekday) {
    return switch (weekday) {
      1 => 'Mon',
      2 => 'Tue',
      3 => 'Wed',
      4 => 'Thu',
      5 => 'Fri',
      6 => 'Sat',
      7 => 'Sun',
      _ => '?',
    };
  }
}

class _DayCountChip extends StatelessWidget {
  const _DayCountChip({
    required this.label,
    required this.color,
    required this.scheme,
    required this.textTheme,
  });

  final String label;
  final Color color;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingXxs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
