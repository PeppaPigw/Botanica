import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_time_machine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {int monthsAgo = 6}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2026, 5 - monthsAgo, 1),
      meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(int daysAgo) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('GardenTimeMachine', () {
    test('reconstructs monthly snapshots', () {
      final result = GardenTimeMachine.reconstruct(
        allPlants: [_plant('p1', monthsAgo: 3)],
        logs: List.generate(20, (i) => _log(i * 5)),
        now: _now, monthsBack: 6,
      );
      expect(result.snapshots.length, 7);
      expect(result.totalPlantsEver, 1);
    });

    test('tracks growth over time', () {
      final plants = [
        _plant('p1', monthsAgo: 5),
        _plant('p2', monthsAgo: 3),
        _plant('p3', monthsAgo: 1),
      ];
      final result = GardenTimeMachine.reconstruct(
        allPlants: plants, logs: [], now: _now, monthsBack: 6,
      );
      expect(result.growthTimeline.last.value, 3);
      expect(result.growthTimeline.first.value, lessThan(3));
    });

    test('identifies peak month', () {
      final result = GardenTimeMachine.reconstruct(
        allPlants: [_plant('p1', monthsAgo: 4)],
        logs: [], now: _now, monthsBack: 6,
      );
      expect(result.peakMonth, greaterThanOrEqualTo(0));
    });

    test('health estimate based on care frequency', () {
      final logs = List.generate(30, (i) => _log(i + 1));
      final result = GardenTimeMachine.reconstruct(
        allPlants: [_plant('p1', monthsAgo: 2)],
        logs: logs, now: _now, monthsBack: 3,
      );
      final latestSnapshot = result.snapshots.last;
      expect(latestSnapshot.healthEstimate, greaterThan(0));
    });
  });
}
