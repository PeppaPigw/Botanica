import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_autobiography_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaPlantAutobiographyCard extends StatelessWidget {
  const BotanicaPlantAutobiographyCard({
    super.key,
    required this.autobiography,
  });

  final PlantAutobiography autobiography;

  @override
  Widget build(BuildContext context) {
    if (autobiography.chapters.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.auto_stories_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.lifeStoryTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${autobiography.totalDays}d',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vXxs,
          Text(
            autobiography.plantNickname,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _Stat(label: 'days', value: '${autobiography.totalDays}', scheme: scheme),
              BotanicaGaps.hSm,
              _Stat(label: 'actions', value: '${autobiography.totalCareActions}', scheme: scheme),
              BotanicaGaps.hSm,
              _Stat(label: 'chapters', value: '${autobiography.chapters.length}', scheme: scheme),
            ],
          ),
          BotanicaGaps.vSm,
          ...autobiography.chapters.take(4).map((ch) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  children: [
                    Icon(_chapterIcon(ch.type),
                        size: 12, color: scheme.primary.withValues(alpha: 0.7)),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        ch.messageKey,
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
      ),
    );
  }

  static IconData _chapterIcon(ChapterType type) => switch (type) {
        ChapterType.arrival => Icons.flight_land_rounded,
        ChapterType.firstCare => Icons.water_drop_rounded,
        ChapterType.growthSpurt => Icons.trending_up_rounded,
        ChapterType.challenge => Icons.warning_rounded,
        ChapterType.milestone => Icons.emoji_events_rounded,
        ChapterType.photoMemory => Icons.photo_camera_rounded,
        ChapterType.seasonChange => Icons.wb_sunny_rounded,
        ChapterType.currentState => Icons.spa_rounded,
      };
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.scheme});

  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
                fontSize: 9,
              ),
        ),
      ],
    );
  }
}
