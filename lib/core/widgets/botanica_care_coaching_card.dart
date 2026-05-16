import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_coaching.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareCoachingCard extends StatelessWidget {
  const BotanicaCareCoachingCard({
    super.key,
    required this.insights,
  });

  final List<CoachingInsight> insights;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.school_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Care Coach',
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
                  '${insights.length} tips',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...insights.take(3).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_typeIcon(insight.type),
                        size: 14, color: _typeColor(insight.type, scheme)),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.titleKey,
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            insight.bodyKey,
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static IconData _typeIcon(CoachingInsightType type) => switch (type) {
        CoachingInsightType.lateWaterer => Icons.schedule_rounded,
        CoachingInsightType.consistentCarer => Icons.verified_rounded,
        CoachingInsightType.neglectedPlant => Icons.warning_amber_rounded,
        CoachingInsightType.improvingHabit => Icons.trending_up_rounded,
        CoachingInsightType.streakAtRisk => Icons.local_fire_department_rounded,
        CoachingInsightType.diversifyCare => Icons.category_rounded,
      };

  static Color _typeColor(CoachingInsightType type, ColorScheme scheme) => switch (type) {
        CoachingInsightType.lateWaterer => const Color(0xFFFFA726),
        CoachingInsightType.consistentCarer => const Color(0xFF66BB6A),
        CoachingInsightType.neglectedPlant => scheme.error,
        CoachingInsightType.improvingHabit => scheme.primary,
        CoachingInsightType.streakAtRisk => const Color(0xFFFF7043),
        CoachingInsightType.diversifyCare => scheme.tertiary,
      };
}
