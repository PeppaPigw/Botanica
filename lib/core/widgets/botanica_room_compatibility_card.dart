import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_compatibility.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaRoomCompatibilityCard extends StatelessWidget {
  const BotanicaRoomCompatibilityCard({
    super.key,
    required this.compatibility,
  });

  final RoomCompatibility compatibility;

  @override
  Widget build(BuildContext context) {
    if (compatibility.pairings.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final scoreColor = compatibility.overallScore >= 0.7
        ? scheme.tertiary
        : compatibility.overallScore >= 0.4
            ? scheme.primary
            : scheme.error;

    final poorPairings = compatibility.pairings
        .where((p) => p.level == CompatibilityLevel.poor)
        .toList();

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scoreColor.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.roomCompatibilityTitle(compatibility.room),
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
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${(compatibility.overallScore * 100).round()}%',
                  style: textTheme.labelSmall?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Text(
            l10n.roomCompatibilityPairings(
              compatibility.plants.length,
              compatibility.pairings.length,
            ),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (poorPairings.isNotEmpty) ...[
            BotanicaGaps.vSm,
            ...poorPairings.take(2).map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: scheme.error.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${p.plantA.nickname} & ${p.plantB.nickname}',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
}
