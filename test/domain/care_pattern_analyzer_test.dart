import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_pattern_analyzer.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant({String id = 'p1'}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(DateTime ts, {
  String plantId = 'p1',
  TaskType type = TaskType.water,
}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}_$plantId',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('CarePatternAnalyzer', () {
    test('returns empty with fewer than 15 logs', () {
      final logs = List.generate(10, (i) =>
          _log(now.subtract(Duration(days: i))));
      final result = CarePatternAnalyzer.analyze(
        plants: [_plant()], logs: logs, now: now);
      expect(result, isEmpty);
    });

    test('detects batch caring pattern', () {
      // 5 actions per day for 4 days
      final logs = <CareLog>[];
      for (int day = 0; day < 4; day++) {
        for (int action = 0; action < 5; action++) {
          logs.add(_log(
            now.subtract(Duration(days: day, hours: action)),
            type: TaskType.values[action % 5],
          ));
        }
      }
      final result = CarePatternAnalyzer.analyze(
        plants: [_plant()], logs: logs, now: now);
      expect(result.any((p) => p.type == PatternType.batchCarer), isTrue);
    });

    test('detects morning ritual', () {
      final logs = List.generate(20, (i) =>
          _log(DateTime(2026, 5, 16 - i, 7, 30)));
      final result = CarePatternAnalyzer.analyze(
        plants: [_plant()], logs: logs, now: now);
      expect(result.any((p) => p.type == PatternType.morningRitual), isTrue);
    });

    test('detects evening ritual', () {
      final logs = List.generate(20, (i) =>
          _log(DateTime(2026, 5, 16 - i, 20, 30)));
      final result = CarePatternAnalyzer.analyze(
        plants: [_plant()], logs: logs, now: now);
      expect(result.any((p) => p.type == PatternType.eveningRitual), isTrue);
    });

    test('detects weekend warrior', () {
      // All logs on Saturdays and Sundays
      final logs = <CareLog>[];
      for (int week = 0; week < 4; week++) {
        // May 9 is Saturday, May 10 is Sunday
        logs.add(_log(DateTime(2026, 5, 10 - week * 7, 10, 0)));
        logs.add(_log(DateTime(2026, 5, 11 - week * 7, 10, 0)));
        logs.add(_log(DateTime(2026, 5, 10 - week * 7, 14, 0)));
        logs.add(_log(DateTime(2026, 5, 11 - week * 7, 14, 0)));
      }
      final result = CarePatternAnalyzer.analyze(
        plants: [_plant()], logs: logs, now: now);
      expect(result.any((p) => p.type == PatternType.weekendWarrior), isTrue);
    });

    test('detects favorite plant', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2'), _plant(id: 'p3')];
      final logs = [
        ...List.generate(12, (i) =>
            _log(now.subtract(Duration(days: i)), plantId: 'p1')),
        ...List.generate(3, (i) =>
            _log(now.subtract(Duration(days: i)), plantId: 'p2')),
        ...List.generate(2, (i) =>
            _log(now.subtract(Duration(days: i)), plantId: 'p3')),
      ];
      final result = CarePatternAnalyzer.analyze(
        plants: plants, logs: logs, now: now);
      expect(result.any((p) => p.type == PatternType.favoriteFirst), isTrue);
    });

    test('detects neglected plant', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2'), _plant(id: 'p3')];
      final logs = [
        ...List.generate(15, (i) =>
            _log(now.subtract(Duration(days: i)), plantId: 'p1')),
        _log(now.subtract(const Duration(days: 25)), plantId: 'p2'),
      ];
      final result = CarePatternAnalyzer.analyze(
        plants: plants, logs: logs, now: now);
      expect(result.any((p) => p.type == PatternType.neglectedChild), isTrue);
    });

    test('detects diverse care routine', () {
      final logs = <CareLog>[];
      for (int i = 0; i < 20; i++) {
        logs.add(_log(
          now.subtract(Duration(days: i)),
          type: TaskType.values[i % 5],
        ));
      }
      final result = CarePatternAnalyzer.analyze(
        plants: [_plant()], logs: logs, now: now);
      expect(result.any((p) => p.type == PatternType.diverseRoutine), isTrue);
    });

    test('limits results to 3 patterns', () {
      // Create conditions for many patterns
      final plants = [_plant(id: 'p1'), _plant(id: 'p2'), _plant(id: 'p3')];
      final logs = <CareLog>[];
      for (int i = 0; i < 30; i++) {
        logs.add(_log(
          DateTime(2026, 5, 16 - i, 7, 30),
          plantId: 'p1',
          type: TaskType.values[i % 5],
        ));
      }
      logs.add(_log(now.subtract(const Duration(days: 25)), plantId: 'p2'));
      final result = CarePatternAnalyzer.analyze(
        plants: plants, logs: logs, now: now);
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('patterns are sorted by confidence descending', () {
      final logs = List.generate(20, (i) =>
          _log(DateTime(2026, 5, 16 - i, 7, 30)));
      final result = CarePatternAnalyzer.analyze(
        plants: [_plant()], logs: logs, now: now);
      for (int i = 0; i < result.length - 1; i++) {
        expect(result[i].confidence,
            greaterThanOrEqualTo(result[i + 1].confidence));
      }
    });
  });
}
