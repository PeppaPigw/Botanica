import '../models/enums.dart';
import '../models/task_instance.dart';

enum ScheduleAnchor { fromCompletion, fromDueDate }

Duration durationFromDays(double days) {
  if (days <= 0) {
    throw RangeError.value(days, 'days', 'Must be > 0');
  }
  final seconds = (days * Duration.secondsPerDay).round();
  const maxSeconds = 365 * Duration.secondsPerDay;
  final clampedSeconds =
      seconds < 1 ? 1 : (seconds > maxSeconds ? maxSeconds : seconds);
  return Duration(seconds: clampedSeconds);
}

DateTime computeNextDueAt({
  required DateTime now,
  required Duration interval,
  required ScheduleAnchor anchor,
  DateTime? lastCompletedAt,
  DateTime? previousDueAt,
}) {
  final base = switch (anchor) {
    ScheduleAnchor.fromCompletion => lastCompletedAt ?? now,
    ScheduleAnchor.fromDueDate => previousDueAt ?? lastCompletedAt ?? now,
  };
  return base.add(interval);
}

TaskInstance scheduleTask({
  required String id,
  required String plantId,
  required TaskType type,
  required DateTime dueAt,
  DateTime? createdAt,
  List<String>? adjustmentReasonIds,
}) =>
    TaskInstance(
      id: id,
      plantId: plantId,
      type: type,
      dueAt: dueAt,
      status: TaskStatus.pending,
      createdAt: createdAt ?? DateTime.now(),
      completedAt: null,
      adjustmentReasonIds: adjustmentReasonIds ?? const <String>[],
    );
