import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_vital_signs_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaPlantVitalsCard extends StatelessWidget {
  const BotanicaPlantVitalsCard({
    super.key,
    required this.dashboard,
  });

  final PlantDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    if (dashboard.vitalSigns.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final statusColor = _statusColor(dashboard.overallStatus, scheme);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_heart_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: statusColor,
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'Vital Signs',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (dashboard.careStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BotanicaTokens.spacingXs,
                    vertical: BotanicaTokens.spacingMicro,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
                  ),
                  child: Text(
                    '${dashboard.careStreak}d streak',
                    style: textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          BotanicaGaps.vSm,
          ...dashboard.vitalSigns.map((vital) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingXxs),
                child: _VitalRow(vital: vital, scheme: scheme),
              )),
          BotanicaGaps.vXxs,
          Row(
            children: [
              Icon(
                _nextActionIcon(dashboard.nextAction),
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  _nextActionLabel(dashboard),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _statusColor(String status, ColorScheme scheme) {
    return switch (status) {
      'vitalStatusThriving' => scheme.tertiary,
      'vitalStatusHealthy' => scheme.primary,
      'vitalStatusNeedsAttention' => const Color(0xFFFFA726),
      _ => scheme.error,
    };
  }

  static IconData _nextActionIcon(String action) {
    return switch (action) {
      'vitalActionWaterNow' => Icons.water_drop_rounded,
      'vitalActionWaterSoon' => Icons.schedule_rounded,
      _ => Icons.check_circle_rounded,
    };
  }

  static String _nextActionLabel(PlantDashboard d) {
    return switch (d.nextAction) {
      'vitalActionWaterNow' => 'Water now',
      'vitalActionWaterSoon' => 'Water in ${d.daysUntilNextCare}d',
      _ => 'All good — next care in ${d.daysUntilNextCare}d',
    };
  }
}

class _VitalRow extends StatelessWidget {
  const _VitalRow({required this.vital, required this.scheme});

  final PlantVitalSign vital;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final color = _vitalColor(vital.status, scheme);
    final trendIcon = vital.trend > 0
        ? Icons.trending_up_rounded
        : vital.trend < 0
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            _capitalize(vital.name),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
            child: LinearProgressIndicator(
              value: vital.value,
              minHeight: 4,
              backgroundColor: scheme.outlineVariant.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        BotanicaGaps.hXs,
        Icon(trendIcon, size: 12, color: color),
      ],
    );
  }

  static Color _vitalColor(String status, ColorScheme scheme) {
    return switch (status) {
      'vitalGood' => scheme.primary,
      'vitalFair' => const Color(0xFFFFA726),
      _ => scheme.error,
    };
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
