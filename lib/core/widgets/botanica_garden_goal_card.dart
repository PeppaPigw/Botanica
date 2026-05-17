import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_goal_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaGardenGoalCard extends StatelessWidget {
  const BotanicaGardenGoalCard({
    super.key,
    required this.goals,
  });

  final List<GoalSuggestion> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();

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
                Icons.flag_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.primary,
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.suggestedGoalsTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${goals.length} available',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...goals.take(3).map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: _GoalRow(goal: goal, scheme: scheme),
              )),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal, required this.scheme});

  final GoalSuggestion goal;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _categoryColor(goal.category, scheme);
    final icon = _categoryIcon(goal.category);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        BotanicaGaps.hXs,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.titleKey
                    .replaceAll('goal', '')
                    .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
                    .trim(),
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${goal.durationDays}d · ${goal.difficulty}',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: BotanicaTokens.spacingXxs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: _difficultyColor(goal.difficulty).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
          ),
          child: Text(
            goal.difficulty,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: _difficultyColor(goal.difficulty),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  static IconData _categoryIcon(String category) {
    return switch (category) {
      'streak' => Icons.local_fire_department_rounded,
      'collection' => Icons.collections_rounded,
      'activity' => Icons.bolt_rounded,
      'documentation' => Icons.camera_alt_rounded,
      'diversity' => Icons.diversity_3_rounded,
      _ => Icons.flag_rounded,
    };
  }

  static Color _categoryColor(String category, ColorScheme scheme) {
    return switch (category) {
      'streak' => const Color(0xFFFFA726),
      'collection' => scheme.primary,
      'activity' => scheme.tertiary,
      'documentation' => const Color(0xFF42A5F5),
      'diversity' => const Color(0xFF66BB6A),
      _ => scheme.primary,
    };
  }

  static Color _difficultyColor(String difficulty) {
    return switch (difficulty) {
      'easy' => const Color(0xFF66BB6A),
      'medium' => const Color(0xFFFFA726),
      'hard' => const Color(0xFFEF5350),
      _ => const Color(0xFF66BB6A),
    };
  }
}
