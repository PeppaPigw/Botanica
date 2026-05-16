import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/care_autopilot_engine.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareAutopilotCard extends StatelessWidget {
  const BotanicaCareAutopilotCard({
    super.key,
    required this.suggestions,
  });

  final List<CareAutopilotSuggestion> suggestions;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final highCount = suggestions.where((s) => s.urgency == SuggestionUrgency.high).length;
    final headerColor = highCount > 0 ? scheme.error : scheme.tertiary;

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_fix_high_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: headerColor.withValues(alpha: 0.8),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.careAutopilotTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (highCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BotanicaTokens.spacingXs,
                    vertical: BotanicaTokens.spacingMicro,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(BotanicaTokens.radiusPill),
                  ),
                  child: Text(
                    l10n.careAutopilotUrgent(highCount),
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          BotanicaGaps.vSm,
          ...suggestions.take(3).map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      _urgencyIcon(s.urgency),
                      size: 14,
                      color: _urgencyColor(s.urgency, scheme)
                          .withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${s.plantNickname}: ${_humanizeKey(s.titleKey)}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (suggestions.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n.careAutopilotMore(suggestions.length - 3),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _urgencyIcon(SuggestionUrgency urgency) {
    switch (urgency) {
      case SuggestionUrgency.high:
        return Icons.priority_high_rounded;
      case SuggestionUrgency.medium:
        return Icons.info_outline_rounded;
      case SuggestionUrgency.low:
        return Icons.lightbulb_outline_rounded;
    }
  }

  static Color _urgencyColor(SuggestionUrgency urgency, ColorScheme scheme) {
    switch (urgency) {
      case SuggestionUrgency.high:
        return scheme.error;
      case SuggestionUrgency.medium:
        return scheme.primary;
      case SuggestionUrgency.low:
        return scheme.tertiary;
    }
  }

  static String _humanizeKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceFirst(RegExp(r'^autopilot_'), '')
        .replaceFirst(RegExp(r'_title$'), '');
  }
}
