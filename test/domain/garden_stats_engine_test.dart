import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_stats_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant({String id = 'p1', String room = 'Room', DateTime? createdAt}) =>
    Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: room,
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(DateTime ts, {
  String plantId = 'p1',
  TaskType type = TaskType.water,
}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('GardenStatsEngine', () {
    test('returns empty for no data', () {
      final stats = GardenStatsEngine.compute(
        plants: [], logs: [], now: now);
      expect(stats, isEmpty);
    });

    test('includes total care actions', () {
      final logs = List.generate(10, (i) =>
          _log(now.subtract(Duration(days: i))));
      final stats = GardenStatsEngine.compute(
        plants: [_plant()], logs: logs, now: now);
      final total = stats.where((s) => s.key == 'totalCareActions');
      expect(total, isNotEmpty);
      expect(total.first.value, '10');
    });

    test('includes room count when multiple rooms', () {
      final plants = [
        _plant(id: 'p1', room: 'Living Room'),
        _plant(id: 'p2', room: 'Bedroom'),
        _plant(id: 'p3', room: 'Kitchen'),
      ];
      final stats = GardenStatsEngine.compute(
        plants: plants, logs: [], now: now);
      final rooms = stats.where((s) => s.key == 'roomCount');
      expect(rooms, isNotEmpty);
      expect(rooms.first.value, '3');
    });

    test('does not include room count for single room', () {
      final stats = GardenStatsEngine.compute(
        plants: [_plant()], logs: [], now: now);
      expect(stats.any((s) => s.key == 'roomCount'), isFalse);
    });

    test('computes average care per day', () {
      final logs = List.generate(10, (i) =>
          _log(now.subtract(Duration(days: i))));
      final stats = GardenStatsEngine.compute(
        plants: [_plant()], logs: logs, now: now);
      final avg = stats.where((s) => s.key == 'avgCarePerDay');
      expect(avg, isNotEmpty);
      expect(double.parse(avg.first.value), closeTo(1.0, 0.2));
    });

    test('detects favorite hour', () {
      final logs = List.generate(8, (i) =>
          _log(DateTime(2026, 5, 16 - i, 8, 30)));
      final stats = GardenStatsEngine.compute(
        plants: [_plant()], logs: logs, now: now);
      final hour = stats.where((s) => s.key == 'favoriteHour');
      expect(hour, isNotEmpty);
      expect(hour.first.value, '8');
    });

    test('detects most cared plant', () {
      final plants = [
        _plant(id: 'p1'),
        _plant(id: 'p2'),
      ];
      final logs = [
        ...List.generate(8, (i) =>
            _log(now.subtract(Duration(days: i)), plantId: 'p1')),
        _log(now.subtract(const Duration(days: 1)), plantId: 'p2'),
      ];
      final stats = GardenStatsEngine.compute(
        plants: plants, logs: logs, now: now);
      final most = stats.where((s) => s.key == 'mostCaredPlant');
      expect(most, isNotEmpty);
      expect(most.first.value, 'Plant p1');
    });

    test('detects care type diversity', () {
      final logs = [
        _log(now.subtract(const Duration(days: 1)), type: TaskType.water),
        _log(now.subtract(const Duration(days: 2)), type: TaskType.fertilize),
        _log(now.subtract(const Duration(days: 3)), type: TaskType.mist),
        _log(now.subtract(const Duration(days: 4)), type: TaskType.rotate),
        _log(now.subtract(const Duration(days: 5)), type: TaskType.water),
      ];
      final stats = GardenStatsEngine.compute(
        plants: [_plant()], logs: logs, now: now);
      final diversity = stats.where((s) => s.key == 'careTypeDiversity');
      expect(diversity, isNotEmpty);
      expect(diversity.first.value, '4');
    });

    test('detects oldest plant', () {
      final plants = [
        _plant(id: 'p1', createdAt: DateTime(2024, 1, 1)),
        _plant(id: 'p2', createdAt: DateTime(2025, 6, 1)),
      ];
      final stats = GardenStatsEngine.compute(
        plants: plants, logs: [], now: now);
      final oldest = stats.where((s) => s.key == 'oldestPlant');
      expect(oldest, isNotEmpty);
      expect(oldest.first.value, startsWith('Plant p1'));
    });

    test('detects busiest weekday', () {
      // Create logs mostly on Tuesdays (weekday=2)
      // May 12, May 5, Apr 28, Apr 21, Apr 14 are all Tuesdays
      final logs = <CareLog>[];
      for (int week = 0; week < 5; week++) {
        final tuesday = DateTime(2026, 5, 12 - week * 7, 9, 0);
        logs.add(_log(tuesday));
      }
      // Add some other days
      logs.add(_log(DateTime(2026, 5, 14, 10, 0)));
      logs.add(_log(DateTime(2026, 5, 15, 10, 0)));

      final stats = GardenStatsEngine.compute(
        plants: [_plant()], logs: logs, now: now);
      final busiest = stats.where((s) => s.key == 'busiestWeekday');
      expect(busiest, isNotEmpty);
      expect(busiest.first.value, '2'); // Tuesday
    });

    test('excludes archived plants', () {
      final archived = Plant(
        id: 'archived',
        nickname: 'Dead',
        speciesId: 'sp1',
        room: 'Special Room',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1),
        meta: const PlantMeta(),
        isArchived: true,
      );
      final stats = GardenStatsEngine.compute(
        plants: [archived, _plant(room: 'Room')],
        logs: [],
        now: now,
      );
      final rooms = stats.where((s) => s.key == 'roomCount');
      expect(rooms, isEmpty);
    });
  });
}
