import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_recommendation_engine.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaPlantRecommendationCard extends StatelessWidget {
  const BotanicaPlantRecommendationCard({
    super.key,
    required this.result,
    required this.speciesNames,
  });

  final RecommendationResult result;
  final Map<String, String> speciesNames;

  @override
  Widget build(BuildContext context) {
    if (result.recommendations.isEmpty) return const SizedBox.shrink();

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
              Icon(
                Icons.local_florist_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.tertiary.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.recommendedForYouTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (result.gardenGaps.isNotEmpty) ...[
            BotanicaGaps.vXs,
            Text(
              l10n.recommendedGaps(result.gardenGaps.take(3).join(', ')),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          BotanicaGaps.vSm,
          ...result.recommendations.take(3).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: scheme.tertiary.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(BotanicaTokens.radiusS),
                      ),
                      child: Center(
                        child: Text(
                          '${(rec.matchScore * 100).round()}',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            color: scheme.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            speciesNames[rec.speciesId] ?? rec.speciesId,
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            rec.reason,
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: scheme.onSurface.withValues(alpha: 0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      rec.lightNeeds,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: scheme.onSurface.withValues(alpha: 0.4),
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
