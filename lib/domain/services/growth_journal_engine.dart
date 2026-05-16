import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/photo_entry.dart';
import '../models/plant.dart';

class JournalHighlight {
  const JournalHighlight({
    required this.type,
    required this.description,
    required this.timestamp,
    this.metric,
  });

  final String type;
  final String description;
  final DateTime timestamp;
  final double? metric;
}

class MonthlyGrowthSummary {
  const MonthlyGrowthSummary({
    required this.plantId,
    required this.plantNickname,
    required this.month,
    required this.year,
    required this.totalCareActions,
    required this.photoCount,
    required this.highlights,
    required this.careBreakdown,
    required this.narrativeKey,
    required this.moodEmoji,
  });

  final String plantId;
  final String plantNickname;
  final int month;
  final int year;
  final int totalCareActions;
  final int photoCount;
  final List<JournalHighlight> highlights;
  final Map<TaskType, int> careBreakdown;
  final String narrativeKey;
  final String moodEmoji;
}

class GrowthJournalEngine {
  const GrowthJournalEngine._();

  static MonthlyGrowthSummary? generateMonthlySummary({
    required Plant plant,
    required List<CareLog> logs,
    required List<PhotoEntry> photos,
    required int month,
    required int year,
  }) {
    final monthLogs = logs.where((l) =>
        l.plantId == plant.id &&
        l.timestamp.month == month &&
        l.timestamp.year == year).toList();

    final monthPhotos = photos.where((p) =>
        p.plantId == plant.id &&
        p.createdAt.month == month &&
        p.createdAt.year == year).toList();

    if (monthLogs.isEmpty && monthPhotos.isEmpty) return null;

    final breakdown = <TaskType, int>{};
    for (final log in monthLogs) {
      breakdown[log.type] = (breakdown[log.type] ?? 0) + 1;
    }

    final highlights = _extractHighlights(monthLogs, monthPhotos, month, year);
    final narrativeKey = _determineNarrative(monthLogs, monthPhotos, breakdown);
    final mood = _determineMood(monthLogs.length, monthPhotos.length);

    return MonthlyGrowthSummary(
      plantId: plant.id,
      plantNickname: plant.nickname,
      month: month,
      year: year,
      totalCareActions: monthLogs.length,
      photoCount: monthPhotos.length,
      highlights: highlights,
      careBreakdown: breakdown,
      narrativeKey: narrativeKey,
      moodEmoji: mood,
    );
  }

  static List<MonthlyGrowthSummary> generateYearInReview({
    required Plant plant,
    required List<CareLog> logs,
    required List<PhotoEntry> photos,
    required int year,
  }) {
    final summaries = <MonthlyGrowthSummary>[];
    for (int m = 1; m <= 12; m++) {
      final summary = generateMonthlySummary(
        plant: plant, logs: logs, photos: photos, month: m, year: year);
      if (summary != null) summaries.add(summary);
    }
    return summaries;
  }

  static List<JournalHighlight> _extractHighlights(
      List<CareLog> logs, List<PhotoEntry> photos, int month, int year) {
    final highlights = <JournalHighlight>[];

    if (logs.isNotEmpty) {
      final firstCare = logs.reduce((a, b) =>
          a.timestamp.isBefore(b.timestamp) ? a : b);
      highlights.add(JournalHighlight(
        type: 'firstCare',
        description: 'journalFirstCareOfMonth',
        timestamp: firstCare.timestamp,
      ));
    }

    final activeDays = logs
        .map((l) => DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day))
        .toSet()
        .length;
    if (activeDays >= 20) {
      highlights.add(JournalHighlight(
        type: 'dedicatedMonth',
        description: 'journalDedicatedMonth',
        timestamp: DateTime(year, month, 15),
        metric: activeDays.toDouble(),
      ));
    }

    if (photos.length >= 4) {
      highlights.add(JournalHighlight(
        type: 'wellDocumented',
        description: 'journalWellDocumented',
        timestamp: photos.first.createdAt,
        metric: photos.length.toDouble(),
      ));
    }

    final pruneCount = logs.where((l) => l.type == TaskType.prune).length;
    if (pruneCount >= 2) {
      highlights.add(JournalHighlight(
        type: 'activePruning',
        description: 'journalActivePruning',
        timestamp: logs.firstWhere((l) => l.type == TaskType.prune).timestamp,
      ));
    }

    return highlights;
  }

  static String _determineNarrative(
      List<CareLog> logs, List<PhotoEntry> photos, Map<TaskType, int> breakdown) {
    if (logs.length >= 30 && photos.length >= 4) return 'journalNarrativeThriving';
    if (logs.length >= 20) return 'journalNarrativeConsistent';
    if (photos.length >= 3 && logs.length < 10) return 'journalNarrativeObserver';
    if (logs.length >= 10) return 'journalNarrativeGrowing';
    if (logs.length < 5) return 'journalNarrativeQuiet';
    return 'journalNarrativeSteady';
  }

  static String _determineMood(int logCount, int photoCount) {
    if (logCount >= 30 && photoCount >= 4) return 'flourishing';
    if (logCount >= 20) return 'thriving';
    if (logCount >= 10) return 'growing';
    if (logCount >= 5) return 'steady';
    return 'resting';
  }
}
