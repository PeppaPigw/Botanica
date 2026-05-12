import 'dart:io';

import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/photo_entry.dart';
import '../../gen/l10n/app_localizations.dart';
import 'photo_compare_screen.dart';
import 'photo_share_card_screen.dart';
import 'widgets/journal_photo_unavailable.dart';

class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({
    super.key,
    required this.entry,
    required this.compareCandidate,
    required this.title,
  });

  final PhotoEntry entry;
  final PhotoEntry? compareCandidate;
  final String title;

  static Future<void> open(
    BuildContext context, {
    required PhotoEntry entry,
    required PhotoEntry? compareCandidate,
    required String title,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          entry: entry,
          compareCandidate: compareCandidate,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => PhotoShareCardScreen.open(
              context,
              entry: entry,
            ),
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: l10n.dailyShare,
          ),
          if (compareCandidate != null)
            IconButton(
              onPressed: () => PhotoCompareScreen.open(
                context,
                beforePath: compareCandidate!.filePath,
                afterPath: entry.filePath,
                title: l10n.journalCompareTitle,
              ),
              icon: const Icon(Icons.compare_rounded),
              tooltip: l10n.journalCompareTitle,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: BotanicaTokens.pagePadding.copyWith(bottom: 18),
          child: Column(
            children: [
              Expanded(
                child: BotanicaGlassCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(BotanicaTokens.radiusXL),
                    child: Semantics(
                      image: true,
                      label: title,
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 3.2,
                        child: Image.file(
                          File(entry.filePath),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) =>
                              const JournalPhotoUnavailable(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              BotanicaGaps.vSm,
              Row(
                children: [
                  Icon(Icons.event_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.70)),
                  BotanicaGaps.hSm,
                  Expanded(
                    child: Text(
                      l10n.journalPhotoMeta(entry.createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.72),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
              if ((entry.note ?? '').trim().isNotEmpty) ...[
                BotanicaGaps.vXs,
                Row(
                  children: [
                    Icon(Icons.notes_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.70)),
                    BotanicaGaps.hSm,
                    Expanded(
                      child: Text(
                        entry.note!.trim(),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
