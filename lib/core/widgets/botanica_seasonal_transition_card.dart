import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/seasonal_transition_planner.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaSeasonalTransitionCard extends StatelessWidget {
  const BotanicaSeasonalTransitionCard({
    super.key,
    required this.plan,
  });

  final SeasonalTransitionPlan plan;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final urgentCount =
        plan.tasks.where((t) => t.urgency >= 3).length;
    final accentColor = urgentCount > 0 ? scheme.error : scheme.secondary;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                size: BotanicaTokens.iconSizeMd,
                color: accentColor.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Seasonal Transition',
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
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${plan.weeksUntilTransition}w away',
                  style: textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vXs,
          Text(
            plan.summary,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          BotanicaGaps.vSm,
          ...plan.tasks.take(3).map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      _actionIcon(t.action),
                      size: 14,
                      color: t.urgency >= 3
                          ? scheme.error.withValues(alpha: 0.8)
                          : scheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${t.plantNickname}: ${_actionLabel(t.action)}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (plan.tasks.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+${plan.tasks.length - 3} more tasks',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _actionIcon(TransitionAction action) {
    switch (action) {
      case TransitionAction.moveIndoors:
        return Icons.home_outlined;
      case TransitionAction.moveOutdoors:
        return Icons.park_outlined;
      case TransitionAction.reduceWatering:
        return Icons.water_drop_outlined;
      case TransitionAction.increaseWatering:
        return Icons.water_drop;
      case TransitionAction.startFertilizing:
        return Icons.eco_outlined;
      case TransitionAction.stopFertilizing:
        return Icons.block_outlined;
      case TransitionAction.increaseHumidity:
        return Icons.cloud_outlined;
      case TransitionAction.protectFromFrost:
        return Icons.ac_unit_outlined;
      case TransitionAction.provideShadeCover:
        return Icons.wb_shade_outlined;
      case TransitionAction.resumeNormalCare:
        return Icons.check_circle_outline;
    }
  }

  static String _actionLabel(TransitionAction action) {
    switch (action) {
      case TransitionAction.moveIndoors:
        return 'Move indoors';
      case TransitionAction.moveOutdoors:
        return 'Move outdoors';
      case TransitionAction.reduceWatering:
        return 'Reduce watering';
      case TransitionAction.increaseWatering:
        return 'Increase watering';
      case TransitionAction.startFertilizing:
        return 'Start fertilizing';
      case TransitionAction.stopFertilizing:
        return 'Stop fertilizing';
      case TransitionAction.increaseHumidity:
        return 'Increase humidity';
      case TransitionAction.protectFromFrost:
        return 'Protect from frost';
      case TransitionAction.provideShadeCover:
        return 'Provide shade';
      case TransitionAction.resumeNormalCare:
        return 'Resume normal care';
    }
  }
}
