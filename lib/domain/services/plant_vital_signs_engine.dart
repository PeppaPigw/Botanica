import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class PlantVitalSign {
  const PlantVitalSign({
    required this.name,
    required this.value,
    required this.status,
    required this.trend,
  });

  final String name;
  final double value;
  final String status;
  final double trend;
}

class PlantDashboard {
  const PlantDashboard({
    required this.plantId,
    required this.plantNickname,
    required this.overallStatus,
    required this.vitalSigns,
    required this.nextAction,
    required this.daysUntilNextCare,
    required this.careStreak,
    required this.lastCareAgo,
  });

  final String plantId;
  final String plantNickname;
  final String overallStatus;
  final List<PlantVitalSign> vitalSigns;
  final String nextAction;
  final int daysUntilNextCare;
  final int careStreak;
  final int lastCareAgo;
}

class PlantVitalSignsEngine {
  const PlantVitalSignsEngine._();

  static PlantDashboard compute({
    required Plant plant,
    required List<CareLog> logs,
    required double healthScore,
    required DateTime now,
    int? waterIntervalDays,
  }) {
    final plantLogs = logs.where((l) => l.plantId == plant.id).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final recentLogs = plantLogs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();

    final waterLogs = plantLogs.where((l) => l.type == TaskType.water).toList();
    final lastWater = waterLogs.isEmpty ? null : waterLogs.first;
    final lastCareAgo = plantLogs.isEmpty
        ? now.difference(plant.createdAt).inDays
        : now.difference(plantLogs.first.timestamp).inDays;

    final hydration = _computeHydration(waterLogs, now, waterIntervalDays ?? 7);
    final careConsistency = _computeConsistency(recentLogs);
    final attention = _computeAttention(recentLogs, now);

    final vitalSigns = [
      PlantVitalSign(name: 'hydration', value: hydration.value, status: hydration.status, trend: hydration.trend),
      PlantVitalSign(name: 'consistency', value: careConsistency.value, status: careConsistency.status, trend: careConsistency.trend),
      PlantVitalSign(name: 'attention', value: attention.value, status: attention.status, trend: attention.trend),
    ];

    final overallStatus = _overallStatus(healthScore, hydration.value);
    final nextAction = _determineNextAction(lastWater, now, waterIntervalDays ?? 7);
    final daysUntilNext = _daysUntilNextCare(lastWater, now, waterIntervalDays ?? 7);

    final careStreak = _computeCareStreak(plantLogs, now);

    return PlantDashboard(
      plantId: plant.id,
      plantNickname: plant.nickname,
      overallStatus: overallStatus,
      vitalSigns: vitalSigns,
      nextAction: nextAction,
      daysUntilNextCare: daysUntilNext,
      careStreak: careStreak,
      lastCareAgo: lastCareAgo,
    );
  }

  static ({double value, String status, double trend}) _computeHydration(
      List<CareLog> waterLogs, DateTime now, int interval) {
    if (waterLogs.isEmpty) return (value: 0.0, status: 'vitalCritical', trend: -1.0);

    final daysSinceLast = now.difference(waterLogs.first.timestamp).inDays;
    final ratio = 1.0 - (daysSinceLast / interval).clamp(0.0, 2.0) / 2.0;
    final value = ratio.clamp(0.0, 1.0);

    final status = value > 0.7 ? 'vitalGood' : value > 0.4 ? 'vitalFair' : 'vitalCritical';

    final trend = waterLogs.length >= 3
        ? (waterLogs[0].timestamp.difference(waterLogs[1].timestamp).inDays -
            waterLogs[1].timestamp.difference(waterLogs[2].timestamp).inDays).sign.toDouble()
        : 0.0;

    return (value: value, status: status, trend: trend);
  }

  static ({double value, String status, double trend}) _computeConsistency(
      List<CareLog> recentLogs) {
    if (recentLogs.isEmpty) return (value: 0.0, status: 'vitalCritical', trend: 0.0);

    final days = recentLogs
        .map((l) => DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day))
        .toSet()
        .length;
    final value = (days / 30.0).clamp(0.0, 1.0);
    final status = value > 0.5 ? 'vitalGood' : value > 0.2 ? 'vitalFair' : 'vitalCritical';
    return (value: value, status: status, trend: 0.0);
  }

  static ({double value, String status, double trend}) _computeAttention(
      List<CareLog> recentLogs, DateTime now) {
    final types = recentLogs.map((l) => l.type).toSet().length;
    final value = (types / 5.0).clamp(0.0, 1.0);
    final status = value > 0.6 ? 'vitalGood' : value > 0.3 ? 'vitalFair' : 'vitalCritical';
    return (value: value, status: status, trend: 0.0);
  }

  static String _overallStatus(double healthScore, double hydration) {
    if (healthScore > 0.8 && hydration > 0.7) return 'vitalStatusThriving';
    if (healthScore > 0.5) return 'vitalStatusHealthy';
    if (healthScore > 0.3) return 'vitalStatusNeedsAttention';
    return 'vitalStatusCritical';
  }

  static String _determineNextAction(CareLog? lastWater, DateTime now, int interval) {
    if (lastWater == null) return 'vitalActionWaterNow';
    final daysSince = now.difference(lastWater.timestamp).inDays;
    if (daysSince >= interval) return 'vitalActionWaterNow';
    if (daysSince >= interval - 1) return 'vitalActionWaterSoon';
    return 'vitalActionAllGood';
  }

  static int _daysUntilNextCare(CareLog? lastWater, DateTime now, int interval) {
    if (lastWater == null) return 0;
    final daysSince = now.difference(lastWater.timestamp).inDays;
    return (interval - daysSince).clamp(0, interval);
  }

  static int _computeCareStreak(List<CareLog> logs, DateTime now) {
    if (logs.isEmpty) return 0;
    int streak = 0;
    var checkDate = DateTime(now.year, now.month, now.day);
    final logDays = logs
        .map((l) => DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final day in logDays) {
      if (day == checkDate || day == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
