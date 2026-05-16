import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_lineage_engine.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/enums.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

Plant _plant(String id, {DateTime? createdAt, bool archived = false}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 6, 1),
      meta: const PlantMeta(), isArchived: archived,
    );

void main() {
  group('PlantLineageEngine', () {
    test('empty garden returns minimal legacy', () {
      final result = PlantLineageEngine.compute(
        plants: [], parentMap: {}, propagationMethods: {}, now: _now);
      expect(result.totalGenerations, 0);
      expect(result.founderCount, 0);
      expect(result.oldestPlant, isNull);
    });

    test('single plant is a founder', () {
      final result = PlantLineageEngine.compute(
        plants: [_plant('p1')],
        parentMap: {'p1': null},
        propagationMethods: {},
        now: _now,
      );
      expect(result.founderCount, 1);
      expect(result.propagatedCount, 0);
      expect(result.totalGenerations, 1);
    });

    test('parent-child relationship tracked', () {
      final result = PlantLineageEngine.compute(
        plants: [_plant('p1'), _plant('p2')],
        parentMap: {'p1': null, 'p2': 'p1'},
        propagationMethods: {'p2': 'cutting'},
        now: _now,
      );
      expect(result.founderCount, 1);
      expect(result.propagatedCount, 1);
      expect(result.totalGenerations, 2);
      final child = result.lineageTree.firstWhere((n) => n.plantId == 'p2');
      expect(child.generation, 1);
      expect(child.parentId, 'p1');
    });

    test('three generations tracked', () {
      final result = PlantLineageEngine.compute(
        plants: [_plant('p1'), _plant('p2'), _plant('p3')],
        parentMap: {'p1': null, 'p2': 'p1', 'p3': 'p2'},
        propagationMethods: {},
        now: _now,
      );
      expect(result.longestLineage, 3);
      final grandchild = result.lineageTree.firstWhere((n) => n.plantId == 'p3');
      expect(grandchild.generation, 2);
    });

    test('oldest plant identified', () {
      final result = PlantLineageEngine.compute(
        plants: [
          _plant('p1', createdAt: DateTime(2024, 1, 1)),
          _plant('p2', createdAt: DateTime(2025, 6, 1)),
        ],
        parentMap: {'p1': null, 'p2': null},
        propagationMethods: {},
        now: _now,
      );
      expect(result.oldestPlant, isNotNull);
      expect(result.oldestPlant!.plantId, 'p1');
    });

    test('archived plants excluded from oldest', () {
      final result = PlantLineageEngine.compute(
        plants: [
          _plant('p1', createdAt: DateTime(2023, 1, 1), archived: true),
          _plant('p2', createdAt: DateTime(2025, 6, 1)),
        ],
        parentMap: {'p1': null, 'p2': null},
        propagationMethods: {},
        now: _now,
      );
      expect(result.oldestPlant!.plantId, 'p2');
    });

    test('milestones computed correctly', () {
      final plants = List.generate(10, (i) =>
          _plant('p$i', createdAt: DateTime(2024, 1, 1)));
      final parentMap = <String, String?>{
        for (int i = 0; i < 10; i++) 'p$i': i == 0 ? null : 'p0',
      };
      final result = PlantLineageEngine.compute(
        plants: plants, parentMap: parentMap,
        propagationMethods: {}, now: _now);
      final yearMilestone = result.milestones.firstWhere((m) => m.type == 'yearSurvivor');
      expect(yearMilestone.achieved, isTrue);
      final tenPlants = result.milestones.firstWhere((m) => m.type == 'tenPlantGarden');
      expect(tenPlants.achieved, isTrue);
    });

    test('child IDs populated on parent node', () {
      final result = PlantLineageEngine.compute(
        plants: [_plant('p1'), _plant('p2'), _plant('p3')],
        parentMap: {'p1': null, 'p2': 'p1', 'p3': 'p1'},
        propagationMethods: {},
        now: _now,
      );
      final parent = result.lineageTree.firstWhere((n) => n.plantId == 'p1');
      expect(parent.childIds, containsAll(['p2', 'p3']));
      expect(parent.hasOffspring, isTrue);
    });
  });
}
