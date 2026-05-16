import '../models/plant.dart';

class ShareableGardenCard {
  const ShareableGardenCard({
    required this.plantCount,
    required this.streakDays,
    required this.topPlantNickname,
    required this.gardenAge,
    required this.titleKey,
    required this.subtitleKey,
    required this.badgeKey,
    required this.stats,
  });

  final int plantCount;
  final int streakDays;
  final String topPlantNickname;
  final int gardenAge;
  final String titleKey;
  final String subtitleKey;
  final String badgeKey;
  final Map<String, String> stats;
}

class GardenSharingEngine {
  const GardenSharingEngine._();

  static ShareableGardenCard generate({
    required List<Plant> plants,
    required int streakDays,
    required int totalCareActions,
    required double momentumScore,
    required DateTime now,
  }) {
    final active = plants.where((p) => !p.isArchived).toList();
    final plantCount = active.length;

    final oldest = active.isEmpty ? null
        : active.reduce((a, b) =>
            a.createdAt.isBefore(b.createdAt) ? a : b);
    final gardenAge = oldest != null
        ? now.difference(oldest.createdAt).inDays : 0;

    final topPlant = active.isNotEmpty ? active.first.nickname : '';
    final titleKey = _title(plantCount, streakDays);
    final subtitleKey = _subtitle(momentumScore);
    final badgeKey = _badge(streakDays, plantCount);

    final stats = <String, String>{
      'shareStatPlants': plantCount.toString(),
      'shareStatStreak': '$streakDays days',
      'shareStatActions': totalCareActions.toString(),
      'shareStatAge': '$gardenAge days',
    };

    return ShareableGardenCard(
      plantCount: plantCount,
      streakDays: streakDays,
      topPlantNickname: topPlant,
      gardenAge: gardenAge,
      titleKey: titleKey,
      subtitleKey: subtitleKey,
      badgeKey: badgeKey,
      stats: stats,
    );
  }

  static String _title(int plants, int streak) {
    if (streak >= 30 && plants >= 10) return 'shareTitleDedicated';
    if (plants >= 20) return 'shareTitleCollector';
    if (streak >= 7) return 'shareTitleConsistent';
    return 'shareTitleGrowing';
  }

  static String _subtitle(double momentum) {
    if (momentum >= 0.8) return 'shareSubtitleOnFire';
    if (momentum >= 0.5) return 'shareSubtitleThriving';
    return 'shareSubtitleNurturing';
  }

  static String _badge(int streak, int plants) {
    if (streak >= 365) return 'shareBadgeLegend';
    if (streak >= 90) return 'shareBadgeVeteran';
    if (streak >= 30) return 'shareBadgeDedicated';
    if (plants >= 10) return 'shareBadgeCollector';
    return 'shareBadgeGardener';
  }
}
