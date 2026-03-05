import 'enums.dart';

class DailyFlowerContent {
  const DailyFlowerContent({
    required this.key,
    required this.name,
    required this.imagePath,
    required this.meaningKeywords,
    required this.symbolism,
    required this.careBasics,
    required this.appreciation,
  });

  final String key;
  final String name;
  final String? imagePath;
  final List<String> meaningKeywords;
  final String symbolism;
  final Map<String, String> careBasics;
  final String appreciation;

  static DailyFlowerContent fromJson(Map<String, dynamic> json) {
    final rawImagePath = (json['imagePath'] as String?)?.trim();
    final imagePath =
        (rawImagePath == null || rawImagePath.isEmpty) ? null : rawImagePath;

    return DailyFlowerContent(
      key: json['key'] as String,
      name: json['name'] as String? ?? '',
      imagePath: imagePath,
      meaningKeywords: (json['meaningKeywords'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const <String>[],
      symbolism: json['symbolism'] as String? ?? '',
      careBasics: (json['careBasics'] as Map?) == null
          ? const <String, String>{}
          : (json['careBasics'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
      appreciation: json['appreciation'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DailyFlowerContent &&
      other.key == key &&
      other.name == name &&
      other.imagePath == imagePath &&
      other.symbolism == symbolism &&
      other.appreciation == appreciation;

  @override
  int get hashCode =>
      Object.hash(key, name, imagePath, symbolism, appreciation);
}

class DailyFlowerEntry {
  const DailyFlowerEntry({
    required this.date,
    required this.localeCode,
    required this.beliefMode,
    required this.content,
  });

  final DateTime date;
  final String localeCode;
  final BeliefMode beliefMode;
  final DailyFlowerContent content;

  @override
  bool operator ==(Object other) =>
      other is DailyFlowerEntry &&
      other.date == date &&
      other.localeCode == localeCode &&
      other.beliefMode == beliefMode &&
      other.content == content;

  @override
  int get hashCode => Object.hash(date, localeCode, beliefMode, content);
}
