import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assets/data/plantsidea.json contains 300+ standardized plant entries',
      () {
    const allowedDifficulty = <String>{'easy', 'medium', 'hard'};
    const allowedLight = <String>{
      'bright_direct',
      'bright_indirect',
      'medium_indirect',
      'low_to_bright_indirect',
      'low_to_bright',
    };
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

    final file = File('assets/data/plantsidea.json');
    expect(file.existsSync(), isTrue, reason: 'Missing plantsidea JSON file.');

    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    expect(decoded['schema_version'], isA<int>());
    expect((decoded['schema_version'] as int) >= 1, isTrue);
    expect(decoded['generated_at'], isA<String>());

    final list = decoded['plants'] as List<dynamic>? ?? const <dynamic>[];
    expect(list.length >= 300, isTrue,
        reason: 'Expected at least 300 plant entries.');

    final ids = <String>{};
    for (final entry in list) {
      final plant = Map<String, dynamic>.from(entry as Map);

      expect(plant['plant_id'], isA<String>());
      final id = (plant['plant_id'] as String).trim();
      expect(id, isNotEmpty);
      expect(ids.add(id), isTrue, reason: 'Duplicate plant_id: $id');

      expect(plant['scientific_name'], isA<String>());
      expect((plant['scientific_name'] as String).trim(), isNotEmpty);

      expect(plant['common_names'], isA<Map>());
      final commonNames =
          Map<String, dynamic>.from(plant['common_names'] as Map);
      expect(commonNames, isNotEmpty);
      expect(commonNames.values.any((v) => v is List && v.isNotEmpty), isTrue);

      expect(plant['category'], isA<String>());
      expect((plant['category'] as String).trim(), isNotEmpty);

      expect(plant['tags'], isA<List>());
      final tags = (plant['tags'] as List).map((e) => e.toString()).toList();
      expect(tags, isNotEmpty);

      expect(plant['image_path'], isA<String>());
      final imagePath = (plant['image_path'] as String).trim();
      expect(imagePath, isNotEmpty);
      expect(imagePath.endsWith('/unknown.png'), isFalse,
          reason: 'image_path must not be unknown.png for $id');
      expect(imagePath.endsWith('/$id.png'), isTrue,
          reason: 'image_path must match plant_id filename for $id');
      expect(File(imagePath).existsSync(), isTrue,
          reason: 'Missing placeholder image file: $imagePath');

      expect(plant['difficulty'], isA<String>());
      expect(allowedDifficulty.contains(plant['difficulty'] as String), isTrue);

      expect(plant['pet_safe'], isA<bool>());

      expect(plant['light'], isA<String>());
      expect(allowedLight.contains(plant['light'] as String), isTrue);

      expect(plant['history'], isA<Map>());
      expect((plant['history'] as Map).isNotEmpty, isTrue);

      expect(plant['habit'], isA<Map>());
      expect((plant['habit'] as Map).isNotEmpty, isTrue);

      expect(plant['care_defaults'], isA<Map>());
      final careDefaults =
          Map<String, dynamic>.from(plant['care_defaults'] as Map);
      for (final key in const <String>[
        'waterBaseDays',
        'fertilizeBaseDays',
        'mistBaseDays',
        'rotateBaseDays',
        'pruneBaseDays',
      ]) {
        expect(careDefaults[key], isA<int>(), reason: 'Missing $key for $id');
        expect((careDefaults[key] as int) >= 0, isTrue,
            reason: '$key must be >= 0 for $id');
      }

      expect(plant['botanical'], isA<Map>());
      final botanical = Map<String, dynamic>.from(plant['botanical'] as Map);
      for (final key in const <String>['family', 'order', 'genus', 'rank']) {
        expect(botanical[key], isA<String>(),
            reason: 'Missing botanical.$key for $id');
        expect((botanical[key] as String).trim(), isNotEmpty);
      }
      expect(botanical['native_range'], isA<Map>());
      expect(botanical['native_habitat'], isA<Map>());

      expect(plant['growth'], isA<Map>());
      final growth = Map<String, dynamic>.from(plant['growth'] as Map);
      expect(growth['rate'], isA<String>());
      expect(allowedGrowthRate.contains(growth['rate'] as String), isTrue);
      expect(growth['form'], isA<String>());
      expect(allowedGrowthForm.contains(growth['form'] as String), isTrue);

      expect(growth['mature_size_cm'], isA<Map>());
      final size = Map<String, dynamic>.from(growth['mature_size_cm'] as Map);
      _expectSizeRange(size['height_cm'], label: 'height_cm', id: id);
      _expectSizeRange(size['spread_cm'], label: 'spread_cm', id: id);
      if (size['vine_length_cm'] != null) {
        _expectSizeRange(size['vine_length_cm'],
            label: 'vine_length_cm', id: id);
      }

      expect(plant['care'], isA<Map>());
      final care = Map<String, dynamic>.from(plant['care'] as Map);
      for (final key in const <String>[
        'watering',
        'fertilizing',
        'soil',
        'temperature_c',
        'humidity_pct',
        'pruning',
        'pests_and_diseases',
        'extreme_weather',
      ]) {
        expect(care[key], isA<Map>(), reason: 'Missing care.$key for $id');
      }

      expect(plant['toxicity'], isA<Map>());
      final toxicity = Map<String, dynamic>.from(plant['toxicity'] as Map);
      expect(toxicity['pets'], isA<String>());
      expect(toxicity['humans'], isA<String>());

      expect(plant['external_resources'], isA<Map>());
      final resources =
          Map<String, dynamic>.from(plant['external_resources'] as Map);
      for (final key in const <String>[
        'wikipedia',
        'youtube_search',
        'baidu_baike_search',
        'bilibili_search',
      ]) {
        expect(resources[key], isA<String>(), reason: 'Missing $key for $id');
        expect((resources[key] as String).trim(), isNotEmpty,
            reason: '$key must be non-empty for $id');
      }
    }
  });
}

void _expectSizeRange(Object? value,
    {required String label, required String id}) {
  expect(value, isA<Map>(),
      reason: 'Missing growth.mature_size_cm.$label for $id');
  final range = Map<String, dynamic>.from(value as Map);
  expect(range['min'], isA<int>(),
      reason: 'Missing growth.mature_size_cm.$label.min for $id');
  expect(range['max'], isA<int>(),
      reason: 'Missing growth.mature_size_cm.$label.max for $id');
  final min = range['min'] as int;
  final max = range['max'] as int;
  expect(min >= 0, isTrue,
      reason: 'growth.mature_size_cm.$label.min must be >= 0 for $id');
  expect(max >= 0, isTrue,
      reason: 'growth.mature_size_cm.$label.max must be >= 0 for $id');
  expect(min <= max, isTrue,
      reason: 'growth.mature_size_cm.$label must be min <= max for $id');
}
