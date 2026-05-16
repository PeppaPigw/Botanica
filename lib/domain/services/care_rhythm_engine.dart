import '../models/care_log.dart';

enum CareRhythmType {
  morningPerson,
  eveningPerson,
  weekendWarrior,
  dailyDevoter,
  batchCarer,
}

class CareRhythm {
  const CareRhythm({
    required this.type,
    required this.confidence,
    required this.streak,
  });

  final CareRhythmType type;
  final double confidence;
  final int streak;
}

class CareRhythmEngine {
  const CareRhythmEngine._();

  static CareRhythm? detect({
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final recent = logs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();

    if (recent.length < 5) return null;

    final candidates = <CareRhythm>[];

    final timeRhythm = _detectTimeOfDay(recent);
    if (timeRhythm != null) candidates.add(timeRhythm);

    final dayRhythm = _detectDayPattern(recent, now);
    if (dayRhythm != null) candidates.add(dayRhythm);

    final frequencyRhythm = _detectFrequency(recent, now);
    if (frequencyRhythm != null) candidates.add(frequencyRhythm);

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    return candidates.first;
  }

  static CareRhythm? _detectTimeOfDay(List<CareLog> logs) {
    int morning = 0;
    int evening = 0;

    for (final log in logs) {
      final hour = log.timestamp.hour;
      if (hour >= 5 && hour < 11) morning++;
      if (hour >= 17 && hour < 23) evening++;
    }

    final total = logs.length;
    final morningRatio = morning / total;
    final eveningRatio = evening / total;

    if (morningRatio >= 0.6) {
      return CareRhythm(
        type: CareRhythmType.morningPerson,
        confidence: morningRatio,
        streak: _consecutiveDaysWithTimeWindow(logs, 5, 11),
      );
    }
    if (eveningRatio >= 0.6) {
      return CareRhythm(
        type: CareRhythmType.eveningPerson,
        confidence: eveningRatio,
        streak: _consecutiveDaysWithTimeWindow(logs, 17, 23),
      );
    }
    return null;
  }

  static CareRhythm? _detectDayPattern(List<CareLog> logs, DateTime now) {
    int weekendLogs = 0;

    for (final log in logs) {
      if (log.timestamp.weekday >= 6) {
        weekendLogs++;
      }
    }

    final total = logs.length;
    final weekendRatio = weekendLogs / total;

    if (weekendRatio >= 0.55 && weekendLogs >= 4) {
      return CareRhythm(
        type: CareRhythmType.weekendWarrior,
        confidence: weekendRatio,
        streak: _consecutiveWeekends(logs, now),
      );
    }
    return null;
  }

  static CareRhythm? _detectFrequency(List<CareLog> logs, DateTime now) {
    final uniqueDays = <int>{};
    for (final log in logs) {
      final daysSinceEpoch = log.timestamp.millisecondsSinceEpoch ~/ 86400000;
      uniqueDays.add(daysSinceEpoch);
    }

    final span = now.difference(logs.last.timestamp).inDays.clamp(1, 30);
    final density = uniqueDays.length / span;

    if (density >= 0.85) {
      return CareRhythm(
        type: CareRhythmType.dailyDevoter,
        confidence: density.clamp(0.0, 1.0),
        streak: _consecutiveActiveDays(logs, now),
      );
    }

    if (density <= 0.3 && logs.length >= 5) {
      final avgLogsPerActiveDay = logs.length / uniqueDays.length;
      if (avgLogsPerActiveDay >= 2.5) {
        return CareRhythm(
          type: CareRhythmType.batchCarer,
          confidence: (avgLogsPerActiveDay / 4).clamp(0.0, 1.0),
          streak: uniqueDays.length,
        );
      }
    }

    return null;
  }

  static int _consecutiveDaysWithTimeWindow(
      List<CareLog> logs, int startHour, int endHour) {
    final sorted = logs
        .where((l) => l.timestamp.hour >= startHour && l.timestamp.hour < endHour)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (sorted.isEmpty) return 0;

    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i - 1].timestamp.difference(sorted[i].timestamp).inDays;
      if (diff <= 2) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static int _consecutiveWeekends(List<CareLog> logs, DateTime now) {
    final weekendLogs = logs
        .where((l) => l.timestamp.weekday >= 6)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (weekendLogs.isEmpty) return 0;

    int streak = 1;
    int lastWeekNumber = _weekNumber(weekendLogs.first.timestamp);

    for (int i = 1; i < weekendLogs.length; i++) {
      final wn = _weekNumber(weekendLogs[i].timestamp);
      if (lastWeekNumber - wn == 1) {
        streak++;
        lastWeekNumber = wn;
      } else if (lastWeekNumber != wn) {
        break;
      }
    }
    return streak;
  }

  static int _consecutiveActiveDays(List<CareLog> logs, DateTime now) {
    final daySet = <int>{};
    for (final log in logs) {
      daySet.add(log.timestamp.millisecondsSinceEpoch ~/ 86400000);
    }

    final today = now.millisecondsSinceEpoch ~/ 86400000;
    int streak = 0;
    for (int d = today; d >= today - 30; d--) {
      if (daySet.contains(d)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static int _weekNumber(DateTime dt) {
    final jan1 = DateTime(dt.year, 1, 1);
    return dt.difference(jan1).inDays ~/ 7;
  }
}
