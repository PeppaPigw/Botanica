import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_cost_tracker.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareCostCard extends StatelessWidget {
  const BotanicaCareCostCard({
    super.key,
    required this.summary,
  });

  final CostSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.savings_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.careCostsTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '\$${summary.totalSpent.toStringAsFixed(0)}',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _CostStat(label: '/month', value: '\$${summary.monthlyAverage.toStringAsFixed(0)}', scheme: scheme),
              BotanicaGaps.hSm,
              _CostStat(label: '/plant', value: '\$${summary.costPerPlant.toStringAsFixed(1)}', scheme: scheme),
              BotanicaGaps.hSm,
              _CostStat(label: '/year est', value: '\$${summary.projectedAnnual.toStringAsFixed(0)}', scheme: scheme),
            ],
          ),
          if (summary.categoryBreakdown.isNotEmpty) ...[
            BotanicaGaps.vSm,
            Wrap(
              spacing: BotanicaTokens.spacingXxs,
              runSpacing: BotanicaTokens.spacingXxs,
              children: summary.categoryBreakdown.entries.take(4).map((e) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BotanicaTokens.spacingXs,
                      vertical: BotanicaTokens.spacingMicro,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                    ),
                    child: Text(
                      '${e.key} \$${e.value.toStringAsFixed(0)}',
                      style: textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                  )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CostStat extends StatelessWidget {
  const _CostStat({required this.label, required this.value, required this.scheme});
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
