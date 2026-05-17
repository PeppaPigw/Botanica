import 'package:botanica/app/intelligence_providers.dart';
import 'package:botanica/core/widgets/care_patterns_card.dart';
import 'package:botanica/domain/services/care_pattern_analyzer.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(List<CarePattern> patterns) => ProviderScope(
      overrides: [
        carePatternProvider.overrideWithValue(patterns),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: CarePatternsCard()),
      ),
    );

void main() {
  group('CarePatternsCard', () {
    testWidgets('renders nothing when patterns empty', (tester) async {
      await tester.pumpWidget(_wrap([]));
      expect(find.byType(CarePatternsCard), findsOneWidget);
      expect(find.text('Your Care Patterns'), findsNothing);
    });

    testWidgets('renders pattern labels localized', (tester) async {
      await tester.pumpWidget(_wrap(const [
        CarePattern(
          type: PatternType.morningRitual,
          messageKey: '',
          confidence: 0.8,
          args: {},
        ),
        CarePattern(
          type: PatternType.batchCarer,
          messageKey: '',
          confidence: 0.6,
          args: {},
        ),
      ]));

      expect(find.text('Your Care Patterns'), findsOneWidget);
      expect(find.text('Morning Ritual'), findsOneWidget);
      expect(find.text('Batch Carer'), findsOneWidget);
    });

    testWidgets('renders all pattern types without error', (tester) async {
      final patterns = PatternType.values
          .map((t) => CarePattern(
                type: t,
                messageKey: '',
                confidence: 0.5,
                args: {},
              ))
          .toList();

      await tester.pumpWidget(_wrap(patterns));
      expect(tester.takeException(), isNull);
      expect(find.text('Your Care Patterns'), findsOneWidget);
    });
  });
}
