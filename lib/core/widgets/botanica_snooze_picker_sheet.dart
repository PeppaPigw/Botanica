import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/models/enums.dart';
import '../../gen/l10n/app_localizations.dart';
import 'botanica_sheet.dart';

Future<SnoozeDuration?> showBotanicaSnoozePicker({
  required BuildContext context,
}) {
  return showBotanicaModalSheet<SnoozeDuration>(
    context: context,
    builder: (context) => const _SnoozeDurationPicker(),
  );
}

class _SnoozeDurationPicker extends StatelessWidget {
  const _SnoozeDurationPicker();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final timeFmt = DateFormat.jm(Localizations.localeOf(context).toString());

    String preview(SnoozeDuration d) {
      final target = switch (d) {
        SnoozeDuration.oneHour => now.add(const Duration(hours: 1)),
        SnoozeDuration.threeHours => now.add(const Duration(hours: 3)),
        SnoozeDuration.tomorrow => now.add(const Duration(days: 1)),
        SnoozeDuration.tomorrowMorning => DateTime(
            now.year, now.month, now.day + 1, 8),
        SnoozeDuration.weekend => () {
            var t = now;
            while (t.weekday != DateTime.saturday) {
              t = t.add(const Duration(days: 1));
            }
            return DateTime(t.year, t.month, t.day, 9);
          }(),
      };
      final dayFmt = DateFormat.E(Localizations.localeOf(context).toString());
      return '${dayFmt.format(target)} ${timeFmt.format(target)}';
    }

    final options = [
      (SnoozeDuration.oneHour, l10n.tasksSnoozeOneHour, Icons.timer_outlined),
      (SnoozeDuration.threeHours, l10n.tasksSnoozeThreeHours, Icons.timer_3_outlined),
      (SnoozeDuration.tomorrow, l10n.tasksSnoozeTomorrow, Icons.wb_sunny_outlined),
      (SnoozeDuration.tomorrowMorning, l10n.tasksSnoozeTomorrowMorning, Icons.light_mode_outlined),
      (SnoozeDuration.weekend, l10n.tasksSnoozeWeekend, Icons.weekend_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.only(
        left: BotanicaTokens.spacingMd,
        right: BotanicaTokens.spacingMd,
        bottom: BotanicaTokens.spacingXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.gardenQuickSnooze,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingMd),
          ...options.map((opt) => _SnoozeOption(
                duration: opt.$1,
                label: opt.$2,
                icon: opt.$3,
                timePreview: preview(opt.$1),
                scheme: scheme,
                textTheme: textTheme,
              )),
        ],
      ),
    );
  }
}

class _SnoozeOption extends StatelessWidget {
  const _SnoozeOption({
    required this.duration,
    required this.label,
    required this.icon,
    required this.timePreview,
    required this.scheme,
    required this.textTheme,
  });

  final SnoozeDuration duration;
  final String label;
  final IconData icon;
  final String timePreview;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
      onTap: () => Navigator.of(context).pop(duration),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: BotanicaTokens.spacingSm,
          horizontal: BotanicaTokens.spacingSm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: scheme.onSurfaceVariant),
            const SizedBox(width: BotanicaTokens.spacingSm),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            Text(
              timePreview,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
