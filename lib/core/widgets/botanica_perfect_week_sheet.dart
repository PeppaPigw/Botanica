import 'package:flutter/material.dart';

import '../../gen/l10n/app_localizations.dart';
import '../haptics/botanica_haptics.dart';
import 'botanica_button.dart';
import 'botanica_celebration.dart';
import 'botanica_gaps.dart';
import 'botanica_sheet.dart';

class BotanicaPerfectWeekSheet {
  BotanicaPerfectWeekSheet._();

  static Future<void> show(BuildContext context, {required int weeks}) {
    BotanicaHaptics.milestone();
    BotanicaCelebration.show(context);

    return showBotanicaModalSheet<void>(
      context: context,
      useSafeArea: false,
      builder: (ctx) => _PerfectWeekBody(weeks: weeks),
    );
  }
}

class _PerfectWeekBody extends StatelessWidget {
  const _PerfectWeekBody({required this.weeks});

  final int weeks;

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
                  scheme.primary.withValues(alpha: 0.15),
                  scheme.tertiary.withValues(alpha: 0.15),
                ],
              ),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 44,
              color: scheme.primary,
            ),
          ),
          BotanicaGaps.vMd,
          Text(
            l10n.perfectWeekTitle(weeks),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vSm,
          Text(
            weeks == 1 ? l10n.perfectWeekBody : l10n.perfectWeekBodyRepeat(weeks),
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
              label: l10n.perfectWeekDismiss,
              icon: Icons.emoji_events_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
