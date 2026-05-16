import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/daily_briefing_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaDailyBriefingCard extends StatelessWidget {
  const BotanicaDailyBriefingCard({
    super.key,
    required this.briefing,
    this.onItemTap,
  });

  final DailyBriefing briefing;
  final void Function(DailyBriefingItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaGlassCard(
      tier: GlassTier.primary,
      padding: BotanicaTokens.cardPaddingRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _BriefingHeader(
            momentumScore: briefing.momentumScore,
            burnoutRisk: briefing.burnoutRisk,
          ),
          BotanicaGaps.vSm,
          if (briefing.items.isNotEmpty) ...[
            ...briefing.items.map((item) => _BriefingItemTile(
                  item: item,
                  onTap: onItemTap != null ? () => onItemTap!(item) : null,
                )),
          ] else
            _EmptyBriefing(scheme: scheme, textTheme: textTheme),
        ],
      ),
    );
  }
}

class _BriefingHeader extends StatelessWidget {
  const _BriefingHeader({
    required this.momentumScore,
    required this.burnoutRisk,
  });

  final double momentumScore;
  final String burnoutRisk;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final momentumColor = momentumScore >= 0.7
        ? scheme.tertiary
        : momentumScore >= 0.4
            ? scheme.primary
            : scheme.error;

    return Row(
      children: [
        Icon(
          Icons.wb_sunny_rounded,
          color: scheme.primary.withValues(alpha: 0.85),
          size: BotanicaTokens.iconSizeLg,
        ),
        BotanicaGaps.hXs,
        Expanded(
          child: Text(
            'Daily Briefing',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        _MomentumPill(score: momentumScore, color: momentumColor),
      ],
    );
  }
}

class _MomentumPill extends StatelessWidget {
  const _MomentumPill({required this.score, required this.color});

  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingXs,
        vertical: BotanicaTokens.spacingMicro,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${(score * 100).round()}%',
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BriefingItemTile extends StatelessWidget {
  const _BriefingItemTile({required this.item, this.onTap});

  final DailyBriefingItem item;
  final VoidCallback? onTap;

  IconData _iconFor(String hint) => switch (hint) {
        'fire' => Icons.local_fire_department_rounded,
        'seedling' => Icons.eco_rounded,
        'warning' => Icons.warning_amber_rounded,
        'lightbulb' => Icons.lightbulb_outline_rounded,
        'heart' => Icons.favorite_rounded,
        'trophy' => Icons.emoji_events_rounded,
        _ => Icons.info_outline_rounded,
      };

  Color _accentFor(String type, ColorScheme scheme) => switch (type) {
        'burnout' => scheme.error,
        'healthAlert' => scheme.error,
        'momentum' => scheme.tertiary,
        'streakMilestone' => scheme.secondary,
        'insight' => scheme.primary,
        _ => scheme.onSurface,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = _accentFor(item.type, scheme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: BotanicaTokens.spacingXxs,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(BotanicaTokens.radiusS),
              ),
              child: Icon(
                _iconFor(item.iconHint),
                size: BotanicaTokens.iconSizeSm,
                color: accent,
              ),
            ),
            BotanicaGaps.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayTitle(item.titleKey),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _displayBody(item.bodyKey),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (item.actionKey != null)
              Icon(
                Icons.chevron_right_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }

  String _displayTitle(String key) => key
      .replaceAll('briefing', '')
      .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
      .trim();

  String _displayBody(String key) => key
      .replaceAll('briefing', '')
      .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
      .trim();
}

class _EmptyBriefing extends StatelessWidget {
  const _EmptyBriefing({required this.scheme, required this.textTheme});

  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BotanicaTokens.spacingSm),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: scheme.tertiary.withValues(alpha: 0.7),
            size: BotanicaTokens.iconSizeMd,
          ),
          BotanicaGaps.hSm,
          Text(
            'All caught up — your garden is thriving!',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
