import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_action_effectiveness.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant() => Plant(
      id: 'p1', nickname: 'Fern', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('CareActionEffectiveness', () {
    test('returns empty report with no logs', () {
      final report = CareActionEffectiveness.evaluate(
        plant: _plant(), logs: [], healthTimeline: [], now: _now,
      );
      expect(report.effects, isEmpty);
      expect(report.overallScore, 0.5);
    });

    test('measures positive effect', () {
      final logs = [
        CareLog(id: 'l1', plantId: 'p1', type: TaskType.water,
          timestamp: DateTime(2026, 5, 10), note: null, linkedPhotoId: null),
      ];
      final timeline = [
        MapEntry(DateTime(2026, 5, 9), 0.5),
        MapEntry(DateTime(2026, 5, 12), 0.7),
      ];
      final report = CareActionEffectiveness.evaluate(
        plant: _plant(), logs: logs, healthTimeline: timeline, now: _now,
      );
      expect(report.effects, isNotEmpty);
      expect(report.effects.first.healthDelta, greaterThan(0));
    });

    test('identifies best action', () {
      final logs = [
        CareLog(id: 'l1', plantId: 'p1', type: TaskType.water,
          timestamp: DateTime(2026, 5, 5), note: null, linkedPhotoId: null),
        CareLog(id: 'l2', plantId: 'p1', type: TaskType.fertilize,
          timestamp: DateTime(2026, 5, 10), note: null, linkedPhotoId: null),
      ];
      final timeline = [
        MapEntry(DateTime(2026, 5, 4), 0.5),
        MapEntry(DateTime(2026, 5, 7), 0.6),
        MapEntry(DateTime(2026, 5, 9), 0.6),
        MapEntry(DateTime(2026, 5, 13), 0.9),
      ];
      final report = CareActionEffectiveness.evaluate(
        plant: _plant(), logs: logs, healthTimeline: timeline, now: _now,
      );
      expect(report.bestAction, TaskType.fertilize);
    });

    test('overall score between 0 and 1', () {
      final logs = List.generate(5, (i) => CareLog(
        id: 'l$i', plantId: 'p1', type: TaskType.water,
        timestamp: _now.subtract(Duration(days: i * 3 + 3)),
        note: null, linkedPhotoId: null,
      ));
      final timeline = List.generate(20, (i) => MapEntry(
        _now.subtract(Duration(days: i)),
        0.5 + (i % 3) * 0.1,
      ));
      final report = CareActionEffectiveness.evaluate(
        plant: _plant(), logs: logs, healthTimeline: timeline, now: _now,
      );
      expect(report.overallScore, greaterThanOrEqualTo(0.0));
      expect(report.overallScore, lessThanOrEqualTo(1.0));
    });
  });
}
