import 'dart:io';

import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/domain/models/diary_entry.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/features/journal/diary_share_card_screen.dart';
import 'package:botanica/features/journal/photo_share_card_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('photo share card builds without errors', (tester) async {
    final entry = PhotoEntry(
      id: 'photo_1',
      plantId: 'plant_1',
      filePath: '${Directory.systemTemp.path}/missing-botanica-photo.jpg',
      createdAt: DateTime(2026, 5, 12, 9),
      note: 'New leaf',
      hash: null,
    );

    await tester.pumpWidget(_app(PhotoShareCardScreen(entry: entry)));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoShareCardScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('diary share card builds without errors', (tester) async {
    final entry = DiaryEntry(
      id: 'diary_1',
      plantId: 'plant_1',
      createdAt: DateTime(2026, 5, 12, 9),
      text: 'A quiet watering day.',
    );

    await tester.pumpWidget(_app(DiaryShareCardScreen(entry: entry)));
    await tester.pumpAndSettle();

    expect(find.byType(DiaryShareCardScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget home) {
  return ProviderScope(
    overrides: [
      plantsStreamProvider.overrideWith(
        (ref) => Stream.value(<Plant>[_plant()]),
      ),
    ],
    child: MaterialApp(
      theme: BotanicaTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

Plant _plant() {
  return Plant(
    id: 'plant_1',
    nickname: 'Pilea',
    speciesId: 'pilea_peperomioides',
    room: 'Studio',
    environmentMode: EnvironmentMode.indoor,
    coverAsset: null,
    createdAt: DateTime(2026, 1, 1),
    meta: const PlantMeta(),
  );
}
