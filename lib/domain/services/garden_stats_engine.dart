import '../models/care_log.dart';
import '../models/plant.dart';

class GardenStat {
  const GardenStat({
    required this.key,
    required this.value,
    required this.label,
  });

  final String key;
  final String value;
  final String label;
}

class GardenStatsEngine {
  const GardenStatsEngine._();

  static List<GardenStat> compute({
    required List<Plant> plants,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final stats = <GardenStat>[];

    final totalCareActions = logs.length;
    if (totalCareActions > 0) {
      stats.add(GardenStat(
        key: 'totalCareActions',
        value: totalCareActions.toString(),
        label: 'statTotalCare',
      ));
    }

    final uniqueRooms = activePlants.map((p) => p.room).toSet().length;
    if (uniqueRooms > 1) {
      stats.add(GardenStat(
        key: 'roomCount',
        value: uniqueRooms.toString(),
        label: 'statRoomCount',
      ));
    }

    if (logs.length >= 5) {
      final avgPerDay = _averageCarePerDay(logs, now);
      if (avgPerDay > 0) {
        stats.add(GardenStat(
          key: 'avgCarePerDay',
          value: avgPerDay.toStringAsFixed(1),
          label: 'statAvgCarePerDay',
        ));
      }
    }

    final favoriteHour = _favoriteHour(logs);
    if (favoriteHour != null) {
      stats.add(GardenStat(
        key: 'favoriteHour',
        value: favoriteHour.toString(),
        label: 'statFavoriteHour',
      ));
    }

    final mostCaredPlant = _mostCaredPlant(activePlants, logs);
    if (mostCaredPlant != null) {
      stats.add(GardenStat(
        key: 'mostCaredPlant',
        value: mostCaredPlant.nickname,
        label: 'statMostCared',
      ));
    }

    final careTypes = _careTypeDiversity(logs);
    if (careTypes > 1) {
      stats.add(GardenStat(
        key: 'careTypeDiversity',
        value: careTypes.toString(),
        label: 'statCareTypes',
      ));
    }

    final oldestPlant = _oldestPlant(activePlants);
    if (oldestPlant != null) {
      final age = now.difference(oldestPlant.createdAt).inDays;
      if (age > 30) {
        stats.add(GardenStat(
          key: 'oldestPlant',
          value: '${oldestPlant.nickname}:$age',
          label: 'statOldestPlant',
        ));
      }
    }

    final busiestWeekday = _busiestWeekday(logs);
    if (busiestWeekday != null) {
      stats.add(GardenStat(
        key: 'busiestWeekday',
        value: busiestWeekday.toString(),
        label: 'statBusiestDay',
      ));
    }

    return stats;
  }

  static double _averageCarePerDay(List<CareLog> logs, DateTime now) {
    if (logs.isEmpty) return 0;
    final sorted = logs.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final span = now.difference(sorted.first.timestamp).inDays;
    if (span <= 0) return logs.length.toDouble();
    return logs.length / span;
  }

  static int? _favoriteHour(List<CareLog> logs) {
    if (logs.length < 5) return null;
    final hourCounts = List.filled(24, 0);
    for (final log in logs) {
      hourCounts[log.timestamp.hour]++;
    }
    int maxCount = 0;
    int? maxHour;
    for (int h = 0; h < 24; h++) {
      if (hourCounts[h] > maxCount) {
        maxCount = hourCounts[h];
        maxHour = h;
      }
    }
    if (maxCount < 3) return null;
    return maxHour;
  }

  static Plant? _mostCaredPlant(List<Plant> plants, List<CareLog> logs) {
    if (plants.isEmpty || logs.isEmpty) return null;
    final counts = <String, int>{};
    for (final log in logs) {
      counts[log.plantId] = (counts[log.plantId] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    final topId = counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    return plants
        .where((p) => p.id == topId)
        .fold<Plant?>(null, (_, p) => p);
  }

  static int _careTypeDiversity(List<CareLog> logs) {
    return logs.map((l) => l.type).toSet().length;
  }

  static Plant? _oldestPlant(List<Plant> plants) {
    if (plants.isEmpty) return null;
    return plants.reduce(
        (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
  }

  static int? _busiestWeekday(List<CareLog> logs) {
    if (logs.length < 7) return null;
    final dayCounts = List.filled(7, 0);
    for (final log in logs) {
      dayCounts[log.timestamp.weekday - 1]++;
    }
    int maxCount = 0;
    int? maxDay;
    for (int d = 0; d < 7; d++) {
      if (dayCounts[d] > maxCount) {
        maxCount = dayCounts[d];
        maxDay = d + 1;
      }
    }
    if (maxCount < 3) return null;
    return maxDay;
  }
}
