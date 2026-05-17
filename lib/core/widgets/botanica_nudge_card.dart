import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/nudge_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaNudgeCard extends StatelessWidget {
  const BotanicaNudgeCard({
    super.key,
    required this.nudges,
  });

  final List<CareNudge> nudges;

  @override
  Widget build(BuildContext context) {
    if (nudges.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.notifications_active_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.tertiary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.gentleNudgesTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...nudges.take(3).map((n) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _priorityIcon(n.priority),
                      size: 14,
                      color: _priorityColor(n.priority, scheme),
                    ),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.plantNickname,
                            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            n.messageKey,
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                            maxLines: 1,
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

  static IconData _priorityIcon(NudgePriority p) => switch (p) {
        NudgePriority.high => Icons.priority_high_rounded,
        NudgePriority.medium => Icons.info_outline_rounded,
        NudgePriority.low => Icons.lightbulb_outline_rounded,
      };

  static Color _priorityColor(NudgePriority p, ColorScheme scheme) => switch (p) {
        NudgePriority.high => scheme.error,
        NudgePriority.medium => const Color(0xFFFFA726),
        NudgePriority.low => scheme.tertiary,
      };
}
