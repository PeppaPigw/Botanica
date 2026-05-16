import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_momentum_engine.dart';
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

CareLog _log(int daysAgo) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('GardenMomentumEngine', () {
    test('returns zero score with no data', () {
      final result = GardenMomentumEngine.compute(
        plants: [], logs: [], streakDays: 0, plantsAddedThisMonth: 0, now: _now,
      );
      expect(result.score, 0.0);
      expect(result.statusKey, 'momentumStalled');
    });

    test('high streak contributes to score', () {
      final result = GardenMomentumEngine.compute(
        plants: [_plant('p1')], logs: [], streakDays: 30,
        plantsAddedThisMonth: 0, now: _now,
      );
      expect(result.streakContribution, 1.0);
      expect(result.score, greaterThan(0.3));
    });

    test('high activity contributes to score', () {
      final logs = List.generate(20, (i) => _log(i + 1));
      final result = GardenMomentumEngine.compute(
        plants: [_plant('p1')], logs: logs, streakDays: 0,
        plantsAddedThisMonth: 0, now: _now,
      );
      expect(result.activityContribution, greaterThanOrEqualTo(0.7));
      expect(result.score, greaterThan(0.3));
    });

    test('positive trend when recent activity exceeds older', () {
      final recentLogs = List.generate(10, (i) => _log(i + 1));
      final olderLogs = List.generate(3, (i) => _log(i + 20));
      final result = GardenMomentumEngine.compute(
        plants: [_plant('p1')], logs: [...recentLogs, ...olderLogs],
        streakDays: 5, plantsAddedThisMonth: 1, now: _now,
      );
      expect(result.trend, greaterThan(0.0));
    });

    test('on fire status with max inputs', () {
      final logs = List.generate(25, (i) => _log(i));
      final result = GardenMomentumEngine.compute(
        plants: List.generate(5, (i) => _plant('p$i')),
        logs: logs, streakDays: 30, plantsAddedThisMonth: 3, now: _now,
      );
      expect(result.statusKey, 'momentumOnFire');
      expect(result.score, greaterThanOrEqualTo(0.8));
    });

    test('encouragement varies by state', () {
      final low = GardenMomentumEngine.compute(
        plants: [_plant('p1')], logs: [], streakDays: 0,
        plantsAddedThisMonth: 0, now: _now,
      );
      expect(low.encouragement, 'momentumEncourageStartToday');

      final mid = GardenMomentumEngine.compute(
        plants: [_plant('p1')], logs: List.generate(10, (i) => _log(i + 1)),
        streakDays: 5, plantsAddedThisMonth: 1, now: _now,
      );
      expect(mid.encouragement, isNotEmpty);
    });
  });
}
