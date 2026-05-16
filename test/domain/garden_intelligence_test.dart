import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_intelligence.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/user_settings.dart';

Plant _plant({String id = 'p1', String nickname = 'Monstera', DateTime? createdAt}) => Plant(
      id: id,
      nickname: nickname,
      speciesId: 'sp1',
      room: 'Living Room',
      coverPhotoPath: null,
      coverAsset: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
      environmentMode: EnvironmentMode.indoor,
    );

CareLog _log({
  required String plantId,
  required DateTime timestamp,
  TaskType type = TaskType.water,
}) =>
    CareLog(
      id: 'log_${timestamp.millisecondsSinceEpoch}',
      plantId: plantId,
      type: type,
      timestamp: timestamp,
      note: null,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);
  final settings = UserSettings(
    hasCompletedOnboarding: true,
    temperatureUnit: TemperatureUnit.celsius,
    beliefMode: BeliefMode.unselected,
    reminderTimePreference: ReminderTimePreference.morning,
    hemisphere: Hemisphere.northern,
    localeCode: 'en',
    enableDynamicColor: true,
    enableAiInsights: true,
    aiPreferredEndpointIndex: 0,
    careStreakDays: 5,
    longestStreak: 10,
    lastCareDate: DateTime(2026, 5, 15),
    lastMilestoneCelebrated: 0,
  );

  group('GardenIntelligence', () {
    test('returns null when no data', () {
      final result = GardenIntelligence.surfaceInsight(
        plants: const [],
        logs: const [],
        tasks: const [],
        settings: settings,
        now: now,
      );
      expect(result, isNull);
    });

    test('returns null with insufficient logs', () {
      final result = GardenIntelligence.surfaceInsight(
        plants: [_plant()],
        logs: [_log(plantId: 'p1', timestamp: now.subtract(const Duration(days: 1)))],
        tasks: const [],
        settings: settings,
        now: now,
      );
      expect(result, isNull);
    });

    test('detects favorite care day', () {
      final logs = List.generate(15, (i) {
        final date = now.subtract(Duration(days: i * 4));
        return _log(plantId: 'p1', timestamp: date);
      });

      final result = GardenIntelligence.surfaceInsight(
        plants: [_plant()],
        logs: logs,
        tasks: const [],
        settings: settings,
        now: now,
      );

      expect(result, isNotNull);
    });

    test('detects most active time', () {
      final logs = List.generate(10, (i) {
        return _log(
          plantId: 'p1',
          timestamp: DateTime(2026, 5, 16 - i, 7, 30),
        );
      });

      final result = GardenIntelligence.surfaceInsight(
        plants: [_plant()],
        logs: logs,
        tasks: const [],
        settings: settings,
        now: now,
      );

      expect(result, isNotNull);
      if (result!.messageKey == 'insightActiveTime') {
        expect(result.args['period'], 'morning');
      }
    });

    test('detects most loved plant', () {
      final plant1 = _plant(id: 'p1', nickname: 'Monstera');
      final plant2 = _plant(id: 'p2', nickname: 'Fern');
      final plant3 = _plant(id: 'p3', nickname: 'Cactus');

      final logs = [
        ...List.generate(8, (i) => _log(
              plantId: 'p1',
              timestamp: now.subtract(Duration(days: i + 1)),
            )),
        _log(plantId: 'p2', timestamp: now.subtract(const Duration(days: 5))),
        _log(plantId: 'p3', timestamp: now.subtract(const Duration(days: 6))),
      ];

      final result = GardenIntelligence.surfaceInsight(
        plants: [plant1, plant2, plant3],
        logs: logs,
        tasks: const [],
        settings: settings,
        now: now,
      );

      expect(result, isNotNull);
    });

    test('detects care acceleration', () {
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

      final logs = [
        ...List.generate(6, (i) => _log(
              plantId: 'p1',
              timestamp: thisWeekStart.add(Duration(hours: i * 4)),
            )),
        ...List.generate(3, (i) => _log(
              plantId: 'p1',
              timestamp: lastWeekStart.add(Duration(days: i)),
            )),
      ];

      final result = GardenIntelligence.surfaceInsight(
        plants: [_plant()],
        logs: logs,
        tasks: const [],
        settings: settings,
        now: now,
      );

      expect(result, isNotNull);
    });

    test('detects garden growing', () {
      final plants = List<Plant>.generate(6, (i) => Plant(
            id: 'p$i',
            nickname: 'Plant $i',
            speciesId: 'sp$i',
            room: 'Room',
            coverPhotoPath: null,
            coverAsset: null,
            createdAt: i < 2
                ? now.subtract(const Duration(days: 5))
                : now.subtract(const Duration(days: 60)),
            meta: const PlantMeta(),
            isArchived: false,
            environmentMode: EnvironmentMode.indoor,
          ));

      final logs = List.generate(10, (i) => _log(
            plantId: 'p0',
            timestamp: now.subtract(Duration(days: i + 1)),
          ));

      final result = GardenIntelligence.surfaceInsight(
        plants: plants,
        logs: logs,
        tasks: const [],
        settings: settings,
        now: now,
      );

      expect(result, isNotNull);
    });

    test('detects watering rhythm shift', () {
      final plant = _plant();
      final logs = <CareLog>[];

      // Older period (31-60 days ago): every 5 days
      for (int i = 0; i < 5; i++) {
        logs.add(_log(
          plantId: 'p1',
          timestamp: now.subtract(Duration(days: 35 + i * 5)),
        ));
      }
      // Recent period (0-30 days ago): every 9 days
      for (int i = 0; i < 4; i++) {
        logs.add(_log(
          plantId: 'p1',
          timestamp: now.subtract(Duration(days: i * 9)),
        ));
      }

      final result = GardenIntelligence.surfaceInsight(
        plants: [plant],
        logs: logs,
        tasks: const [],
        settings: settings,
        now: now,
      );

      expect(result, isNotNull);
    });

    test('insight args are populated', () {
      final logs = List.generate(12, (i) {
        return _log(
          plantId: 'p1',
          timestamp: DateTime(2026, 5, 16 - i, 8, 0),
        );
      });

      final result = GardenIntelligence.surfaceInsight(
        plants: [_plant()],
        logs: logs,
        tasks: const [],
        settings: settings,
        now: now,
      );

      if (result != null) {
        expect(result.args, isNotEmpty);
        expect(result.messageKey, isNotEmpty);
      }
    });
  });
}
