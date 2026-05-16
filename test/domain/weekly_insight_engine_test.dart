import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/weekly_insight_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {bool archived = false}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: archived,
    );

CareLog _log(String plantId, int daysAgo) => CareLog(
      id: 'log_${plantId}_$daysAgo', plantId: plantId, type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('WeeklyInsightEngine', () {
    test('empty digest with no logs', () {
      final digest = WeeklyInsightEngine.generate(
        plants: [_plant('p1')], logs: [],
        healthScores: {'p1': 0.8}, now: _now,
      );
      expect(digest.totalCareActions, 0);
      expect(digest.topInsight, isNull);
    });

    test('identifies most cared plant', () {
      final logs = List.generate(5, (i) => _log('p1', i + 1))
        ..add(_log('p2', 2));
      final digest = WeeklyInsightEngine.generate(
        plants: [_plant('p1'), _plant('p2')], logs: logs,
        healthScores: {'p1': 0.8, 'p2': 0.7}, now: _now,
      );
      final mostCared = digest.insights.where((i) => i.type == 'mostCared');
      expect(mostCared, isNotEmpty);
      expect(mostCared.first.plantIds, contains('p1'));
    });

    test('detects neglected plants', () {
      final logs = List.generate(3, (i) => _log('p1', i + 1));
      final digest = WeeklyInsightEngine.generate(
        plants: [_plant('p1'), _plant('p2')], logs: logs,
        healthScores: {'p1': 0.8, 'p2': 0.3}, now: _now,
      );
      final neglected = digest.insights.where((i) => i.type == 'neglected');
      expect(neglected, isNotEmpty);
      expect(neglected.first.plantIds, contains('p2'));
    });

    test('perfect week when all plants cared for', () {
      final logs = [_log('p1', 1), _log('p2', 2)];
      final digest = WeeklyInsightEngine.generate(
        plants: [_plant('p1'), _plant('p2')], logs: logs,
        healthScores: {'p1': 0.8, 'p2': 0.8}, now: _now,
      );
      final perfect = digest.insights.where((i) => i.type == 'perfectWeek');
      expect(perfect, isNotEmpty);
    });

    test('counts plants needing attention', () {
      final digest = WeeklyInsightEngine.generate(
        plants: [_plant('p1'), _plant('p2'), _plant('p3')], logs: [],
        healthScores: {'p1': 0.2, 'p2': 0.3, 'p3': 0.9}, now: _now,
      );
      expect(digest.plantsNeedingAttention, 2);
    });

    test('excludes archived plants from attention count', () {
      final digest = WeeklyInsightEngine.generate(
        plants: [_plant('p1', archived: true), _plant('p2')], logs: [],
        healthScores: {'p1': 0.1, 'p2': 0.9}, now: _now,
      );
      expect(digest.plantsNeedingAttention, 0);
    });
  });
}
