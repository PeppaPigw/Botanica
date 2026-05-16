import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/emotional_bond_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {String room = 'Room', int daysAgo = 180, String speciesId = 'sp1'}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: speciesId,
      room: room, environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: _now.subtract(Duration(days: daysAgo)),
      meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(String plantId, int daysAgo) => CareLog(
      id: 'log_${plantId}_$daysAgo', plantId: plantId, type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('EmotionalBondEngine', () {
    test('empty with no plants', () {
      final bonds = EmotionalBondEngine.compute(
        plants: [], logs: [], now: _now,
      );
      expect(bonds, isEmpty);
    });

    test('stronger bond with more care', () {
      final logs = List.generate(60, (i) => _log('p1', i));
      final bonds = EmotionalBondEngine.compute(
        plants: [_plant('p1', daysAgo: 400)], logs: logs, now: _now,
      );
      expect(bonds.first.bondStrength, greaterThan(0.5));
      expect(bonds.first.bondType, isNot('bondAcquaintance'));
    });

    test('new friend for recent plants', () {
      final bonds = EmotionalBondEngine.compute(
        plants: [_plant('p1', daysAgo: 10)], logs: [_log('p1', 1)], now: _now,
      );
      expect(bonds.first.bondType, 'bondNewFriend');
    });

    test('detects roommate relationships', () {
      final plants = [
        _plant('p1', room: 'Kitchen'),
        _plant('p2', room: 'Kitchen'),
      ];
      final bonds = EmotionalBondEngine.compute(
        plants: plants, logs: [], now: _now,
      );
      final p1Bond = bonds.firstWhere((b) => b.plantId == 'p1');
      expect(p1Bond.relationships.any((r) => r.relationshipType == 'relationRoommate'), isTrue);
    });

    test('detects sibling relationships', () {
      final plants = [
        _plant('p1', speciesId: 'fern'),
        _plant('p2', speciesId: 'fern'),
      ];
      final bonds = EmotionalBondEngine.compute(
        plants: plants, logs: [], now: _now,
      );
      final p1Bond = bonds.firstWhere((b) => b.plantId == 'p1');
      expect(p1Bond.relationships.any((r) => r.relationshipType == 'relationSibling'), isTrue);
    });

    test('sorted by bond strength descending', () {
      final plants = [_plant('p1', daysAgo: 30), _plant('p2', daysAgo: 400)];
      final logs = List.generate(50, (i) => _log('p2', i));
      final bonds = EmotionalBondEngine.compute(
        plants: plants, logs: logs, now: _now,
      );
      expect(bonds.first.plantId, 'p2');
    });
  });
}
