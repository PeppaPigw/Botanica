class PhotoEntry {
  const PhotoEntry({
    required this.id,
    required this.plantId,
    required this.filePath,
    required this.createdAt,
    required this.note,
    required this.hash,
  });

  final String id;
  final String plantId;
  final String filePath;
  final DateTime createdAt;
  final String? note;
  final String? hash;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'plantId': plantId,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
        'hash': hash,
      };

  static PhotoEntry fromJson(Map<String, dynamic> json) => PhotoEntry(
        id: json['id'] as String,
        plantId: json['plantId'] as String? ?? '',
        filePath: json['filePath'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        note: json['note'] as String?,
        hash: json['hash'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is PhotoEntry &&
      other.id == id &&
      other.plantId == plantId &&
      other.filePath == filePath &&
      other.createdAt == createdAt &&
      other.note == note &&
      other.hash == hash;

  @override
  int get hashCode => Object.hash(id, plantId, filePath, createdAt, note, hash);
}
