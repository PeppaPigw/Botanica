import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class SeasonalAdvice {
  const SeasonalAdvice({
    required this.plantId,
    required this.adviceKey,
    required this.priority,
    required this.category,
    required this.actionType,
  });

  final String plantId;
  final String adviceKey;
  final int priority;
  final String category;
  final TaskType? actionType;
}

class SeasonalTransitionReport {
  const SeasonalTransitionReport({
    required this.currentSeason,
    required this.nextSeason,
    required this.daysUntilTransition,
    required this.advice,
    required this.urgentCount,
  });

  final Season currentSeason;
  final Season nextSeason;
  final int daysUntilTransition;
  final List<SeasonalAdvice> advice;
  final int urgentCount;
}

class SeasonalTransitionAdvisor {
  const SeasonalTransitionAdvisor._();

  static SeasonalTransitionReport analyze({
    required List<Plant> plants,
    required List<CareLog> logs,
    required Season currentSeason,
    required Hemisphere hemisphere,
    required DateTime now,
  }) {
    final nextSeason = _nextSeason(currentSeason);
    final daysUntil = _daysUntilTransition(now, currentSeason, hemisphere);
    final activePlants = plants.where((p) => !p.isArchived).toList();

    final advice = <SeasonalAdvice>[];

    for (final plant in activePlants) {
      _generateAdvice(plant, currentSeason, nextSeason, daysUntil, logs, advice);
    }

    advice.sort((a, b) => b.priority.compareTo(a.priority));
    final urgentCount = advice.where((a) => a.priority >= 8).length;

    return SeasonalTransitionReport(
      currentSeason: currentSeason,
      nextSeason: nextSeason,
      daysUntilTransition: daysUntil,
      advice: advice,
      urgentCount: urgentCount,
    );
  }

  static void _generateAdvice(Plant plant, Season current, Season next,
      int daysUntil, List<CareLog> logs, List<SeasonalAdvice> out) {
    if (daysUntil <= 14) {
      if (current == Season.autumn && plant.environmentMode == EnvironmentMode.balcony) {
        out.add(SeasonalAdvice(
          plantId: plant.id,
          adviceKey: 'seasonalMoveIndoors',
          priority: 9,
          category: 'location',
          actionType: null,
        ));
      }

      if (next == Season.winter) {
        out.add(SeasonalAdvice(
          plantId: plant.id,
          adviceKey: 'seasonalReduceWatering',
          priority: 7,
          category: 'watering',
          actionType: TaskType.water,
        ));
      }

      if (next == Season.spring) {
        out.add(SeasonalAdvice(
          plantId: plant.id,
          adviceKey: 'seasonalStartFertilizing',
          priority: 6,
          category: 'feeding',
          actionType: TaskType.fertilize,
        ));
      }
    }

    if (current == Season.summer) {
      out.add(SeasonalAdvice(
        plantId: plant.id,
        adviceKey: 'seasonalCheckHydration',
        priority: 5,
        category: 'watering',
        actionType: TaskType.mist,
      ));
    }

    if (current == Season.spring && daysUntil > 30) {
      out.add(SeasonalAdvice(
        plantId: plant.id,
        adviceKey: 'seasonalRepotWindow',
        priority: 4,
        category: 'maintenance',
        actionType: TaskType.repot,
      ));
    }
  }

  static Season _nextSeason(Season current) {
    switch (current) {
      case Season.spring: return Season.summer;
      case Season.summer: return Season.autumn;
      case Season.autumn: return Season.winter;
      case Season.winter: return Season.spring;
    }
  }

  static int _daysUntilTransition(DateTime now, Season current, Hemisphere hemisphere) {
    final transitionMonths = hemisphere == Hemisphere.northern
        ? {Season.spring: 6, Season.summer: 9, Season.autumn: 12, Season.winter: 3}
        : {Season.spring: 12, Season.summer: 3, Season.autumn: 6, Season.winter: 9};

    final targetMonth = transitionMonths[current]!;
    var targetDate = DateTime(now.year, targetMonth, 1);
    if (targetDate.isBefore(now)) {
      targetDate = DateTime(now.year + 1, targetMonth, 1);
    }
    return targetDate.difference(now).inDays;
  }
}
