import 'enums.dart';
import 'local_time.dart';
import 'plant_meta.dart';

class Plant {
  const Plant({
    required this.id,
    required this.nickname,
    required this.speciesId,
    required this.room,
    required this.environmentMode,
    required this.coverAsset,
    required this.createdAt,
    required this.meta,
    this.coverPhotoPath,
    this.reminderTimeOverride,
    this.isArchived = false,
  });

  final String id;
  final String nickname;
  final String speciesId;
  final String room;
  final EnvironmentMode environmentMode;
  final String? coverAsset;
  final String? coverPhotoPath;
  final DateTime createdAt;
  final PlantMeta meta;
  final LocalTime? reminderTimeOverride;
  final bool isArchived;

  static const Object _unset = Object();

  Plant copyWith({
    String? nickname,
    String? speciesId,
    String? room,
    EnvironmentMode? environmentMode,
    String? coverAsset,
    String? coverPhotoPath,
    PlantMeta? meta,
    Object? reminderTimeOverride = _unset,
    bool? isArchived,
  }) {
    return Plant(
      id: id,
      nickname: nickname ?? this.nickname,
      speciesId: speciesId ?? this.speciesId,
      room: room ?? this.room,
      environmentMode: environmentMode ?? this.environmentMode,
      coverAsset: coverAsset ?? this.coverAsset,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      createdAt: createdAt,
      meta: meta ?? this.meta,
      reminderTimeOverride: identical(reminderTimeOverride, _unset)
          ? this.reminderTimeOverride
          : reminderTimeOverride as LocalTime?,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nickname': nickname,
        'speciesId': speciesId,
        'room': room,
        'environmentMode': environmentMode.id,
        'coverAsset': coverAsset,
        'coverPhotoPath': coverPhotoPath,
        'createdAt': createdAt.toIso8601String(),
        'meta': meta.toJson(),
        if (reminderTimeOverride != null)
          'reminderTimeOverride': _localTimeToJson(reminderTimeOverride!),
        'isArchived': isArchived,
      };

  static Plant fromJson(Map<String, dynamic> json) => Plant(
        id: json['id'] as String,
        nickname: json['nickname'] as String? ?? '',
        speciesId: json['speciesId'] as String? ?? 'unknown',
        room: json['room'] as String? ?? '',
        environmentMode:
            EnvironmentMode.fromId(json['environmentMode'] as String?),
        coverAsset: json['coverAsset'] as String?,
        coverPhotoPath: json['coverPhotoPath'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        meta: json['meta'] == null
            ? const PlantMeta()
            : PlantMeta.fromJson(
                Map<String, dynamic>.from(json['meta'] as Map)),
        reminderTimeOverride: _parseLocalTime(json['reminderTimeOverride']),
        isArchived: json['isArchived'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      other is Plant &&
      other.id == id &&
      other.nickname == nickname &&
      other.speciesId == speciesId &&
      other.room == room &&
      other.environmentMode == environmentMode &&
      other.coverAsset == coverAsset &&
      other.coverPhotoPath == coverPhotoPath &&
      other.createdAt == createdAt &&
      other.meta == meta &&
      other.reminderTimeOverride == reminderTimeOverride &&
      other.isArchived == isArchived;

  @override
  int get hashCode => Object.hash(
        id,
        nickname,
        speciesId,
        room,
        environmentMode,
        coverAsset,
        coverPhotoPath,
        createdAt,
        meta,
        reminderTimeOverride,
        isArchived,
      );
}

Map<String, int> _localTimeToJson(LocalTime value) => <String, int>{
      'hour': value.hour,
      'minute': value.minute,
    };

LocalTime? _parseLocalTime(Object? raw) {
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final hour = (map['hour'] as num?)?.toInt();
    final minute = (map['minute'] as num?)?.toInt();
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return LocalTime(hour: hour, minute: minute);
  }

  if (raw is String) {
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return LocalTime(hour: hour, minute: minute);
  }

  return null;
}
