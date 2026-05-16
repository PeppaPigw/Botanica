import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';

enum PlantPersonality {
  stoic,
  dramatic,
  cheerful,
  wise,
  shy,
}

class PlantVoice {
  const PlantVoice._();

  static PlantPersonality personalityFor(Plant plant) {
    final hash = plant.id.hashCode.abs();
    return PlantPersonality.values[hash % PlantPersonality.values.length];
  }

  static String speak({
    required Plant plant,
    required List<CareLog> recentLogs,
    required List<TaskInstance> pendingTasks,
    required DateTime now,
  }) {
    final personality = personalityFor(plant);
    final plantLogs = recentLogs.where((l) => l.plantId == plant.id).toList();
    final plantTasks = pendingTasks
        .where((t) => t.plantId == plant.id && !t.isDismissed)
        .toList();

    final daysSinceLastCare = plantLogs.isEmpty
        ? 999
        : now.difference(plantLogs
                .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b)
                .timestamp)
            .inDays;

    final isNew = now.difference(plant.createdAt).inDays <= 7;
    final isNeglected = daysSinceLastCare > 14;
    final isThirsty = plantTasks.any((t) =>
        t.type == TaskType.water &&
        t.dueAt.isBefore(now));
    final isHappy = daysSinceLastCare <= 2 && plantTasks.isEmpty;

    if (isNew) return _newPlantLine(personality);
    if (isNeglected) return _neglectedLine(personality);
    if (isThirsty) return _thirstyLine(personality);
    if (isHappy) return _happyLine(personality);
    return _neutralLine(personality);
  }

  static String _newPlantLine(PlantPersonality p) {
    switch (p) {
      case PlantPersonality.stoic:
        return 'Settling in quietly.';
      case PlantPersonality.dramatic:
        return 'New home, new me!';
      case PlantPersonality.cheerful:
        return 'Hi! I like it here already.';
      case PlantPersonality.wise:
        return 'Every journey begins with a single root.';
      case PlantPersonality.shy:
        return 'Still getting used to things...';
    }
  }

  static String _neglectedLine(PlantPersonality p) {
    switch (p) {
      case PlantPersonality.stoic:
        return 'I can wait. But not forever.';
      case PlantPersonality.dramatic:
        return 'Hello?? Is anyone there??';
      case PlantPersonality.cheerful:
        return 'Miss you! Come say hi sometime.';
      case PlantPersonality.wise:
        return 'Patience has its limits, even for plants.';
      case PlantPersonality.shy:
        return 'It\'s okay... I understand you\'re busy.';
    }
  }

  static String _thirstyLine(PlantPersonality p) {
    switch (p) {
      case PlantPersonality.stoic:
        return 'Water would be appreciated.';
      case PlantPersonality.dramatic:
        return 'Parched! Absolutely parched!';
      case PlantPersonality.cheerful:
        return 'A little drink would make my day!';
      case PlantPersonality.wise:
        return 'The roots grow deeper when they seek.';
      case PlantPersonality.shy:
        return 'Um... could I maybe have some water?';
    }
  }

  static String _happyLine(PlantPersonality p) {
    switch (p) {
      case PlantPersonality.stoic:
        return 'All is well.';
      case PlantPersonality.dramatic:
        return 'Living my best life right now!';
      case PlantPersonality.cheerful:
        return 'Feeling great today!';
      case PlantPersonality.wise:
        return 'Contentment is the greatest wealth.';
      case PlantPersonality.shy:
        return 'I feel... really good actually.';
    }
  }

  static String _neutralLine(PlantPersonality p) {
    switch (p) {
      case PlantPersonality.stoic:
        return 'Steady as always.';
      case PlantPersonality.dramatic:
        return 'Just here, being fabulous.';
      case PlantPersonality.cheerful:
        return 'Another good day in the garden!';
      case PlantPersonality.wise:
        return 'Growing takes time and trust.';
      case PlantPersonality.shy:
        return 'Doing okay over here.';
    }
  }
}
