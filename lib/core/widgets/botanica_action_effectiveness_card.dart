import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/care_action_effectiveness.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaActionEffectivenessCard extends StatelessWidget {
  const BotanicaActionEffectivenessCard({
    super.key,
    required this.reports,
  });

  final List<EffectivenessReport> reports;

  @override
  Widget build(BuildContext context) {
    final nonEmpty = reports.where((r) => r.effects.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final allEffects = <TaskType, List<double>>{};
    for (final r in nonEmpty) {
      for (final e in r.effects) {
        allEffects.putIfAbsent(e.taskType, () => []).add(e.effectivenessScore);
      }
    }
    final avgEffects = allEffects.entries
        .map((e) => MapEntry(e.key, e.value.reduce((a, b) => a + b) / e.value.length))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Care Effectiveness',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${nonEmpty.length} plants',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...avgEffects.take(5).map((entry) {
            final color = entry.value >= 0.6
                ? const Color(0xFF66BB6A)
                : entry.value >= 0.3
                    ? const Color(0xFFFF9800)
                    : scheme.error;

            return Padding(
              padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      entry.key.name,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: entry.value.clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: scheme.onSurface.withValues(alpha: 0.06),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ),
                  BotanicaGaps.hXxs,
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${(entry.value * 100).round()}%',
                      style: textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
