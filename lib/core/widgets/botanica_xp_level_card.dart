import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_care_xp_system.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaXpLevelCard extends StatelessWidget {
  const BotanicaXpLevelCard({
    super.key,
    required this.level,
  });

  final GardenerLevel level;

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
              const Icon(Icons.military_tech_rounded,
                  size: BotanicaTokens.iconSizeMd, color: Color(0xFFFFD700)),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.xpLevelTitle(level.level),
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${level.totalXp} XP',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vXxs,
          Text(
            level.title,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          BotanicaGaps.vSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
            child: LinearProgressIndicator(
              value: level.progressToNext.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD700)),
            ),
          ),
          BotanicaGaps.vXxs,
          Text(
            l10n.xpLevelProgress(level.xpInCurrentLevel, level.xpForNextLevel),
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (level.recentXpEvents.isNotEmpty) ...[
            BotanicaGaps.vSm,
            ...level.recentXpEvents.take(2).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                  child: Row(
                    children: [
                      Text(
                        '+${e.xp}',
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF66BB6A),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      BotanicaGaps.hXxs,
                      Expanded(
                        child: Text(
                          e.action,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 10,
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
