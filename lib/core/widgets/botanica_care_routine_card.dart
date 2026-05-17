import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_routine_detector.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareRoutineCard extends StatelessWidget {
  const BotanicaCareRoutineCard({
    super.key,
    required this.result,
  });

  final CareRoutineResult result;

  @override
  Widget build(BuildContext context) {
    if (result.detectedRoutines.isEmpty) return const SizedBox.shrink();

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
                Icons.schedule_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.tertiary.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.careRoutinesTitle,
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
                  color: scheme.tertiary.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(BotanicaTokens.radiusPill),
                ),
                child: Text(
                  '${result.totalWeeklyMinutes} min/week',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...result.detectedRoutines.take(3).map(
                (r) => _RoutineRow(routine: r),
              ),
          if (result.optimizations.isNotEmpty) ...[
            BotanicaGaps.vXxs,
            _OptimizationHint(optimization: result.optimizations.first),
          ],
        ],
      ),
    );
  }
}

class _RoutineRow extends StatelessWidget {
  const _RoutineRow({required this.routine});

  final CareRoutine routine;

  String _timeLabel(int hour) {
    if (hour < 6) return 'Night';
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  IconData _timeIcon(int hour) {
    if (hour < 6) return Icons.nightlight_rounded;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_cloudy_rounded;
    return Icons.nights_stay_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
      child: Row(
        children: [
          Icon(
            _timeIcon(routine.preferredTime),
            size: 14,
            color: scheme.primary.withValues(alpha: 0.7),
          ),
          BotanicaGaps.hXs,
          Expanded(
            child: Text(
              '${_timeLabel(routine.preferredTime)} ${routine.frequency}',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${routine.plantIds.length} plants',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          BotanicaGaps.hXs,
          SizedBox(
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: routine.consistency,
                backgroundColor:
                    scheme.outlineVariant.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(
                  scheme.tertiary.withValues(alpha: 0.6),
                ),
                minHeight: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimizationHint extends StatelessWidget {
  const _OptimizationHint({required this.optimization});

  final RoutineOptimization optimization;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(BotanicaTokens.spacingXxs),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 14,
            color: scheme.primary,
          ),
          BotanicaGaps.hXs,
          Expanded(
            child: Text(
              optimization.suggestion,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
