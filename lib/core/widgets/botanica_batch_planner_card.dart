import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/watering_batch_planner.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaBatchPlannerCard extends StatelessWidget {
  const BotanicaBatchPlannerCard({
    super.key,
    required this.plan,
    required this.plantNames,
  });

  final WateringBatchPlan plan;
  final Map<String, String> plantNames;

  @override
  Widget build(BuildContext context) {
    if (plan.slots.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
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
              Icon(
                Icons.calendar_month_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Text(
                l10n.batchPlannerTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                l10n.batchPlannerEfficiency(
                  (plan.batchEfficiency * 100).round(),
                ),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              Text(
                l10n.batchPlannerDays(plan.suggestedDays),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                l10n.batchPlannerPlants(plan.totalPlantsPerWeek),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          SizedBox(
            height: 48,
            child: Row(
              children: List.generate(7, (i) {
                final dayNum = i + 1;
                final slot = plan.slots
                    .where((s) => s.dayOfWeek == dayNum)
                    .firstOrNull;
                final isActive = slot != null;
                final plantCount = slot?.plantIds.length ?? 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isActive
                                  ? scheme.primary.withValues(alpha: 0.15)
                                  : scheme.outlineVariant.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: isActive
                                  ? Border.all(
                                      color: scheme.primary.withValues(alpha: 0.3),
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: isActive
                                  ? Text(
                                      '$plantCount',
                                      style: textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: scheme.primary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.remove,
                                      size: 12,
                                      color: scheme.onSurface.withValues(alpha: 0.2),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dayLabel(dayNum),
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            color: isActive
                                ? scheme.primary
                                : scheme.onSurface.withValues(alpha: 0.4),
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  static String _dayLabel(int weekday) => switch (weekday) {
        1 => 'M',
        2 => 'T',
        3 => 'W',
        4 => 'T',
        5 => 'F',
        6 => 'S',
        7 => 'S',
        _ => '',
      };
}
