import 'package:botanica/domain/models/species.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Species.fromJson uses defaults for missing optional fields', () {
    final species = Species.fromJson(
      <String, dynamic>{
        'id': 'legacy_species',
        'commonNames': <String, dynamic>{
          'en': <String>['Legacy plant'],
        },
      },
    );

    expect(species.id, 'legacy_species');
    expect(species.scientificName, '');
    expect(species.difficulty, 'easy');
    expect(species.petSafe, isFalse);
    expect(species.light, '');
    expect(species.tags, isEmpty);
    expect(species.imagePath, isNull);
    expect(species.historyByLocale, isEmpty);
    expect(species.habitByLocale, isEmpty);
    expect(species.careWarningsByLocale, isEmpty);
    expect(species.origin, isNull);
    expect(species.toxicity, isNull);
    expect(species.growth, isNull);
    expect(species.matureSize, isNull);
    expect(species.careDefaults.waterBaseDays, 7);
    expect(species.careDefaults.fertilizeBaseDays, 30);
    expect(species.careDefaults.mistBaseDays, 0);
    expect(species.careDefaults.rotateBaseDays, 14);
    expect(species.careDefaults.pruneBaseDays, 90);
    expect(species.careDefaults.repotBaseDays, 365);
    expect(species.careDefaults.pestCheckBaseDays, 14);
    expect(species.careDefaults.wipeLeavesBaseDays, 14);
  });
}
