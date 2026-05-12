enum TemperatureUnit {
  celsius,
  fahrenheit;

  String get id => switch (this) {
        TemperatureUnit.celsius => 'c',
        TemperatureUnit.fahrenheit => 'f',
      };

  static TemperatureUnit fromId(String? id) => switch (id) {
        'f' => TemperatureUnit.fahrenheit,
        _ => TemperatureUnit.celsius,
      };
}

enum LightLevel {
  low,
  medium,
  high;

  String get id => switch (this) {
        LightLevel.low => 'low',
        LightLevel.medium => 'medium',
        LightLevel.high => 'high',
      };

  static LightLevel fromId(String? id) => switch (id) {
        'low' => LightLevel.low,
        'high' => LightLevel.high,
        _ => LightLevel.medium,
      };
}

enum EnvironmentMode {
  indoor,
  balcony,
  outdoor;

  String get id => switch (this) {
        EnvironmentMode.indoor => 'indoor',
        EnvironmentMode.balcony => 'balcony',
        EnvironmentMode.outdoor => 'outdoor',
      };

  static EnvironmentMode fromId(String? id) => switch (id) {
        'balcony' => EnvironmentMode.balcony,
        'outdoor' => EnvironmentMode.outdoor,
        _ => EnvironmentMode.indoor,
      };
}

enum BeliefMode {
  unselected,
  westernZodiac,
  tarot,
  almanac,
  omikuji,
  runes,
  ogham,
  justFlower;

  String get id => switch (this) {
        BeliefMode.unselected => 'unselected',
        BeliefMode.westernZodiac => 'western_zodiac',
        BeliefMode.tarot => 'tarot',
        BeliefMode.almanac => 'almanac',
        BeliefMode.omikuji => 'omikuji',
        BeliefMode.runes => 'runes',
        BeliefMode.ogham => 'ogham',
        BeliefMode.justFlower => 'just_flower',
      };

  static BeliefMode fromId(String? id) => switch (id) {
        // Migration: replace Chinese zodiac with Almanac.
        'chinese_zodiac' => BeliefMode.almanac,
        'tarot' => BeliefMode.tarot,
        // Migration: local traditions removed; force re-selection.
        'local_traditions' => BeliefMode.unselected,
        'almanac' => BeliefMode.almanac,
        'omikuji' => BeliefMode.omikuji,
        'runes' => BeliefMode.runes,
        'ogham' => BeliefMode.ogham,
        'just_flower' => BeliefMode.justFlower,
        'western_zodiac' => BeliefMode.westernZodiac,
        _ => BeliefMode.unselected,
      };
}

enum ReminderTimePreference {
  morning,
  evening;

  String get id => switch (this) {
        ReminderTimePreference.morning => 'morning',
        ReminderTimePreference.evening => 'evening',
      };

  static ReminderTimePreference fromId(String? id) => switch (id) {
        'evening' => ReminderTimePreference.evening,
        _ => ReminderTimePreference.morning,
      };
}

enum TaskType {
  water,
  fertilize,
  mist,
  rotate,
  prune,
  repot,
  checkPests,
  wipeLeaves,
  sunlightAdjustment;

  String get id => switch (this) {
        TaskType.water => 'water',
        TaskType.fertilize => 'fertilize',
        TaskType.mist => 'mist',
        TaskType.rotate => 'rotate',
        TaskType.prune => 'prune',
        TaskType.repot => 'repot',
        TaskType.checkPests => 'check_pests',
        TaskType.wipeLeaves => 'wipe_leaves',
        TaskType.sunlightAdjustment => 'sunlight_adjustment',
      };

  static TaskType fromId(String? id) => switch (id) {
        'fertilize' => TaskType.fertilize,
        'mist' => TaskType.mist,
        'rotate' => TaskType.rotate,
        'prune' => TaskType.prune,
        'repot' => TaskType.repot,
        'check_pests' => TaskType.checkPests,
        'wipe_leaves' => TaskType.wipeLeaves,
        'sunlight_adjustment' => TaskType.sunlightAdjustment,
        _ => TaskType.water,
      };
}

enum TaskStatus {
  pending,
  done,
  snoozed,
  skipped;

  String get id => switch (this) {
        TaskStatus.pending => 'pending',
        TaskStatus.done => 'done',
        TaskStatus.snoozed => 'snoozed',
        TaskStatus.skipped => 'skipped',
      };

  static TaskStatus fromId(String? id) => switch (id) {
        'done' => TaskStatus.done,
        'snoozed' => TaskStatus.snoozed,
        'skipped' => TaskStatus.skipped,
        _ => TaskStatus.pending,
      };
}

enum CareAdjustmentReason {
  humidityLow,
  humidityHigh,
  hotTemperature,
  springSeason,
  summerSeason,
  autumnSeason,
  winterSeason,
  outdoorMode;

  String get id => switch (this) {
        CareAdjustmentReason.humidityLow => 'humidity_low',
        CareAdjustmentReason.humidityHigh => 'humidity_high',
        CareAdjustmentReason.hotTemperature => 'hot_temperature',
        CareAdjustmentReason.springSeason => 'spring_season',
        CareAdjustmentReason.summerSeason => 'summer_season',
        CareAdjustmentReason.autumnSeason => 'autumn_season',
        CareAdjustmentReason.winterSeason => 'winter_season',
        CareAdjustmentReason.outdoorMode => 'outdoor_mode',
      };
}

enum Hemisphere {
  northern,
  southern;

  String get id => switch (this) {
        Hemisphere.northern => 'northern',
        Hemisphere.southern => 'southern',
      };

  static Hemisphere fromId(String? id) => switch (id) {
        'southern' => Hemisphere.southern,
        _ => Hemisphere.northern,
      };
}

enum Season {
  winter,
  spring,
  summer,
  autumn;

  String get id => switch (this) {
        Season.winter => 'winter',
        Season.spring => 'spring',
        Season.summer => 'summer',
        Season.autumn => 'autumn',
      };

  static Season fromId(String? id) => switch (id) {
        'spring' => Season.spring,
        'summer' => Season.summer,
        'autumn' => Season.autumn,
        _ => Season.winter,
      };
}

enum SeasonalSource {
  defaultBase,
  growingSeasonData,
  dormantSeasonData,
  winterFallback,
  summerFallback;

  String get id => switch (this) {
        SeasonalSource.defaultBase => 'default_base',
        SeasonalSource.growingSeasonData => 'growing_season_data',
        SeasonalSource.dormantSeasonData => 'dormant_season_data',
        SeasonalSource.winterFallback => 'winter_fallback',
        SeasonalSource.summerFallback => 'summer_fallback',
      };

  static SeasonalSource fromId(String? id) => switch (id) {
        'growing_season_data' => SeasonalSource.growingSeasonData,
        'dormant_season_data' => SeasonalSource.dormantSeasonData,
        'winter_fallback' => SeasonalSource.winterFallback,
        'summer_fallback' => SeasonalSource.summerFallback,
        _ => SeasonalSource.defaultBase,
      };
}
