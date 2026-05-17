import 'package:botanica/core/widgets/botanica_care_rhythm_card.dart';
import 'package:botanica/domain/services/care_rhythm_engine.dart';
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
  group('BotanicaCareRhythmCard', () {
    testWidgets('renders morning person rhythm with streak badge',
        (tester) async {
      const rhythm = CareRhythm(
        type: CareRhythmType.morningPerson,
        confidence: 0.85,
        streak: 5,
      );

      await tester.pumpWidget(_wrap(
        const BotanicaCareRhythmCard(rhythm: rhythm),
      ));

      expect(find.text('Morning Person'), findsOneWidget);
      expect(find.text('5x streak'), findsOneWidget);
      expect(find.text('85% match'), findsOneWidget);
    });

    testWidgets('renders all rhythm types without overflow', (tester) async {
      for (final type in CareRhythmType.values) {
        await tester.pumpWidget(_wrap(
          BotanicaCareRhythmCard(
            rhythm: CareRhythm(type: type, confidence: 0.6, streak: 0),
          ),
        ));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('hides streak badge when streak is zero', (tester) async {
      const rhythm = CareRhythm(
        type: CareRhythmType.batchCarer,
        confidence: 0.5,
        streak: 0,
      );

      await tester.pumpWidget(_wrap(
        const BotanicaCareRhythmCard(rhythm: rhythm),
      ));

      expect(find.textContaining('streak'), findsNothing);
    });
  });
}
