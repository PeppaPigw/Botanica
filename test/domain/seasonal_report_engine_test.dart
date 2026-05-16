import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/seasonal_report_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant() => Plant(
      id: 'p1', nickname: 'Fern', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareLog _log(DateTime ts, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}', plantId: 'p1', type: type,
      timestamp: ts, note: null, linkedPhotoId: null,
    );

void main() {
  group('SeasonalReportEngine', () {
    test('generates report for current season', () {
      final logs = List.generate(20, (i) =>
          _log(DateTime(2026, 4, i + 1, 10, 0)));
      final result = SeasonalReportEngine.generate(
        plants: [_plant()], logs: logs,
        currentSeason: 'spring', currentYear: 2026, now: _now);
      expect(result.currentReport.season, 'spring');
      expect(result.currentReport.totalActions, greaterThan(0));
    });

    test('computes grade based on activity', () {
      final logs = List.generate(50, (i) =>
          _log(DateTime(2026, 3, (i % 28) + 1, 10, 0)));
      final result = SeasonalReportEngine.generate(
        plants: [_plant()], logs: logs,
        currentSeason: 'spring', currentYear: 2026, now: _now);
      expect(['A+', 'A', 'B', 'C', 'D'], contains(result.currentReport.grade));
    });

    test('tracks year over year change', () {
      final thisYear = List.generate(30, (i) =>
          _log(DateTime(2026, 4, (i % 28) + 1, 10, 0)));
      final lastYear = List.generate(15, (i) =>
          _log(DateTime(2025, 4, (i % 28) + 1, 10, 0)));
      final result = SeasonalReportEngine.generate(
        plants: [_plant()], logs: [...thisYear, ...lastYear],
        currentSeason: 'spring', currentYear: 2026, now: _now);
      expect(result.yearOverYearChange, isNotNull);
      expect(result.yearOverYearChange!, greaterThan(0));
    });

    test('empty season gets low grade', () {
      final result = SeasonalReportEngine.generate(
        plants: [_plant()], logs: [],
        currentSeason: 'spring', currentYear: 2026, now: _now);
      expect(result.currentReport.grade, 'D');
      expect(result.currentReport.totalActions, 0);
    });

    test('identifies top care type', () {
      final logs = [
        _log(DateTime(2026, 4, 1), type: TaskType.water),
        _log(DateTime(2026, 4, 2), type: TaskType.water),
        _log(DateTime(2026, 4, 3), type: TaskType.fertilize),
      ];
      final result = SeasonalReportEngine.generate(
        plants: [_plant()], logs: logs,
        currentSeason: 'spring', currentYear: 2026, now: _now);
      expect(result.currentReport.topCareType, TaskType.water);
    });
  });
}
