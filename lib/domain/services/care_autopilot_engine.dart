import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/species.dart';

enum SuggestionUrgency { low, medium, high }

class CareAutopilotSuggestion {
  const CareAutopilotSuggestion({
    required this.plantId,
    required this.plantNickname,
    required this.type,
    required this.titleKey,
    required this.bodyKey,
    required this.urgency,
    required this.actionType,
    this.metric,
  });

  final String plantId;
  final String plantNickname;
  final String type;
  final String titleKey;
  final String bodyKey;
  final SuggestionUrgency urgency;
  final TaskType? actionType;
  final double? metric;
}

class CareAutopilotEngine {
  const CareAutopilotEngine._();

  static List<CareAutopilotSuggestion> generate({
    required List<Plant> plants,
    required List<Species> species,
    required List<CareLog> logs,
    required DateTime now,
    required Season currentSeason,
    required Season nextSeason,
  }) {
    final suggestions = <CareAutopilotSuggestion>[];

    for (final plant in plants.where((p) => !p.isArchived)) {
      final spec = species.where((s) => s.id == plant.speciesId).firstOrNull;
      if (spec == null) continue;

      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();

      _checkSeasonalWateringShift(plant, spec, plantLogs, now, currentSeason, suggestions);
      _checkFertilizeReminder(plant, spec, plantLogs, now, currentSeason, suggestions);
      _checkOverwatering(plant, plantLogs, now, suggestions);
      _checkNeglectedPlant(plant, plantLogs, now, suggestions);
    }

    suggestions.sort((a, b) => b.urgency.index.compareTo(a.urgency.index));
    return suggestions.take(8).toList();
  }

  static void _checkSeasonalWateringShift(
    Plant plant,
    Species spec,
    List<CareLog> logs,
    DateTime now,
    Season season,
    List<CareAutopilotSuggestion> out,
  ) {
    final isGrowingSeason = season == Season.spring || season == Season.summer;
    final baseDays = spec.careDefaults.waterBaseDays;

    final recentWater = logs
        .where((l) => l.type == TaskType.water &&
            now.difference(l.timestamp).inDays <= 30)
        .length;

    if (isGrowingSeason && recentWater > 0) {
      final avgInterval = 30 / recentWater;
      if (avgInterval > baseDays + 2) {
        out.add(CareAutopilotSuggestion(
          plantId: plant.id,
          plantNickname: plant.nickname,
          type: 'seasonalIncrease',
          titleKey: 'autopilotIncreaseWateringTitle',
          bodyKey: 'autopilotIncreaseWateringBody',
          urgency: SuggestionUrgency.medium,
          actionType: TaskType.water,
          metric: avgInterval,
        ));
      }
    }

    if (!isGrowingSeason && recentWater > 0) {
      final avgInterval = 30 / recentWater;
      if (avgInterval < baseDays - 2) {
        out.add(CareAutopilotSuggestion(
          plantId: plant.id,
          plantNickname: plant.nickname,
          type: 'seasonalDecrease',
          titleKey: 'autopilotDecreaseWateringTitle',
          bodyKey: 'autopilotDecreaseWateringBody',
          urgency: SuggestionUrgency.low,
          actionType: TaskType.water,
          metric: avgInterval,
        ));
      }
    }
  }

  static void _checkFertilizeReminder(
    Plant plant,
    Species spec,
    List<CareLog> logs,
    DateTime now,
    Season season,
    List<CareAutopilotSuggestion> out,
  ) {
    if (season != Season.spring && season != Season.summer) return;

    final lastFert = logs
        .where((l) => l.type == TaskType.fertilize)
        .fold<DateTime?>(null, (latest, l) =>
            latest == null || l.timestamp.isAfter(latest) ? l.timestamp : latest);

    if (lastFert == null || now.difference(lastFert).inDays > 45) {
      out.add(CareAutopilotSuggestion(
        plantId: plant.id,
        plantNickname: plant.nickname,
        type: 'fertilizeReminder',
        titleKey: 'autopilotFertilizeTitle',
        bodyKey: 'autopilotFertilizeBody',
        urgency: SuggestionUrgency.medium,
        actionType: TaskType.fertilize,
        metric: lastFert == null ? 999 : now.difference(lastFert).inDays.toDouble(),
      ));
    }
  }

  static void _checkOverwatering(
    Plant plant,
    List<CareLog> logs,
    DateTime now,
    List<CareAutopilotSuggestion> out,
  ) {
    final recentWater = logs
        .where((l) => l.type == TaskType.water &&
            now.difference(l.timestamp).inDays <= 14)
        .toList();

    if (recentWater.length >= 7) {
      out.add(CareAutopilotSuggestion(
        plantId: plant.id,
        plantNickname: plant.nickname,
        type: 'overwatering',
        titleKey: 'autopilotOverwateringTitle',
        bodyKey: 'autopilotOverwateringBody',
        urgency: SuggestionUrgency.high,
        actionType: TaskType.water,
        metric: recentWater.length.toDouble(),
      ));
    }
  }

  static void _checkNeglectedPlant(
    Plant plant,
    List<CareLog> logs,
    DateTime now,
    List<CareAutopilotSuggestion> out,
  ) {
    final lastAny = logs.fold<DateTime?>(null, (latest, l) =>
        latest == null || l.timestamp.isAfter(latest) ? l.timestamp : latest);

    if (lastAny == null || now.difference(lastAny).inDays > 21) {
      out.add(CareAutopilotSuggestion(
        plantId: plant.id,
        plantNickname: plant.nickname,
        type: 'neglected',
        titleKey: 'autopilotNeglectedTitle',
        bodyKey: 'autopilotNeglectedBody',
        urgency: SuggestionUrgency.high,
        actionType: null,
        metric: lastAny == null
            ? now.difference(plant.createdAt).inDays.toDouble()
            : now.difference(lastAny).inDays.toDouble(),
      ));
    }
  }
}
