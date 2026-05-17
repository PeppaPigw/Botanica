import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all ARB files define the same top-level keys', () {
    final files = Directory('lib/l10n')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.arb'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    expect(files.map((file) => file.uri.pathSegments.last), [
      'app_ar.arb',
      'app_en.arb',
      'app_es.arb',
      'app_zh.arb',
    ]);

    final keysByFile = <String, Set<String>>{
      for (final file in files)
        file.uri.pathSegments.last:
            (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)
                .keys
                .where((k) => !k.startsWith('@'))
                .toSet(),
    };
    final allKeys = keysByFile.values.fold<Set<String>>(
      <String>{},
      (combined, keys) => combined..addAll(keys),
    );

    final missingByFile = <String, List<String>>{
      for (final entry in keysByFile.entries)
        entry.key: allKeys.difference(entry.value).toList()..sort(),
    }..removeWhere((_, missing) => missing.isEmpty);

    expect(missingByFile, isEmpty);
  });
}
