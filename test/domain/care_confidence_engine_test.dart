import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_confidence_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
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

CareLog _log(int daysAgo, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: type,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('CareConfidenceEngine', () {
    test('novice with no data', () {
      final report = CareConfidenceEngine.assess(
        plants: [], logs: [], healthScores: {},
        streakDays: 0, totalDaysActive: 5, now: _now,
      );
      expect(report.level, 'confidenceNovice');
      expect(report.overallConfidence, lessThan(0.4));
    });

    test('higher confidence with diverse care', () {
      final logs = [
        _log(1, type: TaskType.water),
        _log(2, type: TaskType.fertilize),
        _log(3, type: TaskType.mist),
        _log(4, type: TaskType.prune),
        _log(5, type: TaskType.rotate),
      ];
      final report = CareConfidenceEngine.assess(
        plants: List.generate(6, (i) => _plant('p$i', speciesId: 'sp$i')),
        logs: logs,
        healthScores: {'p0': 0.9, 'p1': 0.8, 'p2': 0.85, 'p3': 0.9, 'p4': 0.8, 'p5': 0.9},
        streakDays: 30, totalDaysActive: 200, now: _now,
      );
      expect(report.overallConfidence, greaterThan(0.5));
    });

    test('has 5 dimensions', () {
      final report = CareConfidenceEngine.assess(
        plants: [_plant('p1')], logs: [_log(1)],
        healthScores: {'p1': 0.7},
        streakDays: 5, totalDaysActive: 60, now: _now,
      );
      expect(report.dimensions.length, 5);
    });

    test('next milestone suggests improvement', () {
      final report = CareConfidenceEngine.assess(
        plants: [_plant('p1')], logs: [],
        healthScores: {'p1': 0.5},
        streakDays: 0, totalDaysActive: 10, now: _now,
      );
      expect(report.nextMilestone, isNotEmpty);
    });

    test('confidence clamped between 0 and 1', () {
      final report = CareConfidenceEngine.assess(
        plants: List.generate(15, (i) => _plant('p$i')),
        logs: List.generate(50, (i) => _log(i + 1)),
        healthScores: {for (int i = 0; i < 15; i++) 'p$i': 0.95},
        streakDays: 60, totalDaysActive: 365, now: _now,
      );
      expect(report.overallConfidence, greaterThanOrEqualTo(0.0));
      expect(report.overallConfidence, lessThanOrEqualTo(1.0));
    });
  });
}
