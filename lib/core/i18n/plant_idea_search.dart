import '../../domain/models/plant_idea.dart';
import 'species_search.dart';

bool plantIdeaMatchesQuery(PlantIdea idea, String rawQuery) {
  final query = normalizeSearchText(rawQuery);
  if (query.isEmpty) return true;

  if (normalizeSearchText(idea.scientificName).contains(query)) return true;

  for (final names in idea.commonNamesByLocale.values) {
    for (final name in names) {
      if (normalizeSearchText(name).contains(query)) return true;
    }
  }

  if (normalizeSearchText(idea.plantId).contains(query)) return true;

  return false;
}
