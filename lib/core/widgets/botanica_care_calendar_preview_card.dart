import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/task_instance.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';

class BotanicaCareCalendarPreviewCard extends StatelessWidget {
  const BotanicaCareCalendarPreviewCard({
    super.key,
    required this.tasks,
    required this.plants,
  });

  final List<TaskInstance> tasks;
  final Map<String, String> plants;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    final weekTasks = tasks
        .where((t) => !t.isDone && t.dueAt.isAfter(today) && t.dueAt.isBefore(weekEnd))
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    if (weekTasks.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final dayBuckets = <int, List<TaskInstance>>{};
    for (final task in weekTasks) {
      final dayOffset = task.dueAt.difference(today).inDays;
      dayBuckets.putIfAbsent(dayOffset, () => []).add(task);
    }

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.date_range_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.primary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  'This Week',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${weekTasks.length} tasks',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          Row(
            children: List.generate(7, (i) {
              final dayTasks = dayBuckets[i] ?? [];
              final dayDate = today.add(Duration(days: i));
              final isToday = i == 0;

              return Expanded(
                child: _DayColumn(
                  label: _weekdayShort(dayDate.weekday),
                  taskCount: dayTasks.length,
                  isToday: isToday,
                  hasOverdue: dayTasks.any((t) => t.dueAt.isBefore(now)),
                  scheme: scheme,
                  textTheme: textTheme,
                ),
              );
            }),
          ),
          if (weekTasks.length <= 4) ...[
            BotanicaGaps.vSm,
            ...weekTasks.take(3).map((t) {
              final plantName = plants[t.plantId] ?? '';
              final daysUntil = t.dueAt.difference(today).inDays;
              final dayLabel = daysUntil == 0
                  ? 'today'
                  : daysUntil == 1
                      ? 'tomorrow'
                      : '${daysUntil}d';

              return Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: Row(
                  children: [
                    Icon(_taskIcon(t.type), size: 12,
                        color: scheme.onSurface.withValues(alpha: 0.5)),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        plantName,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      dayLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  static String _weekdayShort(int weekday) {
    return switch (weekday) {
      1 => 'M',
      2 => 'T',
      3 => 'W',
      4 => 'T',
      5 => 'F',
      6 => 'S',
      7 => 'S',
      _ => '?',
    };
  }

  static IconData _taskIcon(TaskType type) {
    return switch (type) {
      TaskType.water => Icons.water_drop_rounded,
      TaskType.fertilize => Icons.science_rounded,
      TaskType.mist => Icons.blur_on_rounded,
      TaskType.rotate => Icons.rotate_right_rounded,
      TaskType.repot => Icons.yard_rounded,
      TaskType.prune => Icons.content_cut_rounded,
      TaskType.checkPests => Icons.search_rounded,
      TaskType.wipeLeaves => Icons.cleaning_services_rounded,
      TaskType.sunlightAdjustment => Icons.wb_sunny_rounded,
    };
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.label,
    required this.taskCount,
    required this.isToday,
    required this.hasOverdue,
    required this.scheme,
    required this.textTheme,
  });

  final String label;
  final int taskCount;
  final bool isToday;
  final bool hasOverdue;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final dotColor = hasOverdue
        ? scheme.error
        : taskCount > 0
            ? scheme.primary
            : scheme.onSurface.withValues(alpha: 0.1);

    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: isToday
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.5),
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: taskCount > 0 ? dotColor.withValues(alpha: 0.15) : null,
            border: isToday
                ? Border.all(color: scheme.primary, width: 1.5)
                : null,
          ),
          child: Center(
            child: taskCount > 0
                ? Text(
                    '$taskCount',
                    style: textTheme.labelSmall?.copyWith(
                      color: dotColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
