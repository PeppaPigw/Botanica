import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_anniversary_tracker.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaAnniversaryCard extends StatelessWidget {
  const BotanicaAnniversaryCard({
    super.key,
    required this.report,
  });

  final AnniversaryReport report;

  @override
  Widget build(BuildContext context) {
    if (report.today.isEmpty && report.upcoming.isEmpty) {
      return const SizedBox.shrink();
    }

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
              const Icon(Icons.cake_rounded,
                  size: BotanicaTokens.iconSizeMd, color: Color(0xFFE91E63)),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.plantAnniversariesTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (report.oldestPlantDays > 0)
                Text(
                  '${(report.oldestPlantDays / 365).toStringAsFixed(1)}y oldest',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          if (report.today.isNotEmpty) ...[
            BotanicaGaps.vSm,
            ...report.today.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                  padding: const EdgeInsets.all(BotanicaTokens.spacingXs),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration_rounded,
                          size: 14, color: Color(0xFFE91E63)),
                      BotanicaGaps.hXxs,
                      Expanded(
                        child: Text(
                          '${a.plantNickname} — ${a.years} year${a.years > 1 ? 's' : ''}!',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE91E63),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (report.upcoming.isNotEmpty) ...[
            BotanicaGaps.vSm,
            ...report.upcoming.take(3).map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                  child: Row(
                    children: [
                      Icon(Icons.event_rounded, size: 12,
                          color: scheme.onSurface.withValues(alpha: 0.4)),
                      BotanicaGaps.hXxs,
                      Expanded(
                        child: Text(
                          a.plantNickname,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'in ${a.daysUntil}d',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
