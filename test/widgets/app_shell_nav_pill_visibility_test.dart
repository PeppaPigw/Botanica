import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:botanica/app/routing/app_shell.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/core/widgets/botanica_nav_pill.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('AppShell hides nav pill when keyboard is open',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BotanicaTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MediaQuery(
          data: MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 34),
            viewInsets: EdgeInsets.only(bottom: 280),
          ),
          child: AppShell(
            location: '/garden',
            child: SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(BotanicaNavPill), findsNothing);
  });

  testWidgets('AppShell shows nav pill when keyboard is closed',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BotanicaTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MediaQuery(
          data: MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 34),
            viewInsets: EdgeInsets.zero,
          ),
          child: AppShell(
            location: '/garden',
            child: SizedBox.expand(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(BotanicaNavPill), findsOneWidget);
  });
}
