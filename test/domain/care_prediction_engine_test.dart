import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_prediction_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';

CareLog _waterLog(DateTime ts, {String plantId = 'p1'}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

CareLog _fertLog(DateTime ts, {String plantId = 'p1'}) => CareLog(
      id: 'fert_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.fertilize,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('CarePredictionEngine', () {
    test('returns null with fewer than 3 water logs', () {
      final logs = [
        _waterLog(now.subtract(const Duration(days: 7))),
        _waterLog(now.subtract(const Duration(days: 14))),
      ];
      expect(
        CarePredictionEngine.predictNextWatering(
          plantId: 'p1', logs: logs, now: now),
        isNull,
      );
    });

    test('predicts based on regular intervals', () {
      final logs = List.generate(5, (i) =>
          _waterLog(now.subtract(Duration(days: i * 7))));

      final prediction = CarePredictionEngine.predictNextWatering(
        plantId: 'p1', logs: logs, now: now);

      expect(prediction, isNotNull);
      expect(prediction!.averageInterval, closeTo(7.0, 1.0));
      expect(prediction.confidence, greaterThan(0.7));
    });

    test('high confidence for consistent intervals', () {
      final logs = List.generate(6, (i) =>
          _waterLog(now.subtract(Duration(days: i * 5))));

      final prediction = CarePredictionEngine.predictNextWatering(
        plantId: 'p1', logs: logs, now: now);

      expect(prediction!.confidence, greaterThan(0.85));
    });

    test('lower confidence for irregular intervals', () {
      final logs = [
        _waterLog(now),
        _waterLog(now.subtract(const Duration(days: 3))),
        _waterLog(now.subtract(const Duration(days: 12))),
        _waterLog(now.subtract(const Duration(days: 14))),
        _waterLog(now.subtract(const Duration(days: 28))),
      ];

      final prediction = CarePredictionEngine.predictNextWatering(
        plantId: 'p1', logs: logs, now: now);

      expect(prediction, isNotNull);
      expect(prediction!.confidence, lessThan(0.8));
    });

    test('ignores non-water logs', () {
      final logs = [
        _waterLog(now.subtract(const Duration(days: 7))),
        _fertLog(now.subtract(const Duration(days: 5))),
        _waterLog(now.subtract(const Duration(days: 14))),
        _fertLog(now.subtract(const Duration(days: 10))),
      ];

      expect(
        CarePredictionEngine.predictNextWatering(
          plantId: 'p1', logs: logs, now: now),
        isNull,
      );
    });

    test('ignores logs from other plants', () {
      final logs = [
        _waterLog(now.subtract(const Duration(days: 7)), plantId: 'p1'),
        _waterLog(now.subtract(const Duration(days: 14)), plantId: 'p1'),
        _waterLog(now.subtract(const Duration(days: 21)), plantId: 'p1'),
        _waterLog(now.subtract(const Duration(days: 3)), plantId: 'other'),
        _waterLog(now.subtract(const Duration(days: 6)), plantId: 'other'),
      ];

      final prediction = CarePredictionEngine.predictNextWatering(
        plantId: 'p1', logs: logs, now: now);

      expect(prediction, isNotNull);
      expect(prediction!.basedOnLogs, 3);
    });

    test('recent intervals weighted more heavily', () {
      // Recent: every 5 days, older: every 10 days
      final logs = [
        _waterLog(now.subtract(const Duration(days: 0))),
        _waterLog(now.subtract(const Duration(days: 5))),
        _waterLog(now.subtract(const Duration(days: 10))),
        _waterLog(now.subtract(const Duration(days: 20))),
        _waterLog(now.subtract(const Duration(days: 30))),
      ];

      final prediction = CarePredictionEngine.predictNextWatering(
        plantId: 'p1', logs: logs, now: now);

      expect(prediction, isNotNull);
      expect(prediction!.averageInterval, lessThan(8.0));
    });

    test('predicted date is in the future for regular care', () {
      final logs = List.generate(5, (i) =>
          _waterLog(now.subtract(Duration(days: i * 7))));

      final prediction = CarePredictionEngine.predictNextWatering(
        plantId: 'p1', logs: logs, now: now);

      expect(prediction!.predictedDate.isAfter(now), isTrue);
    });

    test('humanReadablePrediction returns correct key', () {
      final futureDate = now.add(const Duration(hours: 6));
      final prediction = CarePrediction(
        predictedDate: futureDate,
        confidence: 0.8,
        basedOnLogs: 5,
        averageInterval: 7.0,
      );

      expect(
        CarePredictionEngine.humanReadablePrediction(
          prediction: prediction, now: now),
        'predictToday',
      );
    });

    test('humanReadablePrediction returns predictTomorrow', () {
      final prediction = CarePrediction(
        predictedDate: now.add(const Duration(hours: 30)),
        confidence: 0.8,
        basedOnLogs: 5,
        averageInterval: 7.0,
      );

      expect(
        CarePredictionEngine.humanReadablePrediction(
          prediction: prediction, now: now),
        'predictTomorrow',
      );
    });

    test('humanReadablePrediction returns predictInDays', () {
      final prediction = CarePrediction(
        predictedDate: now.add(const Duration(days: 4)),
        confidence: 0.8,
        basedOnLogs: 5,
        averageInterval: 7.0,
      );

      expect(
        CarePredictionEngine.humanReadablePrediction(
          prediction: prediction, now: now),
        'predictInDays',
      );
    });

    test('daysUntil calculates correctly', () {
      final prediction = CarePrediction(
        predictedDate: now.add(const Duration(days: 3)),
        confidence: 0.8,
        basedOnLogs: 5,
        averageInterval: 7.0,
      );

      expect(CarePredictionEngine.daysUntil(prediction, now), 3);
    });
  });
}
