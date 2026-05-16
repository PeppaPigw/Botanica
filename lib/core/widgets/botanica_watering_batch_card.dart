import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/watering_batch_planner.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaWateringBatchCard extends StatelessWidget {
  const BotanicaWateringBatchCard({
    super.key,
    required this.plan,
    this.plantNameResolver,
  });

  final WateringBatchPlan plan;
  final String Function(String plantId)? plantNameResolver;

  static const _dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    if (plan.slots.isEmpty) return const SizedBox.shrink();

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
              const Icon(
                Icons.water_drop_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: Color(0xFF42A5F5),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Watering Schedule',
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
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${plan.suggestedDays} days/wk',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF42A5F5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          _WeekStrip(slots: plan.slots, scheme: scheme),
          BotanicaGaps.vSm,
          ...plan.slots.take(4).map((slot) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        _dayNames[slot.dayOfWeek.clamp(1, 7)],
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    BotanicaGaps.hXs,
                    Expanded(
                      child: Text(
                        '${slot.plantIds.length} plants · ~${slot.estimatedMinutes}min',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          BotanicaGaps.vXxs,
          Row(
            children: [
              Icon(
                Icons.speed_rounded,
                size: 14,
                color: scheme.tertiary,
              ),
              BotanicaGaps.hXs,
              Text(
                'Batch efficiency: ${(plan.batchEfficiency * 100).round()}%',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.slots, required this.scheme});

  final List<BatchSlot> slots;
  final ColorScheme scheme;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final activeDays = slots.map((s) => s.dayOfWeek).toSet();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final dayNum = i + 1;
        final isActive = activeDays.contains(dayNum);
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF42A5F5).withValues(alpha: 0.15)
                : scheme.outlineVariant.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _days[i],
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF42A5F5)
                      : scheme.onSurface.withValues(alpha: 0.4),
                ),
          ),
        );
      }),
    );
  }
}
