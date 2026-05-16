import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/next_action_recommender.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaNextActionCard extends StatelessWidget {
  const BotanicaNextActionCard({
    super.key,
    required this.action,
    this.onTap,
  });

  final RecommendedAction action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (IconData icon, Color color, String title, String subtitle) =
        _actionVisual(action, scheme);

    return BotanicaGlassCard(
      tier: GlassTier.primary,
      padding: BotanicaTokens.cardPaddingDense,
      accentColor: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            BotanicaGaps.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }

  static (IconData, Color, String, String) _actionVisual(
      RecommendedAction action, ColorScheme scheme) {
    return switch (action.type) {
      ActionType.waterOverdue => (
          Icons.water_drop_rounded,
          scheme.error,
          'Water ${action.plantNickname}',
          'Overdue — needs attention now',
        ),
      ActionType.waterToday => (
          Icons.water_drop_rounded,
          const Color(0xFF42A5F5),
          'Water ${action.plantNickname}',
          'Scheduled for today',
        ),
      ActionType.takePhoto => (
          Icons.camera_alt_rounded,
          scheme.tertiary,
          'Photo time',
          'Capture ${action.plantNickname}\'s progress',
        ),
      ActionType.checkNewPlant => (
          Icons.visibility_rounded,
          const Color(0xFF66BB6A),
          'Check on ${action.plantNickname}',
          'New plant — getting to know each other',
        ),
      ActionType.fertilize => (
          Icons.science_rounded,
          const Color(0xFFFFA726),
          'Fertilize ${action.plantNickname}',
          'Coming up in the next few days',
        ),
      ActionType.celebrate => (
          Icons.celebration_rounded,
          scheme.tertiary,
          'Celebrate your streak!',
          'You\'re doing amazing',
        ),
      ActionType.explore => (
          Icons.explore_rounded,
          scheme.primary,
          'Explore new plants',
          'Start your plant journey',
        ),
      ActionType.rest => (
          Icons.spa_rounded,
          const Color(0xFF66BB6A),
          'All caught up!',
          'Your garden is happy — enjoy the moment',
        ),
    };
  }
}
