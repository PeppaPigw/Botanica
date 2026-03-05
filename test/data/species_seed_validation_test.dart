import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assets/data/species_seed.json contains required species metadata', () {
    const allowedDifficulty = <String>{'easy', 'medium', 'hard'};
    const allowedLight = <String>{
      'bright_direct',
      'bright_indirect',
      'medium_indirect',
      'low_to_bright_indirect',
      'low_to_bright',
    };
    const allowedToxicityPets = <String>{'pet_safe', 'toxic', 'unknown'};
    const allowedGrowthRate = <String>{'slow', 'moderate', 'fast', 'unknown'};
    const allowedGrowthForm = <String>{
      'upright',
      'trailing',
      'climbing',
      'rosette',
      'tree_like',
      'clumping',
      'epiphytic',
      'succulent',
      'fern',
      'orchid',
      'other',
    };

    final file = File('assets/data/species_seed.json');
    expect(file.existsSync(), isTrue, reason: 'Missing seed JSON file.');

    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final list = decoded['species'] as List<dynamic>? ?? const <dynamic>[];
    expect(list, isNotEmpty, reason: 'Expected at least one seeded species.');

    for (final entry in list) {
      final species = Map<String, dynamic>.from(entry as Map);

      expect(species['id'], isA<String>());
      expect((species['id'] as String).trim(), isNotEmpty);

      expect(species['scientificName'], isA<String>());
      expect((species['scientificName'] as String).trim(), isNotEmpty);

      expect(species['commonNames'], isA<Map>());
      final commonNames =
          Map<String, dynamic>.from(species['commonNames'] as Map);
      expect(commonNames, isNotEmpty);

      expect(species['difficulty'], isA<String>());
      expect(
          allowedDifficulty.contains(species['difficulty'] as String), isTrue);

      expect(species['petSafe'], isA<bool>());
      final petSafe = species['petSafe'] as bool;

      expect(species['light'], isA<String>());
      expect(allowedLight.contains(species['light'] as String), isTrue);

      expect(species['imagePath'], isA<String>());
      final imagePath = (species['imagePath'] as String).trim();
      expect(imagePath, isNotEmpty);
      expect(File(imagePath).existsSync(), isTrue,
          reason: 'Missing placeholder image: $imagePath');

      expect(species['history'], isA<Map>());
      final history = Map<String, dynamic>.from(species['history'] as Map);
      expect(history, isNotEmpty);

      expect(species['habit'], isA<Map>());
      final habit = Map<String, dynamic>.from(species['habit'] as Map);
      expect(habit, isNotEmpty);

      expect(species['origin'], isA<Map>());
      final origin = Map<String, dynamic>.from(species['origin'] as Map);
      expect(origin['nativeRange'], isA<Map>());
      final nativeRange =
          Map<String, dynamic>.from(origin['nativeRange'] as Map);
      expect(nativeRange, isNotEmpty);

      expect(species['toxicity'], isA<Map>());
      final toxicity = Map<String, dynamic>.from(species['toxicity'] as Map);
      expect(toxicity['pets'], isA<String>());
      final pets = toxicity['pets'] as String;
      expect(allowedToxicityPets.contains(pets), isTrue);
      expect(petSafe ? pets == 'pet_safe' : pets == 'toxic', isTrue,
          reason: 'toxicity.pets should match petSafe for ${species['id']}.');

      expect(species['growth'], isA<Map>());
      final growth = Map<String, dynamic>.from(species['growth'] as Map);
      expect(growth['rate'], isA<String>());
      expect(allowedGrowthRate.contains(growth['rate'] as String), isTrue);
      expect(growth['form'], isA<String>());
      expect(allowedGrowthForm.contains(growth['form'] as String), isTrue);

      expect(species['matureSize'], isA<Map>());
      final matureSize =
          Map<String, dynamic>.from(species['matureSize'] as Map);
      _expectSizeRange(matureSize['heightCm'], label: 'heightCm');
      _expectSizeRange(matureSize['spreadCm'], label: 'spreadCm');
      if (matureSize['vineLengthCm'] != null) {
        _expectSizeRange(matureSize['vineLengthCm'], label: 'vineLengthCm');
      }

      expect(species['careDefaults'], isA<Map>());
      final careDefaults =
          Map<String, dynamic>.from(species['careDefaults'] as Map);
      for (final key in const <String>[
        'waterBaseDays',
        'fertilizeBaseDays',
        'mistBaseDays',
        'rotateBaseDays',
        'pruneBaseDays',
      ]) {
        expect(careDefaults[key], isA<int>(), reason: 'Missing $key.');
        expect((careDefaults[key] as int) >= 0, isTrue,
            reason: '$key must be >= 0.');
      }
    }
  });
}

void _expectSizeRange(Object? value, {required String label}) {
  expect(value, isA<Map>(), reason: 'Missing matureSize.$label.');
  final range = Map<String, dynamic>.from(value as Map);
  expect(range['min'], isA<int>(), reason: 'Missing matureSize.$label.min');
  expect(range['max'], isA<int>(), reason: 'Missing matureSize.$label.max');
  final min = range['min'] as int;
  final max = range['max'] as int;
  expect(min >= 0, isTrue, reason: 'matureSize.$label.min must be >= 0');
  expect(max >= 0, isTrue, reason: 'matureSize.$label.max must be >= 0');
  expect(min <= max, isTrue, reason: 'matureSize.$label must be min <= max');
}
