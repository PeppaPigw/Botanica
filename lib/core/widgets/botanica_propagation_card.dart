import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/propagation_tracker.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaPropagationCard extends StatelessWidget {
  const BotanicaPropagationCard({
    super.key,
    required this.stats,
    required this.entries,
  });

  final PropagationStats stats;
  final List<PropagationEntry> entries;

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.content_cut_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Propagation',
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
                  '${(stats.successRate * 100).round()}% success',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _PropStat(label: 'Total', value: '${stats.totalAttempts}', scheme: scheme),
              BotanicaGaps.hSm,
              _PropStat(label: 'Active', value: '${stats.activeCount}', scheme: scheme),
              BotanicaGaps.hSm,
              _PropStat(label: 'Avg days', value: '${stats.averageDaysToEstablish}', scheme: scheme),
            ],
          ),
          if (entries.where((e) => e.isActive).isNotEmpty) ...[
            BotanicaGaps.vSm,
            ...entries.where((e) => e.isActive).take(3).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                  child: Row(
                    children: [
                      Icon(_stageIcon(e.stage), size: 12,
                          color: _stageColor(e.stage, scheme)),
                      BotanicaGaps.hXxs,
                      Expanded(
                        child: Text(
                          e.method.name,
                          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        e.stage.name,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 10,
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

  static IconData _stageIcon(PropagationStage stage) => switch (stage) {
        PropagationStage.started => Icons.play_arrow_rounded,
        PropagationStage.rooting => Icons.grass_rounded,
        PropagationStage.sprouting => Icons.eco_rounded,
        PropagationStage.established => Icons.check_circle_rounded,
        PropagationStage.failed => Icons.close_rounded,
      };

  static Color _stageColor(PropagationStage stage, ColorScheme scheme) => switch (stage) {
        PropagationStage.started => const Color(0xFF42A5F5),
        PropagationStage.rooting => const Color(0xFFFFA726),
        PropagationStage.sprouting => const Color(0xFF66BB6A),
        PropagationStage.established => const Color(0xFF66BB6A),
        PropagationStage.failed => scheme.error,
      };
}

class _PropStat extends StatelessWidget {
  const _PropStat({required this.label, required this.value, required this.scheme});
  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5), fontSize: 9)),
        ],
      ),
    );
  }
}
