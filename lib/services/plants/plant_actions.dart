import '../../data/repositories/diary_repository.dart';
import '../../data/repositories/logs_repository.dart';
import '../../data/repositories/photos_repository.dart';
import '../../data/repositories/plants_repository.dart';
import '../../data/repositories/tasks_repository.dart';

class PlantActions {
  const PlantActions._();

  /// Deletes a plant and all local records associated with it.
  ///
  /// This prevents orphaned Hive records (tasks, logs, diary entries, photos)
  /// from accumulating after a plant is removed.
  static Future<void> deletePlantCascade({
    required String plantId,
    required PlantsRepository plantsRepository,
    required TasksRepository tasksRepository,
    required LogsRepository logsRepository,
    required PhotosRepository photosRepository,
    required DiaryRepository diaryRepository,
  }) async {
    await tasksRepository.deleteForPlant(plantId);
    await logsRepository.deleteForPlant(plantId);
    await photosRepository.deleteForPlant(plantId);
    await diaryRepository.deleteForPlant(plantId);
    await plantsRepository.delete(plantId);
  }
}
