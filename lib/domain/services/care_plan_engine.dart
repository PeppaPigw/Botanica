import '../models/care_rule_set.dart';
import '../models/enums.dart';
import '../models/environment_snapshot.dart';

class CarePlanAdjustment {
  const CarePlanAdjustment({
    required this.taskType,
    required this.baseDays,
    required this.rawAdjustedDays,
    required this.adjustedDays,
    required this.multiplier,
    required this.reasons,
    required this.hemisphere,
    required this.environmentProfile,
  });

  final TaskType taskType;
  final int baseDays;
  final int rawAdjustedDays;
  final int adjustedDays;
  final double multiplier;
  final List<CareAdjustmentReason> reasons;
  final Hemisphere hemisphere;
  final CareRuleEnvironmentProfile environmentProfile;

  List<String> get reasonIds =>
      reasons.map((r) => r.id).toList(growable: false);

  /// Human-friendly "why" bullets suitable for an expandable UI section.
  ///
  /// This is intentionally pure and deterministic: pass the same inputs and you
  /// get the same bullets.
  List<String> whyBullets({
    required EnvironmentSnapshot environment,
    required EnvironmentMode environmentMode,
    required DateTime referenceTime,
  }) {
    final baseBullets = reasons
        .map(
          (reason) => CarePlanEngine.describeReason(
            reason,
            environment: environment,
            environmentMode: environmentMode,
            referenceTime: referenceTime,
            hemisphere: hemisphere,
            environmentProfile: environmentProfile,
          ),
        )
        .toList(growable: false);

    if (rawAdjustedDays != adjustedDays) {
      return <String>[
        ...baseBullets,
        'Clamped ${rawAdjustedDays}d → ${adjustedDays}d '
            '(safety limits ${CarePlanEngine.minDays}–${CarePlanEngine.maxDays}d)',
      ];
    }

    return baseBullets;
  }
}

class CarePlanEngine {
  const CarePlanEngine();

  static const int minDays = 1;
  static const int maxDays = 60;

  /// Outdoor watering is generally more variable; we bias slightly toward more
  /// frequent checks as a conservative default.
  static const double outdoorModeMultiplier = 0.90;

  /// How strongly seasonality affects care by environment mode.
  ///
  /// Indoor plants often experience reduced seasonal swings vs outdoor plants.
  /// This weighting keeps the algorithm explainable while avoiding overreaction.
  static double seasonWeight(EnvironmentMode environmentMode) =>
      switch (environmentMode) {
        EnvironmentMode.indoor => 0.35,
        EnvironmentMode.balcony => 0.70,
        EnvironmentMode.outdoor => 1.00,
      };

  CarePlanAdjustment adjustInterval({
    required TaskType taskType,
    required int baseDays,
    required EnvironmentSnapshot environment,
    required EnvironmentMode environmentMode,
    Hemisphere hemisphere = Hemisphere.northern,
    DateTime? now,
    CareRuleEnvironmentProfile? environmentProfile,
    bool applySeasonalFallback = true,
  }) {
    final referenceTime = now ?? DateTime.now();
    final profile =
        environmentProfile ?? CareRuleEnvironmentProfile.defaultsFor(taskType);

    var multiplier = 1.0;
    final reasons = <CareAdjustmentReason>[];

    if (profile.humidityEnabled) {
      final humidity = environment.humidity;
      if (humidity < profile.humidityLowThresholdPercent) {
        multiplier *= profile.humidityLowMultiplier;
        reasons.add(CareAdjustmentReason.humidityLow);
      } else if (humidity > profile.humidityHighThresholdPercent) {
        multiplier *= profile.humidityHighMultiplier;
        reasons.add(CareAdjustmentReason.humidityHigh);
      }
    }

    if (profile.temperatureEnabled) {
      final tempC = environment.tempC;
      if (tempC > profile.temperatureHotThresholdC) {
        multiplier *= profile.temperatureHotMultiplier;
        reasons.add(CareAdjustmentReason.hotTemperature);
      }
    }

    if (profile.seasonEnabled && applySeasonalFallback) {
      final currentSeason = CarePlanEngine.seasonFor(
        hemisphere: hemisphere,
        month: referenceTime.month,
      );
      final seasonMultiplier = profile.seasonMultipliers[currentSeason];
      if (seasonMultiplier != null) {
        final weight = seasonWeight(environmentMode);
        final effectiveMultiplier = 1.0 + (seasonMultiplier - 1.0) * weight;
        multiplier *= effectiveMultiplier;

        switch (currentSeason) {
          case Season.spring:
            reasons.add(CareAdjustmentReason.springSeason);
            break;
          case Season.summer:
            reasons.add(CareAdjustmentReason.summerSeason);
            break;
          case Season.autumn:
            reasons.add(CareAdjustmentReason.autumnSeason);
            break;
          case Season.winter:
            reasons.add(CareAdjustmentReason.winterSeason);
            break;
        }
      }
    }

    // Outdoor mode is intentionally only applied to watering. Other task types
    // (fertilize, mist, etc.) should be explainable and conservative.
    if (taskType == TaskType.water &&
        environmentMode == EnvironmentMode.outdoor) {
      multiplier *= outdoorModeMultiplier;
      reasons.add(CareAdjustmentReason.outdoorMode);
    }

    final rawAdjustedDays = (baseDays * multiplier).round();
    final adjustedDays = rawAdjustedDays.clamp(minDays, maxDays);

    return CarePlanAdjustment(
      taskType: taskType,
      baseDays: baseDays,
      rawAdjustedDays: rawAdjustedDays,
      adjustedDays: adjustedDays,
      multiplier: multiplier,
      reasons: reasons,
      hemisphere: hemisphere,
      environmentProfile: profile,
    );
  }

  CarePlanAdjustment adjustWatering({
    required int baseDays,
    required EnvironmentSnapshot environment,
    required EnvironmentMode environmentMode,
    Hemisphere hemisphere = Hemisphere.northern,
    DateTime? now,
    bool applySeasonalFallback = true,
  }) {
    return adjustInterval(
      taskType: TaskType.water,
      baseDays: baseDays,
      environment: environment,
      environmentMode: environmentMode,
      hemisphere: hemisphere,
      now: now,
      applySeasonalFallback: applySeasonalFallback,
    );
  }

  static bool isWinter(DateTime referenceTime,
      {required Hemisphere hemisphere}) {
    return switch (hemisphere) {
      Hemisphere.northern => switch (referenceTime.month) {
          12 || 1 || 2 => true,
          _ => false,
        },
      Hemisphere.southern => switch (referenceTime.month) {
          6 || 7 || 8 => true,
          _ => false,
        },
    };
  }

  static Season seasonFor({
    required Hemisphere hemisphere,
    required int month,
  }) {
    final normalizedMonth = month.clamp(1, 12);

    return switch (hemisphere) {
      Hemisphere.northern => switch (normalizedMonth) {
          3 || 4 || 5 => Season.spring,
          6 || 7 || 8 => Season.summer,
          9 || 10 || 11 => Season.autumn,
          _ => Season.winter,
        },
      Hemisphere.southern => switch (normalizedMonth) {
          3 || 4 || 5 => Season.autumn,
          6 || 7 || 8 => Season.winter,
          9 || 10 || 11 => Season.spring,
          _ => Season.summer,
        },
    };
  }

  /// Returns a small set of l10n keys for the current season.
  ///
  /// These keys are intended to be mapped to localized strings at the UI layer.
  static List<String> seasonalTipKeys(Hemisphere hemisphere, DateTime now) {
    final season = seasonFor(hemisphere: hemisphere, month: now.month);

    return switch (season) {
      Season.spring => const <String>[
          'tipSpringRepot',
          'tipSpringFertilize',
        ],
      Season.summer => const <String>[
          'tipSummerWaterMore',
          'tipSummerShadeOutdoor',
        ],
      Season.autumn => const <String>[
          'tipAutumnReduceWater',
          'tipAutumnBringIndoor',
        ],
      Season.winter => const <String>[
          'tipWinterReduceFertilize',
          'tipWinterLowLight',
        ],
    };
  }

  static String describeReason(
    CareAdjustmentReason reason, {
    required EnvironmentSnapshot environment,
    required EnvironmentMode environmentMode,
    required DateTime referenceTime,
    required Hemisphere hemisphere,
    CareRuleEnvironmentProfile? environmentProfile,
  }) {
    final profile = environmentProfile ??
        CareRuleEnvironmentProfile.defaultsFor(TaskType.water);

    switch (reason) {
      case CareAdjustmentReason.humidityLow:
        return 'Low humidity (${environment.humidity}%) '
            '→ interval ×${profile.humidityLowMultiplier.toStringAsFixed(2)} '
            '(dries faster)';
      case CareAdjustmentReason.humidityHigh:
        return 'High humidity (${environment.humidity}%) '
            '→ interval ×${profile.humidityHighMultiplier.toStringAsFixed(2)} '
            '(dries slower)';
      case CareAdjustmentReason.hotTemperature:
        return 'Warm temperature (${environment.tempC.toStringAsFixed(1)}°C) '
            '→ interval ×${profile.temperatureHotMultiplier.toStringAsFixed(2)} '
            '(higher transpiration)';
      case CareAdjustmentReason.springSeason:
      case CareAdjustmentReason.summerSeason:
      case CareAdjustmentReason.autumnSeason:
      case CareAdjustmentReason.winterSeason:
        final currentSeason = CarePlanEngine.seasonFor(
            hemisphere: hemisphere, month: referenceTime.month);

        final weight = seasonWeight(environmentMode);
        final multiplier = profile.seasonMultipliers[currentSeason] ?? 1.0;
        final effectiveMultiplier = 1.0 + (multiplier - 1.0) * weight;
        final capitalizeName = currentSeason.name[0].toUpperCase() +
            currentSeason.name.substring(1);
        return '$capitalizeName season '
            '→ interval ×${effectiveMultiplier.toStringAsFixed(2)} '
            '(weighted ${weight.toStringAsFixed(2)} for ${environmentMode.id})';
      case CareAdjustmentReason.outdoorMode:
        return 'Outdoor mode '
            '→ interval ×${outdoorModeMultiplier.toStringAsFixed(2)} '
            '(more variable conditions)';
    }
  }
}
