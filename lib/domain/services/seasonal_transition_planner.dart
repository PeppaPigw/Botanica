import '../models/enums.dart';
import '../models/plant.dart';
import '../models/species.dart';
import '../models/user_settings.dart';

enum TransitionAction {
  moveIndoors,
  moveOutdoors,
  reduceWatering,
  increaseWatering,
  startFertilizing,
  stopFertilizing,
  increaseHumidity,
  protectFromFrost,
  provideShadeCover,
  resumeNormalCare,
}

class TransitionTask {
  const TransitionTask({
    required this.plantId,
    required this.plantNickname,
    required this.action,
    required this.urgency,
    required this.reason,
  });

  final String plantId;
  final String plantNickname;
  final TransitionAction action;
  final int urgency;
  final String reason;
}

class SeasonalTransitionPlan {
  const SeasonalTransitionPlan({
    required this.fromSeason,
    required this.toSeason,
    required this.tasks,
    required this.weeksUntilTransition,
    required this.summary,
  });

  final Season fromSeason;
  final Season toSeason;
  final List<TransitionTask> tasks;
  final int weeksUntilTransition;
  final String summary;
}

class SeasonalTransitionPlanner {
  const SeasonalTransitionPlanner._();

  static SeasonalTransitionPlan? plan({
    required List<Plant> plants,
    required List<Species> species,
    required UserSettings settings,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.isEmpty) return null;

    final hemisphere = settings.hemisphere;
    final currentSeason = _currentSeason(now, hemisphere);
    final nextSeason = _nextSeason(currentSeason);
    final weeksUntil = _weeksUntilTransition(now, hemisphere);

    if (weeksUntil > 6) return null;

    final tasks = <TransitionTask>[];

    for (final plant in activePlants) {
      final spec = species.where((s) => s.id == plant.speciesId).firstOrNull;
      _generateTasks(plant, spec, currentSeason, nextSeason, tasks);
    }

    if (tasks.isEmpty) return null;

    tasks.sort((a, b) => b.urgency.compareTo(a.urgency));

    final summary = _buildSummary(currentSeason, nextSeason, tasks.length);

    return SeasonalTransitionPlan(
      fromSeason: currentSeason,
      toSeason: nextSeason,
      tasks: tasks,
      weeksUntilTransition: weeksUntil,
      summary: summary,
    );
  }

  static void _generateTasks(
    Plant plant,
    Species? spec,
    Season current,
    Season next,
    List<TransitionTask> out,
  ) {
    final isOutdoor = plant.environmentMode == EnvironmentMode.outdoor ||
        plant.environmentMode == EnvironmentMode.balcony;

    if (next == Season.winter) {
      if (isOutdoor) {
        out.add(TransitionTask(
          plantId: plant.id,
          plantNickname: plant.nickname,
          action: TransitionAction.moveIndoors,
          urgency: 9,
          reason: 'transitionFrostRisk',
        ));
      }
      out.add(TransitionTask(
        plantId: plant.id,
        plantNickname: plant.nickname,
        action: TransitionAction.reduceWatering,
        urgency: 6,
        reason: 'transitionDormancy',
      ));
      out.add(TransitionTask(
        plantId: plant.id,
        plantNickname: plant.nickname,
        action: TransitionAction.stopFertilizing,
        urgency: 5,
        reason: 'transitionSlowGrowth',
      ));
    } else if (next == Season.spring) {
      out.add(TransitionTask(
        plantId: plant.id,
        plantNickname: plant.nickname,
        action: TransitionAction.increaseWatering,
        urgency: 7,
        reason: 'transitionGrowthResumes',
      ));
      out.add(TransitionTask(
        plantId: plant.id,
        plantNickname: plant.nickname,
        action: TransitionAction.startFertilizing,
        urgency: 6,
        reason: 'transitionActiveGrowth',
      ));
      if (isOutdoor) {
        out.add(TransitionTask(
          plantId: plant.id,
          plantNickname: plant.nickname,
          action: TransitionAction.moveOutdoors,
          urgency: 4,
          reason: 'transitionWarmEnough',
        ));
      }
    } else if (next == Season.summer) {
      out.add(TransitionTask(
        plantId: plant.id,
        plantNickname: plant.nickname,
        action: TransitionAction.increaseWatering,
        urgency: 8,
        reason: 'transitionHeatStress',
      ));
      if (spec != null && _isLowLightPlant(spec)) {
        out.add(TransitionTask(
          plantId: plant.id,
          plantNickname: plant.nickname,
          action: TransitionAction.provideShadeCover,
          urgency: 7,
          reason: 'transitionSunBurn',
        ));
      }
      out.add(TransitionTask(
        plantId: plant.id,
        plantNickname: plant.nickname,
        action: TransitionAction.increaseHumidity,
        urgency: 5,
        reason: 'transitionDryAir',
      ));
    } else {
      out.add(TransitionTask(
        plantId: plant.id,
        plantNickname: plant.nickname,
        action: TransitionAction.reduceWatering,
        urgency: 6,
        reason: 'transitionSlowingDown',
      ));
      if (isOutdoor) {
        out.add(TransitionTask(
          plantId: plant.id,
          plantNickname: plant.nickname,
          action: TransitionAction.protectFromFrost,
          urgency: 7,
          reason: 'transitionEarlyFrost',
        ));
      }
    }
  }

  static bool _isLowLightPlant(Species spec) {
    final light = spec.light.toLowerCase();
    return light.contains('low') ||
        light.contains('shade') ||
        light.contains('indirect');
  }

  static Season _currentSeason(DateTime now, Hemisphere hemisphere) {
    final month = now.month;
    final isSouthern = hemisphere == Hemisphere.southern;

    if (isSouthern) {
      if (month >= 3 && month <= 5) return Season.autumn;
      if (month >= 6 && month <= 8) return Season.winter;
      if (month >= 9 && month <= 11) return Season.spring;
      return Season.summer;
    }

    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }

  static Season _nextSeason(Season current) {
    return switch (current) {
      Season.spring => Season.summer,
      Season.summer => Season.autumn,
      Season.autumn => Season.winter,
      Season.winter => Season.spring,
    };
  }

  static int _weeksUntilTransition(DateTime now, Hemisphere hemisphere) {
    final month = now.month;
    final isSouthern = hemisphere == Hemisphere.southern;

    final transitionMonths = isSouthern ? [3, 6, 9, 12] : [3, 6, 9, 12];

    int nextTransitionMonth = transitionMonths.firstWhere(
      (m) => m > month,
      orElse: () => transitionMonths.first + 12,
    );

    final nextTransition = DateTime(
      nextTransitionMonth > 12 ? now.year + 1 : now.year,
      nextTransitionMonth > 12 ? nextTransitionMonth - 12 : nextTransitionMonth,
      1,
    );

    return nextTransition.difference(now).inDays ~/ 7;
  }

  static String _buildSummary(Season from, Season to, int taskCount) {
    return 'transition${from.name.capitalize()}To${to.name.capitalize()}';
  }
}

extension _StringCap on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
