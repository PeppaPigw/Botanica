import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_knowledge_quiz_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaKnowledgeQuizCard extends StatelessWidget {
  const BotanicaKnowledgeQuizCard({
    super.key,
    required this.quiz,
    this.onStart,
  });

  final QuizResult quiz;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    if (quiz.questions.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.quiz_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.plantQuizTitle,
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
                  '${quiz.totalQuestions} Q',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              Text(
                'Difficulty: ',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              ...List.generate(5, (i) => Icon(
                    Icons.circle,
                    size: 8,
                    color: i < quiz.estimatedDifficulty
                        ? scheme.tertiary
                        : scheme.onSurface.withValues(alpha: 0.15),
                  )),
            ],
          ),
          BotanicaGaps.vXxs,
          Wrap(
            spacing: BotanicaTokens.spacingXxs,
            children: quiz.categories.take(3).map((c) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BotanicaTokens.spacingXs,
                    vertical: BotanicaTokens.spacingMicro,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                  ),
                  child: Text(c, style: textTheme.labelSmall?.copyWith(fontSize: 10)),
                )).toList(),
          ),
        ],
      ),
    );
  }
}
