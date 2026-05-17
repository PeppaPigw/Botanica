import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_maturity_estimator.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaMaturityCard extends StatelessWidget {
  const BotanicaMaturityCard({
    super.key,
    required this.estimates,
  });

  final List<MaturityEstimate> estimates;

  @override
  Widget build(BuildContext context) {
    if (estimates.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.park_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.growthStageTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...estimates.take(4).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: e.progressPercent.clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(_stageColor(e.stage)),
                        ),
                      ),
                    ),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        e.plantNickname,
                        style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      e.stage.name,
                      style: textTheme.labelSmall?.copyWith(
                        color: _stageColor(e.stage),
                        fontWeight: FontWeight.w600,
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

  static Color _stageColor(MaturityStage stage) => switch (stage) {
        MaturityStage.seedling => const Color(0xFF8D6E63),
        MaturityStage.juvenile => const Color(0xFF66BB6A),
        MaturityStage.adolescent => const Color(0xFF42A5F5),
        MaturityStage.mature => const Color(0xFFAB47BC),
        MaturityStage.fullGrown => const Color(0xFFFFD700),
      };
}
