import 'package:botanica/features/journal/photo_compare_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PhotoCompareScreen shows fallback when source files are missing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PhotoCompareScreen(
          beforePath: '/tmp/botanica_missing_before.jpg',
          afterPath: '/tmp/botanica_missing_after.jpg',
          title: 'Compare',
        ),
      ),
    );

    await tester.pump();

    expect(find.byIcon(Icons.broken_image_rounded), findsOneWidget);
    expect(find.text('Photo unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
