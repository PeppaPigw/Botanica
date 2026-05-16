import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/seasonal_transition_planner.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/user_settings.dart';

Plant _plant({
  String id = 'p1',
  EnvironmentMode env = EnvironmentMode.indoor,
}) =>
    Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: env,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

Species _species({String light = 'bright indirect'}) => Species(
      id: 'sp1',
      scientificName: 'Testus plantus',
      commonNamesByLocale: const {'en': ['Test']},
      difficulty: '3',
      petSafe: true,
      light: light,
      careDefaults: const SpeciesCareDefaults(
        waterBaseDays: 7,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
      origin: null,
      growth: const SpeciesGrowth(rate: 'moderate', form: 'upright'),
      matureSize: null,
    );

UserSettings _settings({Hemisphere hemisphere = Hemisphere.northern}) =>
    UserSettings(
      hasCompletedOnboarding: true,
      temperatureUnit: TemperatureUnit.celsius,
      beliefMode: BeliefMode.unselected,
      reminderTimePreference: ReminderTimePreference.morning,
      hemisphere: hemisphere,
      localeCode: 'en',
      enableDynamicColor: false,
      enableAiInsights: true,
      aiPreferredEndpointIndex: 0,
      careStreakDays: 10,
      longestStreak: 10,
      lastCareDate: DateTime(2026, 5, 15),
      lastMilestoneCelebrated: 7,
    );

void main() {
  group('SeasonalTransitionPlanner', () {
    test('returns null with no active plants', () {
      final result = SeasonalTransitionPlanner.plan(
        plants: [],
        species: [_species()],
        settings: _settings(),
        now: DateTime(2026, 5, 16),
      );
      expect(result, isNull);
    });

    test('returns null when transition is more than 6 weeks away', () {
      // January in northern hemisphere — next transition is March (8+ weeks)
      final result = SeasonalTransitionPlanner.plan(
        plants: [_plant()],
        species: [_species()],
        settings: _settings(),
        now: DateTime(2026, 1, 10),
      );
      expect(result, isNull);
    });

    test('generates plan when transition is within 6 weeks', () {
      // Late May in northern hemisphere — summer starts June (< 6 weeks)
      final result = SeasonalTransitionPlanner.plan(
        plants: [_plant()],
        species: [_species()],
        settings: _settings(),
        now: DateTime(2026, 5, 16),
      );
      expect(result, isNotNull);
      expect(result!.tasks, isNotEmpty);
      expect(result.toSeason, Season.summer);
    });

    test('outdoor plants get move-indoors task before winter', () {
      // Late October — approaching winter
      final result = SeasonalTransitionPlanner.plan(
        plants: [_plant(env: EnvironmentMode.outdoor)],
        species: [_species()],
        settings: _settings(),
        now: DateTime(2026, 11, 1),
      );
      expect(result, isNotNull);
      expect(result!.toSeason, Season.winter);
      expect(
        result.tasks.any((t) => t.action == TransitionAction.moveIndoors),
        isTrue,
      );
    });

    test('southern hemisphere has inverted seasons', () {
      // May in southern hemisphere = approaching winter
      final result = SeasonalTransitionPlanner.plan(
        plants: [_plant()],
        species: [_species()],
        settings: _settings(hemisphere: Hemisphere.southern),
        now: DateTime(2026, 5, 16),
      );
      expect(result, isNotNull);
      expect(result!.toSeason, Season.winter);
    });

    test('tasks are sorted by urgency descending', () {
      final result = SeasonalTransitionPlanner.plan(
        plants: [_plant(), _plant(id: 'p2', env: EnvironmentMode.outdoor)],
        species: [_species()],
        settings: _settings(),
        now: DateTime(2026, 5, 16),
      );
      if (result != null && result.tasks.length >= 2) {
        for (int i = 0; i < result.tasks.length - 1; i++) {
          expect(result.tasks[i].urgency,
              greaterThanOrEqualTo(result.tasks[i + 1].urgency));
        }
      }
    });

    test('low-light plants get shade cover suggestion before summer', () {
      final result = SeasonalTransitionPlanner.plan(
        plants: [_plant()],
        species: [_species(light: 'low light shade')],
        settings: _settings(),
        now: DateTime(2026, 5, 16),
      );
      expect(result, isNotNull);
      expect(
        result!.tasks.any((t) => t.action == TransitionAction.provideShadeCover),
        isTrue,
      );
    });
  });
}
