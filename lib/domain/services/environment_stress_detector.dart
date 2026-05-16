import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';

enum StressSignal {
  suddenWateringIncrease,
  missedCareAfterConsistency,
  longGapAfterFrequentCare,
  erraticSchedule,
  noRecentCare,
}

enum StressLevel { none, mild, moderate, high }

class PlantStressResult {
  const PlantStressResult({
    required this.plantId,
    required this.plantNickname,
    required this.level,
    required this.signals,
    required this.confidence,
    required this.suggestion,
  });

  final String plantId;
  final String plantNickname;
  final StressLevel level;
  final List<StressSignal> signals;
  final double confidence;
  final String suggestion;
}

class EnvironmentStressDetector {
  const EnvironmentStressDetector._();

  static PlantStressResult? detect({
    required Plant plant,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
  }) {
    if (plant.isArchived) return null;

    final plantLogs = logs.where((l) => l.plantId == plant.id).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (plantLogs.length < 4) return null;

    final signals = <StressSignal>[];

    if (_hasSuddenWateringIncrease(plantLogs, now)) {
      signals.add(StressSignal.suddenWateringIncrease);
    }

    if (_hasMissedCareAfterConsistency(plant, tasks, now)) {
      signals.add(StressSignal.missedCareAfterConsistency);
    }

    if (_hasLongGapAfterFrequentCare(plantLogs, now)) {
      signals.add(StressSignal.longGapAfterFrequentCare);
    }

    if (_hasErraticSchedule(plantLogs, now)) {
      signals.add(StressSignal.erraticSchedule);
    }

    if (_hasNoRecentCare(plantLogs, now)) {
      signals.add(StressSignal.noRecentCare);
    }

    if (signals.isEmpty) return null;

    final level = _levelFromSignals(signals);
    final confidence = (signals.length / 3.0).clamp(0.3, 1.0);
    final suggestion = _suggestionForSignals(signals);

    return PlantStressResult(
      plantId: plant.id,
      plantNickname: plant.nickname,
      level: level,
      signals: signals,
      confidence: confidence,
      suggestion: suggestion,
    );
  }

  static List<PlantStressResult> detectAll({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
  }) {
    final results = <PlantStressResult>[];
    for (final plant in plants.where((p) => !p.isArchived)) {
      final result = detect(plant: plant, logs: logs, tasks: tasks, now: now);
      if (result != null) results.add(result);
    }
    results.sort((a, b) => b.level.index.compareTo(a.level.index));
    return results;
  }

  static bool _hasSuddenWateringIncrease(
      List<CareLog> logs, DateTime now) {
    final waterLogs = logs.where((l) => l.type == TaskType.water).toList();
    if (waterLogs.length < 6) return false;

    final recentWater = waterLogs
        .where((l) => now.difference(l.timestamp).inDays <= 14)
        .length;
    final olderWater = waterLogs
        .where((l) =>
            now.difference(l.timestamp).inDays > 14 &&
            now.difference(l.timestamp).inDays <= 28)
        .length;

    if (olderWater == 0) return false;
    return recentWater > olderWater * 2;
  }

  static bool _hasMissedCareAfterConsistency(
      Plant plant, List<TaskInstance> tasks, DateTime now) {
    final plantTasks = tasks.where((t) => t.plantId == plant.id).toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    if (plantTasks.length < 5) return false;

    final recentTasks = plantTasks
        .where((t) => now.difference(t.dueAt).inDays <= 21)
        .toList();

    final completedRecent =
        recentTasks.where((t) => t.status == TaskStatus.done).length;
    final pendingRecent =
        recentTasks.where((t) => t.status == TaskStatus.pending).length;

    if (recentTasks.length < 3) return false;
    return pendingRecent > completedRecent && completedRecent >= 2;
  }

  static bool _hasLongGapAfterFrequentCare(
      List<CareLog> logs, DateTime now) {
    if (logs.length < 5) return false;

    final sorted = logs.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final daysSinceLast = now.difference(sorted.first.timestamp).inDays;
    if (daysSinceLast < 10) return false;

    final recentBefore = sorted
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .length;
    final avgInterval = 30.0 / (recentBefore > 0 ? recentBefore : 1);

    return daysSinceLast > avgInterval * 3;
  }

  static bool _hasErraticSchedule(List<CareLog> logs, DateTime now) {
    final waterLogs = logs
        .where((l) =>
            l.type == TaskType.water &&
            now.difference(l.timestamp).inDays <= 30)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (waterLogs.length < 4) return false;

    final intervals = <int>[];
    for (int i = 1; i < waterLogs.length; i++) {
      intervals
          .add(waterLogs[i].timestamp.difference(waterLogs[i - 1].timestamp).inDays);
    }

    if (intervals.isEmpty) return false;
    final avg = intervals.reduce((a, b) => a + b) / intervals.length;
    if (avg == 0) return false;

    final variance = intervals
            .map((i) => (i - avg) * (i - avg))
            .reduce((a, b) => a + b) /
        intervals.length;
    final cv = variance / (avg * avg);

    return cv > 1.0;
  }

  static bool _hasNoRecentCare(List<CareLog> logs, DateTime now) {
    if (logs.isEmpty) return true;
    final sorted = logs.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return now.difference(sorted.first.timestamp).inDays > 21;
  }

  static StressLevel _levelFromSignals(List<StressSignal> signals) {
    if (signals.length >= 3) return StressLevel.high;
    if (signals.length == 2) return StressLevel.moderate;
    if (signals.contains(StressSignal.noRecentCare) ||
        signals.contains(StressSignal.suddenWateringIncrease)) {
      return StressLevel.moderate;
    }
    return StressLevel.mild;
  }

  static String _suggestionForSignals(List<StressSignal> signals) {
    if (signals.contains(StressSignal.suddenWateringIncrease)) {
      return 'suggestionCheckDrainage';
    }
    if (signals.contains(StressSignal.noRecentCare)) {
      return 'suggestionResumeCare';
    }
    if (signals.contains(StressSignal.missedCareAfterConsistency)) {
      return 'suggestionGetBackOnTrack';
    }
    if (signals.contains(StressSignal.longGapAfterFrequentCare)) {
      return 'suggestionCheckPlant';
    }
    return 'suggestionReviewSchedule';
  }
}
