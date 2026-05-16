import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/predictive_needs_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _waterLog(String plantId, int daysAgo) => CareLog(
      id: 'log_${plantId}_$daysAgo', plantId: plantId, type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('PredictiveNeedsEngine', () {
    test('no predictions with insufficient data', () {
      final report = PredictiveNeedsEngine.predict(
        plants: [_plant('p1')], logs: [_waterLog('p1', 1)], now: _now,
      );
      expect(report.predictions, isEmpty);
    });

    test('predicts next watering from pattern', () {
      final logs = List.generate(5, (i) => _waterLog('p1', i * 7));
      final report = PredictiveNeedsEngine.predict(
        plants: [_plant('p1')], logs: logs, now: _now,
      );
      expect(report.predictions, isNotEmpty);
      expect(report.predictions.first.predictedNeed, TaskType.water);
    });

    test('confidence reflects consistency', () {
      final logs = List.generate(5, (i) => _waterLog('p1', i * 7));
      final report = PredictiveNeedsEngine.predict(
        plants: [_plant('p1')], logs: logs, now: _now,
      );
      expect(report.predictions.first.confidence, greaterThan(0.3));
    });

    test('accuracy improves with more data', () {
      final fewLogs = List.generate(5, (i) => _waterLog('p1', i * 5));
      final manyLogs = List.generate(60, (i) => _waterLog('p1', i * 2));
      final few = PredictiveNeedsEngine.predict(
        plants: [_plant('p1')], logs: fewLogs, now: _now,
      );
      final many = PredictiveNeedsEngine.predict(
        plants: [_plant('p1')], logs: manyLogs, now: _now,
      );
      expect(many.accuracy, greaterThan(few.accuracy));
    });

    test('skips archived plants', () {
      final archived = Plant(
        id: 'pa', nickname: 'Archived', speciesId: 'sp1',
        room: 'Room', environmentMode: EnvironmentMode.indoor,
        coverAsset: null, coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: true,
      );
      final logs = List.generate(5, (i) => _waterLog('pa', i * 7));
      final report = PredictiveNeedsEngine.predict(
        plants: [archived], logs: logs, now: _now,
      );
      expect(report.predictions, isEmpty);
    });
  });
}
