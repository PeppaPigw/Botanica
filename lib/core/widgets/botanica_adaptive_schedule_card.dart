import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/adaptive_care_scheduler.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaAdaptiveScheduleCard extends StatelessWidget {
  const BotanicaAdaptiveScheduleCard({
    super.key,
    required this.adjustments,
  });

  final List<ScheduleAdjustment> adjustments;

  @override
  Widget build(BuildContext context) {
    if (adjustments.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.tune_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Schedule Tuning',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${adjustments.length} suggestions',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...adjustments.take(3).map((a) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    Icon(
                      a.suggestsMoreFrequent
                          ? Icons.fast_forward_rounded
                          : Icons.slow_motion_video_rounded,
                      size: 14,
                      color: a.suggestsMoreFrequent ? const Color(0xFF42A5F5) : const Color(0xFF66BB6A),
                    ),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        a.plantNickname,
                        style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${a.currentIntervalDays}d → ${a.suggestedIntervalDays}d',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 10,
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
