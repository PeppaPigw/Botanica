import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_burnout_detector.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(int daysAgo) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('CareBurnoutDetector', () {
    test('low risk with manageable garden', () {
      final report = CareBurnoutDetector.assess(
        plants: [_plant('p1'), _plant('p2')],
        logs: List.generate(10, (i) => _log(i + 1)),
        missedTasksThisWeek: 0, missedTasksLastWeek: 0,
        totalDailyTasks: 3, now: _now,
      );
      expect(report.riskLevel, 'burnoutLow');
    });

    test('detects task overload', () {
      final report = CareBurnoutDetector.assess(
        plants: List.generate(25, (i) => _plant('p$i')),
        logs: List.generate(10, (i) => _log(i + 1)),
        missedTasksThisWeek: 2, missedTasksLastWeek: 1,
        totalDailyTasks: 15, now: _now,
      );
      expect(report.signals.any((s) => s.type == 'burnoutTooManyTasks'), isTrue);
      expect(report.signals.any((s) => s.type == 'burnoutLargeCollection'), isTrue);
    });

    test('detects activity decline', () {
      final logs = [
        ...List.generate(2, (i) => _log(i + 1)),
        ...List.generate(10, (i) => _log(i + 8)),
      ];
      final report = CareBurnoutDetector.assess(
        plants: [_plant('p1')], logs: logs,
        missedTasksThisWeek: 3, missedTasksLastWeek: 1,
        totalDailyTasks: 5, now: _now,
      );
      expect(report.signals.any((s) => s.type == 'burnoutActivityDrop'), isTrue);
    });

    test('provides suggestions for each signal', () {
      final report = CareBurnoutDetector.assess(
        plants: List.generate(25, (i) => _plant('p$i')),
        logs: [], missedTasksThisWeek: 8, missedTasksLastWeek: 3,
        totalDailyTasks: 12, now: _now,
      );
      expect(report.suggestions, isNotEmpty);
    });

    test('risk score clamped between 0 and 1', () {
      final report = CareBurnoutDetector.assess(
        plants: List.generate(30, (i) => _plant('p$i')),
        logs: [], missedTasksThisWeek: 10, missedTasksLastWeek: 2,
        totalDailyTasks: 20, now: _now,
      );
      expect(report.riskScore, greaterThanOrEqualTo(0.0));
      expect(report.riskScore, lessThanOrEqualTo(1.0));
    });
  });
}
