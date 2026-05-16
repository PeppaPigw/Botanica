import '../models/care_log.dart';
import '../models/plant.dart';
import '../models/species.dart';

class RoomProfile {
  const RoomProfile({
    required this.roomName,
    required this.plantCount,
    required this.avgHealthScore,
    required this.dominantLight,
    required this.careIntensity,
    required this.suitabilityInsights,
    required this.suggestedSpecies,
  });

  final String roomName;
  final int plantCount;
  final double avgHealthScore;
  final String dominantLight;
  final double careIntensity;
  final List<String> suitabilityInsights;
  final List<String> suggestedSpecies;
}

class RoomMicroclimateProfiler {
  const RoomMicroclimateProfiler._();

  static List<RoomProfile> profile({
    required List<Plant> plants,
    required List<Species> species,
    required List<CareLog> logs,
    required Map<String, double> healthScores,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final rooms = activePlants.map((p) => p.room).toSet();
    final profiles = <RoomProfile>[];

    for (final room in rooms) {
      final roomPlants = activePlants.where((p) => p.room == room).toList();
      if (roomPlants.isEmpty) continue;

      final healthValues = roomPlants
          .map((p) => healthScores[p.id] ?? 0.5)
          .toList();
      final avgHealth = healthValues.reduce((a, b) => a + b) / healthValues.length;

      final roomSpecies = roomPlants
          .map((p) => species.where((s) => s.id == p.speciesId).firstOrNull)
          .whereType<Species>()
          .toList();

      final dominantLight = _determineDominantLight(roomSpecies);

      final roomLogs = logs.where((l) =>
          roomPlants.any((p) => p.id == l.plantId) &&
          now.difference(l.timestamp).inDays <= 30).toList();
      final careIntensity = roomPlants.isNotEmpty
          ? roomLogs.length / roomPlants.length / 30.0
          : 0.0;

      final insights = _generateInsights(avgHealth, careIntensity, roomPlants.length);
      final suggested = _suggestSpecies(dominantLight, avgHealth);

      profiles.add(RoomProfile(
        roomName: room,
        plantCount: roomPlants.length,
        avgHealthScore: avgHealth,
        dominantLight: dominantLight,
        careIntensity: careIntensity,
        suitabilityInsights: insights,
        suggestedSpecies: suggested,
      ));
    }

    profiles.sort((a, b) => b.avgHealthScore.compareTo(a.avgHealthScore));
    return profiles;
  }

  static String _determineDominantLight(List<Species> roomSpecies) {
    if (roomSpecies.isEmpty) return 'unknown';
    final lightCounts = <String, int>{};
    for (final sp in roomSpecies) {
      lightCounts[sp.light] = (lightCounts[sp.light] ?? 0) + 1;
    }
    return lightCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static List<String> _generateInsights(double health, double intensity, int count) {
    final insights = <String>[];
    if (health > 0.8) insights.add('roomInsightThriving');
    if (health < 0.5) insights.add('roomInsightStruggling');
    if (intensity > 0.5) insights.add('roomInsightHighMaintenance');
    if (intensity < 0.1 && count > 0) insights.add('roomInsightLowMaintenance');
    if (count >= 5) insights.add('roomInsightCrowded');
    return insights;
  }

  static List<String> _suggestSpecies(String light, double health) {
    if (light == 'low' || light == 'shade') {
      return ['Pothos', 'Snake Plant', 'ZZ Plant'];
    }
    if (light == 'indirect' || light == 'medium') {
      return ['Monstera', 'Philodendron', 'Peace Lily'];
    }
    if (light == 'bright' || light == 'direct') {
      return ['Succulent', 'Cactus', 'Fiddle Leaf Fig'];
    }
    return ['Pothos', 'Spider Plant'];
  }
}
