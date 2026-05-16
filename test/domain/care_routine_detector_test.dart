import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_routine_detector.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {String room = 'Living Room'}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: room, environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _logAt(int daysAgo, int hour) => CareLog(
      id: 'log_${daysAgo}_$hour', plantId: 'p1', type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)).copyWith(hour: hour),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('CareRoutineDetector', () {
    test('returns empty result with few logs', () {
      final result = CareRoutineDetector.analyze(
        plants: [_plant('p1')], logs: [_logAt(1, 8)], now: _now,
      );
      expect(result.detectedRoutines, isEmpty);
      expect(result.efficiencyScore, 0.5);
    });

    test('detects morning routine', () {
      final logs = List.generate(10, (i) => _logAt(i + 1, 8));
      final result = CareRoutineDetector.analyze(
        plants: [_plant('p1')], logs: logs, now: _now,
      );
      final morning = result.detectedRoutines.where((r) => r.name == 'routineMorning');
      expect(morning, isNotEmpty);
      expect(morning.first.preferredTime, 8);
    });

    test('detects evening routine', () {
      final logs = List.generate(10, (i) => _logAt(i + 1, 19));
      final result = CareRoutineDetector.analyze(
        plants: [_plant('p1')], logs: logs, now: _now,
      );
      final evening = result.detectedRoutines.where((r) => r.name == 'routineEvening');
      expect(evening, isNotEmpty);
    });

    test('suggests room batching optimization', () {
      final plants = List.generate(4, (i) => _plant('p$i', room: 'Kitchen'));
      final logs = List.generate(12, (i) => _logAt(i + 1, 8));
      final result = CareRoutineDetector.analyze(
        plants: plants, logs: logs, now: _now,
      );
      final batchOpt = result.optimizations.where(
        (o) => o.suggestion == 'optimizeBatchRoom');
      expect(batchOpt, isNotEmpty);
    });

    test('estimates weekly time', () {
      final logs = List.generate(20, (i) => _logAt(i + 1, 12));
      final result = CareRoutineDetector.analyze(
        plants: [_plant('p1')], logs: logs, now: _now,
      );
      expect(result.totalWeeklyMinutes, greaterThan(0));
    });

    test('efficiency score reflects consistency', () {
      final logs = List.generate(15, (i) => _logAt(i + 1, 8));
      final result = CareRoutineDetector.analyze(
        plants: [_plant('p1')], logs: logs, now: _now,
      );
      expect(result.efficiencyScore, greaterThan(0.0));
      expect(result.efficiencyScore, lessThanOrEqualTo(1.0));
    });
  });
}
