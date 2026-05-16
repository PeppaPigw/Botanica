import 'package:flutter/material.dart';

import '../../features/profile/streak_share_card_screen.dart';
import '../../gen/l10n/app_localizations.dart';
import '../haptics/botanica_haptics.dart';
import 'botanica_button.dart';
import 'botanica_celebration.dart';
import 'botanica_gaps.dart';
import 'botanica_sheet.dart';
import 'botanica_streak_badge.dart';

class BotanicaStreakMilestoneSheet {
  BotanicaStreakMilestoneSheet._();

  static Future<void> show(BuildContext context, {required int milestone}) {
    BotanicaHaptics.streakCelebration();
    BotanicaCelebration.show(context);

    return showBotanicaModalSheet<void>(
      context: context,
      useSafeArea: false,
      builder: (ctx) => _MilestoneBody(milestone: milestone),
    );
  }
}

class _MilestoneBody extends StatelessWidget {
  const _MilestoneBody({required this.milestone});

  final int milestone;

  String _body(AppLocalizations l10n) => switch (milestone) {
        7 => l10n.streakMilestoneBody7,
        30 => l10n.streakMilestoneBody30,
        90 => l10n.streakMilestoneBody90,
        365 => l10n.streakMilestoneBody365,
        _ => l10n.streakMilestoneBody7,
      };

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
          BotanicaStreakBadge(streakDays: milestone, size: 80),
          BotanicaGaps.vMd,
          Text(
            l10n.streakMilestoneTitle(milestone),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vSm,
          Text(
            _body(l10n),
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
              label: l10n.streakMilestoneDismiss,
              icon: Icons.local_fire_department_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          BotanicaGaps.vSm,
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                StreakShareCardScreen.open(
                  context,
                  streakDays: milestone,
                  plantCount: 0,
                );
              },
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(l10n.streakShareButton),
            ),
          ),
        ],
      ),
    );
  }
}
