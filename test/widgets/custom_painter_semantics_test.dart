import 'package:botanica/core/widgets/botanica_care_confidence_radar.dart';
import 'package:botanica/core/widgets/botanica_health_forecast_mini.dart';
import 'package:botanica/core/widgets/botanica_momentum_ring.dart';
import 'package:botanica/core/widgets/botanica_water_level.dart';
import 'package:botanica/domain/services/care_confidence_engine.dart';
import 'package:botanica/domain/services/plant_health_forecast_engine.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('BotanicaMomentumRing semantics', () {
    testWidgets('default label shows Momentum and percent', (tester) async {
      await tester.pumpWidget(_wrap(
        const BotanicaMomentumRing(score: 0.75),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'Momentum 75 percent')),
        findsOneWidget,
      );
    });

    testWidgets('custom label replaces Momentum in semantics', (tester) async {
      await tester.pumpWidget(_wrap(
        const BotanicaMomentumRing(score: 0.5, label: 'Streak'),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'Streak 50 percent')),
        findsOneWidget,
      );
    });

    testWidgets('zero score shows 0 percent', (tester) async {
      await tester.pumpWidget(_wrap(
        const BotanicaMomentumRing(score: 0.0),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'Momentum 0 percent')),
        findsOneWidget,
      );
    });
  });

  group('BotanicaWaterLevel semantics', () {
    testWidgets('shows water level percent', (tester) async {
      await tester.pumpWidget(_wrap(
        const BotanicaWaterLevel(progress: 0.6),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'Water level 60 percent')),
        findsOneWidget,
      );
    });

    testWidgets('full progress shows 100 percent', (tester) async {
      await tester.pumpWidget(_wrap(
        const BotanicaWaterLevel(progress: 1.0),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'Water level 100 percent')),
        findsOneWidget,
      );
    });

    testWidgets('zero progress shows 0 percent', (tester) async {
      await tester.pumpWidget(_wrap(
        const BotanicaWaterLevel(progress: 0.0),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'Water level 0 percent')),
        findsOneWidget,
      );
    });
  });

  group('BotanicaCareConfidenceRadar semantics', () {
    testWidgets('radar chart has semantics label with overall percent',
        (tester) async {
      const report = CareConfidenceReport(
        overallConfidence: 0.82,
        dimensions: [
          ConfidenceDimension(
              name: 'confidenceConsistency', score: 0.9, evidence: ''),
          ConfidenceDimension(
              name: 'confidenceDiversity', score: 0.7, evidence: ''),
          ConfidenceDimension(
              name: 'confidenceHealth', score: 0.85, evidence: ''),
        ],
        level: 'confidenceMaster',
        nextMilestone: 'confidenceMilestoneKeepGoing',
      );

      await tester.pumpWidget(_wrap(
        const BotanicaCareConfidenceRadar(report: report),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'Care confidence radar chart')),
        findsOneWidget,
      );
    });

    testWidgets('radar chart semantics includes dimension count',
        (tester) async {
      const report = CareConfidenceReport(
        overallConfidence: 0.65,
        dimensions: [
          ConfidenceDimension(
              name: 'confidenceConsistency', score: 0.8, evidence: ''),
          ConfidenceDimension(
              name: 'confidenceDiversity', score: 0.5, evidence: ''),
          ConfidenceDimension(
              name: 'confidenceHealth', score: 0.6, evidence: ''),
          ConfidenceDimension(
              name: 'confidenceExperience', score: 0.7, evidence: ''),
        ],
        level: 'confidenceConfident',
        nextMilestone: 'confidenceMilestoneMaster',
      );

      await tester.pumpWidget(_wrap(
        const BotanicaCareConfidenceRadar(report: report),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'4 dimensions')),
        findsOneWidget,
      );
    });
  });

  group('BotanicaHealthForecastMini semantics', () {
    testWidgets('sparkline has semantics label with trend direction',
        (tester) async {
      final forecast = PlantHealthForecast(
        plantId: 'test-plant-1',
        currentHealth: 0.75,
        forecastPoints: [
          HealthForecastPoint(
            date: DateTime(2026, 5, 18),
            predictedHealth: 0.76,
            confidence: 0.9,
          ),
          HealthForecastPoint(
            date: DateTime(2026, 5, 19),
            predictedHealth: 0.78,
            confidence: 0.85,
          ),
          HealthForecastPoint(
            date: DateTime(2026, 5, 20),
            predictedHealth: 0.80,
            confidence: 0.8,
          ),
        ],
        trendDirection: 'improving',
        riskLevel: 'forecastLowRisk',
        primaryFactor: 'forecastFactorSteadyCare',
      );

      await tester.pumpWidget(_wrap(
        BotanicaHealthForecastMini(forecast: forecast),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'Health forecast sparkline')),
        findsOneWidget,
      );
    });

    testWidgets('sparkline semantics includes trend improving',
        (tester) async {
      final forecast = PlantHealthForecast(
        plantId: 'test-plant-2',
        currentHealth: 0.6,
        forecastPoints: [
          HealthForecastPoint(
            date: DateTime(2026, 5, 18),
            predictedHealth: 0.62,
            confidence: 0.9,
          ),
          HealthForecastPoint(
            date: DateTime(2026, 5, 19),
            predictedHealth: 0.65,
            confidence: 0.85,
          ),
        ],
        trendDirection: 'improving',
        riskLevel: 'forecastLowRisk',
        primaryFactor: 'forecastFactorSteadyCare',
      );

      await tester.pumpWidget(_wrap(
        BotanicaHealthForecastMini(forecast: forecast),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'trend improving')),
        findsOneWidget,
      );
    });

    testWidgets('sparkline semantics includes trend declining',
        (tester) async {
      final forecast = PlantHealthForecast(
        plantId: 'test-plant-3',
        currentHealth: 0.5,
        forecastPoints: [
          HealthForecastPoint(
            date: DateTime(2026, 5, 18),
            predictedHealth: 0.45,
            confidence: 0.9,
          ),
          HealthForecastPoint(
            date: DateTime(2026, 5, 19),
            predictedHealth: 0.40,
            confidence: 0.85,
          ),
        ],
        trendDirection: 'declining',
        riskLevel: 'forecastModerateRisk',
        primaryFactor: 'forecastFactorDecliningAttention',
      );

      await tester.pumpWidget(_wrap(
        BotanicaHealthForecastMini(forecast: forecast),
      ));

      expect(
        find.bySemanticsLabel(RegExp(r'trend declining')),
        findsOneWidget,
      );
    });
  });
}
