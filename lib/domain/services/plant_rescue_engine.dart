import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

enum RescueSeverity { mild, moderate, critical }

enum RescueActionType { water, mist, relocate, prune, inspect, fertilize }

class RescueAction {
  const RescueAction({
    required this.day,
    required this.type,
    required this.instruction,
    required this.priority,
  });

  final int day;
  final RescueActionType type;
  final String instruction;
  final int priority;
}

class RescuePlan {
  const RescuePlan({
    required this.plantId,
    required this.plantNickname,
    required this.severity,
    required this.diagnosis,
    required this.actions,
    required this.estimatedRecoveryDays,
    required this.startedAt,
  });

  final String plantId;
  final String plantNickname;
  final RescueSeverity severity;
  final String diagnosis;
  final List<RescueAction> actions;
  final int estimatedRecoveryDays;
  final DateTime startedAt;

  double progressAt(DateTime now) {
    final elapsed = now.difference(startedAt).inDays;
    return (elapsed / estimatedRecoveryDays).clamp(0.0, 1.0);
  }

  List<RescueAction> actionsForDay(int day) =>
      actions.where((a) => a.day == day).toList();

  int get totalActions => actions.length;
}

class PlantRescueEngine {
  const PlantRescueEngine._();

  static RescuePlan? evaluate({
    required Plant plant,
    required double healthScore,
    required List<CareLog> recentLogs,
    required DateTime now,
  }) {
    if (plant.isArchived) return null;
    if (healthScore >= 0.5) return null;

    final severity = _classifySeverity(healthScore);
    final diagnosis = _diagnose(recentLogs, now);
    final actions = _buildRecoveryPlan(severity, diagnosis, now);

    return RescuePlan(
      plantId: plant.id,
      plantNickname: plant.nickname,
      severity: severity,
      diagnosis: diagnosis.key,
      actions: actions,
      estimatedRecoveryDays: _estimateRecovery(severity),
      startedAt: now,
    );
  }

  static RescueSeverity _classifySeverity(double healthScore) {
    if (healthScore < 0.2) return RescueSeverity.critical;
    if (healthScore < 0.35) return RescueSeverity.moderate;
    return RescueSeverity.mild;
  }

  static ({String key, List<String> factors}) _diagnose(
      List<CareLog> logs, DateTime now) {
    final factors = <String>[];

    final waterLogs =
        logs.where((l) => l.type == TaskType.water).toList();
    final lastWater = waterLogs.isEmpty
        ? null
        : waterLogs.reduce((a, b) =>
            a.timestamp.isAfter(b.timestamp) ? a : b);

    if (lastWater == null || now.difference(lastWater.timestamp).inDays > 14) {
      factors.add('dehydration');
    }

    final recentCount = logs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .length;
    if (recentCount < 3) {
      factors.add('neglect');
    }

    final hasRecentFertilize = logs.any(
        (l) => l.type == TaskType.fertilize &&
            now.difference(l.timestamp).inDays <= 60);
    if (!hasRecentFertilize && logs.length > 5) {
      factors.add('nutrientDeficiency');
    }

    if (factors.isEmpty) factors.add('generalDecline');

    final key = factors.length == 1
        ? factors.first
        : factors.contains('dehydration')
            ? 'dehydration'
            : factors.first;

    return (key: key, factors: factors);
  }

  static List<RescueAction> _buildRecoveryPlan(
      RescueSeverity severity,
      ({String key, List<String> factors}) diagnosis,
      DateTime now) {
    final actions = <RescueAction>[];

    switch (diagnosis.key) {
      case 'dehydration':
        actions.addAll([
          const RescueAction(
              day: 0, type: RescueActionType.water,
              instruction: 'rescueWaterThoroughly', priority: 1),
          const RescueAction(
              day: 0, type: RescueActionType.mist,
              instruction: 'rescueMistLeaves', priority: 2),
          const RescueAction(
              day: 1, type: RescueActionType.inspect,
              instruction: 'rescueCheckSoilMoisture', priority: 1),
          const RescueAction(
              day: 2, type: RescueActionType.water,
              instruction: 'rescueWaterLightly', priority: 1),
          const RescueAction(
              day: 4, type: RescueActionType.water,
              instruction: 'rescueWaterNormally', priority: 2),
        ]);
      case 'neglect':
        actions.addAll([
          const RescueAction(
              day: 0, type: RescueActionType.inspect,
              instruction: 'rescueFullInspection', priority: 1),
          const RescueAction(
              day: 0, type: RescueActionType.water,
              instruction: 'rescueWaterThoroughly', priority: 1),
          const RescueAction(
              day: 1, type: RescueActionType.prune,
              instruction: 'rescueRemoveDeadLeaves', priority: 2),
          const RescueAction(
              day: 3, type: RescueActionType.fertilize,
              instruction: 'rescueLightFeed', priority: 2),
          const RescueAction(
              day: 5, type: RescueActionType.inspect,
              instruction: 'rescueCheckNewGrowth', priority: 1),
          const RescueAction(
              day: 7, type: RescueActionType.water,
              instruction: 'rescueWaterNormally', priority: 2),
        ]);
      case 'nutrientDeficiency':
        actions.addAll([
          const RescueAction(
              day: 0, type: RescueActionType.fertilize,
              instruction: 'rescueHalfStrengthFeed', priority: 1),
          const RescueAction(
              day: 0, type: RescueActionType.water,
              instruction: 'rescueWaterAfterFeed', priority: 2),
          const RescueAction(
              day: 7, type: RescueActionType.inspect,
              instruction: 'rescueCheckColorImprovement', priority: 1),
          const RescueAction(
              day: 14, type: RescueActionType.fertilize,
              instruction: 'rescueFullStrengthFeed', priority: 1),
        ]);
      default:
        actions.addAll([
          const RescueAction(
              day: 0, type: RescueActionType.inspect,
              instruction: 'rescueFullInspection', priority: 1),
          const RescueAction(
              day: 0, type: RescueActionType.relocate,
              instruction: 'rescueCheckLightPosition', priority: 2),
          const RescueAction(
              day: 1, type: RescueActionType.water,
              instruction: 'rescueWaterThoroughly', priority: 1),
          const RescueAction(
              day: 3, type: RescueActionType.mist,
              instruction: 'rescueMistLeaves', priority: 2),
          const RescueAction(
              day: 7, type: RescueActionType.inspect,
              instruction: 'rescueCheckProgress', priority: 1),
        ]);
    }

    if (severity == RescueSeverity.critical) {
      actions.add(const RescueAction(
          day: 0, type: RescueActionType.relocate,
          instruction: 'rescueMoveToShade', priority: 1));
    }

    return actions..sort((a, b) {
      final dayComp = a.day.compareTo(b.day);
      return dayComp != 0 ? dayComp : a.priority.compareTo(b.priority);
    });
  }

  static int _estimateRecovery(RescueSeverity severity) {
    switch (severity) {
      case RescueSeverity.mild:
        return 7;
      case RescueSeverity.moderate:
        return 14;
      case RescueSeverity.critical:
        return 21;
    }
  }
}
