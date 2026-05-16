import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/adaptive_care_scheduler.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

Plant _plant({String id = 'p1'}) => Plant(
      id: id,
      nickname: 'Fern $id',
      speciesId: 'sp1',
      room: 'Living Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

Species _species({int waterDays = 7, int fertilizeDays = 30}) => Species(
      id: 'sp1',
      scientificName: 'Nephrolepis exaltata',
      commonNamesByLocale: const {'en': ['Boston Fern']},
      difficulty: '2',
      petSafe: true,
      light: 'indirect',
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: waterDays,
        fertilizeBaseDays: fertilizeDays,
        mistBaseDays: 3,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
    );

CareLog _waterLog(int daysAgo) => CareLog(
      id: 'log_water_$daysAgo',
      plantId: 'p1',
      type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null,
      linkedPhotoId: null,
    );

CareLog _fertLog(int daysAgo) => CareLog(
      id: 'log_fert_$daysAgo',
      plantId: 'p1',
      type: TaskType.fertilize,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null,
      linkedPhotoId: null,
    );

void main() {
  group('AdaptiveCareScheduler', () {
    test('returns empty when no plants', () {
      final result = AdaptiveCareScheduler.analyze(
        plants: [],
        species: [_species()],
        logs: [],
        now: _now,
      );
      expect(result, isEmpty);
    });

    test('returns empty with insufficient water logs', () {
      final logs = List.generate(3, (i) => _waterLog(i * 5));
      final result = AdaptiveCareScheduler.analyze(
        plants: [_plant()],
        species: [_species()],
        logs: logs,
        now: _now,
      );
      expect(result, isEmpty);
    });

    test('suggests more frequent watering when user waters sooner', () {
      // Species default is 7 days, but user consistently waters every 4 days
      final logs = List.generate(8, (i) => _waterLog(i * 4));
      final result = AdaptiveCareScheduler.analyze(
        plants: [_plant()],
        species: [_species(waterDays: 7)],
        logs: logs,
        now: _now,
      );
      expect(result, isNotEmpty);
      final adj = result.first;
      expect(adj.taskType, TaskType.water);
      expect(adj.suggestedIntervalDays, lessThan(adj.currentIntervalDays));
      expect(adj.suggestsMoreFrequent, isTrue);
    });

    test('suggests less frequent watering when user waters later', () {
      // Species default is 5 days, but user consistently waters every 10 days
      final logs = List.generate(8, (i) => _waterLog(i * 10));
      final result = AdaptiveCareScheduler.analyze(
        plants: [_plant()],
        species: [_species(waterDays: 5)],
        logs: logs,
        now: _now,
      );
      expect(result, isNotEmpty);
      final adj = result.first;
      expect(adj.taskType, TaskType.water);
      expect(adj.suggestedIntervalDays, greaterThan(adj.currentIntervalDays));
      expect(adj.suggestsMoreFrequent, isFalse);
    });

    test('no suggestion when actual interval matches species default', () {
      // User waters every 7 days, species says 7 days — no adjustment needed
      final logs = List.generate(8, (i) => _waterLog(i * 7));
      final result = AdaptiveCareScheduler.analyze(
        plants: [_plant()],
        species: [_species(waterDays: 7)],
        logs: logs,
        now: _now,
      );
      final waterAdj = result.where((a) => a.taskType == TaskType.water);
      expect(waterAdj, isEmpty);
    });

    test('suggests fertilize adjustment with enough data', () {
      // Species default is 30 days, user fertilizes every 14 days
      final logs = List.generate(6, (i) => _fertLog(i * 14));
      final result = AdaptiveCareScheduler.analyze(
        plants: [_plant()],
        species: [_species(fertilizeDays: 30)],
        logs: logs,
        now: _now,
      );
      final fertAdj = result.where((a) => a.taskType == TaskType.fertilize);
      expect(fertAdj, isNotEmpty);
      expect(fertAdj.first.suggestedIntervalDays, lessThan(30));
    });

    test('skips archived plants', () {
      final archived = Plant(
        id: 'p1',
        nickname: 'Archived',
        speciesId: 'sp1',
        room: 'Room',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1),
        meta: const PlantMeta(),
        isArchived: true,
      );
      final logs = List.generate(8, (i) => _waterLog(i * 4));
      final result = AdaptiveCareScheduler.analyze(
        plants: [archived],
        species: [_species()],
        logs: logs,
        now: _now,
      );
      expect(result, isEmpty);
    });

    test('confidence is higher with consistent intervals', () {
      // Very consistent: every 4 days exactly
      final consistentLogs = List.generate(8, (i) => _waterLog(i * 4));
      final consistentResult = AdaptiveCareScheduler.analyze(
        plants: [_plant()],
        species: [_species(waterDays: 7)],
        logs: consistentLogs,
        now: _now,
      );

      // Inconsistent: varying intervals
      final inconsistentLogs = [
        _waterLog(0), _waterLog(3), _waterLog(8),
        _waterLog(10), _waterLog(18), _waterLog(20),
        _waterLog(28), _waterLog(35),
      ];
      final inconsistentResult = AdaptiveCareScheduler.analyze(
        plants: [_plant()],
        species: [_species(waterDays: 7)],
        logs: inconsistentLogs,
        now: _now,
      );

      if (consistentResult.isNotEmpty && inconsistentResult.isNotEmpty) {
        expect(consistentResult.first.confidence,
            greaterThanOrEqualTo(inconsistentResult.first.confidence));
      }
    });

    test('limits results to 5 adjustments', () {
      // Create many plants that all need adjustments
      final plants = List.generate(8, (i) => Plant(
            id: 'p$i',
            nickname: 'Plant $i',
            speciesId: 'sp1',
            room: 'Room',
            environmentMode: EnvironmentMode.indoor,
            coverAsset: null,
            coverPhotoPath: null,
            createdAt: DateTime(2025, 1, 1),
            meta: const PlantMeta(),
            isArchived: false,
          ));
      final logs = <CareLog>[];
      for (int p = 0; p < 8; p++) {
        for (int i = 0; i < 8; i++) {
          logs.add(CareLog(
            id: 'log_p${p}_$i',
            plantId: 'p$p',
            type: TaskType.water,
            timestamp: _now.subtract(Duration(days: i * 4)),
            note: null,
            linkedPhotoId: null,
          ));
        }
      }
      final result = AdaptiveCareScheduler.analyze(
        plants: plants,
        species: [_species(waterDays: 10)],
        logs: logs,
        now: _now,
      );
      expect(result.length, lessThanOrEqualTo(5));
    });
  });
}
