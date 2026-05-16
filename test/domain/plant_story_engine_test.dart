import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_story_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant({int daysAgo = 60}) => Plant(
      id: 'p1', nickname: 'Fern', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: _now.subtract(Duration(days: daysAgo)),
      meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(int daysAgo) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('PlantStoryEngine', () {
    test('generates arrival chapter for new plant', () {
      final story = PlantStoryEngine.generate(
        plant: _plant(daysAgo: 3), logs: [_log(1), _log(2)], now: _now,
      );
      expect(story.chapters.length, 1);
      expect(story.chapters.first.titleKey, 'storyChapterArrival');
      expect(story.totalDays, 3);
    });

    test('generates settling chapter after first week', () {
      final story = PlantStoryEngine.generate(
        plant: _plant(daysAgo: 20),
        logs: List.generate(8, (i) => _log(i + 1)),
        now: _now,
      );
      expect(story.chapters.length, 2);
      expect(story.chapters[1].titleKey, 'storyChapterSettling');
    });

    test('generates monthly chapters for older plants', () {
      final story = PlantStoryEngine.generate(
        plant: _plant(daysAgo: 90),
        logs: List.generate(30, (i) => _log(i + 1)),
        now: _now,
      );
      expect(story.chapters.length, greaterThan(2));
      expect(story.currentChapter, story.chapters.length - 1);
    });

    test('warm welcome with many early logs', () {
      final logs = List.generate(5, (i) => _log(i + 1));
      final story = PlantStoryEngine.generate(
        plant: _plant(daysAgo: 5), logs: logs, now: _now,
      );
      expect(story.chapters.first.narrativeKey, 'storyWarmWelcome');
    });

    test('quiet start with few early logs', () {
      final story = PlantStoryEngine.generate(
        plant: _plant(daysAgo: 5), logs: [_log(4)], now: _now,
      );
      expect(story.chapters.first.narrativeKey, 'storyQuietStart');
    });

    test('caps chapters at 15', () {
      final story = PlantStoryEngine.generate(
        plant: _plant(daysAgo: 600),
        logs: List.generate(50, (i) => _log(i * 10)),
        now: _now,
      );
      expect(story.chapters.length, lessThanOrEqualTo(15));
    });
  });
}
