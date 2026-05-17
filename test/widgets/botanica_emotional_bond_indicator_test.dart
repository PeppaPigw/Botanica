import 'package:botanica/core/widgets/botanica_emotional_bond_indicator.dart';
import 'package:botanica/domain/services/emotional_bond_engine.dart';
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

EmotionalBond _bond(String type, int moments) => EmotionalBond(
      plantId: 'p1',
      plantNickname: 'Fern',
      bondStrength: 0.8,
      bondType: type,
      sharedMoments: moments,
      relationships: const [],
    );

void main() {
  group('BotanicaEmotionalBondIndicator', () {
    testWidgets('renders soulmate bond with shared moments', (tester) async {
      await tester.pumpWidget(_wrap(
        BotanicaEmotionalBondIndicator(bond: _bond('bondSoulmate', 42)),
      ));

      expect(find.text('Soulmate'), findsOneWidget);
      expect(find.text('42 shared moments'), findsOneWidget);
    });

    testWidgets('renders compact mode without moments', (tester) async {
      await tester.pumpWidget(_wrap(
        BotanicaEmotionalBondIndicator(
          bond: _bond('bondBestFriend', 10),
          compact: true,
        ),
      ));

      expect(find.text('Best Friend'), findsOneWidget);
      expect(find.textContaining('shared moments'), findsNothing);
    });

    testWidgets('renders all bond types', (tester) async {
      for (final type in [
        'bondSoulmate',
        'bondBestFriend',
        'bondCompanion',
        'bondNewFriend',
        'unknown',
      ]) {
        await tester.pumpWidget(_wrap(
          BotanicaEmotionalBondIndicator(bond: _bond(type, 5)),
        ));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('renders in es locale', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BotanicaEmotionalBondIndicator(
            bond: _bond('bondSoulmate', 10),
          ),
        ),
      ));

      expect(find.text('Alma gemela'), findsOneWidget);
    });
  });
}
