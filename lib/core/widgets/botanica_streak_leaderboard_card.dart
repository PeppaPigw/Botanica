import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/streak_leaderboard_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaStreakLeaderboardCard extends StatelessWidget {
  const BotanicaStreakLeaderboardCard({
    super.key,
    required this.result,
  });

  final LeaderboardResult result;

  @override
  Widget build(BuildContext context) {
    if (result.entries.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Streak Board',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  'Top ${(result.userPercentile * 100).round()}%',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...result.entries.take(5).map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: _LeaderboardRow(entry: entry, scheme: scheme),
              )),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.scheme});

  final LeaderboardEntry entry;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isUser = entry.isCurrentUser;

    final rankColor = switch (entry.rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => scheme.onSurface.withValues(alpha: 0.5),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingXxs,
        vertical: BotanicaTokens.spacingMicro,
      ),
      decoration: isUser
          ? BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '#${entry.rank}',
              style: textTheme.labelSmall?.copyWith(
                color: rankColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          BotanicaGaps.hXs,
          Expanded(
            child: Text(
              entry.displayName,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
                color: isUser ? scheme.primary : scheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${entry.streakDays}d',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
