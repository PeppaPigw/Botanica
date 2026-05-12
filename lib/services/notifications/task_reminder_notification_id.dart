import '../../domain/models/enums.dart';
import '../../domain/models/task_instance.dart';

const String _taskReminderPayloadPrefix = 'botanica.task_reminder:';

int taskReminderNotificationIdForPlantTask({
  required String plantId,
  required TaskType taskType,
}) {
  final hash32 = _fnv1a32('task_reminder:$plantId:${taskType.id}');
  final id31 = hash32 & 0x7fffffff;
  return id31 == 0 ? 1 : id31;
}

int taskReminderNotificationIdForTask(TaskInstance task) {
  return taskReminderNotificationIdForPlantTask(
    plantId: task.plantId,
    taskType: task.type,
  );
}

String taskReminderNotificationPayload(String taskInstanceId) {
  return '$_taskReminderPayloadPrefix$taskInstanceId';
}

String? taskInstanceIdFromTaskReminderPayload(String? payload) {
  if (payload == null) return null;
  if (!payload.startsWith(_taskReminderPayloadPrefix)) return null;
  final id = payload.substring(_taskReminderPayloadPrefix.length);
  return id.isEmpty ? null : id;
}

int _fnv1a32(String input) {
  const int offsetBasis = 0x811c9dc5;
  const int fnvPrime = 0x01000193;

  var hash = offsetBasis;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * fnvPrime) & 0xffffffff;
  }
  return hash;
}
