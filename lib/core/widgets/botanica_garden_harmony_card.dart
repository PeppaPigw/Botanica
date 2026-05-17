import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/garden_harmony_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaGardenHarmonyCard extends StatelessWidget {
  const BotanicaGardenHarmonyCard({
    super.key,
    required this.result,
  });

  final GardenHarmonyResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final levelColor = _levelColor(result.level, scheme);
    final trendIcon = switch (result.trend) {
      HarmonyTrend.improving => Icons.trending_up_rounded,
      HarmonyTrend.stable => Icons.trending_flat_rounded,
      HarmonyTrend.declining => Icons.trending_down_rounded,
    };

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      accentColor: levelColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.balance_rounded,
                size: BotanicaTokens.iconSizeMd,
                color: levelColor,
              ),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.gardenHarmonyTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(trendIcon, size: 16, color: levelColor),
              BotanicaGaps.hXs,
              Text(
                '${(result.overallScore * 100).round()}%',
                style: textTheme.labelSmall?.copyWith(
                  color: levelColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          _HarmonyBar(
            label: 'Health',
            value: result.healthScore,
            color: levelColor,
            scheme: scheme,
          ),
          _HarmonyBar(
            label: 'Consistency',
            value: result.consistencyScore,
            color: levelColor,
            scheme: scheme,
          ),
          _HarmonyBar(
            label: 'Diversity',
            value: result.diversityScore,
            color: levelColor,
            scheme: scheme,
          ),
          _HarmonyBar(
            label: 'Engagement',
            value: result.engagementScore,
            color: levelColor,
            scheme: scheme,
          ),
          BotanicaGaps.vXxs,
          Text(
            _levelLabel(result.level),
            style: textTheme.labelSmall?.copyWith(
              color: levelColor,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static Color _levelColor(HarmonyLevel level, ColorScheme scheme) {
    return switch (level) {
      HarmonyLevel.thriving => scheme.tertiary,
      HarmonyLevel.balanced => scheme.primary,
      HarmonyLevel.developing => const Color(0xFFFFA726),
      HarmonyLevel.needsAttention => scheme.error,
    };
  }

  static String _levelLabel(HarmonyLevel level) {
    return switch (level) {
      HarmonyLevel.thriving => 'Your garden is thriving in harmony',
      HarmonyLevel.balanced => 'A well-balanced garden ecosystem',
      HarmonyLevel.developing => 'Growing towards balance',
      HarmonyLevel.needsAttention => 'Some areas need your attention',
    };
  }
}

class _HarmonyBar extends StatelessWidget {
  const _HarmonyBar({
    required this.label,
    required this.value,
    required this.color,
    required this.scheme,
  });

  final String label;
  final double value;
  final Color color;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: scheme.outlineVariant.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
