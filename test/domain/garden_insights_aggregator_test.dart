import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_insights_aggregator.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/task_instance.dart';
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

Species _species() => const Species(
      id: 'sp1',
      scientificName: 'Monstera deliciosa',
      commonNamesByLocale: {'en': ['Monstera']},
      difficulty: 'easy',
      petSafe: true,
      light: 'bright indirect',
      careDefaults: SpeciesCareDefaults(
        waterBaseDays: 7,
        fertilizeBaseDays: 30,
        mistBaseDays: 0,
        rotateBaseDays: 14,
        pruneBaseDays: 90,
      ),
    );

CareLog _log(DateTime ts, {String plantId = 'p1'}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task({
  required DateTime dueAt,
  TaskStatus status = TaskStatus.pending,
}) => TaskInstance(
      id: 'task_${dueAt.millisecondsSinceEpoch}',
      plantId: 'p1',
      type: TaskType.water,
      dueAt: dueAt,
      status: status,
      createdAt: dueAt.subtract(const Duration(days: 7)),
      completedAt: null,
      adjustmentReasonIds: const [],
    );

UserSettings _settings({int streak = 5}) => UserSettings(
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
  final now = DateTime(2026, 5, 16, 10, 0);

  group('GardenInsightsAggregator', () {
    test('generates feed with greeting and insights', () {
      final feed = GardenInsightsAggregator.generate(
        plants: [_plant()],
        logs: [_log(now.subtract(const Duration(days: 1)))],
        tasks: [_task(dueAt: now.subtract(const Duration(hours: 2)))],
        settings: _settings(),
        speciesMap: {'sp1': _species()},
        now: now,
      );
      expect(feed.greeting.messageKey, isNotEmpty);
      expect(feed.insights, isNotEmpty);
    });

    test('includes next action insight for overdue task', () {
      final feed = GardenInsightsAggregator.generate(
        plants: [_plant()],
        logs: [],
        tasks: [_task(dueAt: now.subtract(const Duration(hours: 2)))],
        settings: _settings(),
        speciesMap: {'sp1': _species()},
        now: now,
      );
      final actionInsights = feed.insights
          .where((i) => i.type == GardenInsightType.nextAction);
      expect(actionInsights, isNotEmpty);
    });

    test('includes seasonal tip', () {
      final feed = GardenInsightsAggregator.generate(
        plants: [_plant()],
        logs: [],
        tasks: [],
        settings: _settings(),
        speciesMap: {'sp1': _species()},
        now: DateTime(2026, 7, 15, 10, 0), // Summer
      );
      final seasonal = feed.insights
          .where((i) => i.type == GardenInsightType.seasonalTip);
      expect(seasonal, isNotEmpty);
    });

    test('includes stress alert for neglected plant', () {
      final logs = List.generate(5, (i) =>
          _log(now.subtract(Duration(days: 30 + i * 5))));
      final feed = GardenInsightsAggregator.generate(
        plants: [_plant()],
        logs: logs,
        tasks: [],
        settings: _settings(),
        speciesMap: {'sp1': _species()},
        now: now,
      );
      final stress = feed.insights
          .where((i) => i.type == GardenInsightType.stressAlert);
      expect(stress, isNotEmpty);
    });

    test('limits insights to 4', () {
      final plants = List.generate(10, (i) => _plant(id: 'p$i'));
      final logs = <CareLog>[];
      for (final p in plants) {
        logs.addAll(List.generate(5, (i) =>
            _log(now.subtract(Duration(days: 30 + i * 5)), plantId: p.id)));
      }
      final feed = GardenInsightsAggregator.generate(
        plants: plants,
        logs: logs,
        tasks: [_task(dueAt: now.subtract(const Duration(hours: 1)))],
        settings: _settings(streak: 14),
        speciesMap: {'sp1': _species()},
        now: now,
      );
      expect(feed.insights.length, lessThanOrEqualTo(4));
    });

    test('insights are sorted by priority descending', () {
      final feed = GardenInsightsAggregator.generate(
        plants: [_plant()],
        logs: List.generate(5, (i) =>
            _log(now.subtract(Duration(days: 30 + i * 5)))),
        tasks: [_task(dueAt: now.subtract(const Duration(hours: 1)))],
        settings: _settings(),
        speciesMap: {'sp1': _species()},
        now: now,
      );
      for (int i = 0; i < feed.insights.length - 1; i++) {
        expect(feed.insights[i].priority,
            greaterThanOrEqualTo(feed.insights[i + 1].priority));
      }
    });

    test('empty garden still produces greeting', () {
      final feed = GardenInsightsAggregator.generate(
        plants: [],
        logs: [],
        tasks: [],
        settings: _settings(),
        speciesMap: {},
        now: now,
      );
      expect(feed.greeting.messageKey, isNotEmpty);
    });
  });
}
