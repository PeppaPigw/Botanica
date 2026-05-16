import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/watering_batch_planner.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {String speciesId = 'sp1'}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: speciesId,
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _waterLog(int daysAgo, int weekday) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: DateTime(2026, 5, 17 - daysAgo).copyWith(hour: 9),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('WateringBatchPlanner', () {
    test('empty plan for no plants', () {
      final plan = WateringBatchPlanner.plan(
        plants: [], speciesWaterDays: {}, logs: [], now: _now,
      );
      expect(plan.slots, isEmpty);
      expect(plan.suggestedDays, 0);
    });

    test('creates slots for active plants', () {
      final plants = List.generate(5, (i) => _plant('p$i'));
      final plan = WateringBatchPlanner.plan(
        plants: plants,
        speciesWaterDays: {'sp1': 7},
        logs: [], now: _now,
      );
      expect(plan.slots, isNotEmpty);
      expect(plan.totalPlantsPerWeek, 5);
    });

    test('uses preferred days from history', () {
      final logs = List.generate(10, (i) => CareLog(
        id: 'log_$i', plantId: 'p1', type: TaskType.water,
        timestamp: _now.subtract(Duration(days: i * 3)),
        note: null, linkedPhotoId: null,
      ));
      final plan = WateringBatchPlanner.plan(
        plants: [_plant('p1')],
        speciesWaterDays: {'sp1': 7},
        logs: logs, now: _now,
      );
      expect(plan.slots, isNotEmpty);
    });

    test('skips archived plants', () {
      final archived = Plant(
        id: 'pa', nickname: 'Archived', speciesId: 'sp1',
        room: 'Room', environmentMode: EnvironmentMode.indoor,
        coverAsset: null, coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: true,
      );
      final plan = WateringBatchPlanner.plan(
        plants: [archived], speciesWaterDays: {'sp1': 3}, logs: [], now: _now,
      );
      expect(plan.slots, isEmpty);
    });

    test('efficiency score between 0 and 1', () {
      final plants = List.generate(8, (i) => _plant('p$i'));
      final plan = WateringBatchPlanner.plan(
        plants: plants, speciesWaterDays: {'sp1': 5}, logs: [], now: _now,
      );
      expect(plan.batchEfficiency, greaterThan(0.0));
      expect(plan.batchEfficiency, lessThanOrEqualTo(1.0));
    });
  });
}
