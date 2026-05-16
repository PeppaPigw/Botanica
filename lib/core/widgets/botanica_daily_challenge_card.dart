import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/daily_challenge_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaDailyChallengeCard extends StatelessWidget {
  const BotanicaDailyChallengeCard({
    super.key,
    required this.challenge,
    this.onAccept,
  });

  final DailyChallenge challenge;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (IconData icon, Color color) = _categoryVisual(challenge.category, scheme);
    final difficultyColor = _difficultyColor(challenge.difficulty, scheme);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: BotanicaTokens.iconSizeMd, color: color),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Daily Challenge',
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
                  color: difficultyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '+${challenge.xpReward} XP',
                  style: textTheme.labelSmall?.copyWith(
                    color: difficultyColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Text(
            challenge.titleKey
                .replaceAll('challenge', '')
                .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
                .trim(),
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          BotanicaGaps.vXxs,
          Text(
            challenge.descriptionKey
                .replaceAll('challenge', '')
                .replaceAll('Desc', '')
                .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
                .trim(),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _DifficultyDots(difficulty: challenge.difficulty, color: difficultyColor),
              const Spacer(),
              if (onAccept != null)
                GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BotanicaTokens.spacingSm,
                      vertical: BotanicaTokens.spacingTiny,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                    ),
                    child: Text(
                      'Accept',
                      style: textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static (IconData, Color) _categoryVisual(ChallengeCategory cat, ColorScheme scheme) {
    return switch (cat) {
      ChallengeCategory.care => (Icons.spa_rounded, scheme.primary),
      ChallengeCategory.observation => (Icons.visibility_rounded, const Color(0xFF66BB6A)),
      ChallengeCategory.learning => (Icons.school_rounded, const Color(0xFF42A5F5)),
      ChallengeCategory.social => (Icons.groups_rounded, scheme.secondary),
      ChallengeCategory.creative => (Icons.palette_rounded, scheme.tertiary),
    };
  }

  static Color _difficultyColor(ChallengeDifficulty diff, ColorScheme scheme) {
    return switch (diff) {
      ChallengeDifficulty.easy => const Color(0xFF66BB6A),
      ChallengeDifficulty.medium => const Color(0xFFFFA726),
      ChallengeDifficulty.hard => scheme.error,
    };
  }
}

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.difficulty, required this.color});

  final ChallengeDifficulty difficulty;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final count = switch (difficulty) {
      ChallengeDifficulty.easy => 1,
      ChallengeDifficulty.medium => 2,
      ChallengeDifficulty.hard => 3,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < count ? color : color.withValues(alpha: 0.2),
            ),
          )),
    );
  }
}
