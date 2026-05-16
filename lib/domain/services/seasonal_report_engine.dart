import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class SeasonalCareReport {
  const SeasonalCareReport({
    required this.season,
    required this.year,
    required this.totalActions,
    required this.plantsActive,
    required this.topCareType,
    required this.avgActionsPerWeek,
    required this.highlights,
    required this.grade,
  });

  final String season;
  final int year;
  final int totalActions;
  final int plantsActive;
  final TaskType topCareType;
  final double avgActionsPerWeek;
  final List<String> highlights;
  final String grade;
}

class SeasonalReportCard {
  const SeasonalReportCard({
    required this.currentReport,
    required this.previousReport,
    required this.improvement,
    required this.yearOverYearChange,
  });

  final SeasonalCareReport currentReport;
  final SeasonalCareReport? previousReport;
  final double improvement;
  final double? yearOverYearChange;
}

class SeasonalReportEngine {
  const SeasonalReportEngine._();

  static SeasonalReportCard generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required String currentSeason,
    required int currentYear,
    required DateTime now,
  }) {
    final currentReport = _buildReport(plants, logs, currentSeason, currentYear, now);
    final previousSeason = _previousSeason(currentSeason);
    final previousYear = currentSeason == 'spring' ? currentYear - 1 : currentYear;
    final previousReport = _buildReport(plants, logs, previousSeason, previousYear, now);

    final improvement = previousReport.totalActions > 0
        ? (currentReport.totalActions - previousReport.totalActions) /
            previousReport.totalActions
        : 0.0;

    final lastYearReport = _buildReport(plants, logs, currentSeason, currentYear - 1, now);
    final yoyChange = lastYearReport.totalActions > 0
        ? (currentReport.totalActions - lastYearReport.totalActions) /
            lastYearReport.totalActions
        : null;

    return SeasonalReportCard(
      currentReport: currentReport,
      previousReport: previousReport.totalActions > 0 ? previousReport : null,
      improvement: improvement,
      yearOverYearChange: yoyChange,
    );
  }

  static SeasonalCareReport _buildReport(
      List<Plant> plants, List<CareLog> logs, String season, int year, DateTime now) {
    final range = _seasonDateRange(season, year);
    final seasonLogs = logs.where((l) =>
        l.timestamp.isAfter(range.start) && l.timestamp.isBefore(range.end)).toList();

    final activePlantIds = seasonLogs.map((l) => l.plantId).toSet();
    final plantsActive = plants.where((p) => activePlantIds.contains(p.id)).length;

    final typeCounts = <TaskType, int>{};
    for (final log in seasonLogs) {
      typeCounts[log.type] = (typeCounts[log.type] ?? 0) + 1;
    }
    final topType = typeCounts.isEmpty
        ? TaskType.water
        : typeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final weeks = range.end.difference(range.start).inDays / 7.0;
    final avgPerWeek = weeks > 0 ? seasonLogs.length / weeks : 0.0;

    final highlights = _generateHighlights(seasonLogs, plantsActive, avgPerWeek);
    final grade = _computeGrade(avgPerWeek, plantsActive);

    return SeasonalCareReport(
      season: season,
      year: year,
      totalActions: seasonLogs.length,
      plantsActive: plantsActive,
      topCareType: topType,
      avgActionsPerWeek: avgPerWeek,
      highlights: highlights,
      grade: grade,
    );
  }

  static ({DateTime start, DateTime end}) _seasonDateRange(String season, int year) {
    switch (season) {
      case 'spring':
        return (start: DateTime(year, 3, 1), end: DateTime(year, 6, 1));
      case 'summer':
        return (start: DateTime(year, 6, 1), end: DateTime(year, 9, 1));
      case 'autumn':
        return (start: DateTime(year, 9, 1), end: DateTime(year, 12, 1));
      default:
        return (start: DateTime(year, 12, 1), end: DateTime(year + 1, 3, 1));
    }
  }

  static String _previousSeason(String season) {
    switch (season) {
      case 'spring': return 'winter';
      case 'summer': return 'spring';
      case 'autumn': return 'summer';
      default: return 'autumn';
    }
  }

  static List<String> _generateHighlights(
      List<CareLog> logs, int plantsActive, double avgPerWeek) {
    final highlights = <String>[];
    if (avgPerWeek > 10) highlights.add('seasonHighActivity');
    if (plantsActive >= 10) highlights.add('seasonLargeGarden');
    if (logs.length > 100) highlights.add('seasonCenturion');
    return highlights;
  }

  static String _computeGrade(double avgPerWeek, int plantsActive) {
    if (avgPerWeek > 15 && plantsActive >= 5) return 'A+';
    if (avgPerWeek > 10) return 'A';
    if (avgPerWeek > 5) return 'B';
    if (avgPerWeek > 2) return 'C';
    return 'D';
  }
}
