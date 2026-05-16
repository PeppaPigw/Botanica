import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_care_xp_system.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

CareLog _log(DateTime ts, {String plantId = 'p1', TaskType type = TaskType.water}) =>
    CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}_$plantId',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

Plant _plant({String id = 'p1'}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 6, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

PhotoEntry _photo({String plantId = 'p1', required DateTime createdAt}) =>
    PhotoEntry(
      id: 'photo_${createdAt.millisecondsSinceEpoch}_$plantId',
      plantId: plantId,
      filePath: '/photos/$plantId.jpg',
      createdAt: createdAt,
      note: null,
      hash: 'hash',
    );

TaskInstance _task({required DateTime dueAt, DateTime? completedAt}) =>
    TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}',
      plantId: 'p1',
      type: TaskType.water,
      dueAt: dueAt,
      status: completedAt != null ? TaskStatus.done : TaskStatus.pending,
      createdAt: dueAt.subtract(const Duration(days: 1)),
      completedAt: completedAt,
      adjustmentReasonIds: const [],
    );

void main() {
  group('PlantCareXpSystem', () {
    test('computes level 0 with no activity', () {
      final result = PlantCareXpSystem.compute(
        logs: [], tasks: [], photos: [], plants: [],
        streakDays: 0, now: _now);
      expect(result.level, 0);
      expect(result.totalXp, 0);
      expect(result.title, 'Seed Starter');
    });

    test('earns XP from care logs', () {
      final logs = List.generate(10, (i) =>
          _log(_now.subtract(Duration(days: i))));
      final result = PlantCareXpSystem.compute(
        logs: logs, tasks: [], photos: [], plants: [],
        streakDays: 0, now: _now);
      expect(result.totalXp, greaterThan(0));
    });

    test('earns XP from photos', () {
      final photos = List.generate(5, (i) =>
          _photo(createdAt: _now.subtract(Duration(days: i))));
      final result = PlantCareXpSystem.compute(
        logs: [], tasks: [], photos: photos, plants: [],
        streakDays: 0, now: _now);
      expect(result.totalXp, 5 * 15);
    });

    test('earns XP from adding plants', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2')];
      final result = PlantCareXpSystem.compute(
        logs: [], tasks: [], photos: [], plants: plants,
        streakDays: 0, now: _now);
      expect(result.totalXp, 2 * 25);
    });

    test('streak bonus adds extra XP', () {
      final logs = List.generate(5, (i) =>
          _log(_now.subtract(Duration(days: i))));
      final noStreak = PlantCareXpSystem.compute(
        logs: logs, tasks: [], photos: [], plants: [],
        streakDays: 0, now: _now);
      final withStreak = PlantCareXpSystem.compute(
        logs: logs, tasks: [], photos: [], plants: [],
        streakDays: 10, now: _now);
      expect(withStreak.totalXp, greaterThan(noStreak.totalXp));
    });

    test('levels up with sufficient XP', () {
      final logs = List.generate(100, (i) =>
          _log(_now.subtract(Duration(days: i)),
              type: TaskType.values[i % 5]));
      final plants = List.generate(5, (i) => _plant(id: 'p$i'));
      final result = PlantCareXpSystem.compute(
        logs: logs, tasks: [], photos: [], plants: plants,
        streakDays: 30, now: _now);
      expect(result.level, greaterThan(0));
      expect(result.title, isNot('Seed Starter'));
    });

    test('progress is between 0 and 1', () {
      final logs = List.generate(20, (i) =>
          _log(_now.subtract(Duration(days: i))));
      final result = PlantCareXpSystem.compute(
        logs: logs, tasks: [], photos: [], plants: [_plant()],
        streakDays: 5, now: _now);
      expect(result.progressToNext, greaterThanOrEqualTo(0.0));
      expect(result.progressToNext, lessThanOrEqualTo(1.0));
    });

    test('on-time tasks earn bonus XP', () {
      final tasks = List.generate(10, (i) {
        final due = _now.subtract(Duration(days: i));
        return _task(dueAt: due, completedAt: due);
      });
      final withTasks = PlantCareXpSystem.compute(
        logs: [], tasks: tasks, photos: [], plants: [],
        streakDays: 0, now: _now);
      final withoutTasks = PlantCareXpSystem.compute(
        logs: [], tasks: [], photos: [], plants: [],
        streakDays: 0, now: _now);
      expect(withTasks.totalXp, greaterThan(withoutTasks.totalXp));
    });

    test('recent XP events are sorted newest first', () {
      final logs = List.generate(15, (i) =>
          _log(_now.subtract(Duration(days: i))));
      final result = PlantCareXpSystem.compute(
        logs: logs, tasks: [], photos: [], plants: [],
        streakDays: 0, now: _now);
      expect(result.recentXpEvents.length, lessThanOrEqualTo(10));
      for (int i = 0; i < result.recentXpEvents.length - 1; i++) {
        expect(result.recentXpEvents[i].timestamp.isAfter(
            result.recentXpEvents[i + 1].timestamp), isTrue);
      }
    });
  });
}
