import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/growth_journal_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaGrowthJournalCard extends StatelessWidget {
  const BotanicaGrowthJournalCard({
    super.key,
    required this.summary,
  });

  final MonthlyGrowthSummary summary;

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.menu_book_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.growthJournalTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                summary.moodEmoji,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          BotanicaGaps.vXxs,
          Text(
            '${summary.plantNickname} • ${_monthName(summary.month)} ${summary.year}',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          BotanicaGaps.vSm,
          Row(
            children: [
              _JournalStat(
                icon: Icons.touch_app_rounded,
                value: '${summary.totalCareActions}',
                label: 'actions',
                scheme: scheme,
              ),
              BotanicaGaps.hSm,
              _JournalStat(
                icon: Icons.photo_library_rounded,
                value: '${summary.photoCount}',
                label: 'photos',
                scheme: scheme,
              ),
              BotanicaGaps.hSm,
              _JournalStat(
                icon: Icons.star_rounded,
                value: '${summary.highlights.length}',
                label: 'highlights',
                scheme: scheme,
              ),
            ],
          ),
          if (summary.highlights.isNotEmpty) ...[
            BotanicaGaps.vSm,
            ...summary.highlights.take(2).map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      BotanicaGaps.hXxs,
                      Expanded(
                        child: Text(
                          h.description,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  static String _monthName(int month) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][month.clamp(1, 12)];
}

class _JournalStat extends StatelessWidget {
  const _JournalStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.scheme,
  });

  final IconData icon;
  final String value;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: scheme.primary.withValues(alpha: 0.7)),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 9,
                ),
          ),
        ],
      ),
    );
  }
}