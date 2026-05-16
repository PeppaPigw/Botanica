import '../models/care_log.dart';
import '../models/plant.dart';

class GardenGoal {
  const GardenGoal({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.targetValue,
    required this.currentValue,
    required this.deadline,
    required this.category,
    this.plantId,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final int targetValue;
  final int currentValue;
  final DateTime deadline;
  final String category;
  final String? plantId;

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isComplete => currentValue >= targetValue;
  int get remaining => (targetValue - currentValue).clamp(0, targetValue);
}

class GoalSuggestion {
  const GoalSuggestion({
    required this.titleKey,
    required this.descriptionKey,
    required this.targetValue,
    required this.category,
    required this.difficulty,
    required this.durationDays,
  });

  final String titleKey;
  final String descriptionKey;
  final int targetValue;
  final String category;
  final String difficulty;
  final int durationDays;
}

class GardenGoalEngine {
  const GardenGoalEngine._();

  static List<GoalSuggestion> suggestGoals({
    required List<Plant> plants,
    required List<CareLog> logs,
    required int streakDays,
    required DateTime now,
  }) {
    final suggestions = <GoalSuggestion>[];
    final activePlants = plants.where((p) => !p.isArchived).length;
    final recentLogs = logs.where((l) => now.difference(l.timestamp).inDays <= 30).length;

    // Streak goals
    if (streakDays < 7) {
      suggestions.add(const GoalSuggestion(
        titleKey: 'goalWeekStreak', descriptionKey: 'goalWeekStreakDesc',
        targetValue: 7, category: 'streak', difficulty: 'easy', durationDays: 7,
      ));
    } else if (streakDays < 30) {
      suggestions.add(const GoalSuggestion(
        titleKey: 'goalMonthStreak', descriptionKey: 'goalMonthStreakDesc',
        targetValue: 30, category: 'streak', difficulty: 'medium', durationDays: 30,
      ));
    }

    // Collection goals
    if (activePlants < 5) {
      suggestions.add(const GoalSuggestion(
        titleKey: 'goalFivePlants', descriptionKey: 'goalFivePlantsDesc',
        targetValue: 5, category: 'collection', difficulty: 'easy', durationDays: 30,
      ));
    } else if (activePlants < 10) {
      suggestions.add(const GoalSuggestion(
        titleKey: 'goalTenPlants', descriptionKey: 'goalTenPlantsDesc',
        targetValue: 10, category: 'collection', difficulty: 'medium', durationDays: 60,
      ));
    }

    // Activity goals
    if (recentLogs < 30) {
      suggestions.add(const GoalSuggestion(
        titleKey: 'goalThirtyActions', descriptionKey: 'goalThirtyActionsDesc',
        targetValue: 30, category: 'activity', difficulty: 'easy', durationDays: 30,
      ));
    } else {
      suggestions.add(const GoalSuggestion(
        titleKey: 'goalHundredActions', descriptionKey: 'goalHundredActionsDesc',
        targetValue: 100, category: 'activity', difficulty: 'hard', durationDays: 30,
      ));
    }

    // Photo goal
    suggestions.add(const GoalSuggestion(
      titleKey: 'goalWeeklyPhoto', descriptionKey: 'goalWeeklyPhotoDesc',
      targetValue: 4, category: 'documentation', difficulty: 'easy', durationDays: 28,
    ));

    // Diversity goal
    suggestions.add(const GoalSuggestion(
      titleKey: 'goalCareVariety', descriptionKey: 'goalCareVarietyDesc',
      targetValue: 5, category: 'diversity', difficulty: 'medium', durationDays: 14,
    ));

    return suggestions.take(5).toList();
  }

  static GardenGoal trackProgress({
    required GoalSuggestion suggestion,
    required List<CareLog> logs,
    required List<Plant> plants,
    required int streakDays,
    required DateTime startDate,
    required DateTime now,
  }) {
    int current = 0;

    switch (suggestion.category) {
      case 'streak':
        current = streakDays;
      case 'collection':
        current = plants.where((p) => !p.isArchived).length;
      case 'activity':
        current = logs.where((l) =>
            l.timestamp.isAfter(startDate) && l.timestamp.isBefore(now)).length;
      case 'documentation':
        current = logs.where((l) =>
            l.timestamp.isAfter(startDate) && l.linkedPhotoId != null).length;
      case 'diversity':
        current = logs.where((l) => l.timestamp.isAfter(startDate))
            .map((l) => l.type).toSet().length;
    }

    return GardenGoal(
      id: '${suggestion.category}_${suggestion.targetValue}',
      titleKey: suggestion.titleKey,
      descriptionKey: suggestion.descriptionKey,
      targetValue: suggestion.targetValue,
      currentValue: current,
      deadline: startDate.add(Duration(days: suggestion.durationDays)),
      category: suggestion.category,
    );
  }
}
