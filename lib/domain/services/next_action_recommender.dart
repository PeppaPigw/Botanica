import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';
import '../models/user_settings.dart';

enum ActionType {
  waterOverdue,
  waterToday,
  takePhoto,
  checkNewPlant,
  fertilize,
  celebrate,
  explore,
  rest,
}

class RecommendedAction {
  const RecommendedAction({
    required this.type,
    required this.plantId,
    required this.plantNickname,
    required this.messageKey,
    required this.priority,
  });

  final ActionType type;
  final String? plantId;
  final String plantNickname;
  final String messageKey;
  final int priority;
}

class NextActionRecommender {
  const NextActionRecommender._();

  static RecommendedAction recommend({
    required List<Plant> plants,
    required List<TaskInstance> tasks,
    required List<CareLog> logs,
    required UserSettings settings,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();

    if (activePlants.isEmpty) {
      return const RecommendedAction(
        type: ActionType.explore,
        plantId: null,
        plantNickname: '',
        messageKey: 'actionExplore',
        priority: 0,
      );
    }

    final overdueTasks = tasks
        .where((t) =>
            t.status == TaskStatus.pending &&
            t.type == TaskType.water &&
            t.dueAt.isBefore(now))
        .toList();

    if (overdueTasks.isNotEmpty) {
      final task = overdueTasks.first;
      final plant = activePlants
          .where((p) => p.id == task.plantId)
          .fold<Plant?>(null, (_, p) => p);
      return RecommendedAction(
        type: ActionType.waterOverdue,
        plantId: task.plantId,
        plantNickname: plant?.nickname ?? '',
        messageKey: 'actionWaterOverdue',
        priority: 10,
      );
    }

    final todayTasks = tasks
        .where((t) =>
            t.status == TaskStatus.pending &&
            t.type == TaskType.water &&
            _isSameDay(t.dueAt, now))
        .toList();

    if (todayTasks.isNotEmpty) {
      final task = todayTasks.first;
      final plant = activePlants
          .where((p) => p.id == task.plantId)
          .fold<Plant?>(null, (_, p) => p);
      return RecommendedAction(
        type: ActionType.waterToday,
        plantId: task.plantId,
        plantNickname: plant?.nickname ?? '',
        messageKey: 'actionWaterToday',
        priority: 8,
      );
    }

    final newPlants = activePlants
        .where((p) => now.difference(p.createdAt).inDays <= 7)
        .toList();
    if (newPlants.isNotEmpty) {
      final plant = newPlants.first;
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      if (plantLogs.length < 2) {
        return RecommendedAction(
          type: ActionType.checkNewPlant,
          plantId: plant.id,
          plantNickname: plant.nickname,
          messageKey: 'actionCheckNewPlant',
          priority: 6,
        );
      }
    }

    final fertTasks = tasks
        .where((t) =>
            t.status == TaskStatus.pending &&
            t.type == TaskType.fertilize &&
            t.dueAt.isBefore(now.add(const Duration(days: 3))))
        .toList();
    if (fertTasks.isNotEmpty) {
      final task = fertTasks.first;
      final plant = activePlants
          .where((p) => p.id == task.plantId)
          .fold<Plant?>(null, (_, p) => p);
      return RecommendedAction(
        type: ActionType.fertilize,
        plantId: task.plantId,
        plantNickname: plant?.nickname ?? '',
        messageKey: 'actionFertilize',
        priority: 5,
      );
    }

    final plantsWithoutRecentPhoto = activePlants.where((p) {
      final plantLogs = logs.where((l) => l.plantId == p.id).toList();
      final hasRecentPhoto = plantLogs.any(
          (l) => l.linkedPhotoId != null &&
              now.difference(l.timestamp).inDays < 14);
      return !hasRecentPhoto && now.difference(p.createdAt).inDays > 7;
    }).toList();

    if (plantsWithoutRecentPhoto.isNotEmpty) {
      final plant = plantsWithoutRecentPhoto.first;
      return RecommendedAction(
        type: ActionType.takePhoto,
        plantId: plant.id,
        plantNickname: plant.nickname,
        messageKey: 'actionTakePhoto',
        priority: 3,
      );
    }

    if (settings.careStreakDays >= 7 && settings.careStreakDays % 7 == 0) {
      return const RecommendedAction(
        type: ActionType.celebrate,
        plantId: null,
        plantNickname: '',
        messageKey: 'actionCelebrate',
        priority: 2,
      );
    }

    return const RecommendedAction(
      type: ActionType.rest,
      plantId: null,
      plantNickname: '',
      messageKey: 'actionRest',
      priority: 0,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
