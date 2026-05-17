import 'package:botanica/core/widgets/botanica_quick_check_in_card.dart';
import 'package:botanica/domain/services/quick_check_in.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  group('BotanicaQuickCheckInCard', () {
    testWidgets('shows plant name in question', (tester) async {
      await tester.pumpWidget(_wrap(
        BotanicaQuickCheckInCard(
          plantNickname: 'Fern',
          onResponse: (_) {},
        ),
      ));

      expect(find.textContaining('Fern'), findsOneWidget);
      expect(find.text('Thriving'), findsOneWidget);
      expect(find.text('Okay'), findsOneWidget);
      expect(find.text('Worried'), findsOneWidget);
    });

    testWidgets('shows thanks message after response', (tester) async {
      QuickCheckInResponse? received;

      await tester.pumpWidget(_wrap(
        BotanicaQuickCheckInCard(
          plantNickname: 'Monstera',
          onResponse: (r) => received = r,
        ),
      ));

      await tester.tap(find.text('Thriving'));
      await tester.pump();

      expect(received, QuickCheckInResponse.thriving);
      expect(find.text('Thanks for checking in!'), findsOneWidget);
      expect(find.text('Thriving'), findsNothing);
    });

    testWidgets('renders in zh locale', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BotanicaQuickCheckInCard(
            plantNickname: 'Fern',
            onResponse: (_) {},
          ),
        ),
      ));

      expect(find.textContaining('Fern'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
