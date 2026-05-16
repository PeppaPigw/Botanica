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
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dir = Directory.systemTemp.createTempSync('botanica_storage_ui_');
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    final first = File('${dir.path}/first.jpg')
      ..writeAsBytesSync(<int>[1, 2, 3]);
    final second = File('${dir.path}/second.jpg')
      ..writeAsBytesSync(<int>[4, 5]);

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
          photoEntriesStreamProvider
              .overrideWith((ref) => Stream.value(photos)),
          diaryEntriesStreamProvider
              .overrideWith((ref) => Stream.value(diary)),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StorageHealthScreen(),
        ),
      ),
    );

    // Stream.value emits synchronously on first pump, triggering build()
    // which creates _statsFuture with real file I/O. We need the real event
    // loop for File.exists/File.stat to complete.
    await tester.runAsync(() async {
      await tester.pump();
      // Now _statsFuture exists — let file I/O complete.
      await Future<void>.delayed(const Duration(seconds: 1));
      // Rebuild with resolved FutureBuilder snapshot.
      await tester.pump();
    });

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
