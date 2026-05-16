import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_personality_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

Plant _plant() => Plant(
      id: 'p1', nickname: 'Fern', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(int daysAgo, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_${type.name}_$daysAgo', plantId: 'p1', type: type,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('PlantPersonalityEngine', () {
    test('assigns personality with no logs', () {
      final result = PlantPersonalityEngine.analyze(
        plant: _plant(), logs: [], healthScore: 0.5, now: _now);
      expect(result.primaryTrait, 'shy');
      expect(result.moodKey, 'personalityLonely');
    });

    test('resilient trait for gaps with good health', () {
      final logs = [_log(1), _log(20), _log(40)];
      final result = PlantPersonalityEngine.analyze(
        plant: _plant(), logs: logs, healthScore: 0.8, now: _now);
      expect(result.primaryTrait, 'resilient');
    });

    test('thriving mood for high health and activity', () {
      final logs = List.generate(15, (i) => _log(i));
      final result = PlantPersonalityEngine.analyze(
        plant: _plant(), logs: logs, healthScore: 0.9, now: _now);
      expect(result.moodKey, 'personalityThriving');
    });

    test('care style reflects activity level', () {
      final logs = List.generate(25, (i) => _log(i));
      final result = PlantPersonalityEngine.analyze(
        plant: _plant(), logs: logs, healthScore: 0.7, now: _now);
      expect(result.careStyle, isIn([
        'careStyleDedicated', 'careStyleBalanced', 'careStyleCasual', 'careStyleMinimalist',
      ]));
    });

    test('adventurous secondary trait with diverse care', () {
      final logs = [
        _log(1, type: TaskType.water),
        _log(2, type: TaskType.fertilize),
        _log(3, type: TaskType.mist),
        _log(4, type: TaskType.prune),
        _log(5, type: TaskType.rotate),
      ];
      final result = PlantPersonalityEngine.analyze(
        plant: _plant(), logs: logs, healthScore: 0.6, now: _now);
      expect(result.secondaryTrait, 'adventurous');
    });

    test('quote key combines trait and mood', () {
      final result = PlantPersonalityEngine.analyze(
        plant: _plant(), logs: [], healthScore: 0.5, now: _now);
      expect(result.quoteKey, contains(result.primaryTrait));
    });
  });
}
