import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/services/garden_wellness_room_pulse.dart';
import 'package:botanica/domain/services/garden_wellness_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GardenWellnessRoomPulse.build', () {
    test('groups rooms and ranks the weakest room first', () {
      final summary = GardenWellnessSummary.compute(
        plants: <Plant>[
          _plant('p1', 'Monstera', 'Living room'),
          _plant('p2', 'Fern', 'Bathroom'),
          _plant('p3', 'ZZ Plant', 'Bedroom'),
          _plant('p4', 'Palm', 'Living room'),
        ],
        tasks: <TaskInstance>[
          _task(id: 't1', plantId: 'p2', dueAt: DateTime(2026, 3, 5, 7)),
          _task(id: 't2', plantId: 'p2', dueAt: DateTime(2026, 3, 6, 7)),
          _task(id: 't3', plantId: 'p1', dueAt: DateTime(2026, 3, 7, 18)),
          _task(id: 't4', plantId: 'p4', dueAt: DateTime(2026, 3, 9, 10)),
        ],
        logs: <CareLog>[
          _log('l1', 'p1', DateTime(2026, 3, 6, 8)),
          _log('l2', 'p2', DateTime(2026, 2, 10, 8)),
          _log('l3', 'p3', DateTime(2026, 3, 6, 8)),
          _log('l4', 'p4', DateTime(2026, 3, 6, 8)),
        ],
        now: DateTime(2026, 3, 7, 9),
      );

      final rooms = GardenWellnessRoomPulse.build(summary: summary);

      expect(rooms, hasLength(3));
      expect(rooms.first.name, 'Bathroom');
      expect(rooms.first.averageScore, 70);
      expect(rooms.first.overdueTasks, 2);
      expect(rooms.first.atRiskPlants, 1);
      final livingRoom = rooms.firstWhere((room) => room.name == 'Living room');
      expect(livingRoom.plantCount, 2);
    });

    test('uses Unassigned when a room is blank', () {
      final summary = GardenWellnessSummary.compute(
        plants: <Plant>[
          _plant('p1', 'Monstera', ''),
        ],
        tasks: const <TaskInstance>[],
        logs: <CareLog>[
          _log('l1', 'p1', DateTime(2026, 3, 6, 8)),
        ],
        now: DateTime(2026, 3, 7, 9),
      );

      final rooms = GardenWellnessRoomPulse.build(summary: summary);

      expect(rooms.single.name, 'Unassigned');
    });
  });
}

Plant _plant(String id, String nickname, String room) {
  return Plant(
    id: id,
    nickname: nickname,
    speciesId: 'unknown',
    room: room,
    environmentMode: EnvironmentMode.indoor,
    coverAsset: 'assets/placeholders/species/unknown.png',
    createdAt: DateTime(2026, 1, 1),
    meta: const PlantMeta(),
  );
}

TaskInstance _task({
  required String id,
  required String plantId,
  required DateTime dueAt,
}) {
  return TaskInstance(
    id: id,
    plantId: plantId,
    type: TaskType.water,
    dueAt: dueAt,
    status: TaskStatus.pending,
    createdAt: DateTime(2026, 3, 1),
    completedAt: null,
    adjustmentReasonIds: const <String>[],
  );
}

CareLog _log(String id, String plantId, DateTime timestamp) {
  return CareLog(
    id: id,
    plantId: plantId,
    type: TaskType.water,
    timestamp: timestamp,
    note: null,
    linkedPhotoId: null,
  );
}
