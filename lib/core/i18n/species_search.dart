import '../../domain/models/species.dart';

final RegExp _kSearchStrip = RegExp(r"[\\s'’`´\\-_/\\.,]+");

String normalizeSearchText(String input) {
  return input.trim().toLowerCase().replaceAll(_kSearchStrip, '');
}

bool speciesMatchesQuery(Species species, String rawQuery) {
  final query = normalizeSearchText(rawQuery);
  if (query.isEmpty) return true;

  if (normalizeSearchText(species.scientificName).contains(query)) return true;

  for (final names in species.commonNamesByLocale.values) {
    for (final name in names) {
      if (normalizeSearchText(name).contains(query)) return true;
    }
  }

  return false;
}
