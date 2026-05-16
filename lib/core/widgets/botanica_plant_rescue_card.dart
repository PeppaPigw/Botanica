import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_rescue_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaPlantRescueCard extends StatelessWidget {
  const BotanicaPlantRescueCard({
    super.key,
    required this.plan,
  });

  final RescuePlan plan;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final severityColor = switch (plan.severity) {
      RescueSeverity.critical => scheme.error,
      RescueSeverity.moderate => const Color(0xFFFFA726),
      RescueSeverity.mild => const Color(0xFF66BB6A),
    };

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      accentColor: severityColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.healing_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: severityColor,
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Rescue Plan',
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
                  color: severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '~${plan.estimatedRecoveryDays}d recovery',
                  style: textTheme.labelSmall?.copyWith(
                    color: severityColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Text(
            plan.plantNickname,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          BotanicaGaps.vXxs,
          Text(
            _diagnosisLabel(plan.diagnosis),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          BotanicaGaps.vSm,
          ...plan.actions.take(4).map((action) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'D${action.day}',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 8,
                          color: severityColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    BotanicaGaps.hXs,
                    Icon(
                      _actionIcon(action.type),
                      size: 14,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                    BotanicaGaps.hXs,
                    Expanded(
                      child: Text(
                        action.instruction
                            .replaceAll('rescue', '')
                            .replaceAllMapped(
                                RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
                            .trim(),
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
          if (plan.actions.length > 4)
            Text(
              '+${plan.actions.length - 4} more steps',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  static String _diagnosisLabel(String diagnosis) {
    return switch (diagnosis) {
      'dehydration' => 'Likely dehydrated — needs water urgently',
      'neglect' => 'Needs attention after a period of neglect',
      'nutrientDeficiency' => 'Possible nutrient deficiency',
      _ => 'General decline — full inspection needed',
    };
  }

  static IconData _actionIcon(RescueActionType type) {
    return switch (type) {
      RescueActionType.water => Icons.water_drop_rounded,
      RescueActionType.mist => Icons.air_rounded,
      RescueActionType.relocate => Icons.open_with_rounded,
      RescueActionType.prune => Icons.content_cut_rounded,
      RescueActionType.inspect => Icons.search_rounded,
      RescueActionType.fertilize => Icons.science_rounded,
    };
  }
}
