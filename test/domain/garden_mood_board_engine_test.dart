import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_mood_board_engine.dart';
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
  group('GardenMoodBoardEngine', () {
    test('empty garden returns empty mood', () {
      final board = GardenMoodBoardEngine.compute(
        plants: [], logs: [], healthScores: {}, now: _now,
      );
      expect(board.dominantMood, 'moodEmpty');
      expect(board.plantMoods, isEmpty);
    });

    test('thriving mood with high health and care', () {
      final logs = List.generate(5, (i) => _log('p1', i + 1));
      final board = GardenMoodBoardEngine.compute(
        plants: [_plant('p1')], logs: logs,
        healthScores: {'p1': 0.9}, now: _now,
      );
      expect(board.plantMoods.first.mood, 'moodThriving');
      expect(board.overallVibes, greaterThan(0.8));
    });

    test('lonely mood with no recent care', () {
      final board = GardenMoodBoardEngine.compute(
        plants: [_plant('p1')], logs: [],
        healthScores: {'p1': 0.4}, now: _now,
      );
      expect(board.plantMoods.first.mood, 'moodLonely');
    });

    test('skips archived plants', () {
      final board = GardenMoodBoardEngine.compute(
        plants: [_plant('p1', archived: true)], logs: [],
        healthScores: {'p1': 0.9}, now: _now,
      );
      expect(board.dominantMood, 'moodEmpty');
    });

    test('mood distribution counts correctly', () {
      final logs = List.generate(4, (i) => _log('p1', i + 1));
      final board = GardenMoodBoardEngine.compute(
        plants: [_plant('p1'), _plant('p2')],
        logs: logs,
        healthScores: {'p1': 0.9, 'p2': 0.4}, now: _now,
      );
      expect(board.moodDistribution.values.reduce((a, b) => a + b), 2);
    });
  });
}
