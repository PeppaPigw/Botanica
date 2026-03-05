import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../domain/models/diary_entry.dart';
import '../../gen/l10n/app_localizations.dart';

class DiaryShareCardScreen extends ConsumerStatefulWidget {
  const DiaryShareCardScreen({super.key, required this.entry});

  final DiaryEntry entry;

  static Future<void> open(
    BuildContext context, {
    required DiaryEntry entry,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DiaryShareCardScreen(entry: entry),
      ),
    );
  }

  @override
  ConsumerState<DiaryShareCardScreen> createState() =>
      _DiaryShareCardScreenState();
}

class _DiaryShareCardScreenState extends ConsumerState<DiaryShareCardScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    final l10n = AppLocalizations.of(context);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Share card was not ready to render.');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode share image.');
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/botanica-diary-${widget.entry.id}.png');
      await file.writeAsBytes(pngBytes, flush: true);

      await Share.shareXFiles(
        <XFile>[XFile(file.path)],
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
                  size: 18, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 10),
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

    final coverPath = (plant?.coverAsset ?? '').trim().isEmpty
        ? 'assets/illustrations/share_diary_bg.jpg'
        : plant!.coverAsset!.trim();

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
                        scheme.primary.withValues(alpha: 0.8),
                      ),
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
              child: _DiaryShareCard(
                backgroundPath: coverPath,
                plantName: plantName,
                dateLabel: l10n.journalPhotoMeta(widget.entry.createdAt),
                text: widget.entry.text.trim(),
                brandName: l10n.appName,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiaryShareCard extends StatelessWidget {
  const _DiaryShareCard({
    required this.backgroundPath,
    required this.plantName,
    required this.dateLabel,
    required this.text,
    required this.brandName,
  });

  final String backgroundPath;
  final String plantName;
  final String dateLabel;
  final String text;
  final String brandName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isAsset = backgroundPath.trim().startsWith('assets/');

    Widget background;
    if (isAsset) {
      background = Image.asset(backgroundPath,
          fit: BoxFit.cover, filterQuality: FilterQuality.high);
    } else {
      background = Image.file(
        File(backgroundPath),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/illustrations/share_diary_bg.jpg',
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: 360,
        height: 450,
        child: Stack(
          fit: StackFit.expand,
          children: [
            background,
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surface.withValues(alpha: 0.10),
                    scheme.surface.withValues(alpha: 0.50),
                    scheme.surface.withValues(alpha: 0.94),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: scheme.surface.withValues(alpha: 0.80),
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
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.70),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 18,
                          color: scheme.primary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            text,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.82),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.spa_rounded,
                          size: 16,
                          color: scheme.primary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 6),
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
