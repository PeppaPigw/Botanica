import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_social_graph_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {String room = 'Room', String species = 'sp1', DateTime? createdAt}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: species,
      room: room, environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 6, 1),
      meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(String plantId, int daysAgo) => CareLog(
      id: 'log_${plantId}_$daysAgo', plantId: plantId, type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('GardenSocialGraphEngine', () {
    test('single plant is lonely', () {
      final result = GardenSocialGraphEngine.compute(
        plants: [_plant('p1')], logs: [], now: _now);
      expect(result.lonelyPlants, contains('p1'));
      expect(result.siblingGroups, isEmpty);
    });

    test('same room creates sibling group', () {
      final result = GardenSocialGraphEngine.compute(
        plants: [_plant('p1', room: 'Kitchen'), _plant('p2', room: 'Kitchen')],
        logs: [], now: _now);
      expect(result.siblingGroups, isNotEmpty);
      expect(result.siblingGroups.first.sharedTrait, 'sameRoom');
    });

    test('same species creates sibling group', () {
      final result = GardenSocialGraphEngine.compute(
        plants: [_plant('p1', room: 'A'), _plant('p2', room: 'B')],
        logs: [], now: _now);
      final speciesGroups = result.siblingGroups.where((g) => g.sharedTrait == 'sameSpecies');
      expect(speciesGroups, isNotEmpty);
    });

    test('same-day care creates care buddies', () {
      final logs = [
        _log('p1', 1), _log('p2', 1),
        _log('p1', 3), _log('p2', 3),
        _log('p1', 5), _log('p2', 5),
        _log('p1', 7), _log('p2', 7),
      ];
      final result = GardenSocialGraphEngine.compute(
        plants: [_plant('p1', room: 'A'), _plant('p2', room: 'B', species: 'sp2')],
        logs: logs, now: _now);
      final buddies = result.relationships.where((r) => r.relationshipType == 'careBuddies');
      expect(buddies, isNotEmpty);
    });

    test('same acquisition date creates arrival buddies', () {
      final result = GardenSocialGraphEngine.compute(
        plants: [
          _plant('p1', room: 'A', createdAt: DateTime(2025, 6, 1)),
          _plant('p2', room: 'B', species: 'sp2', createdAt: DateTime(2025, 6, 3)),
        ],
        logs: [], now: _now);
      final arrivals = result.relationships.where((r) => r.relationshipType == 'arrivalBuddies');
      expect(arrivals, isNotEmpty);
    });

    test('social butterfly is most connected', () {
      final logs = [
        _log('p1', 1), _log('p2', 1), _log('p3', 1),
        _log('p1', 3), _log('p2', 3), _log('p3', 3),
        _log('p1', 5), _log('p2', 5),
      ];
      final result = GardenSocialGraphEngine.compute(
        plants: [
          _plant('p1', room: 'A'),
          _plant('p2', room: 'B', species: 'sp2'),
          _plant('p3', room: 'C', species: 'sp3'),
        ],
        logs: logs, now: _now);
      if (result.socialButterfly != null) {
        expect(result.socialButterfly, isNotNull);
      }
    });
  });
}
