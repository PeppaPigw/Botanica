import '../models/care_log.dart';
import '../models/plant.dart';

class PlantRelationship {
  const PlantRelationship({
    required this.plantId,
    required this.relationshipType,
    required this.strength,
    required this.description,
  });

  final String plantId;
  final String relationshipType;
  final double strength;
  final String description;
}

class EmotionalBond {
  const EmotionalBond({
    required this.plantId,
    required this.plantNickname,
    required this.bondStrength,
    required this.bondType,
    required this.sharedMoments,
    required this.relationships,
  });

  final String plantId;
  final String plantNickname;
  final double bondStrength;
  final String bondType;
  final int sharedMoments;
  final List<PlantRelationship> relationships;
}

class EmotionalBondEngine {
  const EmotionalBondEngine._();

  static List<EmotionalBond> compute({
    required List<Plant> plants,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final active = plants.where((p) => !p.isArchived).toList();
    final bonds = <EmotionalBond>[];

    for (final plant in active) {
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      final ageDays = now.difference(plant.createdAt).inDays;
      final careCount = plantLogs.length;

      final strength = _bondStrength(ageDays, careCount);
      final type = _bondType(strength, ageDays);
      final relationships = _findRelationships(plant, active, logs);

      bonds.add(EmotionalBond(
        plantId: plant.id,
        plantNickname: plant.nickname,
        bondStrength: strength,
        bondType: type,
        sharedMoments: careCount,
        relationships: relationships,
      ));
    }

    bonds.sort((a, b) => b.bondStrength.compareTo(a.bondStrength));
    return bonds;
  }

  static double _bondStrength(int ageDays, int careCount) {
    final ageScore = (ageDays / 365.0).clamp(0.0, 1.0);
    final careScore = (careCount / 50.0).clamp(0.0, 1.0);
    return (ageScore * 0.4 + careScore * 0.6).clamp(0.0, 1.0);
  }

  static String _bondType(double strength, int ageDays) {
    if (strength >= 0.8 && ageDays >= 365) return 'bondSoulmate';
    if (strength >= 0.6) return 'bondBestFriend';
    if (strength >= 0.4) return 'bondCompanion';
    if (ageDays < 30) return 'bondNewFriend';
    return 'bondAcquaintance';
  }

  static List<PlantRelationship> _findRelationships(
      Plant plant, List<Plant> all, List<CareLog> logs) {
    final relationships = <PlantRelationship>[];

    final sameRoom = all.where((p) => p.id != plant.id && p.room == plant.room).toList();
    for (final neighbor in sameRoom.take(2)) {
      relationships.add(PlantRelationship(
        plantId: neighbor.id,
        relationshipType: 'relationRoommate',
        strength: 0.6,
        description: 'relationRoommateDesc',
      ));
    }

    final sameSpecies = all.where((p) =>
        p.id != plant.id && p.speciesId == plant.speciesId).toList();
    for (final sibling in sameSpecies.take(2)) {
      relationships.add(PlantRelationship(
        plantId: sibling.id,
        relationshipType: 'relationSibling',
        strength: 0.8,
        description: 'relationSiblingDesc',
      ));
    }

    return relationships;
  }
}
