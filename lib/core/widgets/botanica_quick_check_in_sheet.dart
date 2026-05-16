import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/haptics/botanica_haptics.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../domain/models/plant.dart';
import '../../domain/services/quick_check_in.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaQuickCheckInSheet {
  BotanicaQuickCheckInSheet._();

  static Future<QuickCheckInResponse?> show(
    BuildContext context, {
    required Plant plant,
  }) {
    BotanicaHaptics.selectionTick();
    return showBotanicaModalSheet<QuickCheckInResponse>(
      context: context,
      useSafeArea: false,
      builder: (ctx) => _CheckInBody(plant: plant),
    );
  }
}

class _CheckInBody extends StatelessWidget {
  const _CheckInBody({required this.plant});

  final Plant plant;

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
          Text(
            l10n.quickCheckInTitle(plant.nickname),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vXs,
          Text(
            l10n.quickCheckInSubtitle,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ResponseOption(
                emoji: '🌿',
                label: l10n.quickCheckInThriving,
                color: Colors.green,
                onTap: () => Navigator.of(context).pop(
                  QuickCheckInResponse.thriving,
                ),
              ),
              _ResponseOption(
                emoji: '🌱',
                label: l10n.quickCheckInOkay,
                color: scheme.tertiary,
                onTap: () => Navigator.of(context).pop(
                  QuickCheckInResponse.okay,
                ),
              ),
              _ResponseOption(
                emoji: '🥀',
                label: l10n.quickCheckInWorried,
                color: scheme.error,
                onTap: () => Navigator.of(context).pop(
                  QuickCheckInResponse.worried,
                ),
              ),
            ],
          ),
          BotanicaGaps.vMd,
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.commonSkip,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseOption extends StatelessWidget {
  const _ResponseOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        BotanicaHaptics.selectionTick();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingXxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.75),
                ),
          ),
        ],
      ),
    );
  }
}
