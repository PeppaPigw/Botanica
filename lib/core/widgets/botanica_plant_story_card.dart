import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_story_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaPlantStoryCard extends StatelessWidget {
  const BotanicaPlantStoryCard({
    super.key,
    required this.story,
  });

  final PlantStory story;

  @override
  Widget build(BuildContext context) {
    if (story.chapters.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final current = story.chapters.length > story.currentChapter
        ? story.chapters[story.currentChapter]
        : story.chapters.last;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.secondary.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.plantStoryTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Ch. ${story.currentChapter + 1}/${story.chapters.length}',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          _ChapterTimeline(
            chapters: story.chapters,
            currentIndex: story.currentChapter,
            scheme: scheme,
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _MoodIcon(mood: current.mood, scheme: scheme),
              BotanicaGaps.hXs,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.titleKey,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${current.eventCount} care events',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChapterTimeline extends StatelessWidget {
  const _ChapterTimeline({
    required this.chapters,
    required this.currentIndex,
    required this.scheme,
  });

  final List<StoryChapter> chapters;
  final int currentIndex;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(chapters.length, (i) {
        final isActive = i <= currentIndex;
        final isCurrent = i == currentIndex;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < chapters.length - 1 ? 2 : 0),
            decoration: BoxDecoration(
              color: isCurrent
                  ? scheme.primary
                  : isActive
                      ? scheme.primary.withValues(alpha: 0.4)
                      : scheme.outlineVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _MoodIcon extends StatelessWidget {
  const _MoodIcon({required this.mood, required this.scheme});

  final String mood;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (mood) {
      'thriving' => (Icons.spa_rounded, scheme.tertiary),
      'growing' => (Icons.trending_up_rounded, scheme.primary),
      'struggling' => (Icons.sentiment_neutral_rounded, const Color(0xFFFF9800)),
      'recovering' => (Icons.healing_rounded, scheme.secondary),
      _ => (Icons.eco_rounded, scheme.primary),
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
