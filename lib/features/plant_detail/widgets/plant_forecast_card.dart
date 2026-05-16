import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/intelligence_providers.dart';
import '../../../app/theme/botanica_tokens.dart';
import '../../../domain/services/plant_health_forecaster.dart';
import '../../../core/widgets/glass_card.dart';

class PlantForecastCard extends ConsumerWidget {
  const PlantForecastCard({super.key, required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecast = ref.watch(plantForecastProvider(plantId));
    if (forecast == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (icon, color, label) = _forecastVisuals(forecast.forecast, scheme);

    return BotanicaGlassCard(
      accentColor: color.withValues(alpha: 0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: BotanicaTokens.spacingXs),
              Text(
                _forecastTitle(forecast.forecast),
                style: textTheme.titleSmall?.copyWith(color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BotanicaTokens.spacingXs,
                  vertical: BotanicaTokens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
                ),
                child: Text(
                  '${(forecast.confidence * 100).round()}%',
                  style: textTheme.labelSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          Text(
            _forecastDescription(forecast),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
            child: LinearProgressIndicator(
              value: forecast.confidence,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.6)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _forecastVisuals(
      HealthForecast forecast, ColorScheme scheme) {
    return switch (forecast) {
      HealthForecast.improving => (
          Icons.trending_up_rounded,
          Colors.green,
          'Improving',
        ),
      HealthForecast.stable => (
          Icons.horizontal_rule_rounded,
          scheme.primary,
          'Stable',
        ),
      HealthForecast.declining => (
          Icons.trending_down_rounded,
          Colors.orange,
          'Declining',
        ),
      HealthForecast.atRisk => (
          Icons.warning_amber_rounded,
          Colors.red,
          'At Risk',
        ),
    };
  }

  String _forecastTitle(HealthForecast forecast) {
    return switch (forecast) {
      HealthForecast.improving => 'Health Improving',
      HealthForecast.stable => 'Health Stable',
      HealthForecast.declining => 'Health Declining',
      HealthForecast.atRisk => 'Needs Attention',
    };
  }

  String _forecastDescription(PlantHealthForecastResult forecast) {
    final days = forecast.daysUntilChange;
    final factor = _factorLabel(forecast.primaryFactor);

    return switch (forecast.forecast) {
      HealthForecast.improving =>
        'Your care is paying off. $factor Keep it up!',
      HealthForecast.stable =>
        'Consistent care is keeping this plant healthy. Next check in $days days.',
      HealthForecast.declining =>
        '$factor Consider adjusting your routine within $days days.',
      HealthForecast.atRisk =>
        '$factor This plant needs attention in the next $days days.',
    };
  }

  String _factorLabel(String factor) {
    return switch (factor) {
      'increasedCare' => 'You\'ve been caring more frequently.',
      'decreasedCare' => 'Care frequency has dropped recently.',
      'manyOverdue' => 'Several tasks are overdue.',
      'overdueTask' => 'There\'s an overdue task.',
      'longGap' => 'It\'s been a while since last care.',
      'careGap' => 'There\'s a gap in recent care.',
      'diverseCare' => 'You\'re providing varied care types.',
      'consistentCare' => 'Care has been steady.',
      _ => '',
    };
  }
}
