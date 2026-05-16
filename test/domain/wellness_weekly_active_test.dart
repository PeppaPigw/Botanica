import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/services/garden_wellness_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2025, 5, 15);

  Plant makePlant(String id) => Plant(
        id: id,
        nickname: 'Plant $id',
        speciesId: 'species-1',
        room: 'Living Room',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: now.subtract(const Duration(days: 60)),
        meta: const PlantMeta(),
        isArchived: false,
      );

  CareLog makeLog(String plantId, DateTime timestamp) => CareLog(
        id: 'log-${timestamp.hashCode}-$plantId',
        plantId: plantId,
        type: TaskType.water,
        timestamp: timestamp,
        note: null,
        linkedPhotoId: null,
      );

  group('GardenWellnessSummary weeklyActivePercent', () {
    test('100% when every week has at least one log', () {
      final plants = [makePlant('p1')];
      final logs = List.generate(8, (i) {
        final day = now.subtract(Duration(days: (i * 7) + 1));
        return makeLog('p1', day);
      });

      final summary = GardenWellnessSummary.compute(
        plants: plants,
        tasks: const <TaskInstance>[],
        logs: logs,
        now: now,
      );

      expect(summary.weeklyActivePercent, equals(100));
    });

    test('0% when no logs in last 8 weeks', () {
      final plants = [makePlant('p1')];
      final logs = [makeLog('p1', now.subtract(const Duration(days: 100)))];

      final summary = GardenWellnessSummary.compute(
        plants: plants,
        tasks: const <TaskInstance>[],
        logs: logs,
        now: now,
      );

      expect(summary.weeklyActivePercent, equals(0));
    });

    test('50% when 4 of 8 weeks have logs', () {
      final plants = [makePlant('p1')];
      final logs = [
        makeLog('p1', now.subtract(const Duration(days: 1))),
        makeLog('p1', now.subtract(const Duration(days: 8))),
        makeLog('p1', now.subtract(const Duration(days: 15))),
        makeLog('p1', now.subtract(const Duration(days: 22))),
      ];

      final summary = GardenWellnessSummary.compute(
        plants: plants,
        tasks: const <TaskInstance>[],
        logs: logs,
        now: now,
      );

      expect(summary.weeklyActivePercent, equals(50));
    });

    test('empty garden returns 0', () {
      final summary = GardenWellnessSummary.compute(
        plants: const [],
        tasks: const [],
        logs: const [],
        now: now,
      );

      expect(summary.weeklyActivePercent, equals(0));
    });
  });
}
