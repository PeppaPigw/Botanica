import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_memory_lane_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {DateTime? createdAt}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('PlantMemoryLaneEngine', () {
    test('returns empty with no data', () {
      final result = PlantMemoryLaneEngine.generate(
        plants: [], logs: [], photos: [], now: _now);
      expect(result.all, isEmpty);
    });

    test('finds on-this-day photos from last year', () {
      final photos = [
        PhotoEntry(id: 'ph1', plantId: 'p1', filePath: '/p.jpg',
          createdAt: DateTime(2025, 5, 17, 12, 0), note: null, hash: 'h'),
      ];
      final result = PlantMemoryLaneEngine.generate(
        plants: [_plant('p1')], logs: [], photos: photos, now: _now);
      expect(result.onThisDay, isNotEmpty);
      expect(result.onThisDay.first.type, 'onThisDayPhoto');
    });

    test('finds milestone memories', () {
      final plant = _plant('p1', createdAt: _now.subtract(const Duration(days: 365)));
      final result = PlantMemoryLaneEngine.generate(
        plants: [plant], logs: [], photos: [], now: _now);
      final milestones = result.milestoneMemories;
      expect(milestones, isNotEmpty);
    });

    test('finds seasonal memories from last year', () {
      final logs = List.generate(15, (i) => CareLog(
        id: 'log_$i', plantId: 'p1', type: TaskType.water,
        timestamp: DateTime(2025, 5, i + 1, 10, 0),
        note: null, linkedPhotoId: null,
      ));
      final result = PlantMemoryLaneEngine.generate(
        plants: [_plant('p1')], logs: logs, photos: [], now: _now);
      expect(result.seasonalMemories, isNotEmpty);
    });

    test('all memories sorted newest first', () {
      final photos = [
        PhotoEntry(id: 'ph1', plantId: 'p1', filePath: '/p.jpg',
          createdAt: DateTime(2025, 5, 17, 12, 0), note: null, hash: 'h'),
      ];
      final plant = _plant('p1', createdAt: _now.subtract(const Duration(days: 365)));
      final result = PlantMemoryLaneEngine.generate(
        plants: [plant], logs: [], photos: photos, now: _now);
      final all = result.all;
      for (int i = 0; i < all.length - 1; i++) {
        expect(all[i].date.isAfter(all[i + 1].date) ||
            all[i].date.isAtSameMomentAs(all[i + 1].date), isTrue);
      }
    });
  });
}
