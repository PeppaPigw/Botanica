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
  snoozed;

  String get id => switch (this) {
        TaskStatus.pending => 'pending',
        TaskStatus.done => 'done',
        TaskStatus.snoozed => 'snoozed',
      };

  static TaskStatus fromId(String? id) => switch (id) {
        'done' => TaskStatus.done,
        'snoozed' => TaskStatus.snoozed,
        _ => TaskStatus.pending,
      };
}

enum CareAdjustmentReason {
  humidityLow,
  humidityHigh,
  hotTemperature,
  winterSeason,
  outdoorMode;

  String get id => switch (this) {
        CareAdjustmentReason.humidityLow => 'humidity_low',
        CareAdjustmentReason.humidityHigh => 'humidity_high',
        CareAdjustmentReason.hotTemperature => 'hot_temperature',
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
