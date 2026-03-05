import 'package:botanica/data/local/local_db.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';

Future<void> seedOnePlantWithWaterTaskDueToday({
  required DateTime now,
}) async {
  const plantId = 'p1';
  const taskId = 't1';

  await LocalDb.plantsBox.clear();
  await LocalDb.tasksBox.clear();
  await LocalDb.logsBox.clear();

  final plant = Plant(
    id: plantId,
    nickname: 'Test Plant',
    speciesId: 'unknown',
    room: 'Living room',
    environmentMode: EnvironmentMode.indoor,
    coverAsset: null,
    createdAt: now,
    meta: const PlantMeta(),
  );

  final dueAt = DateTime(now.year, now.month, now.day, 9);

  final task = TaskInstance(
    id: taskId,
    plantId: plantId,
    type: TaskType.water,
    dueAt: dueAt,
    status: TaskStatus.pending,
    createdAt: now,
    completedAt: null,
    adjustmentReasonIds: const <String>[],
  );

  await LocalDb.plantsBox.put(plant.id, plant.toJson());
  await LocalDb.tasksBox.put(task.id, task.toJson());
}
