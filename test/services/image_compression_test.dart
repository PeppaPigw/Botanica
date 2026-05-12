import 'dart:ui' as ui;

import 'package:botanica/services/photos/image_compression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('journal and share presets keep requested dimensions and quality', () {
    expect(ImageCompressionPresets.journalPhoto.maxLongestSide, 1200);
    expect(ImageCompressionPresets.journalPhoto.quality, 85);
    expect(ImageCompressionPresets.shareCardExport.maxLongestSide, 2048);
    expect(ImageCompressionPresets.shareCardExport.quality, 92);
  });

  test('share export pixel ratio caps longest side at 2048px', () {
    final ratio = ImageCompressionPresets.shareCardExport.pixelRatioFor(
      const ui.Size(1200, 900),
      3,
    );

    expect(ratio, closeTo(2048 / 1200, 0.001));
  });
}
