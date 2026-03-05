import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class PhotoCompareScreen extends StatelessWidget {
  const PhotoCompareScreen({
    super.key,
    required this.beforePath,
    required this.afterPath,
    required this.title,
  });

  final String beforePath;
  final String afterPath;
  final String title;

  static Future<void> open(
    BuildContext context, {
    required String beforePath,
    required String afterPath,
    required String title,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PhotoCompareScreen(
          beforePath: beforePath,
          afterPath: afterPath,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return BotanicaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.transparent,
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
                      child: PhotoCompare(
                        before: FileImage(File(beforePath)),
                        after: FileImage(File(afterPath)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.drag_indicator_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.70)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.journalCompareHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.72),
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PhotoCompare extends StatefulWidget {
  const PhotoCompare({
    super.key,
    required this.before,
    required this.after,
  });

  final ImageProvider before;
  final ImageProvider after;

  @override
  State<PhotoCompare> createState() => _PhotoCompareState();
}

class _PhotoCompareState extends State<PhotoCompare> {
  double _t = 0.55;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final clipW = w * _t;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _t = (_t + details.delta.dx / w).clamp(0.04, 0.96);
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              _PhotoLayer(image: widget.before),
              ClipRect(
                clipper: _WidthClipper(width: clipW),
                child: _PhotoLayer(image: widget.after),
              ),
              Positioned(
                left: clipW - 1,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              Positioned(
                left: clipW - 22,
                top: (h / 2) - 22,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.80),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.drag_handle_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoLayer extends StatelessWidget {
  const _PhotoLayer({required this.image});
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _WidthClipper extends CustomClipper<Rect> {
  const _WidthClipper({required this.width});

  final double width;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, width, size.height);

  @override
  bool shouldReclip(covariant _WidthClipper oldClipper) {
    return oldClipper.width != width;
  }
}
