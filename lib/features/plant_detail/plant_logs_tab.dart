import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/haptics/botanica_haptics.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/enums.dart';
import '../../gen/l10n/app_localizations.dart';

class PlantLogsTab extends ConsumerWidget {
  const PlantLogsTab({super.key, required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final logsRepo = ref.read(logsRepositoryProvider);

    return StreamBuilder(
      stream: logsRepo.watchForPlant(plantId),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const <CareLog>[];
        return ListView(
          padding: BotanicaTokens.pagePadding.copyWith(bottom: 120),
          children: [
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: BotanicaTokens.iconSizeLg + BotanicaTokens.spacingMd,
                      color: scheme.onSurface.withValues(alpha: 0.35),
                    ),
                    BotanicaGaps.vSm,
                    Text(
                      l10n.plantDetailLogsEmptyTitle,
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    BotanicaGaps.vXxs,
                    Text(
                      l10n.plantDetailLogsEmptyBody,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _CareSparkline(logs: logs),
              BotanicaGaps.vSm,
              ...logs.map(
                (log) => _LogCard(log: log),
              ),
              if (logs.length >= 3 &&
                  !logs.any((l) => l.note != null))
                Padding(
                  padding: const EdgeInsets.only(
                    top: BotanicaTokens.spacingSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14,
                        color: scheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.careLogAddNote,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

IconData _iconForTask(TaskType type) => switch (type) {
      TaskType.water => Icons.water_drop_rounded,
      TaskType.fertilize => Icons.science_rounded,
      TaskType.mist => Icons.blur_on_rounded,
      TaskType.rotate => Icons.rotate_right_rounded,
      TaskType.prune => Icons.content_cut_rounded,
      TaskType.repot => Icons.local_florist_rounded,
      TaskType.checkPests => Icons.bug_report_rounded,
      TaskType.wipeLeaves => Icons.cleaning_services_rounded,
      TaskType.sunlightAdjustment => Icons.wb_sunny_rounded,
    };

String _taskTypeLabel(AppLocalizations l10n, TaskType type) => switch (type) {
      TaskType.water => l10n.taskTypeWater,
      TaskType.fertilize => l10n.taskTypeFertilize,
      TaskType.mist => l10n.taskTypeMist,
      TaskType.rotate => l10n.taskTypeRotate,
      TaskType.prune => l10n.taskTypePrune,
      TaskType.repot => l10n.taskTypeRepot,
      TaskType.checkPests => l10n.taskTypeCheckPests,
      TaskType.wipeLeaves => l10n.taskTypeWipeLeaves,
      TaskType.sunlightAdjustment => l10n.taskTypeSunlightAdjustment,
    };

class _LogCard extends ConsumerWidget {
  const _LogCard({required this.log});

  final CareLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: '${_taskTypeLabel(l10n, log.type)}, '
            '${MaterialLocalizations.of(context).formatShortMonthDay(log.timestamp)}'
            '${log.note != null ? ', ${l10n.careLogEditNote}' : ', ${l10n.careLogAddNote}'}',
        child: GestureDetector(
          onTap: () => _editNote(context, ref),
          child: BotanicaGlassCard(
            padding: BotanicaTokens.cardPaddingDense,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                  Icon(
                    _iconForTask(log.type),
                    color: scheme.onSurface.withValues(alpha: 0.78),
                  ),
                  BotanicaGaps.hSm,
                  Expanded(
                    child: Text(
                      '${_taskTypeLabel(l10n, log.type)} · ${MaterialLocalizations.of(context).formatShortMonthDay(log.timestamp)}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    log.note != null
                        ? Icons.sticky_note_2_rounded
                        : Icons.add_comment_outlined,
                    size: 16,
                    color: scheme.onSurface.withValues(
                      alpha: log.note != null ? 0.6 : 0.3,
                    ),
                  ),
                ],
              ),
              if (log.note != null && log.note!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    log.note!,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _editNote(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await showBotanicaModalSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _NoteEditorSheet(
        initialNote: log.note,
      ),
    );
    if (result == null) return;
    final updated = log.copyWith(note: result.isEmpty ? null : result);
    await ref.read(logsRepositoryProvider).add(updated);
    if (!context.mounted) return;
    BotanicaHaptics.completion();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.careLogNoteSaved),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _NoteEditorSheet extends StatefulWidget {
  const _NoteEditorSheet({this.initialNote});

  final String? initialNote;

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: BotanicaTokens.spacingMd,
        right: BotanicaTokens.spacingMd,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            BotanicaTokens.spacingXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialNote != null
                ? l10n.careLogEditNote
                : l10n.careLogAddNote,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingMd),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.careLogNoteHint,
              filled: true,
              fillColor: scheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BotanicaTokens.radiusM),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: BotanicaTokens.spacingMd),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_controller.text.trim()),
              child: Text(
                widget.initialNote != null
                    ? l10n.careLogEditNote
                    : l10n.careLogAddNote,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareSparkline extends StatelessWidget {
  const _CareSparkline({required this.logs});

  final List<CareLog> logs;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const days = 14;

    final counts = List<int>.filled(days, 0);
    for (final log in logs) {
      final diff = today.difference(
        DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day),
      ).inDays;
      if (diff >= 0 && diff < days) {
        counts[days - 1 - diff]++;
      }
    }

    final totalActions = counts.fold<int>(0, (sum, c) => sum + c);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 16,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.plantDetailLogsSparklineTitle,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                l10n.plantDetailLogsSparklineCount(totalActions),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            child: CustomPaint(
              size: const Size(double.infinity, 32),
              painter: _SparklinePainter(
                counts: counts,
                barColor: scheme.primary,
                emptyColor: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '14d',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
              Text(
                l10n.commonToday,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.counts,
    required this.barColor,
    required this.emptyColor,
  });

  final List<int> counts;
  final Color barColor;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final maxCount = counts.fold<int>(1, (m, c) => c > m ? c : m);
    final barWidth = (size.width - (counts.length - 1) * 3) / counts.length;
    final radius = Radius.circular(barWidth / 2);

    for (int i = 0; i < counts.length; i++) {
      final x = i * (barWidth + 3);
      final count = counts[i];
      final fraction = count / maxCount;
      final barHeight = (fraction * size.height).clamp(3.0, size.height);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
        radius,
      );

      final paint = Paint()
        ..color = count > 0
            ? barColor.withValues(alpha: 0.4 + 0.6 * fraction)
            : emptyColor;

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      counts != oldDelegate.counts ||
      barColor != oldDelegate.barColor;
}
