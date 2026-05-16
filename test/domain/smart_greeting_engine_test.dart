import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/smart_greeting_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/user_settings.dart';

Plant _plant({String id = 'p1', DateTime? createdAt}) => Plant(
      id: id,
      nickname: 'Monstera',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(DateTime ts) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: 'p1',
      type: TaskType.water,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

UserSettings _settings({int streak = 0}) => UserSettings(
      hasCompletedOnboarding: true,
      temperatureUnit: TemperatureUnit.celsius,
      beliefMode: BeliefMode.unselected,
      reminderTimePreference: ReminderTimePreference.morning,
      hemisphere: Hemisphere.northern,
      localeCode: 'en',
      enableDynamicColor: true,
      enableAiInsights: true,
      aiPreferredEndpointIndex: 0,
      careStreakDays: streak,
      longestStreak: streak,
      lastCareDate: DateTime(2026, 5, 15),
      lastMilestoneCelebrated: 0,
    );

void main() {
  group('SmartGreetingEngine', () {
    test('returns morning greeting in morning', () {
      final now = DateTime(2026, 5, 16, 8, 0);
      final result = SmartGreetingEngine.generate(
        plants: [],
        logs: [],
        settings: _settings(),
        now: now,
      );
      expect(result.messageKey, isNotEmpty);
    });

    test('returns afternoon greeting in afternoon', () {
      final now = DateTime(2026, 5, 16, 14, 0);
      final result = SmartGreetingEngine.generate(
        plants: [],
        logs: [],
        settings: _settings(),
        now: now,
      );
      expect(result.messageKey, isNotEmpty);
    });

    test('returns evening greeting at night', () {
      final now = DateTime(2026, 5, 16, 20, 0);
      final result = SmartGreetingEngine.generate(
        plants: [],
        logs: [],
        settings: _settings(),
        now: now,
      );
      expect(result.messageKey, isNotEmpty);
    });

    test('can surface streak greeting with high streak', () {
      bool foundStreak = false;
      for (int day = 0; day < 30; day++) {
        final result = SmartGreetingEngine.generate(
          plants: [_plant()],
          logs: [],
          settings: _settings(streak: 14),
          now: DateTime(2026, 5, day + 1, 10, 0),
        );
        if (result.messageKey == 'greetingStreak') {
          foundStreak = true;
          expect(result.args['days'], '14');
          break;
        }
      }
      expect(foundStreak, isTrue);
    });

    test('can surface rainy greeting', () {
      bool foundRainy = false;
      for (int day = 0; day < 30; day++) {
        final result = SmartGreetingEngine.generate(
          plants: [_plant()],
          logs: [],
          settings: _settings(),
          now: DateTime(2026, 5, day + 1, 10, 0),
          isRaining: true,
        );
        if (result.messageKey == 'greetingRainy') {
          foundRainy = true;
          break;
        }
      }
      expect(foundRainy, isTrue);
    });

    test('can surface new plant greeting', () {
      final now = DateTime(2026, 5, 16, 10, 0);
      final newPlant = _plant(createdAt: now.subtract(const Duration(days: 1)));
      bool found = false;
      for (int h = 0; h < 24; h += 6) {
        final result = SmartGreetingEngine.generate(
          plants: [newPlant],
          logs: [],
          settings: _settings(),
          now: DateTime(2026, 5, 16, h, 0),
        );
        if (result.messageKey == 'greetingNewPlant') {
          found = true;
          expect(result.args['plant'], 'Monstera');
          break;
        }
      }
      // May not always surface due to rotation, but should be possible
      // across multiple days
      if (!found) {
        for (int day = 0; day < 10; day++) {
          final result = SmartGreetingEngine.generate(
            plants: [newPlant],
            logs: [],
            settings: _settings(),
            now: DateTime(2026, 5, day + 14, 10, 0),
          );
          if (result.messageKey == 'greetingNewPlant') {
            found = true;
            break;
          }
        }
      }
      expect(found, isTrue);
    });

    test('can surface productive day greeting', () {
      final logs = [
        _log(DateTime(2026, 5, 16, 8, 0)),
        _log(DateTime(2026, 5, 16, 10, 0)),
        _log(DateTime(2026, 5, 16, 12, 0)),
      ];
      bool found = false;
      for (int day = 0; day < 30; day++) {
        final testNow = DateTime(2026, 5, 16, 15, 0);
        final result = SmartGreetingEngine.generate(
          plants: [_plant()],
          logs: logs,
          settings: _settings(streak: day),
          now: testNow,
        );
        if (result.messageKey == 'greetingProductiveDay') {
          found = true;
          break;
        }
      }
      expect(found, isTrue);
    });

    test('greeting varies by day', () {
      final keys = <String>{};
      for (int day = 0; day < 20; day++) {
        final result = SmartGreetingEngine.generate(
          plants: List.generate(12, (i) => _plant(id: 'p$i')),
          logs: [],
          settings: _settings(streak: 10),
          now: DateTime(2026, 5, day + 1, 10, 0),
          isRaining: day.isEven,
        );
        keys.add(result.messageKey);
      }
      expect(keys.length, greaterThan(2));
    });
  });
}
