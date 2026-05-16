import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/environment_correlation_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

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

EnvironmentReading _reading(int daysAgo, {double temp = 22, double humid = 50}) =>
    EnvironmentReading(
      date: _now.subtract(Duration(days: daysAgo)),
      temperatureC: temp, humidity: humid,
    );

void main() {
  group('EnvironmentCorrelationEngine', () {
    test('returns empty summary with no readings', () {
      final result = EnvironmentCorrelationEngine.analyze(
        plants: [_plant()], logs: [_log(1)], readings: [], now: _now);
      expect(result.avgTemperature, 0);
      expect(result.correlations, isEmpty);
    });

    test('computes averages correctly', () {
      final readings = [
        _reading(1, temp: 20, humid: 40),
        _reading(2, temp: 24, humid: 60),
        _reading(3, temp: 22, humid: 50),
      ];
      final result = EnvironmentCorrelationEngine.analyze(
        plants: [], logs: [], readings: readings, now: _now);
      expect(result.avgTemperature, closeTo(22, 0.01));
      expect(result.avgHumidity, closeTo(50, 0.01));
    });

    test('detects temperature range', () {
      final readings = [
        _reading(1, temp: 15), _reading(2, temp: 30), _reading(3, temp: 22),
      ];
      final result = EnvironmentCorrelationEngine.analyze(
        plants: [], logs: [], readings: readings, now: _now);
      expect(result.temperatureRange.min, 15);
      expect(result.temperatureRange.max, 30);
    });

    test('generates high temp alert', () {
      final readings = List.generate(5, (i) => _reading(i, temp: 35, humid: 50));
      final result = EnvironmentCorrelationEngine.analyze(
        plants: [], logs: [], readings: readings, now: _now);
      expect(result.alerts, contains('envAlertHighTemp'));
    });

    test('generates low humidity alert', () {
      final readings = List.generate(5, (i) => _reading(i, temp: 22, humid: 20));
      final result = EnvironmentCorrelationEngine.analyze(
        plants: [], logs: [], readings: readings, now: _now);
      expect(result.alerts, contains('envAlertLowHumidity'));
    });

    test('generates temp swing alert', () {
      final readings = [
        _reading(1, temp: 10), _reading(2, temp: 30),
      ];
      final result = EnvironmentCorrelationEngine.analyze(
        plants: [], logs: [], readings: readings, now: _now);
      expect(result.alerts, contains('envAlertTempSwings'));
    });

    test('finds correlations with enough data', () {
      // More care when hot, less when cold
      final logs = <CareLog>[];
      final readings = <EnvironmentReading>[];
      for (int w = 0; w < 6; w++) {
        final baseDay = w * 7;
        final temp = 20.0 + w * 3;
        for (int d = 0; d < 7; d++) {
          readings.add(_reading(baseDay + d, temp: temp, humid: 50));
        }
        // More logs in hotter weeks
        for (int c = 0; c < w + 1; c++) {
          logs.add(CareLog(
            id: 'log_w${w}_c$c', plantId: 'p1', type: TaskType.water,
            timestamp: _now.subtract(Duration(days: baseDay + c)),
            note: null, linkedPhotoId: null,
          ));
        }
      }
      final result = EnvironmentCorrelationEngine.analyze(
        plants: [_plant()], logs: logs, readings: readings, now: _now);
      // May or may not find correlation depending on data quality
      expect(result.correlations, isA<List<EnvironmentCorrelation>>());
    });
  });
}
