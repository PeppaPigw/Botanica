import 'package:flutter/foundation.dart';

import 'care_schedule_snapshot.dart';
import 'enums.dart';

class TaskInstance {
  const TaskInstance({
    required this.id,
    required this.plantId,
    required this.type,
    required this.dueAt,
    required this.status,
    required this.createdAt,
    required this.completedAt,
    required this.adjustmentReasonIds,
    this.scheduleSnapshot,
  });

  final String id;
  final String plantId;
  final TaskType type;
  final DateTime dueAt;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<String> adjustmentReasonIds;
  final CareScheduleSnapshot? scheduleSnapshot;
  bool get isDone => status == TaskStatus.done;
  bool get isDismissed =>
      status == TaskStatus.done || status == TaskStatus.skipped;

  /// Pure overdue check. Prefer passing `DateTime.now()` from the call site so
  /// behavior stays deterministic in tests.
  bool isOverdueAt(DateTime now) => !isDismissed && dueAt.isBefore(now);

  TaskInstance copyWith({
    DateTime? dueAt,
    TaskStatus? status,
    DateTime? completedAt,
    List<String>? adjustmentReasonIds,
    CareScheduleSnapshot? scheduleSnapshot,
  }) {
    return TaskInstance(
      id: id,
      plantId: plantId,
      type: type,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      adjustmentReasonIds: adjustmentReasonIds ?? this.adjustmentReasonIds,
      scheduleSnapshot: scheduleSnapshot ?? this.scheduleSnapshot,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'plantId': plantId,
        'type': type.id,
        'dueAt': dueAt.toIso8601String(),
        'status': status.id,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'adjustmentReasonIds': adjustmentReasonIds,
        if (scheduleSnapshot != null)
          'scheduleSnapshot': scheduleSnapshot!.toJson(),
      };

  static TaskInstance fromJson(Map<String, dynamic> json) => TaskInstance(
        id: json['id'] as String,
        plantId: json['plantId'] as String? ?? '',
        type: TaskType.fromId(json['type'] as String?),
        dueAt:
            DateTime.tryParse(json['dueAt'] as String? ?? '') ?? DateTime.now(),
        status: TaskStatus.fromId(json['status'] as String?),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.tryParse(json['completedAt'] as String),
        adjustmentReasonIds: (json['adjustmentReasonIds'] as List?)
                ?.map((e) => e.toString())
                .toList(growable: false) ??
            const <String>[],
        scheduleSnapshot: json['scheduleSnapshot'] == null
            ? null
            : CareScheduleSnapshot.fromJson(
                json['scheduleSnapshot'] as Map<String, dynamic>),
      );

  @override
  bool operator ==(Object other) =>
      other is TaskInstance &&
      other.id == id &&
      other.plantId == plantId &&
      other.type == type &&
      other.dueAt == dueAt &&
      other.status == status &&
      other.createdAt == createdAt &&
      other.completedAt == completedAt &&
      listEquals(other.adjustmentReasonIds, adjustmentReasonIds) &&
      other.scheduleSnapshot == scheduleSnapshot;

  @override
  int get hashCode => Object.hash(
        id,
        plantId,
        type,
        dueAt,
        status,
        createdAt,
        completedAt,
        Object.hashAll(adjustmentReasonIds),
        scheduleSnapshot,
      );
}
