import '../models/care_log.dart';
import '../models/plant.dart';

class CareInsight {
  const CareInsight({
    required this.type,
    required this.titleKey,
    required this.bodyKey,
    required this.confidence,
    required this.plantIds,
    this.metric,
    this.actionSuggestion,
  });

  final String type;
  final String titleKey;
  final String bodyKey;
  final double confidence;
  final List<String> plantIds;
  final double? metric;
  final String? actionSuggestion;
}

class WeeklyInsightDigest {
  const WeeklyInsightDigest({
    required this.weekStart,
    required this.insights,
    required this.topInsight,
    required this.totalCareActions,
    required this.plantsNeedingAttention,
  });

  final DateTime weekStart;
  final List<CareInsight> insights;
  final CareInsight? topInsight;
  final int totalCareActions;
  final int plantsNeedingAttention;
}

class WeeklyInsightEngine {
  const WeeklyInsightEngine._();

  static WeeklyInsightDigest generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required Map<String, double> healthScores,
    required DateTime now,
  }) {
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekLogs = logs.where((l) =>
        l.timestamp.isAfter(weekStart) && l.timestamp.isBefore(now)).toList();

    final insights = <CareInsight>[];

    _checkMostCaredPlant(weekLogs, plants, insights);
    _checkNeglectedPlants(plants, weekLogs, healthScores, insights, now);
    _checkCarePatternShift(logs, weekLogs, insights, now);
    _checkPerfectWeek(weekLogs, plants, insights);
    _checkNewRecord(logs, weekLogs, insights, now);

    insights.sort((a, b) => b.confidence.compareTo(a.confidence));

    final needingAttention = plants.where((p) =>
        !p.isArchived && (healthScores[p.id] ?? 0.5) < 0.4).length;

    return WeeklyInsightDigest(
      weekStart: weekStart,
      insights: insights.take(5).toList(),
      topInsight: insights.isNotEmpty ? insights.first : null,
      totalCareActions: weekLogs.length,
      plantsNeedingAttention: needingAttention,
    );
  }

  static void _checkMostCaredPlant(
      List<CareLog> weekLogs, List<Plant> plants, List<CareInsight> out) {
    if (weekLogs.isEmpty) return;

    final counts = <String, int>{};
    for (final log in weekLogs) {
      counts[log.plantId] = (counts[log.plantId] ?? 0) + 1;
    }
    final topId = counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final plant = plants.where((p) => p.id == topId).firstOrNull;
    if (plant == null) return;

    out.add(CareInsight(
      type: 'mostCared',
      titleKey: 'insightMostCaredTitle',
      bodyKey: 'insightMostCaredBody',
      confidence: 0.9,
      plantIds: [topId],
      metric: counts[topId]!.toDouble(),
    ));
  }

  static void _checkNeglectedPlants(
      List<Plant> plants, List<CareLog> weekLogs,
      Map<String, double> healthScores, List<CareInsight> out, DateTime now) {
    final caredIds = weekLogs.map((l) => l.plantId).toSet();
    final neglected = plants.where((p) =>
        !p.isArchived && !caredIds.contains(p.id) &&
        (healthScores[p.id] ?? 0.5) < 0.5).toList();

    if (neglected.isNotEmpty) {
      out.add(CareInsight(
        type: 'neglected',
        titleKey: 'insightNeglectedTitle',
        bodyKey: 'insightNeglectedBody',
        confidence: 0.8,
        plantIds: neglected.map((p) => p.id).toList(),
        metric: neglected.length.toDouble(),
        actionSuggestion: 'insightActionCheckOnThem',
      ));
    }
  }

  static void _checkCarePatternShift(
      List<CareLog> allLogs, List<CareLog> weekLogs,
      List<CareInsight> out, DateTime now) {
    final prevWeekStart = now.subtract(Duration(days: now.weekday + 6));
    final prevWeekEnd = now.subtract(Duration(days: now.weekday - 1));
    final prevWeekLogs = allLogs.where((l) =>
        l.timestamp.isAfter(prevWeekStart) && l.timestamp.isBefore(prevWeekEnd)).length;

    if (prevWeekLogs > 0 && weekLogs.length > prevWeekLogs * 1.5) {
      out.add(CareInsight(
        type: 'increased',
        titleKey: 'insightIncreasedTitle',
        bodyKey: 'insightIncreasedBody',
        confidence: 0.7,
        plantIds: const [],
        metric: ((weekLogs.length - prevWeekLogs) / prevWeekLogs * 100),
      ));
    }
  }

  static void _checkPerfectWeek(
      List<CareLog> weekLogs, List<Plant> plants, List<CareInsight> out) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.isEmpty) return;

    final caredIds = weekLogs.map((l) => l.plantId).toSet();
    if (caredIds.length == activePlants.length) {
      out.add(const CareInsight(
        type: 'perfectWeek',
        titleKey: 'insightPerfectWeekTitle',
        bodyKey: 'insightPerfectWeekBody',
        confidence: 1.0,
        plantIds: [],
      ));
    }
  }

  static void _checkNewRecord(
      List<CareLog> allLogs, List<CareLog> weekLogs,
      List<CareInsight> out, DateTime now) {
    int maxWeekly = 0;
    for (int w = 1; w <= 8; w++) {
      final start = now.subtract(Duration(days: 7 * w + now.weekday - 1));
      final end = start.add(const Duration(days: 7));
      final count = allLogs.where((l) =>
          l.timestamp.isAfter(start) && l.timestamp.isBefore(end)).length;
      if (count > maxWeekly) maxWeekly = count;
    }

    if (weekLogs.length > maxWeekly && weekLogs.length > 5) {
      out.add(CareInsight(
        type: 'newRecord',
        titleKey: 'insightNewRecordTitle',
        bodyKey: 'insightNewRecordBody',
        confidence: 0.95,
        plantIds: const [],
        metric: weekLogs.length.toDouble(),
      ));
    }
  }
}
