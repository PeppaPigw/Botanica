import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_time_machine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaTimeMachineCard extends StatelessWidget {
  const BotanicaTimeMachineCard({
    super.key,
    required this.result,
  });

  final TimeMachineResult result;

  @override
  Widget build(BuildContext context) {
    if (result.snapshots.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.history_edu_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Garden Timeline',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${result.totalPlantsEver} total',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: result.snapshots.take(6).map((s) {
                final h = (s.healthEstimate * 36).clamp(4.0, 36.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: h,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              scheme.error.withValues(alpha: 0.3),
                              const Color(0xFF66BB6A).withValues(alpha: 0.5),
                              s.healthEstimate,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          BotanicaGaps.vXxs,
          Text(
            'Peak: month ${result.peakMonth} • ${result.snapshots.length} snapshots',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
