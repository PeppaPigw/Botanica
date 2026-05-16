import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/user_care_persona_engine.dart';
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

CareLog _log(int daysAgo, {TaskType type = TaskType.water, int hour = 8}) => CareLog(
      id: 'log_${daysAgo}_${type.name}', plantId: 'p1', type: type,
      timestamp: _now.subtract(Duration(days: daysAgo)).copyWith(hour: hour),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('UserCarePersonaEngine', () {
    test('casual persona with minimal data', () {
      final persona = UserCarePersonaEngine.analyze(
        plants: [_plant('p1')], logs: [_log(1)],
        streakDays: 2, totalDaysActive: 10, now: _now,
      );
      expect(persona.primaryType, 'Casual');
    });

    test('devotee persona with high consistency', () {
      final logs = List.generate(40, (i) => CareLog(
        id: 'log_$i', plantId: 'p1', type: TaskType.water,
        timestamp: _now.subtract(Duration(hours: i * 16)),
        note: null, linkedPhotoId: null,
      ));
      final persona = UserCarePersonaEngine.analyze(
        plants: [_plant('p1')], logs: logs,
        streakDays: 30, totalDaysActive: 60, now: _now,
      );
      expect(persona.primaryType, 'Devotee');
    });

    test('explorer persona with diverse species', () {
      final plants = List.generate(8, (i) => _plant('p$i', speciesId: 'sp$i'));
      final persona = UserCarePersonaEngine.analyze(
        plants: plants, logs: List.generate(10, (i) => _log(i + 1)),
        streakDays: 5, totalDaysActive: 30, now: _now,
      );
      expect(persona.primaryType, 'Explorer');
    });

    test('match percentage between 50 and 99', () {
      final persona = UserCarePersonaEngine.analyze(
        plants: [_plant('p1')], logs: List.generate(20, (i) => _log(i + 1)),
        streakDays: 15, totalDaysActive: 90, now: _now,
      );
      expect(persona.matchPercentage, greaterThanOrEqualTo(0.5));
      expect(persona.matchPercentage, lessThanOrEqualTo(0.99));
    });

    test('identifies strengths and growth areas', () {
      final persona = UserCarePersonaEngine.analyze(
        plants: [_plant('p1')],
        logs: List.generate(5, (i) => _log(i + 1)),
        streakDays: 3, totalDaysActive: 20, now: _now,
      );
      expect(persona.description, isNotEmpty);
    });
  });
}
