import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_delegation_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareDelegationCard extends StatelessWidget {
  const BotanicaCareDelegationCard({
    super.key,
    required this.plan,
  });

  final CareDelegationPlan plan;

  @override
  Widget build(BuildContext context) {
    if (plan.tasks.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.people_outline_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Delegation Plan',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${plan.totalTaskCount} tasks',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...plan.tasks.take(4).map((t) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6,
                        color: t.priority > 2
                            ? scheme.error.withValues(alpha: 0.7)
                            : scheme.onSurface.withValues(alpha: 0.3)),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        '${t.plantNickname} — ${t.taskType.name}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'every ${t.frequencyDays}d',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              )),
          if (plan.criticalPlants.isNotEmpty) ...[
            BotanicaGaps.vXxs,
            Text(
              'Critical: ${plan.criticalPlants.take(3).join(', ')}',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.error.withValues(alpha: 0.7),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
