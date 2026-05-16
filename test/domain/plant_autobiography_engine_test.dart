import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_autobiography_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant({DateTime? createdAt}) => Plant(
      id: 'p1',
      nickname: 'Monstera',
      speciesId: 'sp1',
      room: 'Living Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(DateTime ts, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}_${type.name}',
      plantId: 'p1',
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

PhotoEntry _photo(DateTime ts) => PhotoEntry(
      id: 'photo_${ts.millisecondsSinceEpoch}',
      plantId: 'p1',
      filePath: '/photos/test.jpg',
      createdAt: ts,
      note: null,
      hash: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PlantAutobiographyEngine', () {
    test('always includes arrival chapter', () {
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(),
        logs: [],
        photos: [],
        now: now,
      );
      expect(bio.chapters.first.type, ChapterType.arrival);
      expect(bio.chapters.first.args['room'], 'Living Room');
    });

    test('always includes current state chapter', () {
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(),
        logs: [],
        photos: [],
        now: now,
      );
      expect(bio.chapters.last.type, ChapterType.currentState);
    });

    test('includes first care chapter', () {
      final logs = [_log(DateTime(2025, 1, 5))];
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(),
        logs: logs,
        photos: [],
        now: now,
      );
      final firstCare = bio.chapters
          .where((c) => c.type == ChapterType.firstCare);
      expect(firstCare, isNotEmpty);
    });

    test('detects growth spurts from high-activity months', () {
      final logs = <CareLog>[];
      // Normal months: 3 logs each
      for (int m = 1; m <= 6; m++) {
        for (int d = 0; d < 3; d++) {
          logs.add(_log(DateTime(2025, m, d * 10 + 1)));
        }
      }
      // Spike month: 10 logs
      for (int d = 0; d < 10; d++) {
        logs.add(_log(DateTime(2025, 7, d * 3 + 1)));
      }
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(),
        logs: logs,
        photos: [],
        now: now,
      );
      final spurts = bio.chapters
          .where((c) => c.type == ChapterType.growthSpurt);
      expect(spurts, isNotEmpty);
    });

    test('detects challenges from long care gaps', () {
      final logs = [
        _log(DateTime(2025, 1, 1)),
        _log(DateTime(2025, 1, 5)),
        _log(DateTime(2025, 1, 10)),
        _log(DateTime(2025, 1, 15)),
        _log(DateTime(2025, 2, 15)), // 31-day gap
        _log(DateTime(2025, 2, 20)),
      ];
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(),
        logs: logs,
        photos: [],
        now: now,
      );
      final challenges = bio.chapters
          .where((c) => c.type == ChapterType.challenge);
      expect(challenges, isNotEmpty);
    });

    test('includes time milestones', () {
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(createdAt: DateTime(2024, 1, 1)),
        logs: [],
        photos: [],
        now: now,
      );
      final milestones = bio.chapters
          .where((c) => c.type == ChapterType.milestone);
      expect(milestones.length, greaterThanOrEqualTo(3)); // 30, 90, 365
    });

    test('includes care action milestones', () {
      final logs = List.generate(55, (i) =>
          _log(DateTime(2025, 1, 1).add(Duration(days: i * 3))));
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(),
        logs: logs,
        photos: [],
        now: now,
      );
      final actionMilestones = bio.chapters
          .where((c) =>
              c.type == ChapterType.milestone &&
              c.messageKey == 'bioMilestoneActions');
      expect(actionMilestones.length, 2); // 10 and 50
    });

    test('includes first photo memory', () {
      final photos = [_photo(DateTime(2025, 2, 1))];
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(),
        logs: [],
        photos: photos,
        now: now,
      );
      final photoChapters = bio.chapters
          .where((c) => c.type == ChapterType.photoMemory);
      expect(photoChapters, isNotEmpty);
    });

    test('chapters are sorted chronologically', () {
      final logs = List.generate(15, (i) =>
          _log(DateTime(2025, 1, 1).add(Duration(days: i * 10))));
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(),
        logs: logs,
        photos: [_photo(DateTime(2025, 3, 1))],
        now: now,
      );
      for (int i = 0; i < bio.chapters.length - 1; i++) {
        expect(bio.chapters[i].date.isBefore(bio.chapters[i + 1].date) ||
            bio.chapters[i].date.isAtSameMomentAs(bio.chapters[i + 1].date),
            isTrue);
      }
    });

    test('totalDays and totalCareActions are correct', () {
      final logs = List.generate(8, (i) =>
          _log(now.subtract(Duration(days: i * 5))));
      final bio = PlantAutobiographyEngine.generate(
        plant: _plant(createdAt: DateTime(2025, 1, 1)),
        logs: logs,
        photos: [],
        now: now,
      );
      expect(bio.totalDays, now.difference(DateTime(2025, 1, 1)).inDays);
      expect(bio.totalCareActions, 8);
    });
  });
}
