import '../../domain/models/species.dart';

final RegExp _kSearchStrip = RegExp(r"[\s'’`´\-_/.,]+");

String normalizeSearchText(String input) {
  return input.trim().toLowerCase().replaceAll(_kSearchStrip, '');
}

bool speciesMatchesQuery(Species species, String rawQuery) {
  final query = normalizeSearchText(rawQuery);
  if (query.isEmpty) return true;

  final entries = <String>[
    species.id,
    species.scientificName,
    species.difficulty,
    species.light,
    ...species.tags,
    ...species.commonNamesByLocale.values.expand((items) => items),
    ...species.historyByLocale.values,
    ...species.habitByLocale.values,
    ...species.careWarningsByLocale.values,
    if (species.origin != null) ...species.origin!.nativeRangeByLocale.values,
    if (species.origin != null) ...species.origin!.notesByLocale.values,
    if (species.toxicity != null) species.toxicity!.pets,
    if (species.toxicity?.humans != null) species.toxicity!.humans!,
    if (species.toxicity != null) ...species.toxicity!.notesByLocale.values,
    if (species.growth != null) species.growth!.rate,
    if (species.growth != null) species.growth!.form,
    if (species.growth != null) ...species.growth!.notesByLocale.values,
    if (species.matureSize != null) ...species.matureSize!.notesByLocale.values,
  ];

  for (final entry in entries) {
    if (normalizeSearchText(entry).contains(query)) {
      return true;
    }
  }

  return false;
}
