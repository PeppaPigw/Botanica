import '../models/care_log.dart';
import '../models/photo_entry.dart';
import '../models/plant.dart';

enum ChapterType {
  arrival,
  firstCare,
  growthSpurt,
  challenge,
  milestone,
  photoMemory,
  seasonChange,
  currentState,
}

class LifeChapter {
  const LifeChapter({
    required this.type,
    required this.date,
    required this.messageKey,
    required this.args,
  });

  final ChapterType type;
  final DateTime date;
  final String messageKey;
  final Map<String, String> args;
}

class PlantAutobiography {
  const PlantAutobiography({
    required this.plantId,
    required this.plantNickname,
    required this.chapters,
    required this.totalDays,
    required this.totalCareActions,
  });

  final String plantId;
  final String plantNickname;
  final List<LifeChapter> chapters;
  final int totalDays;
  final int totalCareActions;
}

class PlantAutobiographyEngine {
  const PlantAutobiographyEngine._();

  static PlantAutobiography generate({
    required Plant plant,
    required List<CareLog> logs,
    required List<PhotoEntry> photos,
    required DateTime now,
  }) {
    final plantLogs = logs.where((l) => l.plantId == plant.id).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final plantPhotos = photos.where((p) => p.plantId == plant.id).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final chapters = <LifeChapter>[];

    chapters.add(LifeChapter(
      type: ChapterType.arrival,
      date: plant.createdAt,
      messageKey: 'bioArrival',
      args: {'name': plant.nickname, 'room': plant.room},
    ));

    if (plantLogs.isNotEmpty) {
      chapters.add(LifeChapter(
        type: ChapterType.firstCare,
        date: plantLogs.first.timestamp,
        messageKey: 'bioFirstCare',
        args: {'type': plantLogs.first.type.name},
      ));
    }

    _addGrowthSpurts(chapters, plantLogs, now);
    _addChallenges(chapters, plantLogs, now);
    _addMilestones(chapters, plantLogs, plant.createdAt, now);
    _addPhotoMemories(chapters, plantPhotos);

    chapters.add(LifeChapter(
      type: ChapterType.currentState,
      date: now,
      messageKey: 'bioCurrentState',
      args: {
        'days': now.difference(plant.createdAt).inDays.toString(),
        'actions': plantLogs.length.toString(),
      },
    ));

    chapters.sort((a, b) => a.date.compareTo(b.date));

    return PlantAutobiography(
      plantId: plant.id,
      plantNickname: plant.nickname,
      chapters: chapters,
      totalDays: now.difference(plant.createdAt).inDays,
      totalCareActions: plantLogs.length,
    );
  }

  static void _addGrowthSpurts(
      List<LifeChapter> chapters, List<CareLog> logs, DateTime now) {
    if (logs.length < 10) return;

    final monthCounts = <int, int>{};
    for (final log in logs) {
      final key = log.timestamp.year * 12 + log.timestamp.month;
      monthCounts[key] = (monthCounts[key] ?? 0) + 1;
    }

    if (monthCounts.isEmpty) return;
    final avgPerMonth =
        monthCounts.values.reduce((a, b) => a + b) / monthCounts.length;

    for (final entry in monthCounts.entries) {
      if (entry.value > avgPerMonth * 1.8) {
        final year = entry.key ~/ 12;
        final month = entry.key % 12;
        chapters.add(LifeChapter(
          type: ChapterType.growthSpurt,
          date: DateTime(year, month, 15),
          messageKey: 'bioGrowthSpurt',
          args: {'count': entry.value.toString()},
        ));
      }
    }
  }

  static void _addChallenges(
      List<LifeChapter> chapters, List<CareLog> logs, DateTime now) {
    if (logs.length < 5) return;

    for (int i = 1; i < logs.length; i++) {
      final gap = logs[i].timestamp.difference(logs[i - 1].timestamp).inDays;
      if (gap > 21) {
        chapters.add(LifeChapter(
          type: ChapterType.challenge,
          date: logs[i - 1].timestamp.add(Duration(days: gap ~/ 2)),
          messageKey: 'bioChallenge',
          args: {'days': gap.toString()},
        ));
      }
    }
  }

  static void _addMilestones(List<LifeChapter> chapters, List<CareLog> logs,
      DateTime createdAt, DateTime now) {
    final totalDays = now.difference(createdAt).inDays;

    if (totalDays >= 30) {
      chapters.add(LifeChapter(
        type: ChapterType.milestone,
        date: createdAt.add(const Duration(days: 30)),
        messageKey: 'bioMilestone30',
        args: {},
      ));
    }
    if (totalDays >= 90) {
      chapters.add(LifeChapter(
        type: ChapterType.milestone,
        date: createdAt.add(const Duration(days: 90)),
        messageKey: 'bioMilestone90',
        args: {},
      ));
    }
    if (totalDays >= 365) {
      chapters.add(LifeChapter(
        type: ChapterType.milestone,
        date: createdAt.add(const Duration(days: 365)),
        messageKey: 'bioMilestone365',
        args: {},
      ));
    }

    final milestoneActions = [10, 50, 100];
    for (final m in milestoneActions) {
      if (logs.length >= m) {
        chapters.add(LifeChapter(
          type: ChapterType.milestone,
          date: logs[m - 1].timestamp,
          messageKey: 'bioMilestoneActions',
          args: {'count': m.toString()},
        ));
      }
    }
  }

  static void _addPhotoMemories(
      List<LifeChapter> chapters, List<PhotoEntry> photos) {
    if (photos.isEmpty) return;

    chapters.add(LifeChapter(
      type: ChapterType.photoMemory,
      date: photos.first.createdAt,
      messageKey: 'bioFirstPhoto',
      args: {},
    ));

    if (photos.length >= 10) {
      chapters.add(LifeChapter(
        type: ChapterType.photoMemory,
        date: photos[9].createdAt,
        messageKey: 'bioTenthPhoto',
        args: {},
      ));
    }
  }
}
