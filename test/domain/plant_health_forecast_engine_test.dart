import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_health_forecast_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant() => Plant(
      id: 'p1', nickname: 'Fern', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(int daysAgo) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('PlantHealthForecastEngine', () {
    test('predicts decline with no care', () {
      final forecast = PlantHealthForecastEngine.predict(
        plant: _plant(), logs: [], currentHealth: 0.7,
        forecastDays: 14, now: _now,
      );
      expect(forecast.trendDirection, 'declining');
      expect(forecast.forecastPoints.length, 14);
      expect(forecast.forecastPoints.last.predictedHealth, lessThan(0.7));
    });

    test('stable with regular care', () {
      final logs = List.generate(10, (i) => _log(i + 1));
      final forecast = PlantHealthForecastEngine.predict(
        plant: _plant(), logs: logs, currentHealth: 0.8,
        forecastDays: 14, now: _now,
      );
      expect(forecast.riskLevel, 'forecastLowRisk');
    });

    test('high risk for low health and no care', () {
      final forecast = PlantHealthForecastEngine.predict(
        plant: _plant(), logs: [], currentHealth: 0.3,
        forecastDays: 14, now: _now,
      );
      expect(forecast.riskLevel, 'forecastHighRisk');
    });

    test('confidence decreases over time', () {
      final forecast = PlantHealthForecastEngine.predict(
        plant: _plant(), logs: [_log(1)], currentHealth: 0.6,
        forecastDays: 14, now: _now,
      );
      expect(forecast.forecastPoints.first.confidence,
          greaterThan(forecast.forecastPoints.last.confidence));
    });

    test('identifies primary factor', () {
      final forecast = PlantHealthForecastEngine.predict(
        plant: _plant(), logs: [], currentHealth: 0.3,
        forecastDays: 7, now: _now,
      );
      expect(forecast.primaryFactor, isNotEmpty);
    });
  });
}
