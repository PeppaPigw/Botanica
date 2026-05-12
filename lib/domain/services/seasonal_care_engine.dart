import '../models/care_schedule_snapshot.dart';
import '../models/enums.dart';
import '../models/environment_snapshot.dart';
import '../models/plant_idea.dart';
import 'care_plan_engine.dart';
import 'scheduling.dart';

class CareScheduleDecision {
  const CareScheduleDecision({
    required this.dueAt,
    required this.snapshot,
  });

  /// The next scheduled time for the task. Null if the task should be skipped
  /// during the current season (e.g. fertilizing during dormancy).
  final DateTime? dueAt;

  final CareScheduleSnapshot snapshot;
}

class SeasonalCareEngine {
  const SeasonalCareEngine(this.carePlanEngine);

  final CarePlanEngine carePlanEngine;

  int _midpoint(PlantIdeaIntRange range) =>
      ((range.min + range.max) / 2).round();

  CareScheduleDecision computeSchedule({
    required TaskType taskType,
    required DateTime now,
    required EnvironmentSnapshot environment,
    required Hemisphere hemisphere,
    required EnvironmentMode environmentMode,
    PlantIdea? plantIdea,
    int? fallbackBaseDays,
  }) {
    final season =
        CarePlanEngine.seasonFor(hemisphere: hemisphere, month: now.month);

    int baseDays = 7;
    int seasonalBaseDays = 7;
    SeasonalSource source = SeasonalSource.defaultBase;

    // 1. Resolve base days
    switch (taskType) {
      case TaskType.water:
        baseDays =
            plantIdea?.careDefaults.waterBaseDays ?? fallbackBaseDays ?? 7;
        break;
      case TaskType.fertilize:
        baseDays =
            plantIdea?.careDefaults.fertilizeBaseDays ?? fallbackBaseDays ?? 30;
        break;
      case TaskType.mist:
        baseDays =
            plantIdea?.careDefaults.mistBaseDays ?? fallbackBaseDays ?? 0;
        break;
      case TaskType.rotate:
        baseDays =
            plantIdea?.careDefaults.rotateBaseDays ?? fallbackBaseDays ?? 14;
        break;
      case TaskType.prune:
        baseDays =
            plantIdea?.careDefaults.pruneBaseDays ?? fallbackBaseDays ?? 90;
        break;
      default:
        break;
    }

    // 2. Resolve seasonal override
    seasonalBaseDays = baseDays;
    bool applySeasonalFallback = true;

    if (plantIdea != null) {
      if (taskType == TaskType.water && plantIdea.care?.watering != null) {
        final w = plantIdea.care!.watering!;
        if ((season == Season.spring || season == Season.summer) &&
            w.growingSeasonDays != null) {
          seasonalBaseDays = _midpoint(w.growingSeasonDays!);
          source = SeasonalSource.growingSeasonData;
          applySeasonalFallback = false;
        } else if ((season == Season.autumn || season == Season.winter) &&
            w.dormantSeasonDays != null) {
          seasonalBaseDays = _midpoint(w.dormantSeasonDays!);
          source = SeasonalSource.dormantSeasonData;
          applySeasonalFallback = false;
        }
      } else if (taskType == TaskType.fertilize &&
          plantIdea.care?.fertilizing != null) {
        final f = plantIdea.care!.fertilizing!;
        if ((season == Season.spring || season == Season.summer) &&
            f.growingSeasonDays != null) {
          seasonalBaseDays = f.growingSeasonDays!;
          source = SeasonalSource.growingSeasonData;
          applySeasonalFallback = false;
        } else if ((season == Season.autumn || season == Season.winter) &&
            f.dormantSeasonDays != null) {
          seasonalBaseDays = f.dormantSeasonDays!;
          source = SeasonalSource.dormantSeasonData;
          applySeasonalFallback = false;
        }
      }
    }

    if (seasonalBaseDays == 0) {
      // Intentionally skipped during this season (e.g. no fertilizing in winter)
      final snapshot = CareScheduleSnapshot(
        baseDays: baseDays,
        seasonalBaseDays: 0,
        adjustedDays: 0,
        season: season,
        hemisphere: hemisphere,
        environmentMode: environmentMode,
        temperatureC: environment.tempC.toDouble(),
        humidityPercent: environment.humidity.toDouble(),
        reasonIds: const [],
        seasonalSource: source,
        computedAt: now,
      );
      return CareScheduleDecision(
        dueAt: null,
        snapshot: snapshot,
      );
    }

    // 3. Environment adjustments
    final adjustment = carePlanEngine.adjustInterval(
      taskType: taskType,
      baseDays: seasonalBaseDays,
      environment: environment,
      environmentMode: environmentMode,
      hemisphere: hemisphere,
      now: now,
      applySeasonalFallback: applySeasonalFallback,
    );

    // Identify if fallback was actually applied
    if (applySeasonalFallback) {
      if (adjustment.reasons.contains(CareAdjustmentReason.winterSeason)) {
        source = SeasonalSource.winterFallback;
      } else if (adjustment.reasons
          .contains(CareAdjustmentReason.summerSeason)) {
        source = SeasonalSource.summerFallback;
      }
    }

    final dueAt = addLocalCalendarDays(now, adjustment.adjustedDays);

    final snapshot = CareScheduleSnapshot(
      baseDays: baseDays,
      seasonalBaseDays: seasonalBaseDays,
      adjustedDays: adjustment.adjustedDays,
      season: season,
      hemisphere: hemisphere,
      environmentMode: environmentMode,
      temperatureC: environment.tempC.toDouble(),
      humidityPercent: environment.humidity.toDouble(),
      reasonIds: adjustment.reasonIds,
      seasonalSource: source,
      computedAt: now,
    );

    return CareScheduleDecision(
      dueAt: dueAt,
      snapshot: snapshot,
    );
  }
}
