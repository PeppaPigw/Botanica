import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_survival_predictor.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaSurvivalPredictorCard extends StatelessWidget {
  const BotanicaSurvivalPredictorCard({
    super.key,
    required this.predictions,
  });

  final List<SurvivalPrediction> predictions;

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final atRisk = predictions.where((p) => p.atRisk).toList();

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.shield_rounded,
                  size: BotanicaTokens.iconSizeMd,
                  color: atRisk.isNotEmpty ? scheme.error : const Color(0xFF66BB6A)),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.survivalOutlookTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (atRisk.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BotanicaTokens.spacingXs,
                    vertical: BotanicaTokens.spacingMicro,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                  ),
                  child: Text(
                    '${atRisk.length} at risk',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          BotanicaGaps.vSm,
          ...predictions.take(4).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${(p.survivalProbability * 100).round()}%',
                        style: textTheme.labelSmall?.copyWith(
                          color: p.atRisk ? scheme.error : const Color(0xFF66BB6A),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        p.plantNickname,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${p.projectedMonths}mo',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.5),
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
