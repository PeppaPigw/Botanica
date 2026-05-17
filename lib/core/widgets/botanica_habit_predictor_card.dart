import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_habit_predictor.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaHabitPredictorCard extends StatelessWidget {
  const BotanicaHabitPredictorCard({
    super.key,
    required this.profile,
  });

  final WeeklyHabitProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.predictions.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.careHabitsTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                profile.preferredTimeSlot,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final pred = i < profile.predictions.length ? profile.predictions[i] : null;
              final rate = pred?.avgCompletionRate ?? 0;
              final isBest = (i + 1) == profile.bestDay;
              return Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        scheme.error.withValues(alpha: 0.2),
                        const Color(0xFF66BB6A).withValues(alpha: 0.3),
                        rate,
                      ),
                      shape: BoxShape.circle,
                      border: isBest
                          ? Border.all(color: scheme.primary, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${(rate * 100).round()}',
                      style: textTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    days[i],
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              );
            }),
          ),
          BotanicaGaps.vSm,
          Text(
            'Best: ${days[(profile.bestDay - 1).clamp(0, 6)]} • Weakest: ${days[(profile.worstDay - 1).clamp(0, 6)]}',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
