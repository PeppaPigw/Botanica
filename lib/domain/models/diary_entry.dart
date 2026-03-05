class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.plantId,
    required this.createdAt,
    required this.text,
  });

  final String id;
  final String plantId;
  final DateTime createdAt;
  final String text;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'plantId': plantId,
        'createdAt': createdAt.toIso8601String(),
        'text': text,
      };

  static DiaryEntry fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as String,
        plantId: json['plantId'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        text: json['text'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) =>
      other is DiaryEntry &&
      other.id == id &&
      other.plantId == plantId &&
      other.createdAt == createdAt &&
      other.text == text;

  @override
  int get hashCode => Object.hash(id, plantId, createdAt, text);
}
