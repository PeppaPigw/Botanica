import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_delegation_engine.dart';
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

void main() {
  group('CareDelegationEngine', () {
    test('generates plan for short trip', () {
      final plan = CareDelegationEngine.generate(
        plants: [_plant('p1')], logs: [],
        speciesWaterDays: {'sp1': 3},
        startDate: _now, endDate: _now.add(const Duration(days: 3)),
        currentSeason: Season.summer,
      );
      expect(plan.summaryKey, 'delegationShortTrip');
      expect(plan.tasks, isNotEmpty);
    });

    test('marks critical plants with short water cycles', () {
      final plan = CareDelegationEngine.generate(
        plants: [_plant('p1', speciesId: 'fern')],
        logs: [],
        speciesWaterDays: {'fern': 2},
        startDate: _now, endDate: _now.add(const Duration(days: 14)),
        currentSeason: Season.summer,
      );
      expect(plan.criticalPlants, contains('p1'));
    });

    test('adjusts frequency for summer', () {
      final plan = CareDelegationEngine.generate(
        plants: [_plant('p1')], logs: [],
        speciesWaterDays: {'sp1': 5},
        startDate: _now, endDate: _now.add(const Duration(days: 10)),
        currentSeason: Season.summer,
      );
      final waterTask = plan.tasks.where((t) => t.taskType == TaskType.water).first;
      expect(waterTask.frequencyDays, lessThan(5));
    });

    test('extended absence summary for long trips', () {
      final plan = CareDelegationEngine.generate(
        plants: [_plant('p1')], logs: [],
        speciesWaterDays: {'sp1': 5},
        startDate: _now, endDate: _now.add(const Duration(days: 14)),
        currentSeason: Season.spring,
      );
      expect(plan.summaryKey, 'delegationExtendedAbsence');
    });

    test('includes mist tasks for trips over 14 days', () {
      final plan = CareDelegationEngine.generate(
        plants: [_plant('p1')], logs: [],
        speciesWaterDays: {'sp1': 7},
        startDate: _now, endDate: _now.add(const Duration(days: 15)),
        currentSeason: Season.spring,
      );
      final mistTasks = plan.tasks.where((t) => t.taskType == TaskType.mist);
      expect(mistTasks, isNotEmpty);
    });

    test('skips archived plants', () {
      final archived = Plant(
        id: 'pa', nickname: 'Archived', speciesId: 'sp1',
        room: 'Room', environmentMode: EnvironmentMode.indoor,
        coverAsset: null, coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: true,
      );
      final plan = CareDelegationEngine.generate(
        plants: [archived], logs: [],
        speciesWaterDays: {'sp1': 3},
        startDate: _now, endDate: _now.add(const Duration(days: 7)),
        currentSeason: Season.spring,
      );
      expect(plan.tasks, isEmpty);
    });
  });
}
