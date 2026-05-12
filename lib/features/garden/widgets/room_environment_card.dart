import 'package:flutter/material.dart';

import '../../../app/theme/botanica_glass_theme.dart';
import '../../../app/theme/botanica_tokens.dart';
import '../../../core/widgets/botanica_gaps.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/user_settings.dart';
import '../../../gen/l10n/app_localizations.dart';

class RoomEnvironmentCard extends StatelessWidget {
  const RoomEnvironmentCard({
    super.key,
    required this.temperatureC,
    required this.humidity,
    required this.lightLevel,
    required this.settings,
  });

  final double temperatureC;
  final double humidity;
  final LightLevel lightLevel;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final lightLabel = switch (lightLevel) {
      LightLevel.low => l10n.envLightLow,
      LightLevel.medium => l10n.envLightMedium,
      LightLevel.high => l10n.envLightHigh,
    };

    final isFahrenheit = settings.temperatureUnit == TemperatureUnit.fahrenheit;
    final tempDisplay =
        isFahrenheit ? (temperatureC * 9 / 5) + 32 : temperatureC;
    final tempUnitStr = isFahrenheit ? '°F' : '°C';
    final tempString = '${tempDisplay.toStringAsFixed(1)}$tempUnitStr';

    final lightFraction = switch (lightLevel) {
          LightLevel.low => 1.0,
          LightLevel.medium => 2.0,
          LightLevel.high => 3.0,
        } /
        3.0;

    return BotanicaGlassCard(
      tier: GlassTier.subtle,
      padding: BotanicaTokens.cardPaddingDense,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildGauge(
              context,
              icon: Icons.thermostat_rounded,
              value: tempString,
              label: l10n.envLabelTemp,
              fillColor: scheme.primary,
              fillFraction: (temperatureC - 10) / 30.0,
            ),
          ),
          _buildVerticalDivider(scheme),
          Expanded(
            child: _buildGauge(
              context,
              icon: Icons.water_drop_rounded,
              value: '${(humidity * 100).toInt()}%',
              label: l10n.envLabelHumidity,
              fillColor: scheme.secondary,
              fillFraction: humidity,
            ),
          ),
          _buildVerticalDivider(scheme),
          Expanded(
            child: _buildGauge(
              context,
              icon: Icons.wb_sunny_rounded,
              value: lightLabel,
              label: l10n.envLabelLight,
              fillColor: scheme.tertiary,
              fillFraction: lightFraction,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(ColorScheme scheme) {
    return Container(
      width: 1,
      height: 32,
      color: scheme.outlineVariant.withValues(alpha: 0.5),
    );
  }

  Widget _buildGauge(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color fillColor,
    required double fillFraction,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: BotanicaTokens.iconSizeXs, color: scheme.onSurfaceVariant),
            BotanicaGaps.hMicro,
            Flexible(
              child: Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        BotanicaGaps.vMicro,
        Text(
          value,
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        BotanicaGaps.vXs,
        Container(
          height: 4,
          width: 48,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fillFraction.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
