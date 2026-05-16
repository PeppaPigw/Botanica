import 'package:flutter/material.dart';

import '../../gen/l10n/app_localizations.dart';
import '../haptics/botanica_haptics.dart';
import 'botanica_button.dart';
import 'botanica_celebration.dart';
import 'botanica_gaps.dart';
import 'botanica_sheet.dart';

class BotanicaPlantAnniversarySheet {
  BotanicaPlantAnniversarySheet._();

  static Future<void> show(
    BuildContext context, {
    required String plantName,
    required int milestoneDays,
  }) {
    BotanicaHaptics.milestone();
    BotanicaCelebration.show(context);

    return showBotanicaModalSheet<void>(
      context: context,
      useSafeArea: false,
      builder: (_) => _AnniversaryBody(
        plantName: plantName,
        milestoneDays: milestoneDays,
      ),
    );
  }
}

class _AnniversaryBody extends StatelessWidget {
  const _AnniversaryBody({
    required this.plantName,
    required this.milestoneDays,
  });

  final String plantName;
  final int milestoneDays;

  IconData get _icon => milestoneDays >= 365
      ? Icons.emoji_events_rounded
      : milestoneDays >= 180
          ? Icons.park_rounded
          : milestoneDays >= 90
              ? Icons.local_florist_rounded
              : Icons.eco_rounded;

  String _bodyText(AppLocalizations l10n) {
    if (milestoneDays >= 365) return l10n.plantAnniversaryBody365;
    if (milestoneDays >= 180) return l10n.plantAnniversaryBody180;
    if (milestoneDays >= 90) return l10n.plantAnniversaryBody90;
    return l10n.plantAnniversaryBody30;
  }

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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withValues(alpha: 0.2),
                  scheme.tertiary.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Icon(_icon, size: 32, color: scheme.primary),
          ),
          BotanicaGaps.vMd,
          Text(
            l10n.plantAnniversaryTitle(plantName),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vSm,
          Text(
            _bodyText(l10n),
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
              expand: true,
              label: l10n.plantAnniversaryDismiss,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
