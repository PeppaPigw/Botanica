import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_sharing_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaGardenSharingCard extends StatelessWidget {
  const BotanicaGardenSharingCard({
    super.key,
    required this.card,
  });

  final ShareableGardenCard card;

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
              Icon(Icons.share_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.secondary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.gardenCardTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXxs,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  card.badgeKey.replaceAll('badge_', ''),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _StatPill(label: '${card.plantCount} plants', scheme: scheme, textTheme: textTheme),
              BotanicaGaps.hXxs,
              _StatPill(label: '${card.streakDays}d streak', scheme: scheme, textTheme: textTheme),
              BotanicaGaps.hXxs,
              _StatPill(label: '${card.gardenAge}d old', scheme: scheme, textTheme: textTheme),
            ],
          ),
          if (card.topPlantNickname.isNotEmpty) ...[
            BotanicaGaps.vXxs,
            Text(
              'Star plant: ${card.topPlantNickname}',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.scheme,
    required this.textTheme,
  });

  final String label;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingXxs,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.6),
          fontSize: 9,
        ),
      ),
    );
  }
}
