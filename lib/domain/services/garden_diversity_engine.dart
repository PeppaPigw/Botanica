import '../models/enums.dart';
import '../models/plant.dart';

class DiversityMetrics {
  const DiversityMetrics({
    required this.speciesCount,
    required this.uniqueSpeciesRatio,
    required this.lightSpread,
    required this.difficultySpread,
    required this.environmentSpread,
    required this.overallIndex,
    required this.statusKey,
    required this.suggestions,
  });

  final int speciesCount;
  final double uniqueSpeciesRatio;
  final double lightSpread;
  final double difficultySpread;
  final double environmentSpread;
  final double overallIndex;
  final String statusKey;
  final List<String> suggestions;
}

class GardenDiversityEngine {
  const GardenDiversityEngine._();

  static DiversityMetrics compute({
    required List<Plant> plants,
    required Map<String, String> speciesLight,
    required Map<String, String> speciesDifficulty,
  }) {
    final active = plants.where((p) => !p.isArchived).toList();
    if (active.isEmpty) {
      return const DiversityMetrics(
        speciesCount: 0, uniqueSpeciesRatio: 0.0, lightSpread: 0.0,
        difficultySpread: 0.0, environmentSpread: 0.0, overallIndex: 0.0,
        statusKey: 'diversityEmpty', suggestions: ['diversitySuggestAddPlants'],
      );
    }

    final speciesIds = active.map((p) => p.speciesId).toSet();
    final uniqueRatio = speciesIds.length / active.length;

    final lightValues = active.map((p) => speciesLight[p.speciesId] ?? 'medium').toSet();
    final lightSpread = lightValues.length / 4.0;

    final diffValues = active.map((p) => speciesDifficulty[p.speciesId] ?? 'medium').toSet();
    final diffSpread = diffValues.length / 3.0;

    final envValues = active.map((p) => p.environmentMode).toSet();
    final envSpread = envValues.length / EnvironmentMode.values.length;

    final overall = (uniqueRatio * 0.3 + lightSpread * 0.25 +
        diffSpread * 0.25 + envSpread * 0.2).clamp(0.0, 1.0);

    final statusKey = _status(overall);
    final suggestions = _suggest(uniqueRatio, lightSpread, diffSpread, envSpread);

    return DiversityMetrics(
      speciesCount: speciesIds.length,
      uniqueSpeciesRatio: uniqueRatio,
      lightSpread: lightSpread,
      difficultySpread: diffSpread,
      environmentSpread: envSpread,
      overallIndex: overall,
      statusKey: statusKey,
      suggestions: suggestions,
    );
  }

  static String _status(double index) {
    if (index >= 0.8) return 'diversityExcellent';
    if (index >= 0.6) return 'diversityGood';
    if (index >= 0.4) return 'diversityModerate';
    return 'diversityLow';
  }

  static List<String> _suggest(
      double species, double light, double diff, double env) {
    final suggestions = <String>[];
    if (species < 0.5) suggestions.add('diversitySuggestNewSpecies');
    if (light < 0.5) suggestions.add('diversitySuggestDifferentLight');
    if (diff < 0.5) suggestions.add('diversitySuggestVaryDifficulty');
    if (env < 0.5) suggestions.add('diversitySuggestOutdoor');
    return suggestions;
  }
}
