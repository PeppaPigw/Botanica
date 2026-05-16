import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_button.dart';
import 'botanica_gaps.dart';
import 'botanica_sheet.dart';

class BotanicaRescueResetSheet {
  BotanicaRescueResetSheet._();

  static Future<String?> show(
    BuildContext context, {
    required int previousStreak,
    required int daysMissed,
  }) {
    return showBotanicaModalSheet<String>(
      context: context,
      useSafeArea: false,
      builder: (ctx) => _RescueResetBody(
        previousStreak: previousStreak,
        daysMissed: daysMissed,
      ),
    );
  }
}

class _RescueResetBody extends StatelessWidget {
  const _RescueResetBody({
    required this.previousStreak,
    required this.daysMissed,
  });

  final int previousStreak;
  final int daysMissed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaSheetBody(
      top: 16,
      bottom: 24,
      includeKeyboardInset: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF81C784).withValues(alpha: 0.3),
                  scheme.primaryContainer.withValues(alpha: 0.5),
                ],
              ),
            ),
            child: Icon(
              Icons.spa_rounded,
              size: 40,
              color: scheme.primary.withValues(alpha: 0.85),
            ),
          ),
          BotanicaGaps.vMd,
          Text(
            l10n.rescueResetTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vSm,
          Text(
            l10n.rescueResetBody(previousStreak, daysMissed),
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vLg,
          SizedBox(
            width: double.infinity,
            child: BotanicaButton(
              label: l10n.rescueResetWaterNow,
              icon: Icons.water_drop_rounded,
              onPressed: () => Navigator.of(context).pop('water'),
            ),
          ),
          BotanicaGaps.vXxs,
          SizedBox(
            width: double.infinity,
            child: BotanicaButton(
              label: l10n.rescueResetFreshStart,
              icon: Icons.refresh_rounded,
              variant: BotanicaButtonVariant.outlined,
              onPressed: () => Navigator.of(context).pop('fresh'),
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingXs),
        ],
      ),
    );
  }
}
