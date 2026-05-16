import '../models/care_log.dart';
import '../models/plant.dart';

class PlantStory {
  const PlantStory({
    required this.plantId,
    required this.plantNickname,
    required this.chapters,
    required this.currentChapter,
    required this.totalDays,
  });

  final String plantId;
  final String plantNickname;
  final List<StoryChapter> chapters;
  final int currentChapter;
  final int totalDays;
}

class StoryChapter {
  const StoryChapter({
    required this.index,
    required this.titleKey,
    required this.narrativeKey,
    required this.startDate,
    required this.endDate,
    required this.eventCount,
    required this.mood,
  });

  final int index;
  final String titleKey;
  final String narrativeKey;
  final DateTime startDate;
  final DateTime? endDate;
  final int eventCount;
  final String mood;
}

class PlantStoryEngine {
  const PlantStoryEngine._();

  static PlantStory generate({
    required Plant plant,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final plantLogs = logs.where((l) => l.plantId == plant.id).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final totalDays = now.difference(plant.createdAt).inDays;
    final chapters = _buildChapters(plant, plantLogs, now);

    return PlantStory(
      plantId: plant.id,
      plantNickname: plant.nickname,
      chapters: chapters,
      currentChapter: chapters.length - 1,
      totalDays: totalDays,
    );
  }

  static List<StoryChapter> _buildChapters(
      Plant plant, List<CareLog> logs, DateTime now) {
    final chapters = <StoryChapter>[];
    final totalDays = now.difference(plant.createdAt).inDays;

    // Chapter 1: Arrival
    final arrivalEnd = plant.createdAt.add(const Duration(days: 7));
    final arrivalLogs = logs.where((l) => l.timestamp.isBefore(arrivalEnd)).length;
    chapters.add(StoryChapter(
      index: 0,
      titleKey: 'storyChapterArrival',
      narrativeKey: arrivalLogs > 3 ? 'storyWarmWelcome' : 'storyQuietStart',
      startDate: plant.createdAt,
      endDate: arrivalEnd,
      eventCount: arrivalLogs,
      mood: 'curious',
    ));

    if (totalDays <= 7) return chapters;

    // Chapter 2: Settling In (week 2-4)
    final settleStart = arrivalEnd;
    final settleEnd = plant.createdAt.add(const Duration(days: 30));
    final settleLogs = logs.where((l) =>
        l.timestamp.isAfter(settleStart) && l.timestamp.isBefore(settleEnd)).length;
    final settleMood = settleLogs > 10 ? 'happy' : settleLogs > 3 ? 'content' : 'lonely';
    chapters.add(StoryChapter(
      index: 1,
      titleKey: 'storyChapterSettling',
      narrativeKey: 'storySettling_$settleMood',
      startDate: settleStart,
      endDate: totalDays > 30 ? settleEnd : null,
      eventCount: settleLogs,
      mood: settleMood,
    ));

    if (totalDays <= 30) return chapters;

    // Chapter 3+: Monthly chapters
    int chapterIdx = 2;
    var chapterStart = settleEnd;
    while (chapterStart.isBefore(now)) {
      final chapterEnd = chapterStart.add(const Duration(days: 30));
      final actualEnd = chapterEnd.isAfter(now) ? now : chapterEnd;
      final chapterLogs = logs.where((l) =>
          l.timestamp.isAfter(chapterStart) && l.timestamp.isBefore(actualEnd)).length;

      final mood = _chapterMood(chapterLogs);
      final title = _chapterTitle(chapterIdx, totalDays);

      chapters.add(StoryChapter(
        index: chapterIdx,
        titleKey: title,
        narrativeKey: 'storyMonth_$mood',
        startDate: chapterStart,
        endDate: chapterEnd.isAfter(now) ? null : chapterEnd,
        eventCount: chapterLogs,
        mood: mood,
      ));

      chapterIdx++;
      chapterStart = chapterEnd;
      if (chapters.length >= 15) break;
    }

    return chapters;
  }

  static String _chapterMood(int logCount) {
    if (logCount >= 20) return 'thriving';
    if (logCount >= 10) return 'growing';
    if (logCount >= 5) return 'steady';
    if (logCount >= 1) return 'quiet';
    return 'dormant';
  }

  static String _chapterTitle(int index, int totalDays) {
    if (totalDays > 365 && index > 10) return 'storyChapterVeteran';
    if (index < 5) return 'storyChapterGrowing';
    if (index < 10) return 'storyChapterMature';
    return 'storyChapterEstablished';
  }
}
