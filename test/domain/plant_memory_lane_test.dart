import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_memory_lane.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant({String id = 'p1', DateTime? createdAt}) => Plant(
      id: id,
      nickname: 'Monstera',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(DateTime ts, {String plantId = 'p1'}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

PhotoEntry _photo(DateTime ts, {String plantId = 'p1'}) => PhotoEntry(
      id: 'photo_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      filePath: '/photos/$plantId/${ts.millisecondsSinceEpoch}.jpg',
      createdAt: ts,
      note: null,
      hash: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PlantMemoryLane', () {
    test('returns null with no data', () {
      final plant = _plant(createdAt: now);
      final result = PlantMemoryLane.surfaceMemory(
        plant: plant, logs: [], photos: [], now: now);
      expect(result, isNull);
    });

    test('detects month anniversary', () {
      // Plant created on Jan 16, now is May 16 = 4 months
      final plant = _plant(createdAt: DateTime(2026, 1, 16));
      final result = PlantMemoryLane.surfaceMemory(
        plant: plant, logs: [], photos: [], now: now);
      expect(result, isNotNull);
      expect(result!.type, MemoryType.anniversaryMonth);
      expect(result.args['months'], '4');
    });

    test('no anniversary if day does not match', () {
      final plant = _plant(createdAt: DateTime(2026, 1, 15));
      final result = PlantMemoryLane.surfaceMemory(
        plant: plant, logs: [], photos: [], now: now);
      // May not be anniversary, could still get other memories
      if (result != null) {
        expect(result.type, isNot(MemoryType.anniversaryMonth));
      }
    });

    test('detects first photo memory', () {
      final plant = _plant();
      final photos = [_photo(DateTime(2025, 3, 1))];

      bool found = false;
      for (int day = 0; day < 30; day++) {
        final result = PlantMemoryLane.surfaceMemory(
          plant: plant,
          logs: [],
          photos: photos,
          now: DateTime(2026, 5, day + 1),
        );
        if (result != null && result.type == MemoryType.firstPhoto) {
          found = true;
          expect(result.photoPath, isNotNull);
          break;
        }
      }
      expect(found, isTrue);
    });

    test('detects care comeback after long gap', () {
      final plant = _plant();
      final logs = [
        _log(DateTime(2025, 6, 1)),
        _log(DateTime(2025, 6, 5)),
        _log(DateTime(2025, 6, 10)),
        // 20-day gap
        _log(DateTime(2025, 6, 30)),
        _log(DateTime(2025, 7, 3)),
      ];

      bool found = false;
      for (int day = 0; day < 30; day++) {
        final result = PlantMemoryLane.surfaceMemory(
          plant: plant,
          logs: logs,
          photos: [],
          now: DateTime(2026, 5, day + 1),
        );
        if (result != null && result.type == MemoryType.careComeback) {
          found = true;
          break;
        }
      }
      expect(found, isTrue);
    });

    test('detects busiest day', () {
      final plant = _plant();
      final busiestDate = DateTime(2025, 8, 15);
      final logs = [
        // 4 logs on the same day
        _log(busiestDate),
        _log(busiestDate.add(const Duration(hours: 2))),
        _log(busiestDate.add(const Duration(hours: 4))),
        _log(busiestDate.add(const Duration(hours: 6))),
        // Spread other logs
        ...List.generate(8, (i) =>
            _log(DateTime(2025, 9, i + 1))),
      ];

      bool found = false;
      for (int day = 0; day < 30; day++) {
        final result = PlantMemoryLane.surfaceMemory(
          plant: plant,
          logs: logs,
          photos: [],
          now: DateTime(2026, 5, day + 1),
        );
        if (result != null && result.type == MemoryType.busiestDay) {
          found = true;
          expect(int.parse(result.args['count']!), greaterThanOrEqualTo(3));
          break;
        }
      }
      expect(found, isTrue);
    });

    test('ignores data from other plants', () {
      final plant = _plant(id: 'target', createdAt: now);
      final logs = List.generate(15, (i) =>
          _log(now.subtract(Duration(days: i)), plantId: 'other'));
      final photos = [_photo(DateTime(2025, 1, 1), plantId: 'other')];

      final result = PlantMemoryLane.surfaceMemory(
        plant: plant, logs: logs, photos: photos, now: now);
      expect(result, isNull);
    });

    test('same day returns same memory', () {
      final plant = _plant(createdAt: DateTime(2026, 1, 16));
      final r1 = PlantMemoryLane.surfaceMemory(
        plant: plant, logs: [], photos: [], now: now);
      final r2 = PlantMemoryLane.surfaceMemory(
        plant: plant, logs: [], photos: [],
        now: now.add(const Duration(hours: 5)));
      expect(r1?.type, r2?.type);
    });
  });
}
