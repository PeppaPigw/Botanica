import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_goal_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(int daysAgo) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('GardenGoalEngine', () {
    test('suggests goals for new user', () {
      final suggestions = GardenGoalEngine.suggestGoals(
        plants: [_plant('p1')], logs: [], streakDays: 0, now: _now);
      expect(suggestions, isNotEmpty);
      expect(suggestions.length, lessThanOrEqualTo(5));
    });

    test('suggests streak goal when streak is low', () {
      final suggestions = GardenGoalEngine.suggestGoals(
        plants: [_plant('p1')], logs: [], streakDays: 3, now: _now);
      final streakGoal = suggestions.where((s) => s.category == 'streak');
      expect(streakGoal, isNotEmpty);
      expect(streakGoal.first.targetValue, 7);
    });

    test('suggests month streak when week achieved', () {
      final suggestions = GardenGoalEngine.suggestGoals(
        plants: [_plant('p1')], logs: [], streakDays: 10, now: _now);
      final streakGoal = suggestions.where((s) => s.category == 'streak');
      expect(streakGoal, isNotEmpty);
      expect(streakGoal.first.targetValue, 30);
    });

    test('tracks progress for activity goal', () {
      final logs = List.generate(15, (i) => _log(i + 1));
      final suggestion = const GoalSuggestion(
        titleKey: 'goalThirtyActions', descriptionKey: 'goalThirtyActionsDesc',
        targetValue: 30, category: 'activity', difficulty: 'easy', durationDays: 30,
      );
      final goal = GardenGoalEngine.trackProgress(
        suggestion: suggestion, logs: logs, plants: [_plant('p1')],
        streakDays: 5, startDate: _now.subtract(const Duration(days: 30)), now: _now);
      expect(goal.currentValue, 15);
      expect(goal.progress, closeTo(0.5, 0.01));
      expect(goal.isComplete, isFalse);
    });

    test('goal marked complete when target reached', () {
      final logs = List.generate(35, (i) => _log(i));
      final suggestion = const GoalSuggestion(
        titleKey: 'goalThirtyActions', descriptionKey: 'goalThirtyActionsDesc',
        targetValue: 30, category: 'activity', difficulty: 'easy', durationDays: 30,
      );
      final goal = GardenGoalEngine.trackProgress(
        suggestion: suggestion, logs: logs, plants: [_plant('p1')],
        streakDays: 5, startDate: _now.subtract(const Duration(days: 40)), now: _now);
      expect(goal.isComplete, isTrue);
      expect(goal.progress, 1.0);
    });

    test('collection goal tracks plant count', () {
      final plants = List.generate(7, (i) => _plant('p$i'));
      final suggestion = const GoalSuggestion(
        titleKey: 'goalTenPlants', descriptionKey: 'goalTenPlantsDesc',
        targetValue: 10, category: 'collection', difficulty: 'medium', durationDays: 60,
      );
      final goal = GardenGoalEngine.trackProgress(
        suggestion: suggestion, logs: [], plants: plants,
        streakDays: 0, startDate: _now.subtract(const Duration(days: 10)), now: _now);
      expect(goal.currentValue, 7);
      expect(goal.remaining, 3);
    });
  });
}
