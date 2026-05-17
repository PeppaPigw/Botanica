import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/next_action_recommender.dart';
import '../../gen/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    final (IconData icon, Color color, String title, String subtitle) =
        _actionVisual(action, scheme, l10n);

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
      RecommendedAction action, ColorScheme scheme, AppLocalizations l10n) {
    final plant = action.plantNickname;
    return switch (action.type) {
      ActionType.waterOverdue => (
          Icons.water_drop_rounded,
          scheme.error,
          l10n.nextActionWaterOverdue(plant),
          l10n.nextActionWaterOverdueSub,
        ),
      ActionType.waterToday => (
          Icons.water_drop_rounded,
          const Color(0xFF42A5F5),
          l10n.nextActionWaterToday(plant),
          l10n.nextActionWaterTodaySub,
        ),
      ActionType.takePhoto => (
          Icons.camera_alt_rounded,
          scheme.tertiary,
          l10n.nextActionTakePhoto,
          l10n.nextActionTakePhotoSub(plant),
        ),
      ActionType.checkNewPlant => (
          Icons.visibility_rounded,
          const Color(0xFF66BB6A),
          l10n.nextActionCheckNewPlant(plant),
          l10n.nextActionCheckNewPlantSub,
        ),
      ActionType.fertilize => (
          Icons.science_rounded,
          const Color(0xFFFFA726),
          l10n.nextActionFertilize(plant),
          l10n.nextActionFertilizeSub,
        ),
      ActionType.celebrate => (
          Icons.celebration_rounded,
          scheme.tertiary,
          l10n.nextActionCelebrate,
          l10n.nextActionCelebrateSub,
        ),
      ActionType.explore => (
          Icons.explore_rounded,
          scheme.primary,
          l10n.nextActionExplore,
          l10n.nextActionExploreSub,
        ),
      ActionType.rest => (
          Icons.spa_rounded,
          const Color(0xFF66BB6A),
          l10n.nextActionRest,
          l10n.nextActionRestSub,
        ),
    };
  }
}
