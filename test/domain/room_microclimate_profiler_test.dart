import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/room_microclimate_profiler.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {String room = 'Living Room'}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: room, environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

Species _species({String light = 'indirect'}) => Species(
      id: 'sp1', scientificName: 'Test', commonNamesByLocale: const {'en': ['Test']},
      difficulty: '2', petSafe: true, light: light,
      careDefaults: const SpeciesCareDefaults(
        waterBaseDays: 7, fertilizeBaseDays: 30,
        mistBaseDays: 3, rotateBaseDays: 14, pruneBaseDays: 90,
      ),
    );

CareLog _log(int daysAgo, {String plantId = 'p1'}) => CareLog(
      id: 'log_${plantId}_$daysAgo', plantId: plantId, type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('RoomMicroclimateProfiler', () {
    test('returns empty with no plants', () {
      final result = RoomMicroclimateProfiler.profile(
        plants: [], species: [], logs: [], healthScores: {}, now: _now);
      expect(result, isEmpty);
    });

    test('profiles a single room', () {
      final result = RoomMicroclimateProfiler.profile(
        plants: [_plant('p1'), _plant('p2')],
        species: [_species()],
        logs: [_log(1), _log(2, plantId: 'p2')],
        healthScores: {'p1': 0.8, 'p2': 0.7},
        now: _now,
      );
      expect(result.length, 1);
      expect(result.first.roomName, 'Living Room');
      expect(result.first.plantCount, 2);
      expect(result.first.avgHealthScore, closeTo(0.75, 0.01));
    });

    test('profiles multiple rooms', () {
      final result = RoomMicroclimateProfiler.profile(
        plants: [_plant('p1', room: 'Kitchen'), _plant('p2', room: 'Bedroom')],
        species: [_species()],
        logs: [],
        healthScores: {'p1': 0.9, 'p2': 0.5},
        now: _now,
      );
      expect(result.length, 2);
      expect(result.first.avgHealthScore, greaterThan(result.last.avgHealthScore));
    });

    test('determines dominant light', () {
      final result = RoomMicroclimateProfiler.profile(
        plants: [_plant('p1')],
        species: [_species(light: 'bright')],
        logs: [],
        healthScores: {'p1': 0.7},
        now: _now,
      );
      expect(result.first.dominantLight, 'bright');
    });

    test('suggests species based on light', () {
      final result = RoomMicroclimateProfiler.profile(
        plants: [_plant('p1')],
        species: [_species(light: 'low')],
        logs: [],
        healthScores: {'p1': 0.7},
        now: _now,
      );
      expect(result.first.suggestedSpecies, contains('Pothos'));
    });

    test('generates insights for thriving room', () {
      final result = RoomMicroclimateProfiler.profile(
        plants: [_plant('p1')],
        species: [_species()],
        logs: [],
        healthScores: {'p1': 0.9},
        now: _now,
      );
      expect(result.first.suitabilityInsights, contains('roomInsightThriving'));
    });
  });
}
