import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'image_compression.dart';

Future<XFile> exportShareCardPng({
  required GlobalKey repaintKey,
  required String fileName,
}) async {
  final boundary =
      repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('Share card was not ready to render.');
  }

  final pixelRatio = ImageCompressionPresets.shareCardExport.pixelRatioFor(
    boundary.size,
    3.0,
  );
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode share image.');
    }
    final pngBytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, fileName);
    final writtenPath = await compute(
      _writePngFile,
      <String, Object>{
        'path': path,
        'bytes': Uint8List.fromList(pngBytes),
      },
    );
    return XFile(writtenPath);
  } finally {
    image.dispose();
  }
}

Future<String> _writePngFile(Map<String, Object> args) async {
  final path = args['path']! as String;
  final bytes = args['bytes']! as Uint8List;
  await File(path).writeAsBytes(bytes, flush: true);
  return path;
}
