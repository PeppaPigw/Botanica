import '../models/care_log.dart';
import '../models/plant.dart';

class PlantSiblingGroup {
  const PlantSiblingGroup({
    required this.groupName,
    required this.plants,
    required this.sharedTrait,
    required this.insight,
  });

  final String groupName;
  final List<({String id, String nickname})> plants;
  final String sharedTrait;
  final String insight;
}

class PlantRelationship {
  const PlantRelationship({
    required this.plantAId,
    required this.plantBId,
    required this.relationshipType,
    required this.strength,
    required this.description,
  });

  final String plantAId;
  final String plantBId;
  final String relationshipType;
  final double strength;
  final String description;
}

class GardenSocialGraph {
  const GardenSocialGraph({
    required this.siblingGroups,
    required this.relationships,
    required this.lonelyPlants,
    required this.socialButterfly,
  });

  final List<PlantSiblingGroup> siblingGroups;
  final List<PlantRelationship> relationships;
  final List<String> lonelyPlants;
  final String? socialButterfly;
}

class GardenSocialGraphEngine {
  const GardenSocialGraphEngine._();

  static GardenSocialGraph compute({
    required List<Plant> plants,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final active = plants.where((p) => !p.isArchived).toList();
    if (active.length < 2) {
      return GardenSocialGraph(
        siblingGroups: const [],
        relationships: const [],
        lonelyPlants: active.map((p) => p.id).toList(),
        socialButterfly: null,
      );
    }

    final siblingGroups = _findSiblingGroups(active);
    final relationships = _findRelationships(active, logs, now);
    final lonelyPlants = _findLonelyPlants(active, relationships);
    final socialButterfly = _findSocialButterfly(active, relationships);

    return GardenSocialGraph(
      siblingGroups: siblingGroups,
      relationships: relationships,
      lonelyPlants: lonelyPlants,
      socialButterfly: socialButterfly,
    );
  }

  static List<PlantSiblingGroup> _findSiblingGroups(List<Plant> plants) {
    final groups = <PlantSiblingGroup>[];

    // Group by room
    final byRoom = <String, List<Plant>>{};
    for (final p in plants) {
      byRoom.putIfAbsent(p.room, () => []).add(p);
    }
    for (final entry in byRoom.entries) {
      if (entry.value.length >= 2) {
        groups.add(PlantSiblingGroup(
          groupName: entry.key,
          plants: entry.value.map((p) => (id: p.id, nickname: p.nickname)).toList(),
          sharedTrait: 'sameRoom',
          insight: 'socialRoommates',
        ));
      }
    }

    // Group by species
    final bySpecies = <String, List<Plant>>{};
    for (final p in plants) {
      bySpecies.putIfAbsent(p.speciesId, () => []).add(p);
    }
    for (final entry in bySpecies.entries) {
      if (entry.value.length >= 2) {
        groups.add(PlantSiblingGroup(
          groupName: 'species_${entry.key}',
          plants: entry.value.map((p) => (id: p.id, nickname: p.nickname)).toList(),
          sharedTrait: 'sameSpecies',
          insight: 'socialTwins',
        ));
      }
    }

    return groups;
  }

  static List<PlantRelationship> _findRelationships(
      List<Plant> plants, List<CareLog> logs, DateTime now) {
    final relationships = <PlantRelationship>[];

    for (int i = 0; i < plants.length; i++) {
      for (int j = i + 1; j < plants.length; j++) {
        final a = plants[i];
        final b = plants[j];

        // Same-day care relationship
        final aLogs = logs.where((l) => l.plantId == a.id &&
            now.difference(l.timestamp).inDays <= 30).toList();
        final bLogs = logs.where((l) => l.plantId == b.id &&
            now.difference(l.timestamp).inDays <= 30).toList();

        final aDays = aLogs.map((l) =>
            DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day)).toSet();
        final bDays = bLogs.map((l) =>
            DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day)).toSet();

        final sharedDays = aDays.intersection(bDays).length;
        final totalDays = aDays.union(bDays).length;

        if (totalDays > 0 && sharedDays / totalDays > 0.5) {
          relationships.add(PlantRelationship(
            plantAId: a.id,
            plantBId: b.id,
            relationshipType: 'careBuddies',
            strength: sharedDays / totalDays,
            description: 'socialCareBuddies',
          ));
        }

        // Same acquisition period
        if ((a.createdAt.difference(b.createdAt)).inDays.abs() <= 7) {
          relationships.add(PlantRelationship(
            plantAId: a.id,
            plantBId: b.id,
            relationshipType: 'arrivalBuddies',
            strength: 0.6,
            description: 'socialArrivalBuddies',
          ));
        }
      }
    }

    relationships.sort((a, b) => b.strength.compareTo(a.strength));
    return relationships.take(10).toList();
  }

  static List<String> _findLonelyPlants(
      List<Plant> plants, List<PlantRelationship> relationships) {
    final connected = <String>{};
    for (final r in relationships) {
      connected.add(r.plantAId);
      connected.add(r.plantBId);
    }
    return plants.where((p) => !connected.contains(p.id)).map((p) => p.id).toList();
  }

  static String? _findSocialButterfly(
      List<Plant> plants, List<PlantRelationship> relationships) {
    final counts = <String, int>{};
    for (final r in relationships) {
      counts[r.plantAId] = (counts[r.plantAId] ?? 0) + 1;
      counts[r.plantBId] = (counts[r.plantBId] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
