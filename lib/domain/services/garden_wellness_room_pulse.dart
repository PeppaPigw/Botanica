import 'garden_wellness_summary.dart';

class GardenWellnessRoomPulse {
  const GardenWellnessRoomPulse._();

  static List<GardenWellnessRoomPulseEntry> build({
    required GardenWellnessSummary summary,
  }) {
    final grouped = <String, List<GardenFocusPlant>>{};

    for (final focus in summary.focusPlants) {
      final room = _normalizedRoom(focus.plant.room);
      (grouped[room] ??= <GardenFocusPlant>[]).add(focus);
    }

    final rooms = grouped.entries.map((entry) {
      final plants = entry.value;
      final averageScore =
          (plants.fold<int>(0, (sum, plant) => sum + plant.score) /
                  plants.length)
              .round();
      final overdueTasks =
          plants.fold<int>(0, (sum, plant) => sum + plant.overdueTasks);
      final atRiskPlants = plants.where((plant) => plant.score < 80).length;

      return GardenWellnessRoomPulseEntry(
        name: entry.key,
        plantCount: plants.length,
        averageScore: averageScore,
        overdueTasks: overdueTasks,
        atRiskPlants: atRiskPlants,
      );
    }).toList(growable: false)
      ..sort(_compareRooms);

    return rooms;
  }
}

class GardenWellnessRoomPulseEntry {
  const GardenWellnessRoomPulseEntry({
    required this.name,
    required this.plantCount,
    required this.averageScore,
    required this.overdueTasks,
    required this.atRiskPlants,
  });

  final String name;
  final int plantCount;
  final int averageScore;
  final int overdueTasks;
  final int atRiskPlants;
}

int _compareRooms(
  GardenWellnessRoomPulseEntry a,
  GardenWellnessRoomPulseEntry b,
) {
  final score = a.averageScore.compareTo(b.averageScore);
  if (score != 0) return score;

  final overdue = b.overdueTasks.compareTo(a.overdueTasks);
  if (overdue != 0) return overdue;

  return a.name.compareTo(b.name);
}

String _normalizedRoom(String room) {
  final normalized = room.trim();
  return normalized.isEmpty ? 'Unassigned' : normalized;
}
