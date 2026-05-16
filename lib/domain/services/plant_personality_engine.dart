import '../models/care_log.dart';
import '../models/plant.dart';

class PlantPersonality {
  const PlantPersonality({
    required this.plantId,
    required this.plantNickname,
    required this.primaryTrait,
    required this.secondaryTrait,
    required this.moodKey,
    required this.quoteKey,
    required this.careStyle,
  });

  final String plantId;
  final String plantNickname;
  final String primaryTrait;
  final String secondaryTrait;
  final String moodKey;
  final String quoteKey;
  final String careStyle;
}

class PlantPersonalityEngine {
  const PlantPersonalityEngine._();

  static PlantPersonality analyze({
    required Plant plant,
    required List<CareLog> logs,
    required double healthScore,
    required DateTime now,
  }) {
    final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
    final recentLogs = plantLogs
        .where((l) => now.difference(l.timestamp).inDays <= 30)
        .toList();

    final primaryTrait = _determinePrimaryTrait(plantLogs, recentLogs, healthScore, now);
    final secondaryTrait = _determineSecondaryTrait(plantLogs, primaryTrait);
    final mood = _determineMood(recentLogs, healthScore, now);
    final quote = _generateQuote(primaryTrait, mood);
    final careStyle = _determineCareStyle(recentLogs);

    return PlantPersonality(
      plantId: plant.id,
      plantNickname: plant.nickname,
      primaryTrait: primaryTrait,
      secondaryTrait: secondaryTrait,
      moodKey: mood,
      quoteKey: quote,
      careStyle: careStyle,
    );
  }

  static String _determinePrimaryTrait(
      List<CareLog> allLogs, List<CareLog> recentLogs,
      double healthScore, DateTime now) {
    if (allLogs.isEmpty) return 'shy';

    final gaps = <int>[];
    final sorted = allLogs.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (int i = 1; i < sorted.length; i++) {
      gaps.add(sorted[i].timestamp.difference(sorted[i - 1].timestamp).inDays);
    }

    if (gaps.isNotEmpty) {
      final avgGap = gaps.reduce((a, b) => a + b) / gaps.length;
      final maxGap = gaps.reduce((a, b) => a > b ? a : b);

      if (maxGap > 14 && healthScore > 0.6) return 'resilient';
      if (avgGap < 2 && recentLogs.length > 20) return 'needy';
      if (maxGap > 21 && healthScore > 0.5) return 'independent';
    }

    if (healthScore > 0.8 && recentLogs.length > 15) return 'dramatic';
    if (recentLogs.length < 5) return 'zen';
    return 'social';
  }

  static String _determineSecondaryTrait(List<CareLog> logs, String primary) {
    final types = logs.map((l) => l.type).toSet();
    if (types.length >= 4) return 'adventurous';
    if (primary == 'resilient') return 'zen';
    if (primary == 'needy') return 'dramatic';
    return 'social';
  }

  static String _determineMood(List<CareLog> recentLogs, double healthScore, DateTime now) {
    if (healthScore > 0.8 && recentLogs.length > 10) return 'personalityThriving';
    if (healthScore > 0.6) return 'personalityHappy';
    if (recentLogs.isEmpty) return 'personalityLonely';

    final lastLog = recentLogs.reduce((a, b) =>
        a.timestamp.isAfter(b.timestamp) ? a : b);
    if (now.difference(lastLog.timestamp).inDays > 7) return 'personalityThirsty';

    return 'personalityContent';
  }

  static String _generateQuote(String trait, String mood) {
    return 'personalityQuote_${trait}_$mood';
  }

  static String _determineCareStyle(List<CareLog> recentLogs) {
    if (recentLogs.isEmpty) return 'careStyleMinimalist';

    final activeDays = recentLogs
        .map((l) => DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day))
        .toSet()
        .length;

    if (activeDays >= 20) return 'careStyleDedicated';
    if (activeDays >= 10) return 'careStyleBalanced';
    if (activeDays >= 5) return 'careStyleCasual';
    return 'careStyleMinimalist';
  }
}
