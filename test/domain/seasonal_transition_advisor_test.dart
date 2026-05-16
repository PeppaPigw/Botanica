import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/seasonal_transition_advisor.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {EnvironmentMode env = EnvironmentMode.indoor}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: env,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('SeasonalTransitionAdvisor', () {
    test('generates advice for spring', () {
      final report = SeasonalTransitionAdvisor.analyze(
        plants: [_plant('p1')], logs: [],
        currentSeason: Season.spring,
        hemisphere: Hemisphere.northern,
        now: DateTime(2026, 4, 1),
      );
      expect(report.currentSeason, Season.spring);
      expect(report.nextSeason, Season.summer);
      expect(report.advice, isNotEmpty);
    });

    test('urgent advice for autumn balcony plants', () {
      final report = SeasonalTransitionAdvisor.analyze(
        plants: [_plant('p1', env: EnvironmentMode.balcony)], logs: [],
        currentSeason: Season.autumn,
        hemisphere: Hemisphere.northern,
        now: DateTime(2026, 11, 20),
      );
      final moveAdvice = report.advice.where((a) => a.adviceKey == 'seasonalMoveIndoors');
      expect(moveAdvice, isNotEmpty);
      expect(moveAdvice.first.priority, 9);
    });

    test('counts urgent items', () {
      final report = SeasonalTransitionAdvisor.analyze(
        plants: [_plant('p1', env: EnvironmentMode.balcony)], logs: [],
        currentSeason: Season.autumn,
        hemisphere: Hemisphere.northern,
        now: DateTime(2026, 11, 20),
      );
      expect(report.urgentCount, greaterThan(0));
    });

    test('days until transition is positive', () {
      final report = SeasonalTransitionAdvisor.analyze(
        plants: [_plant('p1')], logs: [],
        currentSeason: Season.spring,
        hemisphere: Hemisphere.northern, now: _now,
      );
      expect(report.daysUntilTransition, greaterThan(0));
    });

    test('skips archived plants', () {
      final archived = Plant(
        id: 'pa', nickname: 'Archived', speciesId: 'sp1',
        room: 'Room', environmentMode: EnvironmentMode.balcony,
        coverAsset: null, coverPhotoPath: null,
        createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: true,
      );
      final report = SeasonalTransitionAdvisor.analyze(
        plants: [archived], logs: [],
        currentSeason: Season.autumn,
        hemisphere: Hemisphere.northern,
        now: DateTime(2026, 11, 20),
      );
      expect(report.advice, isEmpty);
    });

    test('summer advice includes hydration check', () {
      final report = SeasonalTransitionAdvisor.analyze(
        plants: [_plant('p1')], logs: [],
        currentSeason: Season.summer,
        hemisphere: Hemisphere.northern, now: _now,
      );
      final hydration = report.advice.where((a) => a.adviceKey == 'seasonalCheckHydration');
      expect(hydration, isNotEmpty);
    });
  });
}
