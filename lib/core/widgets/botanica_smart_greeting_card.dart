import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/smart_greeting_engine.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_gaps.dart';

class BotanicaSmartGreetingCard extends StatelessWidget {
  const BotanicaSmartGreetingCard({
    super.key,
    required this.greeting,
  });

  final SmartGreeting greeting;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final (String text, IconData icon) = _greetingContent(greeting, l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary.withValues(alpha: 0.7)),
          BotanicaGaps.hXs,
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static (String, IconData) _greetingContent(SmartGreeting g, AppLocalizations l10n) {
    return switch (g.messageKey) {
      'greetingMorning' => (l10n.smartGreetingMorning, Icons.wb_sunny_rounded),
      'greetingAfternoon' => (l10n.smartGreetingAfternoon, Icons.wb_cloudy_rounded),
      'greetingEvening' => (l10n.smartGreetingEvening, Icons.nightlight_round),
      'greetingStreak' => (l10n.smartGreetingStreak(g.args['days'] ?? ''), Icons.local_fire_department_rounded),
      'greetingRainy' => (l10n.smartGreetingRainy, Icons.water_drop_rounded),
      'greetingNewPlant' => (l10n.smartGreetingNewPlant(g.args['plant'] ?? ''), Icons.spa_rounded),
      'greetingProductiveDay' => (l10n.smartGreetingProductive, Icons.star_rounded),
      'greetingEarlyBird' => (l10n.smartGreetingEarlyBird, Icons.alarm_rounded),
      'greetingLateNight' => (l10n.smartGreetingLateNight(g.args['count'] ?? ''), Icons.bedtime_rounded),
      'greetingBigGarden' => (l10n.smartGreetingBigGarden(g.args['count'] ?? ''), Icons.park_rounded),
      _ => (l10n.smartGreetingDefault, Icons.eco_rounded),
    };
  }
}
