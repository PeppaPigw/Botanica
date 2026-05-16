import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/smart_notification_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaSmartNotificationCard extends StatelessWidget {
  const BotanicaSmartNotificationCard({
    super.key,
    required this.notification,
  });

  final SmartNotification notification;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (IconData icon, Color color) = _iconAndColor(notification.type, scheme);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          BotanicaGaps.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _titleText(notification),
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _bodyText(notification),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static (IconData, Color) _iconAndColor(SmartNotificationType type, ColorScheme scheme) {
    return switch (type) {
      SmartNotificationType.streakEncouragement => (Icons.local_fire_department_rounded, const Color(0xFFFF9800)),
      SmartNotificationType.neglectWarning => (Icons.warning_rounded, scheme.error),
      SmartNotificationType.batchOpportunity => (Icons.group_work_rounded, scheme.primary),
      SmartNotificationType.comebackWelcome => (Icons.waving_hand_rounded, scheme.tertiary),
      SmartNotificationType.perfectWeekCelebration => (Icons.celebration_rounded, const Color(0xFF66BB6A)),
      SmartNotificationType.milestoneApproaching => (Icons.flag_rounded, const Color(0xFF9C27B0)),
      SmartNotificationType.seasonalReminder => (Icons.wb_sunny_rounded, const Color(0xFFFF9800)),
      SmartNotificationType.rhythmChange => (Icons.show_chart_rounded, scheme.secondary),
    };
  }

  static String _titleText(SmartNotification n) {
    return n.titleKey
        .replaceAll('notification_', '')
        .replaceAll('_', ' ')
        .replaceFirstMapped(RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());
  }

  static String _bodyText(SmartNotification n) {
    return n.bodyKey
        .replaceAll('notification_', '')
        .replaceAll('_', ' ')
        .replaceFirstMapped(RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());
  }
}
