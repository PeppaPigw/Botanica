import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/seasonal_transition_planner.dart';
import '../../gen/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

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
                  l10n.seasonalTransitionTitle,
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
                  l10n.seasonalTransitionWeeks(plan.weeksUntilTransition),
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
                        '${t.plantNickname}: ${_actionLabel(t.action, l10n)}',
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
                l10n.seasonalTransitionMore(plan.tasks.length - 3),
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

  static String _actionLabel(TransitionAction action, AppLocalizations l10n) {
    switch (action) {
      case TransitionAction.moveIndoors:
        return l10n.transitionMoveIndoors;
      case TransitionAction.moveOutdoors:
        return l10n.transitionMoveOutdoors;
      case TransitionAction.reduceWatering:
        return l10n.transitionReduceWatering;
      case TransitionAction.increaseWatering:
        return l10n.transitionIncreaseWatering;
      case TransitionAction.startFertilizing:
        return l10n.transitionStartFertilizing;
      case TransitionAction.stopFertilizing:
        return l10n.transitionStopFertilizing;
      case TransitionAction.increaseHumidity:
        return l10n.transitionIncreaseHumidity;
      case TransitionAction.protectFromFrost:
        return l10n.transitionProtectFromFrost;
      case TransitionAction.provideShadeCover:
        return l10n.transitionProvideShadeCover;
      case TransitionAction.resumeNormalCare:
        return l10n.transitionResumeNormalCare;
    }
  }
}
