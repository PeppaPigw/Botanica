import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/care_log.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaWeeklyRecapSheet extends StatelessWidget {
  const BotanicaWeeklyRecapSheet({
    super.key,
    required this.logs,
    required this.streakDays,
  });

  final List<CareLog> logs;
  final int streakDays;

  static Future<void> show(
    BuildContext context, {
    required List<CareLog> logs,
    required int streakDays,
  }) {
    return showBotanicaModalSheet(
      context: context,
      builder: (_) => BotanicaWeeklyRecapSheet(
        logs: logs,
        streakDays: streakDays,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday));
    final weekLogs = logs.where(
      (log) => log.timestamp.isAfter(weekStart),
    ).toList();

    final activeDays = <int>{};
    final dayCounts = <int, int>{};
    for (final log in weekLogs) {
      final day = log.timestamp.weekday;
      activeDays.add(day);
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    int? bestDay;
    int bestCount = 0;
    for (final entry in dayCounts.entries) {
      if (entry.value > bestCount) {
        bestCount = entry.value;
        bestDay = entry.key;
      }
    }

    final narrowWeekdays = MaterialLocalizations.of(context).narrowWeekdays;
    final bestDayLabel = bestDay != null ? narrowWeekdays[bestDay % 7] : '';

    return BotanicaSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: scheme.primary,
          ),
          BotanicaGaps.vMd,
          Text(
            l10n.weeklyRecapTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vSm,
          Text(
            l10n.weeklyRecapSummary(weekLogs.length, activeDays.length),
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vLg,
          _WeekDayBar(
            dayCounts: dayCounts,
            narrowWeekdays: narrowWeekdays,
          ),
          BotanicaGaps.vLg,
          Row(
            children: [
              Expanded(
                child: BotanicaGlassCard(
                  padding: BotanicaTokens.cardPaddingDense,
                  child: Column(
                    children: [
                      Text(
                        '${activeDays.length}/7',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                      Text(
                        l10n.weeklyRecapActiveDays,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.60),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: BotanicaTokens.spacingSm),
              if (streakDays > 0)
                Expanded(
                  child: BotanicaGlassCard(
                    padding: BotanicaTokens.cardPaddingDense,
                    child: Column(
                      children: [
                        Text(
                          '$streakDays',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          l10n.weeklyRecapStreak(streakDays),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.60),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              if (bestDayLabel.isNotEmpty) ...[
                const SizedBox(width: BotanicaTokens.spacingSm),
                Expanded(
                  child: BotanicaGlassCard(
                    padding: BotanicaTokens.cardPaddingDense,
                    child: Column(
                      children: [
                        Text(
                          bestDayLabel,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.teal,
                          ),
                        ),
                        Text(
                          l10n.weeklyRecapBestDay(bestDayLabel),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.60),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          BotanicaGaps.vXl,
          BotanicaButton(
            expand: true,
            label: l10n.weeklyRecapDismiss,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _WeekDayBar extends StatelessWidget {
  const _WeekDayBar({
    required this.dayCounts,
    required this.narrowWeekdays,
  });

  final Map<int, int> dayCounts;
  final List<String> narrowWeekdays;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final maxCount = dayCounts.values.fold(0, (a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final weekday = (i + 1) % 7 == 0 ? 7 : (i + 1);
        final count = dayCounts[weekday] ?? 0;
        final fraction = maxCount > 0 ? count / maxCount : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48,
              width: 24,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: BotanicaTokens.motionMedium,
                  height: 8 + 40 * fraction,
                  width: 20,
                  decoration: BoxDecoration(
                    color: count > 0
                        ? scheme.primary.withValues(alpha: 0.3 + 0.7 * fraction)
                        : scheme.surfaceContainerHighest.withValues(alpha: 0.40),
                    borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              narrowWeekdays[(i + 1) % 7],
              style: textTheme.labelSmall?.copyWith(
                color: count > 0
                    ? scheme.onSurface
                    : scheme.onSurface.withValues(alpha: 0.40),
                fontWeight: count > 0 ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}
