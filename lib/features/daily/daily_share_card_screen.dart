import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_page_scaffold.dart';
import '../../domain/models/daily_flower.dart';
import '../../gen/l10n/app_localizations.dart';

class DailyShareCardScreen extends StatefulWidget {
  const DailyShareCardScreen({
    super.key,
    required this.entry,
    required this.modeLabel,
    required this.variantLabel,
  });

  final DailyFlowerEntry entry;
  final String modeLabel;
  final String variantLabel;

  static Future<void> open(
    BuildContext context, {
    required DailyFlowerEntry entry,
    required String modeLabel,
    required String variantLabel,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DailyShareCardScreen(
          entry: entry,
          modeLabel: modeLabel,
          variantLabel: variantLabel,
        ),
      ),
    );
  }

  @override
  State<DailyShareCardScreen> createState() => _DailyShareCardScreenState();
}

class _DailyShareCardScreenState extends State<DailyShareCardScreen> {
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
      final file = File(
        '${dir.path}/botanica-daily-${widget.entry.content.key}.png',
      );
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

    return BotanicaPageScaffold(
      appBar: AppBar(
        title: Text(l10n.journalShareCardTitle),
        actions: [
          IconButton(
            key: const ValueKey('daily-share-card-share'),
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
              child: _DailyShareCard(
                entry: widget.entry,
                modeLabel: widget.modeLabel,
                variantLabel: widget.variantLabel,
                brandName: l10n.appName,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyShareCard extends StatelessWidget {
  const _DailyShareCard({
    required this.entry,
    required this.modeLabel,
    required this.variantLabel,
    required this.brandName,
  });

  final DailyFlowerEntry entry;
  final String modeLabel;
  final String variantLabel;
  final String brandName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final content = entry.content;
    final dateLabel = MaterialLocalizations.of(context).formatFullDate(
      entry.date,
    );

    String careLabel(String key) => switch (key) {
          'light' => l10n.careKeyLight,
          'water' => l10n.careKeyWater,
          'temperature' => l10n.careKeyTemperature,
          'petSafety' => l10n.careKeyPetSafety,
          _ => key,
        };

    Widget pill({required IconData icon, required String label}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: scheme.surface.withValues(alpha: 0.55),
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16, color: scheme.onSurface.withValues(alpha: 0.72)),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.74),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
            Image.asset(
              'assets/illustrations/share_daily_bg.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            if ((content.imagePath ?? '').trim().isNotEmpty)
              Positioned(
                right: -42,
                top: 84,
                bottom: 84,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.45,
                    child: Image.asset(
                      content.imagePath!.trim(),
                      width: 260,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.55),
                    scheme.tertiaryContainer.withValues(alpha: 0.30),
                    scheme.surface.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              top: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.70),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      pill(
                        icon: Icons.auto_awesome_rounded,
                        label: modeLabel,
                      ),
                      pill(
                        icon: Icons.tune_rounded,
                        label: variantLabel,
                      ),
                    ],
                  ),
                ],
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
                            content.symbolism,
                            maxLines: 4,
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
                    Text(
                      l10n.dailyCareToday,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...content.careBasics.entries.take(4).map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• ${careLabel(e.key)}: ${e.value}',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.74),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.spa_rounded,
                          size: 16,
                          color: scheme.onSurface.withValues(alpha: 0.70),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          brandName,
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
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
