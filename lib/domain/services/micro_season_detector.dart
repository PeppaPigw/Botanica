import '../models/care_log.dart';
import '../models/enums.dart';

class MicroSeason {
  const MicroSeason({
    required this.name,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.wateringMultiplier,
    required this.confidence,
    required this.evidence,
  });

  final String name;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final double wateringMultiplier;
  final double confidence;
  final String evidence;
}

class MicroSeasonReport {
  const MicroSeasonReport({
    required this.detectedSeasons,
    required this.currentMicroSeason,
    required this.dataQuality,
  });

  final List<MicroSeason> detectedSeasons;
  final MicroSeason? currentMicroSeason;
  final String dataQuality;
}

class MicroSeasonDetector {
  const MicroSeasonDetector._();

  static MicroSeasonReport detect({
    required List<CareLog> logs,
    required DateTime now,
  }) {
    if (logs.length < 60) {
      return const MicroSeasonReport(
        detectedSeasons: [],
        currentMicroSeason: null,
        dataQuality: 'insufficient',
      );
    }

    final waterLogs = logs.where((l) => l.type == TaskType.water).toList();
    if (waterLogs.length < 30) {
      return const MicroSeasonReport(
        detectedSeasons: [],
        currentMicroSeason: null,
        dataQuality: 'needMoreWatering',
      );
    }

    final monthlyFreq = _monthlyFrequency(waterLogs);
    final seasons = _detectTransitions(monthlyFreq);
    final current = _findCurrent(seasons, now);

    final quality = logs.length >= 365 ? 'excellent' :
        logs.length >= 180 ? 'good' : 'fair';

    return MicroSeasonReport(
      detectedSeasons: seasons,
      currentMicroSeason: current,
      dataQuality: quality,
    );
  }

  static Map<int, double> _monthlyFrequency(List<CareLog> waterLogs) {
    final counts = <int, int>{};
    final days = <int, int>{};

    for (final log in waterLogs) {
      counts[log.timestamp.month] = (counts[log.timestamp.month] ?? 0) + 1;
      days[log.timestamp.month] = 30;
    }

    return counts.map((month, count) => MapEntry(month, count / (days[month] ?? 30)));
  }

  static List<MicroSeason> _detectTransitions(Map<int, double> freq) {
    final seasons = <MicroSeason>[];
    if (freq.length < 4) return seasons;

    final avgFreq = freq.values.reduce((a, b) => a + b) / freq.length;

    int? highStart;
    int? lowStart;

    for (int m = 1; m <= 12; m++) {
      final f = freq[m] ?? 0;
      if (f > avgFreq * 1.3 && highStart == null) {
        highStart = m;
      } else if (f <= avgFreq * 1.3 && highStart != null) {
        seasons.add(MicroSeason(
          name: 'microSeasonHighDemand',
          startMonth: highStart, startDay: 1,
          endMonth: m - 1, endDay: 28,
          wateringMultiplier: 1.3,
          confidence: 0.7,
          evidence: 'microSeasonEvidenceFrequency',
        ));
        highStart = null;
      }

      if (f < avgFreq * 0.7 && lowStart == null) {
        lowStart = m;
      } else if (f >= avgFreq * 0.7 && lowStart != null) {
        seasons.add(MicroSeason(
          name: 'microSeasonLowDemand',
          startMonth: lowStart, startDay: 1,
          endMonth: m - 1, endDay: 28,
          wateringMultiplier: 0.7,
          confidence: 0.7,
          evidence: 'microSeasonEvidenceFrequency',
        ));
        lowStart = null;
      }
    }

    return seasons;
  }

  static MicroSeason? _findCurrent(List<MicroSeason> seasons, DateTime now) {
    for (final s in seasons) {
      if (_isInRange(now.month, now.day, s.startMonth, s.startDay, s.endMonth, s.endDay)) {
        return s;
      }
    }
    return null;
  }

  static bool _isInRange(int month, int day, int sm, int sd, int em, int ed) {
    if (sm <= em) {
      return (month > sm || (month == sm && day >= sd)) &&
             (month < em || (month == em && day <= ed));
    }
    return (month > sm || (month == sm && day >= sd)) ||
           (month < em || (month == em && day <= ed));
  }
}
