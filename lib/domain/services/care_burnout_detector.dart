import '../models/care_log.dart';
import '../models/plant.dart';

class BurnoutSignal {
  const BurnoutSignal({
    required this.type,
    required this.severity,
    required this.evidence,
  });

  final String type;
  final double severity;
  final String evidence;
}

class BurnoutReport {
  const BurnoutReport({
    required this.riskLevel,
    required this.riskScore,
    required this.signals,
    required this.suggestions,
    required this.overloadedDays,
    required this.missedTasksTrend,
  });

  final String riskLevel;
  final double riskScore;
  final List<BurnoutSignal> signals;
  final List<String> suggestions;
  final int overloadedDays;
  final double missedTasksTrend;
}

class CareBurnoutDetector {
  const CareBurnoutDetector._();

  static BurnoutReport assess({
    required List<Plant> plants,
    required List<CareLog> logs,
    required int missedTasksThisWeek,
    required int missedTasksLastWeek,
    required int totalDailyTasks,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).length;
    final signals = <BurnoutSignal>[];

    _checkOverload(activePlants, totalDailyTasks, signals);
    _checkDecline(logs, now, signals);
    _checkMissedTrend(missedTasksThisWeek, missedTasksLastWeek, signals);
    _checkCareGaps(logs, now, signals);

    final riskScore = signals.isEmpty ? 0.0
        : signals.map((s) => s.severity).reduce((a, b) => a + b) / signals.length;

    final riskLevel = _riskLevel(riskScore);
    final suggestions = _suggest(signals, activePlants);
    final overloaded = _overloadedDays(logs, now);
    final missedTrend = missedTasksLastWeek > 0
        ? (missedTasksThisWeek - missedTasksLastWeek) / missedTasksLastWeek
        : missedTasksThisWeek > 0 ? 1.0 : 0.0;

    return BurnoutReport(
      riskLevel: riskLevel,
      riskScore: riskScore.clamp(0.0, 1.0),
      signals: signals,
      suggestions: suggestions,
      overloadedDays: overloaded,
      missedTasksTrend: missedTrend.clamp(-1.0, 1.0),
    );
  }

  static void _checkOverload(int plants, int dailyTasks, List<BurnoutSignal> out) {
    if (dailyTasks > 10) {
      out.add(const BurnoutSignal(
        type: 'burnoutTooManyTasks',
        severity: 0.8,
        evidence: 'burnoutEvidenceTaskCount',
      ));
    }
    if (plants > 20) {
      out.add(const BurnoutSignal(
        type: 'burnoutLargeCollection',
        severity: 0.5,
        evidence: 'burnoutEvidencePlantCount',
      ));
    }
  }

  static void _checkDecline(List<CareLog> logs, DateTime now, List<BurnoutSignal> out) {
    final thisWeek = logs.where((l) => now.difference(l.timestamp).inDays <= 7).length;
    final lastWeek = logs.where((l) {
      final d = now.difference(l.timestamp).inDays;
      return d > 7 && d <= 14;
    }).length;

    if (lastWeek > 0 && thisWeek < lastWeek * 0.5) {
      out.add(const BurnoutSignal(
        type: 'burnoutActivityDrop',
        severity: 0.7,
        evidence: 'burnoutEvidenceActivityDecline',
      ));
    }
  }

  static void _checkMissedTrend(int thisWeek, int lastWeek, List<BurnoutSignal> out) {
    if (thisWeek > lastWeek && thisWeek >= 5) {
      out.add(const BurnoutSignal(
        type: 'burnoutMissedIncreasing',
        severity: 0.6,
        evidence: 'burnoutEvidenceMissedTasks',
      ));
    }
  }

  static void _checkCareGaps(List<CareLog> logs, DateTime now, List<BurnoutSignal> out) {
    final recent = logs.where((l) => now.difference(l.timestamp).inDays <= 14).toList();
    if (recent.isEmpty) return;

    recent.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    int maxGap = 0;
    for (int i = 1; i < recent.length; i++) {
      final gap = recent[i].timestamp.difference(recent[i - 1].timestamp).inDays;
      if (gap > maxGap) maxGap = gap;
    }

    if (maxGap >= 4) {
      out.add(const BurnoutSignal(
        type: 'burnoutCareGaps',
        severity: 0.5,
        evidence: 'burnoutEvidenceGaps',
      ));
    }
  }

  static String _riskLevel(double score) {
    if (score >= 0.7) return 'burnoutHigh';
    if (score >= 0.4) return 'burnoutModerate';
    return 'burnoutLow';
  }

  static List<String> _suggest(List<BurnoutSignal> signals, int plantCount) {
    final suggestions = <String>[];
    for (final s in signals) {
      switch (s.type) {
        case 'burnoutTooManyTasks':
          suggestions.add('burnoutSuggestBatchTasks');
        case 'burnoutLargeCollection':
          suggestions.add('burnoutSuggestArchiveSome');
        case 'burnoutActivityDrop':
          suggestions.add('burnoutSuggestSimplify');
        case 'burnoutMissedIncreasing':
          suggestions.add('burnoutSuggestReduceFrequency');
        case 'burnoutCareGaps':
          suggestions.add('burnoutSuggestSetReminders');
      }
    }
    return suggestions;
  }

  static int _overloadedDays(List<CareLog> logs, DateTime now) {
    final dayCounts = <int, int>{};
    for (final log in logs) {
      final daysAgo = now.difference(log.timestamp).inDays;
      if (daysAgo <= 14) {
        dayCounts[daysAgo] = (dayCounts[daysAgo] ?? 0) + 1;
      }
    }
    return dayCounts.values.where((c) => c >= 8).length;
  }
}
