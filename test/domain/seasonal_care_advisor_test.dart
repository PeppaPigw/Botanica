import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/seasonal_care_advisor.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/user_settings.dart';

Plant _plant({String id = 'p1', String speciesId = 'sp1'}) => Plant(
      id: id,
      nickname: 'Monstera',
      speciesId: speciesId,
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

Species _species({
  String id = 'sp1',
  int waterDays = 7,
  String light = 'bright indirect',
  String difficulty = 'easy',
}) =>
    Species(
      id: id,
      scientificName: 'Monstera deliciosa',
      commonNamesByLocale: const {'en': ['Monstera']},
      difficulty: difficulty,
      petSafe: true,
      light: light,
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: waterDays,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
    );

UserSettings _settings({Hemisphere hemisphere = Hemisphere.northern}) =>
    UserSettings(
      hasCompletedOnboarding: true,
      temperatureUnit: TemperatureUnit.celsius,
      beliefMode: BeliefMode.unselected,
      reminderTimePreference: ReminderTimePreference.morning,
      hemisphere: hemisphere,
      localeCode: 'en',
      enableDynamicColor: true,
      enableAiInsights: true,
      aiPreferredEndpointIndex: 0,
      careStreakDays: 5,
      longestStreak: 10,
      lastCareDate: DateTime(2026, 5, 15),
      lastMilestoneCelebrated: 0,
    );

void main() {
  group('SeasonalCareAdvisor', () {
    group('currentSeason', () {
      test('March is spring in northern hemisphere', () {
        final season = SeasonalCareAdvisor.currentSeason(
            DateTime(2026, 3, 15), Hemisphere.northern);
        expect(season, Season.spring);
      });

      test('July is summer in northern hemisphere', () {
        final season = SeasonalCareAdvisor.currentSeason(
            DateTime(2026, 7, 15), Hemisphere.northern);
        expect(season, Season.summer);
      });

      test('October is autumn in northern hemisphere', () {
        final season = SeasonalCareAdvisor.currentSeason(
            DateTime(2026, 10, 15), Hemisphere.northern);
        expect(season, Season.autumn);
      });

      test('January is winter in northern hemisphere', () {
        final season = SeasonalCareAdvisor.currentSeason(
            DateTime(2026, 1, 15), Hemisphere.northern);
        expect(season, Season.winter);
      });

      test('July is winter in southern hemisphere', () {
        final season = SeasonalCareAdvisor.currentSeason(
            DateTime(2026, 7, 15), Hemisphere.southern);
        expect(season, Season.winter);
      });

      test('January is summer in southern hemisphere', () {
        final season = SeasonalCareAdvisor.currentSeason(
            DateTime(2026, 1, 15), Hemisphere.southern);
        expect(season, Season.summer);
      });
    });

    group('advise', () {
      test('returns tips for spring', () {
        final tips = SeasonalCareAdvisor.advise(
          plants: [_plant()],
          speciesMap: {'sp1': _species()},
          settings: _settings(),
          now: DateTime(2026, 4, 15),
        );
        expect(tips, isNotEmpty);
        expect(
          tips.any((t) => t.advice == SeasonalAdvice.startFertilizing),
          isTrue,
        );
      });

      test('returns increase watering in summer', () {
        final tips = SeasonalCareAdvisor.advise(
          plants: [_plant()],
          speciesMap: {'sp1': _species()},
          settings: _settings(),
          now: DateTime(2026, 7, 15),
        );
        expect(
          tips.any((t) => t.advice == SeasonalAdvice.increaseWatering),
          isTrue,
        );
      });

      test('returns reduce sun for low-light plants in summer', () {
        final tips = SeasonalCareAdvisor.advise(
          plants: [_plant()],
          speciesMap: {'sp1': _species(light: 'low')},
          settings: _settings(),
          now: DateTime(2026, 7, 15),
        );
        expect(
          tips.any((t) => t.advice == SeasonalAdvice.reduceSunExposure),
          isTrue,
        );
      });

      test('returns stop fertilizing in autumn', () {
        final tips = SeasonalCareAdvisor.advise(
          plants: [_plant()],
          speciesMap: {'sp1': _species()},
          settings: _settings(),
          now: DateTime(2026, 10, 15),
        );
        expect(
          tips.any((t) => t.advice == SeasonalAdvice.stopFertilizing),
          isTrue,
        );
      });

      test('returns decrease watering in winter', () {
        final tips = SeasonalCareAdvisor.advise(
          plants: [_plant()],
          speciesMap: {'sp1': _species()},
          settings: _settings(),
          now: DateTime(2026, 1, 15),
        );
        expect(
          tips.any((t) => t.advice == SeasonalAdvice.decreaseWatering),
          isTrue,
        );
      });

      test('returns humidity tip for hard plants in winter', () {
        final tips = SeasonalCareAdvisor.advise(
          plants: [_plant()],
          speciesMap: {'sp1': _species(difficulty: 'hard')},
          settings: _settings(),
          now: DateTime(2026, 1, 15),
        );
        expect(
          tips.any((t) => t.advice == SeasonalAdvice.increaseHumidity),
          isTrue,
        );
      });

      test('limits to 5 tips max', () {
        final plants = List.generate(10, (i) => _plant(id: 'p$i'));
        final tips = SeasonalCareAdvisor.advise(
          plants: plants,
          speciesMap: {'sp1': _species()},
          settings: _settings(),
          now: DateTime(2026, 4, 15),
        );
        expect(tips.length, lessThanOrEqualTo(5));
      });

      test('skips archived plants', () {
        final archived = Plant(
          id: 'archived',
          nickname: 'Dead',
          speciesId: 'sp1',
          room: 'Room',
          environmentMode: EnvironmentMode.indoor,
          coverAsset: null,
          coverPhotoPath: null,
          createdAt: DateTime(2025, 1, 1),
          meta: const PlantMeta(),
          isArchived: true,
        );
        final tips = SeasonalCareAdvisor.advise(
          plants: [archived],
          speciesMap: {'sp1': _species()},
          settings: _settings(),
          now: DateTime(2026, 4, 15),
        );
        expect(tips, isEmpty);
      });

      test('skips plants without species data', () {
        final tips = SeasonalCareAdvisor.advise(
          plants: [_plant(speciesId: 'unknown')],
          speciesMap: {'sp1': _species()},
          settings: _settings(),
          now: DateTime(2026, 4, 15),
        );
        expect(tips, isEmpty);
      });

      test('respects southern hemisphere', () {
        final tips = SeasonalCareAdvisor.advise(
          plants: [_plant()],
          speciesMap: {'sp1': _species()},
          settings: _settings(hemisphere: Hemisphere.southern),
          now: DateTime(2026, 7, 15), // Winter in southern
        );
        expect(
          tips.any((t) => t.advice == SeasonalAdvice.decreaseWatering),
          isTrue,
        );
      });

      test('tips are sorted by priority descending', () {
        final tips = SeasonalCareAdvisor.advise(
          plants: [_plant()],
          speciesMap: {'sp1': _species()},
          settings: _settings(),
          now: DateTime(2026, 7, 15),
        );
        for (int i = 0; i < tips.length - 1; i++) {
          expect(tips[i].priority, greaterThanOrEqualTo(tips[i + 1].priority));
        }
      });
    });
  });
}
