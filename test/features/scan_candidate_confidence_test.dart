import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/features/scan/scan_candidate_card.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _species = Species(
  id: 'monstera_deliciosa',
  scientificName: 'Monstera deliciosa',
  commonNamesByLocale: <String, List<String>>{
    'en': <String>['Monstera'],
  },
  difficulty: 'easy',
  petSafe: false,
  light: 'bright_indirect',
  careDefaults: CareDefaults(
    waterBaseDays: 7,
    fertilizeBaseDays: 30,
    mistBaseDays: 3,
    rotateBaseDays: 14,
    pruneBaseDays: 90,
  ),
);

Future<void> _pumpCandidate(
  WidgetTester tester, {
  required double confidence,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BotanicaTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ScanCandidateCard(
          species: _species,
          localeCode: 'en',
          confidence: confidence,
          selected: false,
          onTap: () {},
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('0.90 shows high-confidence UI',
      (WidgetTester tester) async {
    await _pumpCandidate(tester, confidence: 0.90);
    final l10n =
        AppLocalizations.of(tester.element(find.byType(ScanCandidateCard)));

    expect(find.text('90%'), findsOneWidget);
    expect(find.text(l10n.scanConfidenceStrongLabel), findsOneWidget);
    expect(find.text(l10n.scanConfidenceStrongBody), findsOneWidget);

    // Verify the confidence bar width via FractionallySizedBox.
    final bar = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(bar.widthFactor, 0.90);
  });

  testWidgets('0.80 shows moderate-confidence UI',
      (WidgetTester tester) async {
    await _pumpCandidate(tester, confidence: 0.80);
    final l10n =
        AppLocalizations.of(tester.element(find.byType(ScanCandidateCard)));

    expect(find.text('80%'), findsOneWidget);
    expect(find.text(l10n.scanConfidenceLikelyLabel), findsOneWidget);
    expect(find.text(l10n.scanConfidenceLikelyBody), findsOneWidget);
  });

  testWidgets('0.45 shows low-confidence UI',
      (WidgetTester tester) async {
    await _pumpCandidate(tester, confidence: 0.45);
    final l10n =
        AppLocalizations.of(tester.element(find.byType(ScanCandidateCard)));

    expect(find.text('45%'), findsOneWidget);
    expect(find.text(l10n.scanConfidencePossibleLabel), findsOneWidget);
    expect(find.text(l10n.scanConfidencePossibleBody), findsOneWidget);
  });
}
