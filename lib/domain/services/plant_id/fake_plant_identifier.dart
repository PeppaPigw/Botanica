import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../models/species.dart';
import 'plant_identifier.dart';

class FakePlantIdentifier implements PlantIdentifier {
  const FakePlantIdentifier();

  @override
  List<PlantIdCandidate> identify({
    required Uint8List imageBytes,
    required List<Species> speciesPool,
    int maxResults = 3,
  }) {
    if (speciesPool.isEmpty) return const <PlantIdCandidate>[];

    final seed = sha1.convert(imageBytes).bytes;

    final scored = speciesPool.map((s) {
      final digest = sha1.convert(<int>[
        ...seed,
        ...utf8.encode(s.id),
      ]).bytes;

      // 0.55–0.95 for a pleasant "confident enough" demo UX.
      final conf = 0.55 + (digest[0] / 255.0) * 0.40;
      return PlantIdCandidate(species: s, confidence: conf);
    }).toList(growable: false)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return scored.take(maxResults).toList(growable: false);
  }
}
