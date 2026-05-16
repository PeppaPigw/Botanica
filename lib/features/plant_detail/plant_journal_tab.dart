import 'dart:async';
import 'dart:io';

import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/i18n/task_labels.dart' as task_labels;
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/botanica_timeline_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/diary_entry.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/photo_entry.dart';
import '../../domain/models/plant.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/journal/journal_actions.dart';
import '../journal/diary_share_card_screen.dart';
import '../journal/photo_compare_screen.dart';
import '../journal/photo_share_card_screen.dart';
import '../journal/photo_viewer_screen.dart';
import '../journal/widgets/journal_photo_unavailable.dart';

abstract class _JournalEvent {
  DateTime get timestamp;
}

class _PhotoEvent implements _JournalEvent {
  final PhotoEntry item;
  _PhotoEvent(this.item);

  @override
  DateTime get timestamp => item.createdAt;
}

class _DiaryEvent implements _JournalEvent {
  final DiaryEntry item;
  _DiaryEvent(this.item);

  @override
  DateTime get timestamp => item.createdAt;
}

class _CareEvent implements _JournalEvent {
  final CareLog item;
  _CareEvent(this.item);

  @override
  DateTime get timestamp => item.timestamp;
}

enum _PhotoJournalAction { open, compare, share, delete }

enum _DiaryJournalAction { view, edit, share, delete }

class PlantJournalTab extends ConsumerWidget {
  const PlantJournalTab({
    super.key,
    required this.plant,
    required this.onAddPhoto,
    required this.onAddNote,
  });

  final Plant plant;
  final VoidCallback onAddPhoto;
  final VoidCallback onAddNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final photosRepo = ref.read(photosRepositoryProvider);
    final diaryRepo = ref.read(diaryRepositoryProvider);
    final logsRepo = ref.read(logsRepositoryProvider);

    return StreamBuilder(
      stream: diaryRepo.watchForPlant(plant.id),
      builder: (context, diarySnapshot) {
        final diaryEntries = diarySnapshot.data ?? const <DiaryEntry>[];

        return StreamBuilder(
          stream: photosRepo.watchForPlant(plant.id),
          builder: (context, photosSnapshot) {
            final photos = photosSnapshot.data ?? const [];

            return StreamBuilder(
              stream: logsRepo.watchForPlant(plant.id),
              builder: (context, logsSnapshot) {
                final logs = logsSnapshot.data ?? const <CareLog>[];

                final events = <_JournalEvent>[];
                final photoEvents = <_PhotoEvent>[];
                for (final p in photos) {
                  final ev = _PhotoEvent(p);
                  events.add(ev);
                  photoEvents.add(ev);
                }
                for (final d in diaryEntries) {
                  events.add(_DiaryEvent(d));
                }
                for (final log in logs) {
                  events.add(_CareEvent(log));
                }
                events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                photoEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                final nextPhotoMap = <String, PhotoEntry>{};
                for (int i = 0; i < photoEvents.length - 1; i++) {
                  nextPhotoMap[photoEvents[i].item.id] =
                      photoEvents[i + 1].item;
                }

                Widget buildEventCard(_JournalEvent ev, int index) {
                  final isFirst = index == 0;
                  final isLast = index == events.length - 1;

                  if (ev is _PhotoEvent) {
                    final p = ev.item;
                    final compareCandidate = nextPhotoMap[p.id];

                    return BotanicaTimelineCard(
                      key: ValueKey('journal-photo-${p.id}'),
                      isFirst: isFirst,
                      isLast: isLast,
                      icon: Icons.photo_camera_rounded,
                      title: l10n.journalPhotoMeta(p.createdAt),
                      subtitle: (p.note ?? '').trim().isEmpty
                          ? l10n.journalPhotoNoNote
                          : p.note!.trim(),
                      trailingIcon: Icons.more_horiz_rounded,
                      trailingTooltip:
                          MaterialLocalizations.of(context).showMenuTooltip,
                      onTap: () => PhotoViewerScreen.open(
                        context,
                        entry: p,
                        compareCandidate: compareCandidate,
                        title: l10n.journalPhotoTitle,
                      ),
                      leading: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(BotanicaTokens.radiusL),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Image.file(
                            File(p.filePath),
                            cacheWidth: 112,
                            cacheHeight: 112,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) =>
                                const JournalPhotoUnavailable(compact: true),
                          ),
                        ),
                      ),
                      onTrailingTap: () => _showPhotoActions(
                        context,
                        ref,
                        plant,
                        entry: p,
                        compareCandidate: compareCandidate,
                      ),
                    );
                  } else if (ev is _DiaryEvent) {
                    final e = ev.item;

                    return BotanicaTimelineCard(
                      key: ValueKey('journal-diary-${e.id}'),
                      isFirst: isFirst,
                      isLast: isLast,
                      icon: Icons.edit_note_rounded,
                      title: l10n
                          .journalPhotoMeta(e.createdAt), // re-using date format
                      subtitle: l10n.diaryEntryTitle,
                      body: Text(
                        e.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                          height: 1.35,
                        ),
                      ),
                      onTap: () => _editDiaryEntry(context, ref, e),
                      trailingIcon: Icons.more_horiz_rounded,
                      trailingTooltip:
                          MaterialLocalizations.of(context).showMenuTooltip,
                      onTrailingTap: () => _showDiaryActions(
                        context,
                        ref,
                        entry: e,
                      ),
                    );
                  } else if (ev is _CareEvent) {
                    final log = ev.item;
                    final note = log.note?.trim();

                    return BotanicaTimelineCard(
                      key: ValueKey('journal-care-${log.id}'),
                      isFirst: isFirst,
                      isLast: isLast,
                      icon: _iconForTask(log.type),
                      title: _taskTypeLabel(l10n, log.type),
                      subtitle: l10n.journalPhotoMeta(log.timestamp),
                      body: note == null || note.isEmpty
                          ? null
                          : Text(
                              note,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.72),
                                height: 1.35,
                              ),
                            ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final growthEcho = _growthEchoInsight(photos);

                final timelineItems = <Widget>[];
                for (int i = 0; i < events.length; i++) {
                  final ev = events[i];
                  if (i == 0 ||
                      !_isSameYearMonth(
                        ev.timestamp,
                        events[i - 1].timestamp,
                      )) {
                    timelineItems.add(_MonthHeader(date: ev.timestamp));
                  }
                  timelineItems.add(buildEventCard(ev, i));
                }

                return ListView(
                  padding: BotanicaTokens.pagePadding.copyWith(bottom: 120),
                  children: [
                    BotanicaGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.auto_stories_rounded,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.80),
                              ),
                              BotanicaGaps.hSm,
                              Expanded(
                                child: Text(
                                  l10n.plantDetailJournalIntro,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.72),
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          BotanicaGaps.vSm,
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: onAddPhoto,
                                  icon: const Icon(Icons.add_a_photo_rounded),
                                  label: Text(l10n.journalAddPhotoTitle),
                                ),
                              ),
                              BotanicaGaps.hSm,
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: onAddNote,
                                  icon: const Icon(Icons.edit_note_rounded),
                                  label: Text(l10n.diaryAddEntryButton),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        BotanicaTokens.radiusXL,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (growthEcho != null) ...[
                      BotanicaGaps.vSm,
                      _GrowthEchoCard(
                        plant: plant,
                        insight: growthEcho,
                        onAddPhoto: onAddPhoto,
                        onCompare: () => PhotoCompareScreen.open(
                          context,
                          beforePath: growthEcho.previous!.filePath,
                          afterPath: growthEcho.latest.filePath,
                          title: l10n.journalCompareTitle,
                        ),
                      ),
                    ],
                    BotanicaGaps.vBase,
                    Text(
                      l10n.diarySectionTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    BotanicaGaps.vSm,
                    if (events.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timeline_rounded,
                              size: BotanicaTokens.iconSizeLg +
                                  BotanicaTokens.spacingMicro,
                              color: scheme.onSurface.withValues(alpha: 0.35),
                            ),
                            BotanicaGaps.hSm,
                            Expanded(
                              child: Text(
                                l10n.diaryEmptyBody,
                                style: textTheme.bodyMedium?.copyWith(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.60),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...timelineItems,
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

IconData _iconForTask(TaskType type) => task_labels.iconForTask(type);

String _taskTypeLabel(AppLocalizations l10n, TaskType type) =>
    task_labels.taskTypeLabel(l10n, type);

bool _isSameYearMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final monthLabel = MaterialLocalizations.of(context).formatMonthYear(date);

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        monthLabel,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface.withValues(alpha: 0.55),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

enum _GrowthEchoMode { compare, capture }

class _GrowthEchoInsight {
  const _GrowthEchoInsight.compare({
    required this.latest,
    required this.previous,
    required this.daysApart,
  })  : mode = _GrowthEchoMode.compare;

  const _GrowthEchoInsight.capture({
    required this.latest,
    required this.daysApart,
  })  : mode = _GrowthEchoMode.capture,
        previous = null;

  final _GrowthEchoMode mode;
  final PhotoEntry latest;
  final PhotoEntry? previous;
  final int daysApart;
}

_GrowthEchoInsight? _growthEchoInsight(List<PhotoEntry> photos) {
  if (photos.isEmpty) return null;

  final sorted = [...photos]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final latest = sorted.first;

  if (sorted.length >= 2) {
    final previous = sorted[1];
    final days = latest.createdAt.difference(previous.createdAt).inDays.abs();
    if (days >= 10) {
      return _GrowthEchoInsight.compare(
        latest: latest,
        previous: previous,
        daysApart: days,
      );
    }
  }

  final daysSinceLatest = DateTime.now().difference(latest.createdAt).inDays;
  if (daysSinceLatest >= 14) {
    return _GrowthEchoInsight.capture(
      latest: latest,
      daysApart: daysSinceLatest,
    );
  }

  return null;
}

class _GrowthEchoCard extends StatelessWidget {
  const _GrowthEchoCard({
    required this.plant,
    required this.insight,
    required this.onAddPhoto,
    required this.onCompare,
  });

  final Plant plant;
  final _GrowthEchoInsight insight;
  final VoidCallback onAddPhoto;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final isCompare = insight.mode == _GrowthEchoMode.compare;
    final title = isCompare
        ? l10n.growthEchoCompareTitle
        : l10n.growthEchoCaptureTitle;
    final body = isCompare
        ? l10n.growthEchoCompareBody(plant.nickname, insight.daysApart)
        : l10n.growthEchoCaptureBody(insight.daysApart, plant.nickname);
    final icon =
        isCompare ? Icons.auto_awesome_rounded : Icons.add_a_photo_rounded;
    final ctaLabel =
        isCompare ? l10n.journalCompareTitle : l10n.journalAddPhotoTitle;
    final onTap = isCompare ? onCompare : onAddPhoto;

    return BotanicaGlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BotanicaTokens.radiusXL),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer.withValues(alpha: 0.5),
              ),
              child: Icon(icon, size: 20, color: scheme.primary),
            ),
            BotanicaGaps.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    body,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            BotanicaGaps.hSm,
            Text(
              ctaLabel,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPhotoActions(
  BuildContext context,
  WidgetRef ref,
  Plant plant, {
  required PhotoEntry entry,
  required PhotoEntry? compareCandidate,
}) async {
  final l10n = AppLocalizations.of(context);
  final action = await showBotanicaModalSheet<_PhotoJournalAction>(
    context: context,
    builder: (sheetContext) => BotanicaSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetTitle(title: l10n.journalEntryActions),
          ListTile(
            key: ValueKey('journal-photo-action-open-${entry.id}'),
            leading: const Icon(Icons.open_in_full_rounded),
            title: Text(l10n.journalPhotoTitle),
            onTap: () =>
                Navigator.of(sheetContext).pop(_PhotoJournalAction.open),
          ),
          if (compareCandidate != null)
            ListTile(
              key: ValueKey('journal-photo-action-compare-${entry.id}'),
              leading: const Icon(Icons.compare_rounded),
              title: Text(l10n.journalCompareTitle),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_PhotoJournalAction.compare),
            ),
          ListTile(
            key: ValueKey('journal-photo-action-share-${entry.id}'),
            leading: const Icon(Icons.ios_share_rounded),
            title: Text(l10n.dailyShare),
            onTap: () =>
                Navigator.of(sheetContext).pop(_PhotoJournalAction.share),
          ),
          ListTile(
            key: ValueKey('journal-photo-action-delete-${entry.id}'),
            leading: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(sheetContext).colorScheme.error,
            ),
            title: Text(
              l10n.deletePlantConfirm,
              style: TextStyle(color: Theme.of(sheetContext).colorScheme.error),
            ),
            onTap: () =>
                Navigator.of(sheetContext).pop(_PhotoJournalAction.delete),
          ),
        ],
      ),
    ),
  );

  if (!context.mounted || action == null) return;

  switch (action) {
    case _PhotoJournalAction.open:
      await PhotoViewerScreen.open(
        context,
        entry: entry,
        compareCandidate: compareCandidate,
        title: l10n.journalPhotoTitle,
      );
    case _PhotoJournalAction.compare:
      final candidate = compareCandidate;
      if (candidate == null) return;
      await PhotoCompareScreen.open(
        context,
        beforePath: candidate.filePath,
        afterPath: entry.filePath,
        title: l10n.journalCompareTitle,
      );
    case _PhotoJournalAction.share:
      await PhotoShareCardScreen.open(context, entry: entry);
    case _PhotoJournalAction.delete:
      final confirmed = await _confirmDelete(
        context,
        title: l10n.journalPhotoDeleteTitle,
        body: l10n.journalPhotoDeleteBody,
      );
      if (!context.mounted || !confirmed) return;

      final messenger = ScaffoldMessenger.of(context);
      final plantsRepository = ref.read(plantsRepositoryProvider);
      final photosRepository = ref.read(photosRepositoryProvider);
      Future<void>? undoFuture;

      await JournalActions.removePhotoEntry(
        entry: entry,
        plant: plant,
        plantsRepository: plantsRepository,
        photosRepository: photosRepository,
      );

      if (!messenger.mounted) {
        await JournalActions.deletePhotoFile(entry: entry);
        return;
      }

      final controller = messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.journalPhotoDeleted),
          action: SnackBarAction(
            label: l10n.commonUndo,
            onPressed: () {
              undoFuture = JournalActions.restorePhotoEntry(
                entry: entry,
                plant: plant,
                plantsRepository: plantsRepository,
                photosRepository: photosRepository,
              );
            },
          ),
        ),
      );

      final reason = await controller.closed;
      if (reason == SnackBarClosedReason.action) {
        final pendingUndo = undoFuture;
        if (pendingUndo != null) {
          await pendingUndo;
        }
        return;
      }
      await JournalActions.deletePhotoFile(entry: entry);
  }
}

Future<void> _showDiaryActions(
  BuildContext context,
  WidgetRef ref, {
  required DiaryEntry entry,
}) async {
  final l10n = AppLocalizations.of(context);
  final action = await showBotanicaModalSheet<_DiaryJournalAction>(
    context: context,
    builder: (sheetContext) => BotanicaSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetTitle(title: l10n.journalEntryActions),
          ListTile(
            key: ValueKey('journal-diary-action-view-${entry.id}'),
            leading: const Icon(Icons.article_rounded),
            title: Text(l10n.diaryEntryTitle),
            onTap: () =>
                Navigator.of(sheetContext).pop(_DiaryJournalAction.view),
          ),
          ListTile(
            key: ValueKey('journal-diary-action-edit-${entry.id}'),
            leading: const Icon(Icons.edit_rounded),
            title: Text(l10n.commonEdit),
            onTap: () =>
                Navigator.of(sheetContext).pop(_DiaryJournalAction.edit),
          ),
          ListTile(
            key: ValueKey('journal-diary-action-share-${entry.id}'),
            leading: const Icon(Icons.ios_share_rounded),
            title: Text(l10n.dailyShare),
            onTap: () =>
                Navigator.of(sheetContext).pop(_DiaryJournalAction.share),
          ),
          ListTile(
            key: ValueKey('journal-diary-action-delete-${entry.id}'),
            leading: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(sheetContext).colorScheme.error,
            ),
            title: Text(
              l10n.deletePlantConfirm,
              style: TextStyle(color: Theme.of(sheetContext).colorScheme.error),
            ),
            onTap: () =>
                Navigator.of(sheetContext).pop(_DiaryJournalAction.delete),
          ),
        ],
      ),
    ),
  );

  if (!context.mounted || action == null) return;

  switch (action) {
    case _DiaryJournalAction.view:
      await _showDiaryEntry(context, entry);
    case _DiaryJournalAction.edit:
      await _editDiaryEntry(context, ref, entry);
    case _DiaryJournalAction.share:
      await DiaryShareCardScreen.open(context, entry: entry);
    case _DiaryJournalAction.delete:
      final confirmed = await _confirmDelete(
        context,
        title: l10n.diaryEntryDeleteTitle,
        body: l10n.diaryEntryDeleteBody,
      );
      if (!context.mounted || !confirmed) return;

      final diaryRepository = ref.read(diaryRepositoryProvider);
      await JournalActions.deleteDiaryEntry(
        entry: entry,
        diaryRepository: diaryRepository,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.diaryEntryDeleted),
          action: SnackBarAction(
            label: l10n.commonUndo,
            onPressed: () => unawaited(diaryRepository.add(entry)),
          ),
        ),
      );
  }
}

Future<void> _editDiaryEntry(
  BuildContext context,
  WidgetRef ref,
  DiaryEntry entry,
) async {
  final l10n = AppLocalizations.of(context);
  final text = await _promptForDiaryEdit(context, entry.text);
  if (!context.mounted || text == null) return;
  if (text == entry.text.trim()) return;

  final confirmed = await _confirmDiaryEdit(context);
  if (!context.mounted || !confirmed) return;

  await JournalActions.updateDiaryEntry(
    entry: entry,
    text: text,
    diaryRepository: ref.read(diaryRepositoryProvider),
  );

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(l10n.diaryEntryUpdated),
    ),
  );
}

Future<void> _showDiaryEntry(BuildContext context, DiaryEntry entry) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return showBotanicaModalSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BotanicaSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.diaryEntryTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          BotanicaGaps.vTiny,
          Text(
            l10n.journalPhotoMeta(entry.createdAt),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          BotanicaGaps.vSm,
          Text(
            entry.text,
            style: textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
        ],
      ),
    ),
  );
}

Future<String?> _promptForDiaryEdit(
  BuildContext context,
  String initialText,
) {
  final l10n = AppLocalizations.of(context);

  return showBotanicaModalSheet<String?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    builder: (_) => _DiaryEditSheet(
      title: l10n.diaryEditEntryTitle,
      hint: l10n.diaryAddEntryHint,
      initialText: initialText,
    ),
  );
}

Future<bool> _confirmDelete(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            l10n.deletePlantConfirm,
            style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<bool> _confirmDiaryEdit(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.diaryEditConfirmTitle),
      content: Text(l10n.diaryEditConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.commonSave),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        bottom: 8,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _DiaryEditSheet extends StatefulWidget {
  const _DiaryEditSheet({
    required this.title,
    required this.hint,
    required this.initialText,
  });

  final String title;
  final String hint;
  final String initialText;

  @override
  State<_DiaryEditSheet> createState() => _DiaryEditSheetState();
}

class _DiaryEditSheetState extends State<_DiaryEditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentText = _controller.text.trim();
    final canSave =
        currentText.isNotEmpty && currentText != widget.initialText.trim();

    return BotanicaSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          BotanicaGaps.vSm,
          TextField(
            key: const ValueKey('journal-diary-edit-field'),
            controller: _controller,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          BotanicaGaps.vBase,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(l10n.commonCancel),
                ),
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: FilledButton(
                  onPressed: canSave
                      ? () => Navigator.of(context).pop(currentText)
                      : null,
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
