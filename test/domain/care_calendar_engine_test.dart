import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_calendar_engine.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {String speciesId = 'sp1'}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: speciesId,
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('CareCalendarEngine', () {
    test('empty calendar with no plants', () {
      final cal = CareCalendarEngine.generateWeek(
        plants: [], speciesWaterDays: {}, lastWatered: {}, now: _now,
      );
      expect(cal.events, isEmpty);
      expect(cal.totalTasks, 0);
    });

    test('overdue when never watered', () {
      final cal = CareCalendarEngine.generateWeek(
        plants: [_plant('p1')],
        speciesWaterDays: {'sp1': 7},
        lastWatered: {},
        now: _now,
      );
      expect(cal.overdueCount, 1);
      expect(cal.events.first.isOverdue, isTrue);
    });

    test('schedules future watering within week', () {
      final cal = CareCalendarEngine.generateWeek(
        plants: [_plant('p1')],
        speciesWaterDays: {'sp1': 5},
        lastWatered: {'p1': _now.subtract(const Duration(days: 2))},
        now: _now,
      );
      expect(cal.events, isNotEmpty);
      expect(cal.events.first.isOverdue, isFalse);
    });

    test('marks overdue when past due date', () {
      final cal = CareCalendarEngine.generateWeek(
        plants: [_plant('p1')],
        speciesWaterDays: {'sp1': 3},
        lastWatered: {'p1': _now.subtract(const Duration(days: 5))},
        now: _now,
      );
      expect(cal.overdueCount, 1);
    });

    test('skips plants not due within 7 days', () {
      final cal = CareCalendarEngine.generateWeek(
        plants: [_plant('p1')],
        speciesWaterDays: {'sp1': 14},
        lastWatered: {'p1': _now.subtract(const Duration(days: 2))},
        now: _now,
      );
      expect(cal.events, isEmpty);
    });

    test('identifies busiest day', () {
      final plants = List.generate(5, (i) => _plant('p$i'));
      final lastWatered = {for (final p in plants) p.id: _now.subtract(const Duration(days: 4))};
      final cal = CareCalendarEngine.generateWeek(
        plants: plants,
        speciesWaterDays: {'sp1': 7},
        lastWatered: lastWatered,
        now: _now,
      );
      expect(cal.busiestDay, greaterThanOrEqualTo(1));
      expect(cal.busiestDay, lessThanOrEqualTo(7));
    });
  });
}
