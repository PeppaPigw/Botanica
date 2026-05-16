import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/growth_journal_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant() => Plant(
      id: 'p1',
      nickname: 'My Fern',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(int day, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_${type.name}_$day',
      plantId: 'p1',
      type: type,
      timestamp: DateTime(2026, 5, day, 10, 0),
      note: null,
      linkedPhotoId: null,
    );

PhotoEntry _photo(int day) => PhotoEntry(
      id: 'photo_$day',
      plantId: 'p1',
      filePath: '/photos/p1_$day.jpg',
      createdAt: DateTime(2026, 5, day, 12, 0),
      note: null,
      hash: 'hash$day',
    );

void main() {
  group('GrowthJournalEngine', () {
    test('returns null with no activity in month', () {
      final result = GrowthJournalEngine.generateMonthlySummary(
        plant: _plant(), logs: [], photos: [], month: 5, year: 2026);
      expect(result, isNull);
    });

    test('generates summary with care logs', () {
      final logs = List.generate(10, (i) => _log(i + 1));
      final result = GrowthJournalEngine.generateMonthlySummary(
        plant: _plant(), logs: logs, photos: [], month: 5, year: 2026);
      expect(result, isNotNull);
      expect(result!.totalCareActions, 10);
      expect(result.plantNickname, 'My Fern');
    });

    test('counts photos correctly', () {
      final photos = [_photo(1), _photo(5), _photo(10), _photo(15)];
      final result = GrowthJournalEngine.generateMonthlySummary(
        plant: _plant(), logs: [_log(1)], photos: photos, month: 5, year: 2026);
      expect(result, isNotNull);
      expect(result!.photoCount, 4);
    });

    test('care breakdown tracks task types', () {
      final logs = [
        _log(1, type: TaskType.water),
        _log(2, type: TaskType.water),
        _log(3, type: TaskType.fertilize),
        _log(4, type: TaskType.prune),
      ];
      final result = GrowthJournalEngine.generateMonthlySummary(
        plant: _plant(), logs: logs, photos: [], month: 5, year: 2026);
      expect(result, isNotNull);
      expect(result!.careBreakdown[TaskType.water], 2);
      expect(result.careBreakdown[TaskType.fertilize], 1);
      expect(result.careBreakdown[TaskType.prune], 1);
    });

    test('thriving narrative for high activity', () {
      final logs = List.generate(30, (i) => _log((i % 15) + 1));
      final photos = List.generate(5, (i) => _photo(i + 1));
      final result = GrowthJournalEngine.generateMonthlySummary(
        plant: _plant(), logs: logs, photos: photos, month: 5, year: 2026);
      expect(result, isNotNull);
      expect(result!.narrativeKey, 'journalNarrativeThriving');
    });

    test('quiet narrative for low activity', () {
      final logs = [_log(1), _log(15)];
      final result = GrowthJournalEngine.generateMonthlySummary(
        plant: _plant(), logs: logs, photos: [], month: 5, year: 2026);
      expect(result, isNotNull);
      expect(result!.narrativeKey, 'journalNarrativeQuiet');
    });

    test('year in review generates multiple months', () {
      final logs = <CareLog>[];
      for (int m = 1; m <= 6; m++) {
        for (int d = 1; d <= 5; d++) {
          logs.add(CareLog(
            id: 'log_m${m}_d$d',
            plantId: 'p1',
            type: TaskType.water,
            timestamp: DateTime(2026, m, d, 10, 0),
            note: null,
            linkedPhotoId: null,
          ));
        }
      }
      final result = GrowthJournalEngine.generateYearInReview(
        plant: _plant(), logs: logs, photos: [], year: 2026);
      expect(result.length, 6);
    });

    test('highlights well-documented month', () {
      final photos = List.generate(5, (i) => _photo(i + 1));
      final result = GrowthJournalEngine.generateMonthlySummary(
        plant: _plant(), logs: [_log(1)], photos: photos, month: 5, year: 2026);
      expect(result, isNotNull);
      final docHighlight = result!.highlights.where((h) => h.type == 'wellDocumented');
      expect(docHighlight, isNotEmpty);
    });
  });
}
