import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_rhythm_engine.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareRhythmCard extends StatelessWidget {
  const BotanicaCareRhythmCard({
    super.key,
    required this.rhythm,
  });

  final CareRhythm rhythm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final (IconData icon, Color color, String label, String desc) =
        _rhythmVisual(rhythm.type, scheme, l10n);

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
                  l10n.careRhythmTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (rhythm.streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BotanicaTokens.spacingXs,
                    vertical: BotanicaTokens.spacingMicro,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(BotanicaTokens.radiusPill),
                  ),
                  child: Text(
                    l10n.careRhythmStreakBadge(rhythm.streak),
                    style: textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          BotanicaGaps.vSm,
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          BotanicaGaps.vXxs,
          Text(
            desc,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          BotanicaGaps.vSm,
          _ConfidenceBar(confidence: rhythm.confidence, color: color, scheme: scheme),
        ],
      ),
    );
  }

  static (IconData, Color, String, String) _rhythmVisual(
      CareRhythmType type, ColorScheme scheme, AppLocalizations l10n) {
    return switch (type) {
      CareRhythmType.morningPerson => (
          Icons.wb_sunny_rounded,
          const Color(0xFFFFA726),
          l10n.careRhythmMorningPerson,
          l10n.careRhythmMorningPersonDesc,
        ),
      CareRhythmType.eveningPerson => (
          Icons.nightlight_round,
          const Color(0xFF7E57C2),
          l10n.careRhythmEveningCarer,
          l10n.careRhythmEveningCarerDesc,
        ),
      CareRhythmType.weekendWarrior => (
          Icons.weekend_rounded,
          scheme.tertiary,
          l10n.careRhythmWeekendWarrior,
          l10n.careRhythmWeekendWarriorDesc,
        ),
      CareRhythmType.dailyDevoter => (
          Icons.calendar_today_rounded,
          scheme.primary,
          l10n.careRhythmDailyDevoter,
          l10n.careRhythmDailyDevoterDesc,
        ),
      CareRhythmType.batchCarer => (
          Icons.layers_rounded,
          scheme.secondary,
          l10n.careRhythmBatchCarer,
          l10n.careRhythmBatchCarerDesc,
        ),
    };
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({
    required this.confidence,
    required this.color,
    required this.scheme,
  });

  final double confidence;
  final Color color;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 4,
              backgroundColor: scheme.outlineVariant.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        BotanicaGaps.hXs,
        Text(
          l10n.careRhythmConfidence((confidence * 100).round()),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }
}
