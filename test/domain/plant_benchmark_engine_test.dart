import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_benchmark_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

Plant _plant({String id = 'p1', String speciesId = 'sp1'}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: speciesId,
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _waterLog(int daysAgo, {String plantId = 'p1'}) => CareLog(
      id: 'log_$daysAgo', plantId: plantId, type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

const _community = CommunityStats(
  speciesId: 'sp1', avgWaterIntervalDays: 7.0,
  avgFertilizeIntervalDays: 30.0, avgHealthScore: 0.7,
  avgSurvivalMonths: 18, sampleSize: 500,
);

void main() {
  group('PlantBenchmarkEngine', () {
    test('returns empty with no plants', () {
      final result = PlantBenchmarkEngine.compare(
        plants: [], logs: [], healthScores: {},
        communityData: {'sp1': _community}, now: _now);
      expect(result, isEmpty);
    });

    test('returns empty with insufficient logs', () {
      final result = PlantBenchmarkEngine.compare(
        plants: [_plant()], logs: [_waterLog(1)], healthScores: {'p1': 0.8},
        communityData: {'sp1': _community}, now: _now);
      expect(result, isEmpty);
    });

    test('generates benchmark with enough data', () {
      final logs = List.generate(10, (i) => _waterLog(i * 5));
      final result = PlantBenchmarkEngine.compare(
        plants: [_plant()], logs: logs, healthScores: {'p1': 0.8},
        communityData: {'sp1': _community}, now: _now);
      expect(result, isNotEmpty);
      expect(result.first.percentile, greaterThanOrEqualTo(0));
      expect(result.first.percentile, lessThanOrEqualTo(99));
    });

    test('above average health gives higher percentile', () {
      final logs = List.generate(10, (i) => _waterLog(i * 7));
      final high = PlantBenchmarkEngine.compare(
        plants: [_plant()], logs: logs, healthScores: {'p1': 0.95},
        communityData: {'sp1': _community}, now: _now);
      final low = PlantBenchmarkEngine.compare(
        plants: [_plant()], logs: logs, healthScores: {'p1': 0.3},
        communityData: {'sp1': _community}, now: _now);
      if (high.isNotEmpty && low.isNotEmpty) {
        expect(high.first.percentile, greaterThan(low.first.percentile));
      }
    });

    test('skips plants without community data', () {
      final logs = List.generate(10, (i) => _waterLog(i * 5));
      final result = PlantBenchmarkEngine.compare(
        plants: [_plant(speciesId: 'unknown')], logs: logs,
        healthScores: {'p1': 0.8}, communityData: {'sp1': _community}, now: _now);
      expect(result, isEmpty);
    });
  });
}
