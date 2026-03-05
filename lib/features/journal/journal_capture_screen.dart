import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/botanica_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class JournalCaptureScreen extends StatefulWidget {
  const JournalCaptureScreen({
    super.key,
    required this.title,
    this.ghostOverlayPath,
  });

  final String title;
  final String? ghostOverlayPath;

  static Future<XFile?> capture(
    BuildContext context, {
    required String title,
    String? ghostOverlayPath,
  }) {
    return Navigator.of(context).push<XFile?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => JournalCaptureScreen(
          title: title,
          ghostOverlayPath: ghostOverlayPath,
        ),
      ),
    );
  }

  @override
  State<JournalCaptureScreen> createState() => _JournalCaptureScreenState();
}

class _JournalCaptureScreenState extends State<JournalCaptureScreen> {
  CameraController? _controller;
  Future<void>? _init;

  bool _flashOn = false;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _init = _initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final cameras = await availableCameras();
    final back = cameras
        .where((c) => c.lensDirection == CameraLensDirection.back)
        .toList();

    final selected = (back.isNotEmpty ? back.first : cameras.first);

    final controller = CameraController(
      selected,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _flashOn = !_flashOn);
    try {
      await controller.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      // Some devices/simulators may not support torch. Keep UX graceful.
      if (!mounted) return;
      setState(() => _flashOn = false);
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null) return;
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(file);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop(null);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return BotanicaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FutureBuilder<void>(
            future: _init,
            builder: (context, snapshot) {
              final controller = _controller;
              if (snapshot.connectionState != ConnectionState.done ||
                  controller == null ||
                  !controller.value.isInitialized) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                        scheme.primary.withValues(alpha: 0.7)),
                  ),
                );
              }

              final overlayPath = widget.ghostOverlayPath;
              final overlayFile =
                  overlayPath == null ? null : File(overlayPath);

              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(BotanicaTokens.radiusXL),
                    child: CameraPreview(controller),
                  ),
                  if (overlayFile != null && overlayFile.existsSync())
                    IgnorePointer(
                      child: Opacity(
                        opacity: 0.22,
                        child: Image.file(
                          overlayFile,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _FramingGuidePainter(
                        color: scheme.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(null),
                            icon: const Icon(Icons.close_rounded),
                            tooltip: l10n.commonClose,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filledTonal(
                            onPressed: _toggleFlash,
                            icon: Icon(
                              _flashOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                            ),
                            tooltip: l10n.journalFlash,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BotanicaGlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.center_focus_strong_rounded,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.80)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.journalCaptureTip,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurface
                                              .withValues(alpha: 0.74),
                                          height: 1.35,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: _capturing ? null : _takePicture,
                            child: AnimatedContainer(
                              duration: BotanicaTokens.motionFast,
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: scheme.surface.withValues(alpha: 0.20),
                                border: Border.all(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.75),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: BotanicaTokens.motionFast,
                                  width: _capturing ? 34 : 52,
                                  height: _capturing ? 34 : 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.90),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FramingGuidePainter extends CustomPainter {
  const _FramingGuidePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rect = Rect.fromLTWH(
      size.width * 0.10,
      size.height * 0.20,
      size.width * 0.80,
      size.height * 0.55,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      paint,
    );

    final corner = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const len = 18.0;
    // Top-left
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(len, 0), corner);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, len), corner);
    // Top-right
    canvas.drawLine(
        rect.topRight, rect.topRight + const Offset(-len, 0), corner);
    canvas.drawLine(
        rect.topRight, rect.topRight + const Offset(0, len), corner);
    // Bottom-left
    canvas.drawLine(
        rect.bottomLeft, rect.bottomLeft + const Offset(len, 0), corner);
    canvas.drawLine(
        rect.bottomLeft, rect.bottomLeft + const Offset(0, -len), corner);
    // Bottom-right
    canvas.drawLine(
        rect.bottomRight, rect.bottomRight + const Offset(-len, 0), corner);
    canvas.drawLine(
        rect.bottomRight, rect.bottomRight + const Offset(0, -len), corner);
  }

  @override
  bool shouldRepaint(covariant _FramingGuidePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
