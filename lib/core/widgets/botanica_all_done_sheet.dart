import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/task_instance.dart';
import '../../gen/l10n/app_localizations.dart';
import '../haptics/botanica_haptics.dart';
import '../i18n/task_labels.dart';
import 'botanica_button.dart';
import 'botanica_celebration.dart';
import 'botanica_gaps.dart';
import 'botanica_sheet.dart';

class BotanicaAllDoneSheet {
  BotanicaAllDoneSheet._();

  static Future<void> show(BuildContext context) {
    BotanicaHaptics.allDone();
    BotanicaCelebration.show(context);

    return showBotanicaModalSheet<void>(
      context: context,
      useSafeArea: false,
      builder: (ctx) => const _AllDoneBody(),
    );
  }
}

class _AllDoneBody extends ConsumerWidget {
  const _AllDoneBody();

  String _rotatingBody(AppLocalizations l10n) {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final messages = [
      l10n.gardenAllTasksDoneBody,
      l10n.gardenAllDoneBody2,
      l10n.gardenAllDoneBody3,
      l10n.gardenAllDoneBody4,
      l10n.gardenAllDoneBody5,
    ];
    return messages[dayOfYear % messages.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final settings = ref.watch(settingsControllerProvider);
    final logsAsync = ref.watch(careLogsStreamProvider);
    final logs = logsAsync.valueOrNull ?? const [];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayCount = logs.where((l) => !l.timestamp.isBefore(todayStart)).length;

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
                  scheme.primaryContainer,
                  scheme.tertiaryContainer,
                ],
              ),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 44,
              color: scheme.primary,
            ),
          ),
          BotanicaGaps.vMd,
          Text(
            l10n.gardenAllTasksDoneTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          BotanicaGaps.vSm,
          Text(
            _rotatingBody(l10n),
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (todayCount > 0 || settings.careStreakDays > 0) ...[
            BotanicaGaps.vMd,
            Wrap(
              spacing: BotanicaTokens.spacingXs,
              runSpacing: BotanicaTokens.spacingXxs,
              alignment: WrapAlignment.center,
              children: [
                if (todayCount > 0)
                  _AllDoneChip(
                    icon: Icons.task_alt_rounded,
                    label: l10n.gardenWeeklyCareActions(todayCount),
                    color: scheme.primary,
                  ),
                if (settings.careStreakDays > 0)
                  _AllDoneChip(
                    icon: Icons.local_fire_department_rounded,
                    label: l10n.gardenCareStreakChip(settings.careStreakDays),
                    color: Colors.orange,
                  ),
              ],
            ),
          ],
          BotanicaGaps.vMd,
          _NextUpPeek(todayStart: todayStart),
          BotanicaGaps.vLg,
          SizedBox(
            width: double.infinity,
            child: BotanicaButton(
              label: l10n.gardenAllCaughtUp,
              icon: Icons.spa_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingXs),
        ],
      ),
    );
  }
}

class _NextUpPeek extends ConsumerWidget {
  const _NextUpPeek({required this.todayStart});

  final DateTime todayStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tasks = ref.watch(tasksStreamProvider).valueOrNull ?? const <TaskInstance>[];
    final plants = ref.watch(plantsStreamProvider).valueOrNull ?? const <Plant>[];
    final plantsById = <String, Plant>{for (final p in plants) p.id: p};

    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final tomorrowEnd = tomorrowStart.add(const Duration(days: 1));

    final tomorrowTasks = tasks
        .where((t) =>
            !t.isDismissed &&
            !t.dueAt.isBefore(tomorrowStart) &&
            t.dueAt.isBefore(tomorrowEnd))
        .toList();

    if (tomorrowTasks.isEmpty) {
      final nextTask = tasks
          .where((t) => !t.isDismissed && t.dueAt.isAfter(todayStart))
          .toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

      final daysUntilNext = nextTask.isEmpty
          ? null
          : nextTask.first.dueAt.difference(todayStart).inDays;

      if (daysUntilNext == null || daysUntilNext <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BotanicaTokens.spacingMd,
          vertical: BotanicaTokens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: BotanicaTokens.spacingXxs),
            Text(
              l10n.allDoneQuietRunway(daysUntilNext),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    final previewTasks = tomorrowTasks.take(3).toList();
    final plantNames = previewTasks
        .map((t) => plantsById[t.plantId]?.nickname ?? '')
        .where((n) => n.isNotEmpty)
        .toSet()
        .take(2)
        .join(' + ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BotanicaTokens.spacingSm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: BotanicaTokens.spacingXxs),
              Text(
                l10n.allDoneTomorrowPreview(tomorrowTasks.length, plantNames),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: BotanicaTokens.spacingXxs),
          ...previewTasks.map((t) {
            final plant = plantsById[t.plantId];
            return Padding(
              padding: const EdgeInsets.only(
                left: 22,
                top: 2,
              ),
              child: Text(
                '${taskTypeLabel(l10n, t.type)} ${plant?.nickname ?? ''}',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AllDoneChip extends StatelessWidget {
  const _AllDoneChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BotanicaTokens.spacingSm,
        vertical: BotanicaTokens.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusPill),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}
