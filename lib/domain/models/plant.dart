import 'enums.dart';
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
  });

  final String id;
  final String nickname;
  final String speciesId;
  final String room;
  final EnvironmentMode environmentMode;
  final String? coverAsset;
  final DateTime createdAt;
  final PlantMeta meta;

  Plant copyWith({
    String? nickname,
    String? speciesId,
    String? room,
    EnvironmentMode? environmentMode,
    String? coverAsset,
    PlantMeta? meta,
  }) {
    return Plant(
      id: id,
      nickname: nickname ?? this.nickname,
      speciesId: speciesId ?? this.speciesId,
      room: room ?? this.room,
      environmentMode: environmentMode ?? this.environmentMode,
      coverAsset: coverAsset ?? this.coverAsset,
      createdAt: createdAt,
      meta: meta ?? this.meta,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nickname': nickname,
        'speciesId': speciesId,
        'room': room,
        'environmentMode': environmentMode.id,
        'coverAsset': coverAsset,
        'createdAt': createdAt.toIso8601String(),
        'meta': meta.toJson(),
      };

  static Plant fromJson(Map<String, dynamic> json) => Plant(
        id: json['id'] as String,
        nickname: json['nickname'] as String? ?? '',
        speciesId: json['speciesId'] as String? ?? 'unknown',
        room: json['room'] as String? ?? '',
        environmentMode:
            EnvironmentMode.fromId(json['environmentMode'] as String?),
        coverAsset: json['coverAsset'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        meta: json['meta'] == null
            ? const PlantMeta()
            : PlantMeta.fromJson(
                Map<String, dynamic>.from(json['meta'] as Map)),
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
      other.createdAt == createdAt &&
      other.meta == meta;

  @override
  int get hashCode => Object.hash(
        id,
        nickname,
        speciesId,
        room,
        environmentMode,
        coverAsset,
        createdAt,
        meta,
      );
}
