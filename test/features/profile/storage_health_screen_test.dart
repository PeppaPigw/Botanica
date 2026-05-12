import 'dart:io';

import 'package:botanica/app/providers.dart';
import 'package:botanica/domain/models/diary_entry.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/features/profile/storage_health_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('storage health summarizes journal media',
      (WidgetTester tester) async {
    final dir = await Directory.systemTemp.createTemp('botanica_storage_ui_');
    addTearDown(() async {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    final first = File('${dir.path}/first.jpg');
    final second = File('${dir.path}/second.jpg');
    await first.writeAsBytes(<int>[1, 2, 3]);
    await second.writeAsBytes(<int>[4, 5]);

    final photos = <PhotoEntry>[
      _photo(id: 'first', path: first.path),
      _photo(id: 'second', path: second.path),
    ];
    final diary = <DiaryEntry>[
      DiaryEntry(
        id: 'diary',
        plantId: 'plant_1',
        createdAt: DateTime.utc(2026, 5, 1),
        text: 'New leaf',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          photoEntriesStreamProvider.overrideWith((ref) => Stream.value(photos)),
          diaryEntriesStreamProvider.overrideWith((ref) => Stream.value(diary)),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StorageHealthScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Storage health'), findsOneWidget);
    expect(find.text('5 B'), findsOneWidget);
    expect(find.text('2 files'), findsOneWidget);
    expect(find.text('3 entries'), findsOneWidget);
    expect(find.text('Clear cache'), findsOneWidget);
  });
}

PhotoEntry _photo({
  required String id,
  required String path,
}) {
  return PhotoEntry(
    id: id,
    plantId: 'plant_1',
    filePath: path,
    createdAt: DateTime.utc(2026, 5, 1),
    note: null,
    hash: null,
  );
}
