import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/daily_briefing_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {bool archived = false}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: archived,
    );

CareLog _log(int daysAgo) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('DailyBriefingEngine', () {
    test('generates morning greeting', () {
      final briefing = DailyBriefingEngine.generate(
        plants: [_plant('p1')], logs: [_log(1)],
        healthScores: {'p1': 0.8}, streakDays: 5,
        plantsAddedThisMonth: 0, missedTasksThisWeek: 0,
        missedTasksLastWeek: 0, totalDailyTasks: 3, now: _now,
      );
      expect(briefing.greeting, 'briefingGoodMorning');
    });

    test('evening greeting after 5pm', () {
      final evening = DateTime(2026, 5, 17, 19, 0);
      final briefing = DailyBriefingEngine.generate(
        plants: [_plant('p1')], logs: [],
        healthScores: {'p1': 0.8}, streakDays: 5,
        plantsAddedThisMonth: 0, missedTasksThisWeek: 0,
        missedTasksLastWeek: 0, totalDailyTasks: 3, now: evening,
      );
      expect(briefing.greeting, 'briefingGoodEvening');
    });

    test('includes health alert for critical plants', () {
      final briefing = DailyBriefingEngine.generate(
        plants: [_plant('p1')], logs: [],
        healthScores: {'p1': 0.2}, streakDays: 0,
        plantsAddedThisMonth: 0, missedTasksThisWeek: 0,
        missedTasksLastWeek: 0, totalDailyTasks: 3, now: _now,
      );
      final alert = briefing.items.where((i) => i.type == 'healthAlert');
      expect(alert, isNotEmpty);
    });

    test('includes burnout warning when overloaded', () {
      final briefing = DailyBriefingEngine.generate(
        plants: List.generate(25, (i) => _plant('p$i')),
        logs: [],
        healthScores: {}, streakDays: 0,
        plantsAddedThisMonth: 0, missedTasksThisWeek: 10,
        missedTasksLastWeek: 3, totalDailyTasks: 15, now: _now,
      );
      expect(briefing.burnoutRisk, isNot('burnoutLow'));
    });

    test('limits items to 5', () {
      final briefing = DailyBriefingEngine.generate(
        plants: List.generate(10, (i) => _plant('p$i')),
        logs: List.generate(20, (i) => _log(i + 1)),
        healthScores: {'p0': 0.1, 'p1': 0.2},
        streakDays: 6, plantsAddedThisMonth: 2,
        missedTasksThisWeek: 8, missedTasksLastWeek: 2,
        totalDailyTasks: 12, now: _now,
      );
      expect(briefing.items.length, lessThanOrEqualTo(5));
    });

    test('streak milestone near 7 days', () {
      final briefing = DailyBriefingEngine.generate(
        plants: [_plant('p1')], logs: [_log(1)],
        healthScores: {'p1': 0.8}, streakDays: 6,
        plantsAddedThisMonth: 0, missedTasksThisWeek: 0,
        missedTasksLastWeek: 0, totalDailyTasks: 3, now: _now,
      );
      final milestone = briefing.items.where((i) => i.type == 'streakMilestone');
      expect(milestone, isNotEmpty);
    });
  });
}
