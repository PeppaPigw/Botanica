import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageCompressionPreset {
  const ImageCompressionPreset({
    required this.maxLongestSide,
    required this.quality,
  });

  final int maxLongestSide;
  final int quality;

  double get pickerMaxDimension => maxLongestSide.toDouble();

  double pixelRatioFor(ui.Size logicalSize, double desiredPixelRatio) {
    final longest = math.max(logicalSize.width, logicalSize.height);
    if (longest <= 0) return desiredPixelRatio;
    final cap = maxLongestSide / longest;
    return math.min(desiredPixelRatio, cap).clamp(1.0, desiredPixelRatio)
        .toDouble();
  }
}

class ImageCompressionPresets {
  const ImageCompressionPresets._();

  static const journalPhoto = ImageCompressionPreset(
    maxLongestSide: 1200,
    quality: 85,
  );

  static const shareCardExport = ImageCompressionPreset(
    maxLongestSide: 2048,
    quality: 92,
  );
}

class ImageCompression {
  const ImageCompression._();

  static Future<XFile> prepareForStorage({
    required XFile file,
    required ImageCompressionPreset preset,
  }) async {
    final bytes = await file.readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    ui.ImageDescriptor? descriptor;

    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
    } catch (_) {
      buffer.dispose();
      return file;
    }

    final longest = math.max(descriptor.width, descriptor.height);
    if (longest <= preset.maxLongestSide) {
      descriptor.dispose();
      buffer.dispose();
      return file;
    }

    final scale = preset.maxLongestSide / longest;
    final targetWidth = math.max(1, (descriptor.width * scale).round());
    final targetHeight = math.max(1, (descriptor.height * scale).round());

    ui.Codec? codec;
    ui.Image? image;
    try {
      codec = await descriptor.instantiateCodec(
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      final frame = await codec.getNextFrame();
      image = frame.image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return file;

      final dir = await getTemporaryDirectory();
      final path = p.join(
        dir.path,
        'botanica-journal-${DateTime.now().microsecondsSinceEpoch}.png',
      );
      final resizedBytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      await File(path).writeAsBytes(resizedBytes, flush: true);
      return XFile(path);
    } catch (_) {
      return file;
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor.dispose();
      buffer.dispose();
    }
  }
}
