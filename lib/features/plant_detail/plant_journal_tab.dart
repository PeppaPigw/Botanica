import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_sheet.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/diary_entry.dart';
import '../../domain/models/plant.dart';
import '../../gen/l10n/app_localizations.dart';
import '../journal/diary_share_card_screen.dart';
import '../journal/photo_share_card_screen.dart';
import '../journal/photo_viewer_screen.dart';

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

    return StreamBuilder(
      stream: diaryRepo.watchForPlant(plant.id),
      builder: (context, diarySnapshot) {
        final diaryEntries = diarySnapshot.data ?? const <DiaryEntry>[];

        return StreamBuilder(
          stream: photosRepo.watchForPlant(plant.id),
          builder: (context, photosSnapshot) {
            final photos = photosSnapshot.data ?? const [];

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
                            color: scheme.onSurface.withValues(alpha: 0.80),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.plantDetailJournalIntro,
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.72),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: onAddPhoto,
                              icon: const Icon(Icons.add_a_photo_rounded),
                              label: Text(l10n.journalAddPhotoTitle),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                const SizedBox(height: 14),
                Text(
                  l10n.journalSectionPhotos,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                if (photos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo_library_rounded,
                          size: 28,
                          color: scheme.onSurface.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.journalEmptyBody,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.60),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...photos.indexed.map((item) {
                    final index = item.$1;
                    final p = item.$2;
                    final compareCandidate =
                        index + 1 < photos.length ? photos[index + 1] : null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BotanicaGlassCard(
                        padding: const EdgeInsets.all(12),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BotanicaTokens.radiusXL),
                          onTap: () => PhotoViewerScreen.open(
                            context,
                            entry: p,
                            compareCandidate: compareCandidate,
                            title: l10n.journalPhotoTitle,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    BotanicaTokens.radiusL),
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Image.file(
                                    File(p.filePath),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                    errorBuilder: (_, __, ___) => DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: scheme.surface
                                            .withValues(alpha: 0.65),
                                        border: Border.all(
                                          color: scheme.outlineVariant
                                              .withValues(alpha: 0.45),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.photo_rounded,
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.journalPhotoMeta(p.createdAt),
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      (p.note ?? '').trim().isEmpty
                                          ? l10n.journalPhotoNoNote
                                          : p.note!.trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.70),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => PhotoShareCardScreen.open(
                                      context,
                                      entry: p,
                                    ),
                                    icon: const Icon(Icons.ios_share_rounded),
                                    tooltip: l10n.dailyShare,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.70),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 18),
                Text(
                  l10n.diarySectionTitle,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                if (diaryEntries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 28,
                          color: scheme.onSurface.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.diaryEmptyBody,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.60),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...diaryEntries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BotanicaGlassCard(
                        padding: const EdgeInsets.all(12),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BotanicaTokens.radiusXL),
                          onTap: () => showBotanicaModalSheet(
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
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.journalPhotoMeta(e.createdAt),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    e.text,
                                    style: textTheme.bodyMedium?.copyWith(
                                      height: 1.55,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                color: scheme.onSurface.withValues(alpha: 0.78),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.journalPhotoMeta(e.createdAt),
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      e.text,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.72),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => DiaryShareCardScreen.open(
                                      context,
                                      entry: e,
                                    ),
                                    icon: const Icon(Icons.ios_share_rounded),
                                    tooltip: l10n.dailyShare,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.70),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }
}
