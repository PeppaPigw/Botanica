import 'package:flutter/material.dart';

import '../../app/theme/botanica_glass_theme.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/haptics/botanica_haptics.dart';
import '../../core/widgets/botanica_button.dart';
import '../../core/widgets/botanica_gaps.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/scheduling.dart';
import '../../gen/l10n/app_localizations.dart';

class SnoozeOption {
  const SnoozeOption({
    required this.icon,
    required this.label,
    required this.computeTarget,
  });

  final IconData icon;
  final String label;
  final DateTime Function(DateTime, ReminderTimePreference) computeTarget;
}

Future<DateTime?> showSnoozeSheet({
  required BuildContext context,
  required ReminderTimePreference reminderPref,
}) async {
  return showBotanicaModalSheet<DateTime?>(
    context: context,
    builder: (_) => _SnoozeSheet(reminderPref: reminderPref),
  );
}

class _SnoozeSheet extends StatelessWidget {
  const _SnoozeSheet({required this.reminderPref});

  final ReminderTimePreference reminderPref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final options = [
      SnoozeOption(
        icon: Icons.schedule_rounded,
        label: l10n.tasksSnoozeOneHour,
        computeTarget: (now, _) => now.add(const Duration(hours: 1)),
      ),
      SnoozeOption(
        icon: Icons.schedule_rounded,
        label: l10n.tasksSnoozeThreeHours,
        computeTarget: (now, _) => now.add(const Duration(hours: 3)),
      ),
      SnoozeOption(
        icon: Icons.wb_sunny_rounded,
        label: l10n.tasksSnoozeTomorrowMorning,
        computeTarget: _tomorrowMorning,
      ),
      SnoozeOption(
        icon: Icons.weekend_rounded,
        label: l10n.tasksSnoozeWeekend,
        computeTarget: _weekend,
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: BotanicaTokens.pagePadding,
          child: BotanicaGlassCard(
            tier: GlassTier.primary,
            padding: BotanicaTokens.cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.snooze_rounded,
                      color: scheme.primary,
                      size: BotanicaTokens.iconSizeMd,
                    ),
                    BotanicaGaps.hSm,
                    Text(
                      l10n.gardenQuickSnooze,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                BotanicaGaps.vBase,
                ...options.map((opt) {
                  final target =
                      opt.computeTarget(DateTime.now(), reminderPref);
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: BotanicaTokens.spacingXxs,
                    ),
                    child: _SnoozeOptionTile(
                      option: opt,
                      target: target,
                      onTap: () {
                        BotanicaHaptics.selectionTick();
                        Navigator.of(context).pop(
                          opt.computeTarget(DateTime.now(), reminderPref),
                        );
                      },
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: BotanicaTokens.spacingXxs,
                  ),
                  child: _CustomSnoozeOptionTile(
                    label: l10n.tasksSnoozeCustomTime,
                    target: DateTime.now().add(const Duration(hours: 1)),
                    onTap: () => _pickCustomTime(context),
                  ),
                ),
                const SizedBox(height: BotanicaTokens.spacingSm),
                SizedBox(
                  width: double.infinity,
                  child: BotanicaButton(
                    variant: BotanicaButtonVariant.text,
                    label: l10n.commonCancel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Duration _durationToWeekend(DateTime from) {
    var days = 1;
    var currentDay = from.weekday;
    while (true) {
      currentDay = (currentDay % 7) + 1;
      if (currentDay == DateTime.saturday || currentDay == DateTime.sunday) {
        break;
      }
      days++;
    }
    return Duration(days: days);
  }

  DateTime _tomorrowMorning(DateTime now, ReminderTimePreference _) =>
      localWallClockDateTime(
        year: now.year,
        month: now.month,
        day: now.day + 1,
        hour: 9,
      );

  DateTime _weekend(DateTime now, ReminderTimePreference pref) =>
      alignToReminderTime(
        addLocalCalendarDays(now, _durationToWeekend(now).inDays),
        pref,
      );

  Future<void> _pickCustomTime(BuildContext context) async {
    BotanicaHaptics.selectionTick();
    final now = DateTime.now();
    final initial = now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !context.mounted) return;

    var target = localWallClockDateTime(
      year: date.year,
      month: date.month,
      day: date.day,
      hour: time.hour,
      minute: time.minute,
    );
    if (!target.isAfter(now)) {
      target = now.add(const Duration(minutes: 1));
    }
    Navigator.of(context).pop(target);
  }
}

class _SnoozeOptionTile extends StatelessWidget {
  const _SnoozeOptionTile({
    required this.option,
    required this.target,
    required this.onTap,
  });

  final SnoozeOption option;
  final DateTime target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: BotanicaTokens.cardPaddingDense,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.22),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.36),
            ),
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                color: scheme.primary.withValues(alpha: 0.8),
                size: BotanicaTokens.iconSizeMd,
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    BotanicaGaps.vMicro,
                    Text(
                      formatSnoozeTarget(context, target),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: 0.4),
                size: BotanicaTokens.iconSizeMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomSnoozeOptionTile extends StatelessWidget {
  const _CustomSnoozeOptionTile({
    required this.label,
    required this.target,
    required this.onTap,
  });

  final String label;
  final DateTime target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: BotanicaTokens.cardPaddingDense,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.22),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.36),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit_calendar_rounded,
                color: scheme.primary.withValues(alpha: 0.8),
                size: BotanicaTokens.iconSizeMd,
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    BotanicaGaps.vMicro,
                    Text(
                      formatSnoozeTarget(context, target),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: 0.4),
                size: BotanicaTokens.iconSizeMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatSnoozeTarget(BuildContext context, DateTime target) {
  final material = MaterialLocalizations.of(context);
  return '${material.formatMediumDate(target)} · '
      '${material.formatTimeOfDay(TimeOfDay.fromDateTime(target))}';
}
