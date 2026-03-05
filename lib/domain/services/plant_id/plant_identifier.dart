import 'dart:typed_data';

import '../../models/species.dart';

class PlantIdCandidate {
  const PlantIdCandidate({
    required this.species,
    required this.confidence,
  });

  final Species species;
  final double confidence;
}

abstract interface class PlantIdentifier {
  List<PlantIdCandidate> identify({
    required Uint8List imageBytes,
    required List<Species> speciesPool,
    int maxResults = 3,
  });
}
