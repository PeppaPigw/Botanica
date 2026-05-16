import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_rescue_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

Plant _plant({bool archived = false}) => Plant(
      id: 'p1',
      nickname: 'Sick Fern',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: archived,
    );

CareLog _log(int daysAgo, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_${type.name}_$daysAgo',
      plantId: 'p1',
      type: type,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null,
      linkedPhotoId: null,
    );

void main() {
  group('PlantRescueEngine', () {
    test('returns null for healthy plant', () {
      final result = PlantRescueEngine.evaluate(
        plant: _plant(),
        healthScore: 0.8,
        recentLogs: [_log(1), _log(3), _log(7)],
        now: _now,
      );
      expect(result, isNull);
    });

    test('returns null for archived plant', () {
      final result = PlantRescueEngine.evaluate(
        plant: _plant(archived: true),
        healthScore: 0.1,
        recentLogs: [],
        now: _now,
      );
      expect(result, isNull);
    });

    test('creates rescue plan for low health score', () {
      final result = PlantRescueEngine.evaluate(
        plant: _plant(),
        healthScore: 0.4,
        recentLogs: [_log(20)],
        now: _now,
      );
      expect(result, isNotNull);
      expect(result!.severity, RescueSeverity.mild);
      expect(result.actions, isNotEmpty);
    });

    test('critical severity for very low health', () {
      final result = PlantRescueEngine.evaluate(
        plant: _plant(),
        healthScore: 0.1,
        recentLogs: [],
        now: _now,
      );
      expect(result, isNotNull);
      expect(result!.severity, RescueSeverity.critical);
      expect(result.estimatedRecoveryDays, 21);
    });

    test('diagnoses dehydration when no recent watering', () {
      final result = PlantRescueEngine.evaluate(
        plant: _plant(),
        healthScore: 0.3,
        recentLogs: [_log(20)],
        now: _now,
      );
      expect(result, isNotNull);
      expect(result!.diagnosis, 'dehydration');
    });

    test('diagnoses neglect when very few recent logs', () {
      final result = PlantRescueEngine.evaluate(
        plant: _plant(),
        healthScore: 0.4,
        recentLogs: [_log(1), _log(5)],
        now: _now,
      );
      expect(result, isNotNull);
      expect(result!.diagnosis, 'neglect');
    });

    test('actions are sorted by day then priority', () {
      final result = PlantRescueEngine.evaluate(
        plant: _plant(),
        healthScore: 0.3,
        recentLogs: [],
        now: _now,
      );
      expect(result, isNotNull);
      for (int i = 0; i < result!.actions.length - 1; i++) {
        final a = result.actions[i];
        final b = result.actions[i + 1];
        expect(a.day <= b.day || (a.day == b.day && a.priority <= b.priority),
            isTrue);
      }
    });

    test('progress calculation works', () {
      final result = PlantRescueEngine.evaluate(
        plant: _plant(),
        healthScore: 0.3,
        recentLogs: [_log(20)],
        now: _now,
      );
      expect(result, isNotNull);
      expect(result!.progressAt(_now), 0.0);
      expect(result.progressAt(_now.add(Duration(days: result.estimatedRecoveryDays))), 1.0);
    });

    test('nutrient deficiency when no fertilize in history', () {
      final logs = List.generate(8, (i) => _log(i * 3));
      final result = PlantRescueEngine.evaluate(
        plant: _plant(),
        healthScore: 0.4,
        recentLogs: logs,
        now: _now,
      );
      expect(result, isNotNull);
      expect(result!.diagnosis, 'nutrientDeficiency');
    });
  });
}
