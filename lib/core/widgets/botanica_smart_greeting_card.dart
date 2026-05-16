import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/smart_greeting_engine.dart';
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

    final (String text, IconData icon) = _greetingContent(greeting);

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

  static (String, IconData) _greetingContent(SmartGreeting g) {
    return switch (g.messageKey) {
      'greetingMorning' => ('Good morning! Your plants are waiting.', Icons.wb_sunny_rounded),
      'greetingAfternoon' => ('Good afternoon! Time for a garden check.', Icons.wb_cloudy_rounded),
      'greetingEvening' => ('Good evening! Wind down with your plants.', Icons.nightlight_round),
      'greetingStreak' => ('${g.args['days']}-day streak! Keep it up.', Icons.local_fire_department_rounded),
      'greetingRainy' => ('Rainy day — your outdoor plants are happy.', Icons.water_drop_rounded),
      'greetingNewPlant' => ('How\'s ${g.args['plant']} settling in?', Icons.spa_rounded),
      'greetingProductiveDay' => ('Productive day! Your garden thanks you.', Icons.star_rounded),
      'greetingEarlyBird' => ('Early bird! Plants love morning care.', Icons.alarm_rounded),
      'greetingLateNight' => ('Late night check on your ${g.args['count']} plants.', Icons.bedtime_rounded),
      'greetingBigGarden' => ('${g.args['count']} plants strong! Impressive.', Icons.park_rounded),
      _ => ('Welcome back to your garden.', Icons.eco_rounded),
    };
  }
}
