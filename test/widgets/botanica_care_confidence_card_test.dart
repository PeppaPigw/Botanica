import 'package:botanica/core/widgets/botanica_care_confidence_card.dart';
import 'package:botanica/domain/services/care_confidence_engine.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

CareConfidenceReport _report({
  String level = 'confidenceMaster',
  String milestone = 'confidenceMilestoneKeepGoing',
}) =>
    CareConfidenceReport(
      overallConfidence: 0.82,
      dimensions: const [
        ConfidenceDimension(
            name: 'confidenceConsistency', score: 0.9, evidence: ''),
        ConfidenceDimension(
            name: 'confidenceDiversity', score: 0.7, evidence: ''),
        ConfidenceDimension(
            name: 'confidenceHealth', score: 0.85, evidence: ''),
      ],
      level: level,
      nextMilestone: milestone,
    );

void main() {
  group('BotanicaCareConfidenceCard', () {
    testWidgets('renders master level with dimensions', (tester) async {
      await tester.pumpWidget(_wrap(
        BotanicaCareConfidenceCard(report: _report()),
      ));

      expect(find.text('Plant Master'), findsOneWidget);
      expect(find.textContaining('Keep the streak alive'), findsOneWidget);
      expect(find.text('Consistency'), findsOneWidget);
      expect(find.text('Diversity'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
    });

    testWidgets('renders learning level', (tester) async {
      await tester.pumpWidget(_wrap(
        BotanicaCareConfidenceCard(
          report: _report(
            level: 'confidenceLearning',
            milestone: 'confidenceMilestoneConfident',
          ),
        ),
      ));

      expect(find.text('Growing Learner'), findsOneWidget);
      expect(find.textContaining('Reach Confident level'), findsOneWidget);
    });

    testWidgets('renders empty milestone gracefully', (tester) async {
      await tester.pumpWidget(_wrap(
        BotanicaCareConfidenceCard(
          report: _report(milestone: ''),
        ),
      ));

      expect(find.text('Plant Master'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in zh locale', (tester) async {
      await tester.pumpWidget(_wrap(
        BotanicaCareConfidenceCard(report: _report()),
        locale: const Locale('zh'),
      ));

      expect(find.text('植物大师'), findsOneWidget);
      expect(find.text('一致性'), findsOneWidget);
    });
  });
}
