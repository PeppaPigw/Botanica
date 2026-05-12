import 'dart:io';

import 'package:botanica/core/widgets/botanica_gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../domain/models/photo_entry.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/photos/share_card_export.dart';
import 'widgets/journal_photo_unavailable.dart';

class PhotoShareCardScreen extends ConsumerStatefulWidget {
  const PhotoShareCardScreen({super.key, required this.entry});

  final PhotoEntry entry;

  static Future<void> open(
    BuildContext context, {
    required PhotoEntry entry,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PhotoShareCardScreen(entry: entry),
      ),
    );
  }

  @override
  ConsumerState<PhotoShareCardScreen> createState() =>
      _PhotoShareCardScreenState();
}

class _PhotoShareCardScreenState extends ConsumerState<PhotoShareCardScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    final l10n = AppLocalizations.of(context);

    try {
      final file = await exportShareCardPng(
        repaintKey: _repaintKey,
        fileName: 'botanica-${widget.entry.id}.png',
      );

      await Share.shareXFiles(
        [file],
        text: l10n.journalShareCardText,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  size: BotanicaTokens.iconSizeSm, color: Theme.of(context).colorScheme.error),
              BotanicaGaps.hSm,
              Expanded(child: Text(l10n.journalShareFailed)),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final plants = ref.watch(plantsStreamProvider).valueOrNull ?? const [];

    final plant = plants.where((p) => p.id == widget.entry.plantId).firstOrNull;
    final plantName = plant?.nickname ?? l10n.appName;

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.journalShareCardTitle),
        actions: [
          IconButton(
            onPressed: _sharing ? null : _share,
            icon: _sharing
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(
                          scheme.primary.withValues(alpha: 0.8)),
                    ),
                  )
                : const Icon(Icons.ios_share_rounded),
            tooltip: l10n.dailyShare,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: BotanicaTokens.pagePadding.copyWith(bottom: 18),
          child: Center(
            child: RepaintBoundary(
              key: _repaintKey,
              child: _ShareCard(
                photoPath: widget.entry.filePath,
                plantName: plantName,
                dateLabel: l10n.journalPhotoMeta(widget.entry.createdAt),
                note: (widget.entry.note ?? '').trim().isEmpty
                    ? null
                    : widget.entry.note!.trim(),
                brandName: l10n.appName,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.photoPath,
    required this.plantName,
    required this.dateLabel,
    required this.note,
    required this.brandName,
  });

  final String photoPath;
  final String plantName;
  final String dateLabel;
  final String? note;
  final String brandName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: 360,
        height: 450,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(photoPath),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) =>
                  const JournalPhotoUnavailable(),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surface.withValues(alpha: 0.05),
                    scheme.surface.withValues(alpha: 0.35),
                    scheme.surface.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Container(
                padding: BotanicaTokens.cardPaddingDense,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: scheme.surface.withValues(alpha: 0.78),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      plantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    BotanicaGaps.vTiny,
                    Text(
                      dateLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.70),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (note != null) ...[
                      BotanicaGaps.vSm,
                      Text(
                        note!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.78),
                          height: 1.35,
                        ),
                      ),
                    ],
                    BotanicaGaps.vSm,
                    Row(
                      children: [
                        Icon(Icons.spa_rounded,
                            size: BotanicaTokens.iconSizeSm,
                            color: scheme.primary.withValues(alpha: 0.85)),
                        BotanicaGaps.hXxs,
                        Text(
                          brandName,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: scheme.onSurface.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
