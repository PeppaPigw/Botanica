import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/nudge_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant({
  String id = 'p1',
  DateTime? createdAt,
  bool archived = false,
}) =>
    Plant(
      id: id,
      nickname: 'Monstera',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: archived,
    );

CareLog _log(
  DateTime ts, {
  String plantId = 'p1',
  TaskType type = TaskType.water,
}) =>
    CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('NudgeEngine', () {
    test('returns empty for no plants', () {
      final nudges = NudgeEngine.generate(
        plants: [],
        logs: [],
        tasks: [],
        now: now,
        isWinter: false,
      );
      expect(nudges, isEmpty);
    });

    test('skips archived plants', () {
      final nudges = NudgeEngine.generate(
        plants: [_plant(archived: true)],
        logs: [],
        tasks: [],
        now: now,
        isWinter: false,
      );
      expect(nudges, isEmpty);
    });

    test('detects forgotten rotation', () {
      final logs = [
        _log(now.subtract(const Duration(days: 25)), type: TaskType.rotate),
      ];
      final nudges = NudgeEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        now: now,
        isWinter: false,
      );
      expect(nudges.any((n) => n.type == NudgeType.forgottenRotation), isTrue);
    });

    test('does not nudge rotation if recent', () {
      final logs = [
        _log(now.subtract(const Duration(days: 10)), type: TaskType.rotate),
      ];
      final nudges = NudgeEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        now: now,
        isWinter: false,
      );
      expect(nudges.any((n) => n.type == NudgeType.forgottenRotation), isFalse);
    });

    test('detects long since fertilize', () {
      final logs = [
        _log(now.subtract(const Duration(days: 40)), type: TaskType.fertilize),
      ];
      final nudges = NudgeEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        now: now,
        isWinter: false,
      );
      expect(nudges.any((n) => n.type == NudgeType.longSinceFertilize), isTrue);
    });

    test('does not nudge fertilize in winter', () {
      final logs = [
        _log(now.subtract(const Duration(days: 40)), type: TaskType.fertilize),
      ];
      final nudges = NudgeEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        now: now,
        isWinter: true,
      );
      expect(nudges.any((n) => n.type == NudgeType.longSinceFertilize), isFalse);
    });

    test('detects new plant needing check-up', () {
      final plant = _plant(createdAt: now.subtract(const Duration(days: 10)));
      final nudges = NudgeEngine.generate(
        plants: [plant],
        logs: [_log(now.subtract(const Duration(days: 8)))],
        tasks: [],
        now: now,
        isWinter: false,
      );
      expect(nudges.any((n) => n.type == NudgeType.newPlantCheckUp), isTrue);
    });

    test('does not nudge new plant if well-cared', () {
      final plant = _plant(createdAt: now.subtract(const Duration(days: 10)));
      final logs = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: i + 1))));
      final nudges = NudgeEngine.generate(
        plants: [plant],
        logs: logs,
        tasks: [],
        now: now,
        isWinter: false,
      );
      expect(nudges.any((n) => n.type == NudgeType.newPlantCheckUp), isFalse);
    });

    test('detects dusty leaves', () {
      final logs = [
        _log(now.subtract(const Duration(days: 25)), type: TaskType.wipeLeaves),
      ];
      final nudges = NudgeEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        now: now,
        isWinter: false,
      );
      expect(nudges.any((n) => n.type == NudgeType.dustyLeaves), isTrue);
    });

    test('detects growth spurt', () {
      final logs = [
        // 5 waterings in last 14 days
        ...List.generate(5, (i) =>
            _log(now.subtract(Duration(days: i * 2)))),
        // 2 waterings in 14-28 days ago
        _log(now.subtract(const Duration(days: 18))),
        _log(now.subtract(const Duration(days: 25))),
        // Prevent other nudges from crowding out growth spurt
        _log(now.subtract(const Duration(days: 5)), type: TaskType.fertilize),
        _log(now.subtract(const Duration(days: 5)), type: TaskType.wipeLeaves),
      ];
      final nudges = NudgeEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        now: now,
        isWinter: false,
        maxNudges: 5,
      );
      expect(nudges.any((n) => n.type == NudgeType.growthSpurt), isTrue);
    });

    test('limits to maxNudges', () {
      final logs = [
        _log(now.subtract(const Duration(days: 25)), type: TaskType.rotate),
        _log(now.subtract(const Duration(days: 40)), type: TaskType.fertilize),
        _log(now.subtract(const Duration(days: 25)), type: TaskType.wipeLeaves),
      ];
      final nudges = NudgeEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        now: now,
        isWinter: false,
        maxNudges: 1,
      );
      expect(nudges.length, 1);
    });

    test('higher priority nudges come first', () {
      final logs = [
        _log(now.subtract(const Duration(days: 25)), type: TaskType.rotate),
        _log(now.subtract(const Duration(days: 40)), type: TaskType.fertilize),
      ];
      final nudges = NudgeEngine.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        now: now,
        isWinter: false,
      );
      if (nudges.length >= 2) {
        expect(
          nudges.first.priority.index,
          greaterThanOrEqualTo(nudges.last.priority.index),
        );
      }
    });
  });
}
