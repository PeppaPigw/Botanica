import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_mood_board_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaGardenMoodBoardCard extends StatelessWidget {
  const BotanicaGardenMoodBoardCard({
    super.key,
    required this.moodBoard,
  });

  final GardenMoodBoard moodBoard;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final moodColor = _moodColor(moodBoard.dominantMood);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.mood_rounded,
                  size: BotanicaTokens.iconSizeMd, color: moodColor),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Garden Mood',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${_moodEmoji(moodBoard.dominantMood)} ${(moodBoard.overallVibes * 100).round()}%',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Wrap(
            spacing: BotanicaTokens.spacingXxs,
            runSpacing: BotanicaTokens.spacingXxs,
            children: moodBoard.moodDistribution.entries.take(4).map((e) {
              final c = _moodColor(e.key);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${e.key} ${e.value}',
                  style: textTheme.labelSmall?.copyWith(
                    color: c,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
          if (moodBoard.suggestion.isNotEmpty) ...[
            BotanicaGaps.vSm,
            Text(
              moodBoard.suggestion,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  static Color _moodColor(String mood) => switch (mood) {
        'happy' => const Color(0xFF66BB6A),
        'stressed' => const Color(0xFFFFA726),
        'thriving' => const Color(0xFF26A69A),
        'neglected' => const Color(0xFFEF5350),
        _ => const Color(0xFF9E9E9E),
      };

  static String _moodEmoji(String mood) => switch (mood) {
        'happy' => '\u{1F33F}',
        'stressed' => '\u{1F4A7}',
        'thriving' => '\u{2728}',
        'neglected' => '\u{1F622}',
        _ => '\u{1F331}',
      };
}