import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_autopilot_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

Plant _plant({String id = 'p1', bool archived = false}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: archived,
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

CareLog _log(int daysAgo, {TaskType type = TaskType.water, String plantId = 'p1'}) =>
    CareLog(
      id: 'log_${type.name}_${daysAgo}_$plantId',
      plantId: plantId,
      type: type,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null,
      linkedPhotoId: null,
    );

void main() {
  group('CareAutopilotEngine', () {
    test('returns empty with no plants', () {
      final result = CareAutopilotEngine.generate(
        plants: [],
        species: [_species()],
        logs: [],
        now: _now,
        currentSeason: Season.spring,
        nextSeason: Season.summer,
      );
      expect(result, isEmpty);
    });

    test('skips archived plants', () {
      final result = CareAutopilotEngine.generate(
        plants: [_plant(archived: true)],
        species: [_species()],
        logs: [_log(25)],
        now: _now,
        currentSeason: Season.spring,
        nextSeason: Season.summer,
      );
      expect(result, isEmpty);
    });

    test('detects neglected plant', () {
      final result = CareAutopilotEngine.generate(
        plants: [_plant()],
        species: [_species()],
        logs: [_log(30)],
        now: _now,
        currentSeason: Season.spring,
        nextSeason: Season.summer,
      );
      final neglected = result.where((s) => s.type == 'neglected');
      expect(neglected, isNotEmpty);
      expect(neglected.first.urgency, SuggestionUrgency.high);
    });

    test('detects overwatering', () {
      final logs = List.generate(8, (i) => _log(i));
      final result = CareAutopilotEngine.generate(
        plants: [_plant()],
        species: [_species()],
        logs: logs,
        now: _now,
        currentSeason: Season.spring,
        nextSeason: Season.summer,
      );
      final overwater = result.where((s) => s.type == 'overwatering');
      expect(overwater, isNotEmpty);
    });

    test('suggests fertilize in growing season', () {
      final logs = List.generate(5, (i) => _log(i * 3));
      final result = CareAutopilotEngine.generate(
        plants: [_plant()],
        species: [_species()],
        logs: logs,
        now: _now,
        currentSeason: Season.spring,
        nextSeason: Season.summer,
      );
      final fertSuggestion = result.where((s) => s.type == 'fertilizeReminder');
      expect(fertSuggestion, isNotEmpty);
    });

    test('no fertilize suggestion in winter', () {
      final logs = List.generate(5, (i) => _log(i * 3));
      final result = CareAutopilotEngine.generate(
        plants: [_plant()],
        species: [_species()],
        logs: logs,
        now: _now,
        currentSeason: Season.winter,
        nextSeason: Season.spring,
      );
      final fertSuggestion = result.where((s) => s.type == 'fertilizeReminder');
      expect(fertSuggestion, isEmpty);
    });

    test('limits results to 8 suggestions', () {
      final plants = List.generate(10, (i) => _plant(id: 'p$i'));
      final logs = <CareLog>[];
      for (int i = 0; i < 10; i++) {
        logs.add(_log(25, plantId: 'p$i'));
      }
      final result = CareAutopilotEngine.generate(
        plants: plants,
        species: [_species()],
        logs: logs,
        now: _now,
        currentSeason: Season.spring,
        nextSeason: Season.summer,
      );
      expect(result.length, lessThanOrEqualTo(8));
    });

    test('results sorted by urgency descending', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2')];
      final logs = [
        _log(25, plantId: 'p1'),
        ...List.generate(8, (i) => _log(i, plantId: 'p2')),
      ];
      final result = CareAutopilotEngine.generate(
        plants: plants,
        species: [_species()],
        logs: logs,
        now: _now,
        currentSeason: Season.spring,
        nextSeason: Season.summer,
      );
      if (result.length >= 2) {
        expect(result.first.urgency.index,
            greaterThanOrEqualTo(result.last.urgency.index));
      }
    });
  });
}
