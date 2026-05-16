import '../models/care_log.dart';
import '../models/plant.dart';

enum PatternType {
  batchCarer,
  morningRitual,
  eveningRitual,
  weekendWarrior,
  seasonalDip,
  seasonalSurge,
  favoriteFirst,
  neglectedChild,
  diverseRoutine,
  focusedCarer,
}

class CarePattern {
  const CarePattern({
    required this.type,
    required this.messageKey,
    required this.confidence,
    required this.args,
  });

  final PatternType type;
  final String messageKey;
  final double confidence;
  final Map<String, String> args;
}

class CarePatternAnalyzer {
  const CarePatternAnalyzer._();

  static List<CarePattern> analyze({
    required List<Plant> plants,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    if (logs.length < 15) return [];

    final patterns = <CarePattern>[];

    _detectBatchCaring(logs, patterns, now);
    _detectTimeRitual(logs, patterns, now);
    _detectWeekendWarrior(logs, patterns, now);
    _detectSeasonalPatterns(logs, patterns, now);
    _detectFavoriteFirst(plants, logs, patterns, now);
    _detectNeglectedChild(plants, logs, patterns, now);
    _detectCareRoutineDiversity(logs, patterns, now);

    patterns.sort((a, b) => b.confidence.compareTo(a.confidence));
    return patterns.take(3).toList();
  }

  static void _detectBatchCaring(
      List<CareLog> logs, List<CarePattern> out, DateTime now) {
    final recentLogs = logs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();
    if (recentLogs.length < 10) return;

    final dayGroups = <String, int>{};
    for (final log in recentLogs) {
      final key =
          '${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}';
      dayGroups[key] = (dayGroups[key] ?? 0) + 1;
    }

    final activeDays = dayGroups.length;
    final avgPerDay = recentLogs.length / activeDays;
    final batchDays = dayGroups.values.where((c) => c >= 3).length;

    if (avgPerDay >= 2.5 && batchDays >= 3) {
      out.add(CarePattern(
        type: PatternType.batchCarer,
        messageKey: 'patternBatchCarer',
        confidence: (batchDays / activeDays).clamp(0.0, 1.0),
        args: {'avgPerDay': avgPerDay.toStringAsFixed(1)},
      ));
    }
  }

  static void _detectTimeRitual(
      List<CareLog> logs, List<CarePattern> out, DateTime now) {
    final recentLogs = logs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();
    if (recentLogs.length < 10) return;

    int morning = 0;
    int evening = 0;
    for (final log in recentLogs) {
      if (log.timestamp.hour >= 5 && log.timestamp.hour < 9) morning++;
      if (log.timestamp.hour >= 19 && log.timestamp.hour < 23) evening++;
    }

    final morningRatio = morning / recentLogs.length;
    final eveningRatio = evening / recentLogs.length;

    if (morningRatio >= 0.5) {
      out.add(CarePattern(
        type: PatternType.morningRitual,
        messageKey: 'patternMorningRitual',
        confidence: morningRatio,
        args: {'percent': (morningRatio * 100).round().toString()},
      ));
    } else if (eveningRatio >= 0.5) {
      out.add(CarePattern(
        type: PatternType.eveningRitual,
        messageKey: 'patternEveningRitual',
        confidence: eveningRatio,
        args: {'percent': (eveningRatio * 100).round().toString()},
      ));
    }
  }

  static void _detectWeekendWarrior(
      List<CareLog> logs, List<CarePattern> out, DateTime now) {
    final recentLogs = logs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();
    if (recentLogs.length < 10) return;

    final weekendLogs =
        recentLogs.where((l) => l.timestamp.weekday >= 6).length;
    final ratio = weekendLogs / recentLogs.length;

    if (ratio >= 0.5) {
      out.add(CarePattern(
        type: PatternType.weekendWarrior,
        messageKey: 'patternWeekendWarrior',
        confidence: ratio,
        args: {'percent': (ratio * 100).round().toString()},
      ));
    }
  }

  static void _detectSeasonalPatterns(
      List<CareLog> logs, List<CarePattern> out, DateTime now) {
    if (logs.length < 30) return;

    final monthCounts = List.filled(12, 0);
    for (final log in logs) {
      monthCounts[log.timestamp.month - 1]++;
    }

    final nonZero = monthCounts.where((c) => c > 0).toList();
    if (nonZero.length < 4) return;

    final avg = nonZero.reduce((a, b) => a + b) / nonZero.length;
    final currentMonth = now.month - 1;

    if (monthCounts[currentMonth] > avg * 1.5) {
      out.add(CarePattern(
        type: PatternType.seasonalSurge,
        messageKey: 'patternSeasonalSurge',
        confidence: 0.7,
        args: {'month': (currentMonth + 1).toString()},
      ));
    } else if (monthCounts[currentMonth] < avg * 0.5 &&
        monthCounts[currentMonth] > 0) {
      out.add(CarePattern(
        type: PatternType.seasonalDip,
        messageKey: 'patternSeasonalDip',
        confidence: 0.7,
        args: {'month': (currentMonth + 1).toString()},
      ));
    }
  }

  static void _detectFavoriteFirst(List<Plant> plants, List<CareLog> logs,
      List<CarePattern> out, DateTime now) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 3) return;

    final recentLogs = logs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();
    if (recentLogs.length < 10) return;

    final counts = <String, int>{};
    for (final log in recentLogs) {
      counts[log.plantId] = (counts[log.plantId] ?? 0) + 1;
    }

    if (counts.isEmpty) return;
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sorted.fold<int>(0, (s, e) => s + e.value);
    final topRatio = sorted.first.value / total;

    if (topRatio >= 0.4) {
      final topPlant = activePlants
          .where((p) => p.id == sorted.first.key)
          .fold<Plant?>(null, (_, p) => p);
      if (topPlant != null) {
        out.add(CarePattern(
          type: PatternType.favoriteFirst,
          messageKey: 'patternFavoriteFirst',
          confidence: topRatio,
          args: {'plant': topPlant.nickname},
        ));
      }
    }
  }

  static void _detectNeglectedChild(List<Plant> plants, List<CareLog> logs,
      List<CarePattern> out, DateTime now) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.length < 3) return;

    for (final plant in activePlants) {
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      if (plantLogs.isEmpty) continue;

      final lastCare = plantLogs
          .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
      final daysSince = now.difference(lastCare.timestamp).inDays;

      if (daysSince > 21 && now.difference(plant.createdAt).inDays > 30) {
        out.add(CarePattern(
          type: PatternType.neglectedChild,
          messageKey: 'patternNeglectedChild',
          confidence: (daysSince / 30.0).clamp(0.5, 1.0),
          args: {'plant': plant.nickname, 'days': daysSince.toString()},
        ));
        return;
      }
    }
  }

  static void _detectCareRoutineDiversity(
      List<CareLog> logs, List<CarePattern> out, DateTime now) {
    final recentLogs = logs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();
    if (recentLogs.length < 10) return;

    final types = recentLogs.map((l) => l.type).toSet();

    if (types.length >= 5) {
      out.add(CarePattern(
        type: PatternType.diverseRoutine,
        messageKey: 'patternDiverseRoutine',
        confidence: (types.length / 6.0).clamp(0.5, 1.0),
        args: {'types': types.length.toString()},
      ));
    } else if (types.length == 1) {
      out.add(CarePattern(
        type: PatternType.focusedCarer,
        messageKey: 'patternFocusedCarer',
        confidence: 0.8,
        args: {'type': types.first.name},
      ));
    }
  }
}
