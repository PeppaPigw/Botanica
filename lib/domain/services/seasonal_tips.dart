import '../models/enums.dart';

class SeasonalTip {
  const SeasonalTip({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    this.relevantTaskTypes = const [],
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final String icon;
  final List<TaskType> relevantTaskTypes;
}

class SeasonalTipsEngine {
  const SeasonalTipsEngine._();

  static Season currentSeason(Hemisphere hemisphere, {DateTime? now}) {
    final month = (now ?? DateTime.now()).month;
    final isNorthern = hemisphere == Hemisphere.northern;

    return switch (month) {
      3 || 4 || 5 => isNorthern ? Season.spring : Season.autumn,
      6 || 7 || 8 => isNorthern ? Season.summer : Season.winter,
      9 || 10 || 11 => isNorthern ? Season.autumn : Season.spring,
      _ => isNorthern ? Season.winter : Season.summer,
    };
  }

  static List<SeasonalTip> tipsForSeason(Season season) {
    return switch (season) {
      Season.spring => _springTips,
      Season.summer => _summerTips,
      Season.autumn => _autumnTips,
      Season.winter => _winterTips,
    };
  }

  static SeasonalTip tipOfTheDay(Hemisphere hemisphere, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final season = currentSeason(hemisphere, now: today);
    final tips = tipsForSeason(season);
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }

  static const _springTips = <SeasonalTip>[
    SeasonalTip(
      id: 'spring_repot',
      titleKey: 'seasonalTipSpringRepotTitle',
      bodyKey: 'seasonalTipSpringRepotBody',
      icon: 'repot',
      relevantTaskTypes: [TaskType.repot],
    ),
    SeasonalTip(
      id: 'spring_fertilize',
      titleKey: 'seasonalTipSpringFertilizeTitle',
      bodyKey: 'seasonalTipSpringFertilizeBody',
      icon: 'fertilize',
      relevantTaskTypes: [TaskType.fertilize],
    ),
    SeasonalTip(
      id: 'spring_growth',
      titleKey: 'seasonalTipSpringGrowthTitle',
      bodyKey: 'seasonalTipSpringGrowthBody',
      icon: 'growth',
    ),
    SeasonalTip(
      id: 'spring_water_increase',
      titleKey: 'seasonalTipSpringWaterTitle',
      bodyKey: 'seasonalTipSpringWaterBody',
      icon: 'water',
      relevantTaskTypes: [TaskType.water],
    ),
    SeasonalTip(
      id: 'spring_pests',
      titleKey: 'seasonalTipSpringPestsTitle',
      bodyKey: 'seasonalTipSpringPestsBody',
      icon: 'pests',
      relevantTaskTypes: [TaskType.checkPests],
    ),
  ];

  static const _summerTips = <SeasonalTip>[
    SeasonalTip(
      id: 'summer_water',
      titleKey: 'seasonalTipSummerWaterTitle',
      bodyKey: 'seasonalTipSummerWaterBody',
      icon: 'water',
      relevantTaskTypes: [TaskType.water],
    ),
    SeasonalTip(
      id: 'summer_mist',
      titleKey: 'seasonalTipSummerMistTitle',
      bodyKey: 'seasonalTipSummerMistBody',
      icon: 'mist',
      relevantTaskTypes: [TaskType.mist],
    ),
    SeasonalTip(
      id: 'summer_sunburn',
      titleKey: 'seasonalTipSummerSunburnTitle',
      bodyKey: 'seasonalTipSummerSunburnBody',
      icon: 'sun',
      relevantTaskTypes: [TaskType.sunlightAdjustment],
    ),
    SeasonalTip(
      id: 'summer_outdoor',
      titleKey: 'seasonalTipSummerOutdoorTitle',
      bodyKey: 'seasonalTipSummerOutdoorBody',
      icon: 'outdoor',
    ),
    SeasonalTip(
      id: 'summer_propagate',
      titleKey: 'seasonalTipSummerPropagateTitle',
      bodyKey: 'seasonalTipSummerPropagateBody',
      icon: 'prune',
      relevantTaskTypes: [TaskType.prune],
    ),
  ];

  static const _autumnTips = <SeasonalTip>[
    SeasonalTip(
      id: 'autumn_reduce_water',
      titleKey: 'seasonalTipAutumnWaterTitle',
      bodyKey: 'seasonalTipAutumnWaterBody',
      icon: 'water',
      relevantTaskTypes: [TaskType.water],
    ),
    SeasonalTip(
      id: 'autumn_stop_fertilize',
      titleKey: 'seasonalTipAutumnFertilizeTitle',
      bodyKey: 'seasonalTipAutumnFertilizeBody',
      icon: 'fertilize',
      relevantTaskTypes: [TaskType.fertilize],
    ),
    SeasonalTip(
      id: 'autumn_light',
      titleKey: 'seasonalTipAutumnLightTitle',
      bodyKey: 'seasonalTipAutumnLightBody',
      icon: 'sun',
      relevantTaskTypes: [TaskType.rotate],
    ),
    SeasonalTip(
      id: 'autumn_bring_inside',
      titleKey: 'seasonalTipAutumnInsideTitle',
      bodyKey: 'seasonalTipAutumnInsideBody',
      icon: 'indoor',
    ),
    SeasonalTip(
      id: 'autumn_clean',
      titleKey: 'seasonalTipAutumnCleanTitle',
      bodyKey: 'seasonalTipAutumnCleanBody',
      icon: 'wipe',
      relevantTaskTypes: [TaskType.wipeLeaves],
    ),
  ];

  static const _winterTips = <SeasonalTip>[
    SeasonalTip(
      id: 'winter_reduce_water',
      titleKey: 'seasonalTipWinterWaterTitle',
      bodyKey: 'seasonalTipWinterWaterBody',
      icon: 'water',
      relevantTaskTypes: [TaskType.water],
    ),
    SeasonalTip(
      id: 'winter_humidity',
      titleKey: 'seasonalTipWinterHumidityTitle',
      bodyKey: 'seasonalTipWinterHumidityBody',
      icon: 'mist',
      relevantTaskTypes: [TaskType.mist],
    ),
    SeasonalTip(
      id: 'winter_drafts',
      titleKey: 'seasonalTipWinterDraftsTitle',
      bodyKey: 'seasonalTipWinterDraftsBody',
      icon: 'indoor',
    ),
    SeasonalTip(
      id: 'winter_light',
      titleKey: 'seasonalTipWinterLightTitle',
      bodyKey: 'seasonalTipWinterLightBody',
      icon: 'sun',
      relevantTaskTypes: [TaskType.rotate],
    ),
    SeasonalTip(
      id: 'winter_rest',
      titleKey: 'seasonalTipWinterRestTitle',
      bodyKey: 'seasonalTipWinterRestBody',
      icon: 'rest',
    ),
  ];
}
