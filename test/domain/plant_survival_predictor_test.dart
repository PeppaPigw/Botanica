import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_survival_predictor.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {DateTime? createdAt}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(int daysAgo, {String plantId = 'p1'}) => CareLog(
      id: 'log_${plantId}_$daysAgo', plantId: plantId, type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('PlantSurvivalPredictor', () {
    test('healthy active plant has high survival', () {
      final logs = List.generate(15, (i) => _log(i * 2));
      final result = PlantSurvivalPredictor.predict(
        plants: [_plant('p1')], logs: logs,
        healthScores: {'p1': 0.9}, now: _now);
      expect(result.first.survivalProbability, greaterThan(0.7));
      expect(result.first.atRisk, isFalse);
    });

    test('neglected plant has low survival', () {
      final result = PlantSurvivalPredictor.predict(
        plants: [_plant('p1')], logs: [_log(30)],
        healthScores: {'p1': 0.3}, now: _now);
      expect(result.first.survivalProbability, lessThan(0.5));
      expect(result.first.atRisk, isTrue);
    });

    test('established plants get bonus', () {
      final oldPlant = _plant('p1', createdAt: DateTime(2024, 1, 1));
      final newPlant = _plant('p2', createdAt: _now.subtract(const Duration(days: 10)));
      final logs = [_log(1, plantId: 'p1'), _log(1, plantId: 'p2')];
      final result = PlantSurvivalPredictor.predict(
        plants: [oldPlant, newPlant], logs: logs,
        healthScores: {'p1': 0.6, 'p2': 0.6}, now: _now);
      final old = result.firstWhere((p) => p.plantId == 'p1');
      final young = result.firstWhere((p) => p.plantId == 'p2');
      expect(old.survivalProbability, greaterThan(young.survivalProbability));
    });

    test('risk factors populated for at-risk plants', () {
      final result = PlantSurvivalPredictor.predict(
        plants: [_plant('p1')], logs: [],
        healthScores: {'p1': 0.2}, now: _now);
      expect(result.first.riskFactors, isNotEmpty);
    });

    test('results sorted by survival probability ascending', () {
      final logs = List.generate(10, (i) => _log(i, plantId: 'p1'));
      final result = PlantSurvivalPredictor.predict(
        plants: [_plant('p1'), _plant('p2')],
        logs: logs,
        healthScores: {'p1': 0.9, 'p2': 0.2},
        now: _now);
      expect(result.first.survivalProbability,
          lessThanOrEqualTo(result.last.survivalProbability));
    });
  });
}
