import '../models/enums.dart';
import '../models/plant.dart';
import '../models/species.dart';
import '../models/user_settings.dart';

enum SeasonalAdvice {
  increaseWatering,
  decreaseWatering,
  startFertilizing,
  stopFertilizing,
  watchForPests,
  increaseHumidity,
  reduceSunExposure,
  moveFromDrafts,
  normalCare,
}

class SeasonalTip {
  const SeasonalTip({
    required this.plantId,
    required this.plantNickname,
    required this.advice,
    required this.messageKey,
    required this.priority,
  });

  final String plantId;
  final String plantNickname;
  final SeasonalAdvice advice;
  final String messageKey;
  final int priority;
}

class SeasonalCareAdvisor {
  const SeasonalCareAdvisor._();

  static Season currentSeason(DateTime now, Hemisphere hemisphere) {
    final month = now.month;
    final northernSeason = _monthToSeason(month);
    if (hemisphere == Hemisphere.southern) {
      return _flipSeason(northernSeason);
    }
    return northernSeason;
  }

  static List<SeasonalTip> advise({
    required List<Plant> plants,
    required Map<String, Species> speciesMap,
    required UserSettings settings,
    required DateTime now,
  }) {
    final season = currentSeason(now, settings.hemisphere);
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final tips = <SeasonalTip>[];

    for (final plant in activePlants) {
      final species = speciesMap[plant.speciesId];
      if (species == null) continue;

      final plantTips = _tipsForPlant(plant, species, season);
      tips.addAll(plantTips);
    }

    tips.sort((a, b) => b.priority.compareTo(a.priority));
    return tips.take(5).toList();
  }

  static List<SeasonalTip> _tipsForPlant(
    Plant plant,
    Species species,
    Season season,
  ) {
    final tips = <SeasonalTip>[];
    final waterDays = species.careDefaults.waterBaseDays;
    final isHighWater = waterDays <= 5;
    final difficulty = species.difficulty;

    switch (season) {
      case Season.spring:
        tips.add(SeasonalTip(
          plantId: plant.id,
          plantNickname: plant.nickname,
          advice: SeasonalAdvice.startFertilizing,
          messageKey: 'seasonalStartFertilizing',
          priority: 7,
        ));
        if (isHighWater) {
          tips.add(SeasonalTip(
            plantId: plant.id,
            plantNickname: plant.nickname,
            advice: SeasonalAdvice.increaseWatering,
            messageKey: 'seasonalIncreaseWater',
            priority: 6,
          ));
        }
        tips.add(SeasonalTip(
          plantId: plant.id,
          plantNickname: plant.nickname,
          advice: SeasonalAdvice.watchForPests,
          messageKey: 'seasonalWatchPests',
          priority: 4,
        ));

      case Season.summer:
        tips.add(SeasonalTip(
          plantId: plant.id,
          plantNickname: plant.nickname,
          advice: SeasonalAdvice.increaseWatering,
          messageKey: 'seasonalIncreaseWater',
          priority: 8,
        ));
        if (species.light == 'low' || species.light == 'medium') {
          tips.add(SeasonalTip(
            plantId: plant.id,
            plantNickname: plant.nickname,
            advice: SeasonalAdvice.reduceSunExposure,
            messageKey: 'seasonalReduceSun',
            priority: 6,
          ));
        }
        tips.add(SeasonalTip(
          plantId: plant.id,
          plantNickname: plant.nickname,
          advice: SeasonalAdvice.increaseHumidity,
          messageKey: 'seasonalIncreaseHumidity',
          priority: 5,
        ));

      case Season.autumn:
        tips.add(SeasonalTip(
          plantId: plant.id,
          plantNickname: plant.nickname,
          advice: SeasonalAdvice.stopFertilizing,
          messageKey: 'seasonalStopFertilizing',
          priority: 7,
        ));
        tips.add(SeasonalTip(
          plantId: plant.id,
          plantNickname: plant.nickname,
          advice: SeasonalAdvice.decreaseWatering,
          messageKey: 'seasonalDecreaseWater',
          priority: 6,
        ));

      case Season.winter:
        tips.add(SeasonalTip(
          plantId: plant.id,
          plantNickname: plant.nickname,
          advice: SeasonalAdvice.decreaseWatering,
          messageKey: 'seasonalDecreaseWater',
          priority: 8,
        ));
        tips.add(SeasonalTip(
          plantId: plant.id,
          plantNickname: plant.nickname,
          advice: SeasonalAdvice.moveFromDrafts,
          messageKey: 'seasonalMoveFromDrafts',
          priority: 5,
        ));
        if (difficulty == 'hard' || difficulty == 'expert') {
          tips.add(SeasonalTip(
            plantId: plant.id,
            plantNickname: plant.nickname,
            advice: SeasonalAdvice.increaseHumidity,
            messageKey: 'seasonalIncreaseHumidity',
            priority: 6,
          ));
        }
    }

    return tips;
  }

  static Season _monthToSeason(int month) {
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }

  static Season _flipSeason(Season season) {
    switch (season) {
      case Season.spring:
        return Season.autumn;
      case Season.summer:
        return Season.winter;
      case Season.autumn:
        return Season.spring;
      case Season.winter:
        return Season.summer;
    }
  }
}
