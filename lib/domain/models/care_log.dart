import 'enums.dart';

class CareLog {
  const CareLog({
    required this.id,
    required this.plantId,
    required this.type,
    required this.timestamp,
    required this.note,
    required this.linkedPhotoId,
  });

  final String id;
  final String plantId;
  final TaskType type;
  final DateTime timestamp;
  final String? note;
  final String? linkedPhotoId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'plantId': plantId,
        'type': type.id,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
        'linkedPhotoId': linkedPhotoId,
      };

  static CareLog fromJson(Map<String, dynamic> json) => CareLog(
        id: json['id'] as String,
        plantId: json['plantId'] as String? ?? '',
        type: TaskType.fromId(json['type'] as String?),
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
        note: json['note'] as String?,
        linkedPhotoId: json['linkedPhotoId'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is CareLog &&
      other.id == id &&
      other.plantId == plantId &&
      other.type == type &&
      other.timestamp == timestamp &&
      other.note == note &&
      other.linkedPhotoId == linkedPhotoId;

  @override
  int get hashCode =>
      Object.hash(id, plantId, type, timestamp, note, linkedPhotoId);
}
