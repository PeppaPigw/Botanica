import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Daily flower JSON entries include valid imagePath placeholders', () {
    for (final path in const <String>[
      'assets/data/daily_flower_en.json',
      'assets/data/daily_flower_zh.json',
    ]) {
      final file = File(path);
      expect(file.existsSync(), isTrue,
          reason: 'Missing daily flower file: $path');

      final decoded =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final entries = decoded['entries'] as List<dynamic>? ?? const <dynamic>[];
      expect(entries, isNotEmpty,
          reason: 'Expected at least one entry in $path.');

      for (final raw in entries) {
        final entry = Map<String, dynamic>.from(raw as Map);
        final key = (entry['key'] as String?)?.trim() ?? '';
        expect(key, isNotEmpty,
            reason: 'Daily flower entry is missing key in $path.');

        final imagePath = (entry['imagePath'] as String?)?.trim() ?? '';
        expect(imagePath, isNotEmpty,
            reason: 'Daily flower entry "$key" missing imagePath in $path.');
        expect(
            imagePath.endsWith('/$key.png') || imagePath.endsWith('$key.png'),
            isTrue,
            reason:
                'Expected "$key" imagePath to end with "$key.png": $imagePath');
        expect(File(imagePath).existsSync(), isTrue,
            reason: 'Missing placeholder image for "$key": $imagePath');
      }
    }
  });
}
