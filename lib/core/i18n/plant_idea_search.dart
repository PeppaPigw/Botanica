import '../../domain/models/plant_idea.dart';
import 'species_search.dart';

bool plantIdeaMatchesQuery(PlantIdea idea, String rawQuery) {
  final query = normalizeSearchText(rawQuery);
  if (query.isEmpty) return true;

  final entries = <String>[
    idea.plantId,
    idea.scientificName,
    idea.category,
    idea.difficulty ?? '',
    idea.light ?? '',
    ...idea.tags,
    ...idea.commonNamesByLocale.values.expand((items) => items),
    ...idea.historyByLocale.values,
    ...idea.habitByLocale.values,
    if (idea.botanical?.family != null) idea.botanical!.family!,
    if (idea.botanical?.genus != null) idea.botanical!.genus!,
    if (idea.botanical?.order != null) idea.botanical!.order!,
    if (idea.botanical?.nativeRange != null) idea.botanical!.nativeRange!,
    if (idea.botanical?.nativeHabitat != null) idea.botanical!.nativeHabitat!,
    if (idea.growth?.rate != null) idea.growth!.rate!,
    if (idea.growth?.form != null) idea.growth!.form!,
    if (idea.toxicity?.pets != null) idea.toxicity!.pets!,
    if (idea.toxicity?.humans != null) idea.toxicity!.humans!,
    if (idea.toxicity != null) ...idea.toxicity!.notesByLocale.values,
  ];

  for (final entry in entries) {
    if (normalizeSearchText(entry).contains(query)) {
      return true;
    }
  }

  return false;
}
