import '../models/care_log.dart';
import '../models/plant.dart';

class PlantMoodState {
  const PlantMoodState({
    required this.plantId,
    required this.mood,
    required this.intensity,
    required this.reason,
  });

  final String plantId;
  final String mood;
  final double intensity;
  final String reason;
}

class GardenMoodBoard {
  const GardenMoodBoard({
    required this.dominantMood,
    required this.moodDistribution,
    required this.plantMoods,
    required this.overallVibes,
    required this.suggestion,
  });

  final String dominantMood;
  final Map<String, int> moodDistribution;
  final List<PlantMoodState> plantMoods;
  final double overallVibes;
  final String suggestion;
}

class GardenMoodBoardEngine {
  const GardenMoodBoardEngine._();

  static GardenMoodBoard compute({
    required List<Plant> plants,
    required List<CareLog> logs,
    required Map<String, double> healthScores,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.isEmpty) {
      return const GardenMoodBoard(
        dominantMood: 'moodEmpty',
        moodDistribution: {},
        plantMoods: [],
        overallVibes: 0.0,
        suggestion: 'moodSuggestionAddPlants',
      );
    }

    final plantMoods = <PlantMoodState>[];
    for (final plant in activePlants) {
      plantMoods.add(_computePlantMood(plant, logs, healthScores, now));
    }

    final distribution = <String, int>{};
    for (final pm in plantMoods) {
      distribution[pm.mood] = (distribution[pm.mood] ?? 0) + 1;
    }

    final dominant = distribution.entries
        .reduce((a, b) => a.value >= b.value ? a : b).key;

    final overallVibes = plantMoods.map((m) => m.intensity).reduce((a, b) => a + b)
        / plantMoods.length;

    final suggestion = _suggest(dominant, overallVibes);

    return GardenMoodBoard(
      dominantMood: dominant,
      moodDistribution: distribution,
      plantMoods: plantMoods,
      overallVibes: overallVibes,
      suggestion: suggestion,
    );
  }

  static PlantMoodState _computePlantMood(
      Plant plant, List<CareLog> logs, Map<String, double> healthScores, DateTime now) {
    final health = healthScores[plant.id] ?? 0.5;
    final recentCare = logs.where((l) =>
        l.plantId == plant.id && now.difference(l.timestamp).inDays <= 7).length;

    if (health >= 0.8 && recentCare >= 3) {
      return PlantMoodState(
        plantId: plant.id, mood: 'moodThriving', intensity: 0.9,
        reason: 'moodReasonWellCared',
      );
    }
    if (health >= 0.6) {
      return PlantMoodState(
        plantId: plant.id, mood: 'moodContent', intensity: 0.7,
        reason: 'moodReasonHealthy',
      );
    }
    if (recentCare == 0) {
      return PlantMoodState(
        plantId: plant.id, mood: 'moodLonely', intensity: 0.4,
        reason: 'moodReasonNeglected',
      );
    }
    return PlantMoodState(
      plantId: plant.id, mood: 'moodRecovering', intensity: 0.5,
      reason: 'moodReasonNeedsCare',
    );
  }

  static String _suggest(String dominant, double vibes) {
    if (vibes >= 0.8) return 'moodSuggestionKeepItUp';
    if (dominant == 'moodLonely') return 'moodSuggestionVisitPlants';
    if (dominant == 'moodRecovering') return 'moodSuggestionExtraCare';
    return 'moodSuggestionMaintain';
  }
}
