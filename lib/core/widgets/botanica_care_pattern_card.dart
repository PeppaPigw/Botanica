import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_pattern_analyzer.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCarePatternCard extends StatelessWidget {
  const BotanicaCarePatternCard({
    super.key,
    required this.patterns,
  });

  final List<CarePattern> patterns;

  @override
  Widget build(BuildContext context) {
    if (patterns.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.pattern_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.carePatternsTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${patterns.length} detected',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...patterns.take(4).map((p) {
            final icon = _patternIcon(p.type);
            final confidenceColor = p.confidence >= 0.7
                ? const Color(0xFF66BB6A)
                : p.confidence >= 0.4
                    ? const Color(0xFFFF9800)
                    : scheme.onSurface.withValues(alpha: 0.4);

            return Padding(
              padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
              child: Row(
                children: [
                  Icon(icon, size: 14, color: scheme.tertiary.withValues(alpha: 0.7)),
                  BotanicaGaps.hXxs,
                  Expanded(
                    child: Text(
                      p.messageKey.replaceAll('pattern_', '').replaceAll('_', ' '),
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: scheme.onSurface.withValues(alpha: 0.06),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: p.confidence.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: confidenceColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static IconData _patternIcon(PatternType type) {
    return switch (type) {
      PatternType.batchCarer => Icons.group_work_rounded,
      PatternType.morningRitual => Icons.wb_sunny_rounded,
      PatternType.eveningRitual => Icons.nightlight_round,
      PatternType.weekendWarrior => Icons.weekend_rounded,
      PatternType.seasonalDip => Icons.trending_down_rounded,
      PatternType.seasonalSurge => Icons.trending_up_rounded,
      PatternType.favoriteFirst => Icons.favorite_rounded,
      PatternType.neglectedChild => Icons.warning_rounded,
      PatternType.diverseRoutine => Icons.shuffle_rounded,
      PatternType.focusedCarer => Icons.center_focus_strong_rounded,
    };
  }
}
