import '../models/care_log.dart';
import '../models/plant.dart';

class GardenMomentum {
  const GardenMomentum({
    required this.score,
    required this.trend,
    required this.streakContribution,
    required this.activityContribution,
    required this.growthContribution,
    required this.statusKey,
    required this.encouragement,
  });

  final double score;
  final double trend;
  final double streakContribution;
  final double activityContribution;
  final double growthContribution;
  final String statusKey;
  final String encouragement;
}

class GardenMomentumEngine {
  const GardenMomentumEngine._();

  static GardenMomentum compute({
    required List<Plant> plants,
    required List<CareLog> logs,
    required int streakDays,
    required int plantsAddedThisMonth,
    required DateTime now,
  }) {
    final recentLogs = logs.where((l) => now.difference(l.timestamp).inDays <= 14).toList();
    final olderLogs = logs.where((l) {
      final days = now.difference(l.timestamp).inDays;
      return days > 14 && days <= 28;
    }).toList();

    final streakContrib = _streakScore(streakDays);
    final activityContrib = _activityScore(recentLogs.length, olderLogs.length);
    final growthContrib = _growthScore(plantsAddedThisMonth, plants.length);

    final score = (streakContrib * 0.35 + activityContrib * 0.45 + growthContrib * 0.2)
        .clamp(0.0, 1.0);

    final trend = olderLogs.isNotEmpty
        ? (recentLogs.length - olderLogs.length) / olderLogs.length
        : recentLogs.isNotEmpty ? 1.0 : 0.0;

    final statusKey = _status(score);
    final encouragement = _encourage(score, trend, streakDays);

    return GardenMomentum(
      score: score,
      trend: trend.clamp(-1.0, 1.0),
      streakContribution: streakContrib,
      activityContribution: activityContrib,
      growthContribution: growthContrib,
      statusKey: statusKey,
      encouragement: encouragement,
    );
  }

  static double _streakScore(int days) {
    if (days >= 30) return 1.0;
    if (days >= 14) return 0.8;
    if (days >= 7) return 0.6;
    if (days >= 3) return 0.4;
    if (days >= 1) return 0.2;
    return 0.0;
  }

  static double _activityScore(int recent, int older) {
    if (recent >= 20) return 1.0;
    if (recent >= 10) return 0.7;
    if (recent >= 5) return 0.5;
    if (recent >= 1) return 0.3;
    return 0.0;
  }

  static double _growthScore(int added, int total) {
    if (total == 0) return 0.0;
    if (added >= 3) return 1.0;
    if (added >= 1) return 0.6;
    return 0.3;
  }

  static String _status(double score) {
    if (score >= 0.8) return 'momentumOnFire';
    if (score >= 0.6) return 'momentumStrong';
    if (score >= 0.4) return 'momentumBuilding';
    if (score >= 0.2) return 'momentumStarting';
    return 'momentumStalled';
  }

  static String _encourage(double score, double trend, int streak) {
    if (score >= 0.8 && trend > 0) return 'momentumEncourageKeepGoing';
    if (score >= 0.6) return 'momentumEncourageGreatWork';
    if (trend > 0.3) return 'momentumEncourageImproving';
    if (streak > 0) return 'momentumEncourageStreakAlive';
    return 'momentumEncourageStartToday';
  }
}
