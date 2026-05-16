import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/services/garden_wellness_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Use a Wednesday so weekday math is straightforward.
  final now = DateTime(2025, 5, 14); // Wednesday

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

  group('GardenWellnessSummary careMomentum', () {
    test('stable when both weeks have zero logs', () {
      final summary = GardenWellnessSummary.compute(
        plants: [makePlant('p1')],
        tasks: <TaskInstance>[],
        logs: <CareLog>[],
        now: now,
      );
      expect(summary.careMomentum, CareMomentum.stable);
    });

    test('increasing when this week has more logs than last week', () {
      // This week: 3 logs, last week: 1 log
      final thisWeekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

      final logs = [
        makeLog('p1', thisWeekStart.add(const Duration(hours: 1))),
        makeLog('p1', thisWeekStart.add(const Duration(hours: 5))),
        makeLog('p1', thisWeekStart.add(const Duration(hours: 10))),
        makeLog('p1', lastWeekStart.add(const Duration(hours: 2))),
      ];

      final summary = GardenWellnessSummary.compute(
        plants: [makePlant('p1')],
        tasks: <TaskInstance>[],
        logs: logs,
        now: now,
      );
      expect(summary.careMomentum, CareMomentum.increasing);
    });

    test('decreasing when last week had 2+ more logs than this week', () {
      // This week: 1 log, last week: 4 logs (diff >= 2)
      final thisWeekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

      final logs = [
        makeLog('p1', thisWeekStart.add(const Duration(hours: 1))),
        makeLog('p1', lastWeekStart.add(const Duration(hours: 1))),
        makeLog('p1', lastWeekStart.add(const Duration(hours: 5))),
        makeLog('p1', lastWeekStart.add(const Duration(hours: 10))),
        makeLog('p1', lastWeekStart.add(const Duration(hours: 15))),
      ];

      final summary = GardenWellnessSummary.compute(
        plants: [makePlant('p1')],
        tasks: <TaskInstance>[],
        logs: logs,
        now: now,
      );
      expect(summary.careMomentum, CareMomentum.decreasing);
    });

    test('stable when difference is only 1 fewer this week', () {
      // This week: 2 logs, last week: 3 logs (diff = 1, not >= 2)
      final thisWeekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

      final logs = [
        makeLog('p1', thisWeekStart.add(const Duration(hours: 1))),
        makeLog('p1', thisWeekStart.add(const Duration(hours: 5))),
        makeLog('p1', lastWeekStart.add(const Duration(hours: 1))),
        makeLog('p1', lastWeekStart.add(const Duration(hours: 5))),
        makeLog('p1', lastWeekStart.add(const Duration(hours: 10))),
      ];

      final summary = GardenWellnessSummary.compute(
        plants: [makePlant('p1')],
        tasks: <TaskInstance>[],
        logs: logs,
        now: now,
      );
      expect(summary.careMomentum, CareMomentum.stable);
    });

    test('stable for empty garden', () {
      final summary = GardenWellnessSummary.compute(
        plants: <Plant>[],
        tasks: <TaskInstance>[],
        logs: <CareLog>[],
        now: now,
      );
      expect(summary.careMomentum, CareMomentum.stable);
    });
  });
}
