import '../models/plant.dart';

class PlantLineageNode {
  const PlantLineageNode({
    required this.plantId,
    required this.plantNickname,
    required this.generation,
    required this.parentId,
    required this.childIds,
    required this.acquiredAt,
    this.propagationMethod,
  });

  final String plantId;
  final String plantNickname;
  final int generation;
  final String? parentId;
  final List<String> childIds;
  final DateTime acquiredAt;
  final String? propagationMethod;

  bool get isFounder => parentId == null;
  bool get hasOffspring => childIds.isNotEmpty;
}

class GardenLegacy {
  const GardenLegacy({
    required this.totalGenerations,
    required this.founderCount,
    required this.propagatedCount,
    required this.longestLineage,
    required this.oldestPlant,
    required this.lineageTree,
    required this.milestones,
  });

  final int totalGenerations;
  final int founderCount;
  final int propagatedCount;
  final int longestLineage;
  final ({String plantId, String nickname, int daysOwned})? oldestPlant;
  final List<PlantLineageNode> lineageTree;
  final List<LegacyMilestone> milestones;
}

class LegacyMilestone {
  const LegacyMilestone({
    required this.type,
    required this.titleKey,
    required this.achieved,
    this.achievedAt,
  });

  final String type;
  final String titleKey;
  final bool achieved;
  final DateTime? achievedAt;
}

class PlantLineageEngine {
  const PlantLineageEngine._();

  static GardenLegacy compute({
    required List<Plant> plants,
    required Map<String, String?> parentMap,
    required Map<String, String?> propagationMethods,
    required DateTime now,
  }) {
    final nodes = <PlantLineageNode>[];
    final childMap = <String, List<String>>{};

    for (final plant in plants) {
      final parentId = parentMap[plant.id];
      childMap.putIfAbsent(plant.id, () => []);
      if (parentId != null) {
        childMap.putIfAbsent(parentId, () => []);
        childMap[parentId]!.add(plant.id);
      }
    }

    for (final plant in plants) {
      final generation = _computeGeneration(plant.id, parentMap);
      nodes.add(PlantLineageNode(
        plantId: plant.id,
        plantNickname: plant.nickname,
        generation: generation,
        parentId: parentMap[plant.id],
        childIds: childMap[plant.id] ?? [],
        acquiredAt: plant.createdAt,
        propagationMethod: propagationMethods[plant.id],
      ));
    }

    final founders = nodes.where((n) => n.isFounder).length;
    final propagated = nodes.where((n) => !n.isFounder).length;
    final maxGen = nodes.isEmpty ? -1 : nodes.map((n) => n.generation).reduce((a, b) => a > b ? a : b);

    final activePlants = plants.where((p) => !p.isArchived).toList();
    final oldest = activePlants.isEmpty
        ? null
        : activePlants.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);

    final milestones = _computeMilestones(nodes, plants, now);

    return GardenLegacy(
      totalGenerations: maxGen + 1,
      founderCount: founders,
      propagatedCount: propagated,
      longestLineage: maxGen + 1,
      oldestPlant: oldest == null
          ? null
          : (
              plantId: oldest.id,
              nickname: oldest.nickname,
              daysOwned: now.difference(oldest.createdAt).inDays,
            ),
      lineageTree: nodes,
      milestones: milestones,
    );
  }

  static int _computeGeneration(String plantId, Map<String, String?> parentMap) {
    int gen = 0;
    String? current = plantId;
    final visited = <String>{};
    while (current != null && !visited.contains(current)) {
      visited.add(current);
      final parent = parentMap[current];
      if (parent == null) break;
      gen++;
      current = parent;
    }
    return gen;
  }

  static List<LegacyMilestone> _computeMilestones(
      List<PlantLineageNode> nodes, List<Plant> plants, DateTime now) {
    final milestones = <LegacyMilestone>[];

    final hasFirstProp = nodes.any((n) => !n.isFounder);
    milestones.add(LegacyMilestone(
      type: 'firstPropagation',
      titleKey: 'legacyFirstPropagation',
      achieved: hasFirstProp,
    ));

    final hasThreeGen = nodes.any((n) => n.generation >= 2);
    milestones.add(LegacyMilestone(
      type: 'threeGenerations',
      titleKey: 'legacyThreeGenerations',
      achieved: hasThreeGen,
    ));

    final yearOld = plants.any((p) =>
        !p.isArchived && now.difference(p.createdAt).inDays >= 365);
    milestones.add(LegacyMilestone(
      type: 'yearSurvivor',
      titleKey: 'legacyYearSurvivor',
      achieved: yearOld,
    ));

    final tenPlants = plants.where((p) => !p.isArchived).length >= 10;
    milestones.add(LegacyMilestone(
      type: 'tenPlantGarden',
      titleKey: 'legacyTenPlants',
      achieved: tenPlants,
    ));

    final fivePropagated = nodes.where((n) => !n.isFounder).length >= 5;
    milestones.add(LegacyMilestone(
      type: 'fivePropagated',
      titleKey: 'legacyFivePropagated',
      achieved: fivePropagated,
    ));

    return milestones;
  }
}
