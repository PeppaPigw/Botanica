import '../models/plant.dart';
import '../models/species.dart';

enum RoomSuggestionReason {
  similarLight,
  similarWater,
  humidityBuddies,
  sameGrowthRate,
}

class RoomPlacement {
  const RoomPlacement({
    required this.plantId,
    required this.plantNickname,
    required this.currentRoom,
    required this.suggestedRoom,
    required this.reasons,
    required this.companionIds,
  });

  final String plantId;
  final String plantNickname;
  final String currentRoom;
  final String suggestedRoom;
  final List<RoomSuggestionReason> reasons;
  final List<String> companionIds;
}

class RoomOptimizer {
  const RoomOptimizer._();

  static List<RoomPlacement> optimize({
    required List<Plant> plants,
    required Map<String, Species> speciesMap,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 3) return [];

    final rooms = activePlants.map((p) => p.room).toSet().toList();
    if (rooms.length < 2) return [];

    final suggestions = <RoomPlacement>[];

    for (final plant in activePlants) {
      final species = speciesMap[plant.speciesId];
      if (species == null) continue;

      final bestRoom = _findBestRoom(
        plant: plant,
        species: species,
        allPlants: activePlants,
        speciesMap: speciesMap,
        rooms: rooms,
      );

      if (bestRoom != null && bestRoom.room != plant.room) {
        suggestions.add(RoomPlacement(
          plantId: plant.id,
          plantNickname: plant.nickname,
          currentRoom: plant.room,
          suggestedRoom: bestRoom.room,
          reasons: bestRoom.reasons,
          companionIds: bestRoom.companionIds,
        ));
      }
    }

    return suggestions;
  }

  static _RoomScore? _findBestRoom({
    required Plant plant,
    required Species species,
    required List<Plant> allPlants,
    required Map<String, Species> speciesMap,
    required List<String> rooms,
  }) {
    _RoomScore? best;
    double bestScore = 0;

    for (final room in rooms) {
      if (room == plant.room) continue;

      final roommates = allPlants
          .where((p) => p.room == room && p.id != plant.id)
          .toList();
      if (roommates.isEmpty) continue;

      double score = 0;
      final reasons = <RoomSuggestionReason>{};
      final companions = <String>[];

      for (final mate in roommates) {
        final mateSpecies = speciesMap[mate.speciesId];
        if (mateSpecies == null) continue;

        if (_similarLight(species, mateSpecies)) {
          score += 0.3;
          reasons.add(RoomSuggestionReason.similarLight);
          companions.add(mate.id);
        }

        if (_similarWater(species, mateSpecies)) {
          score += 0.25;
          reasons.add(RoomSuggestionReason.similarWater);
          if (!companions.contains(mate.id)) companions.add(mate.id);
        }

        if (_sameGrowthRate(species, mateSpecies)) {
          score += 0.15;
          reasons.add(RoomSuggestionReason.sameGrowthRate);
        }
      }

      final currentRoommates = allPlants
          .where((p) => p.room == plant.room && p.id != plant.id)
          .toList();
      double currentScore = 0;
      for (final mate in currentRoommates) {
        final mateSpecies = speciesMap[mate.speciesId];
        if (mateSpecies == null) continue;
        if (_similarLight(species, mateSpecies)) currentScore += 0.3;
        if (_similarWater(species, mateSpecies)) currentScore += 0.25;
      }

      if (score > currentScore && score > bestScore) {
        bestScore = score;
        best = _RoomScore(
          room: room,
          reasons: reasons.toList(),
          companionIds: companions,
        );
      }
    }

    return best;
  }

  static bool _similarLight(Species a, Species b) {
    return a.light.toLowerCase() == b.light.toLowerCase();
  }

  static bool _similarWater(Species a, Species b) {
    final aWater = a.careDefaults.waterBaseDays;
    final bWater = b.careDefaults.waterBaseDays;
    final ratio = aWater < bWater
        ? aWater / bWater.toDouble()
        : bWater / aWater.toDouble();
    return ratio >= 0.7;
  }

  static bool _sameGrowthRate(Species a, Species b) {
    if (a.growth == null || b.growth == null) return false;
    return a.growth!.rate == b.growth!.rate;
  }
}

class _RoomScore {
  const _RoomScore({
    required this.room,
    required this.reasons,
    required this.companionIds,
  });

  final String room;
  final List<RoomSuggestionReason> reasons;
  final List<String> companionIds;
}
