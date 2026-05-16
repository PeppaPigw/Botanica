import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/micro_season_detector.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

CareLog _waterLog(int month, int day) => CareLog(
      id: 'log_${month}_$day', plantId: 'p1', type: TaskType.water,
      timestamp: DateTime(2025, month, day),
      note: null, linkedPhotoId: null,
    );

void main() {
  group('MicroSeasonDetector', () {
    test('insufficient data with few logs', () {
      final report = MicroSeasonDetector.detect(
        logs: List.generate(10, (i) => _waterLog(3, i + 1)), now: _now,
      );
      expect(report.dataQuality, 'insufficient');
      expect(report.detectedSeasons, isEmpty);
    });

    test('needs more watering data', () {
      final logs = List.generate(70, (i) => CareLog(
        id: 'log_$i', plantId: 'p1', type: TaskType.fertilize,
        timestamp: _now.subtract(Duration(days: i)),
        note: null, linkedPhotoId: null,
      ));
      final report = MicroSeasonDetector.detect(logs: logs, now: _now);
      expect(report.dataQuality, 'needMoreWatering');
    });

    test('detects seasons with sufficient data', () {
      final logs = <CareLog>[];
      for (int m = 1; m <= 12; m++) {
        final count = m >= 5 && m <= 8 ? 15 : 5;
        for (int d = 0; d < count; d++) {
          logs.add(CareLog(
            id: 'log_${m}_$d', plantId: 'p1', type: TaskType.water,
            timestamp: DateTime(2025, m, (d % 28) + 1),
            note: null, linkedPhotoId: null,
          ));
        }
      }
      final report = MicroSeasonDetector.detect(logs: logs, now: _now);
      expect(report.dataQuality, isNot('insufficient'));
      expect(report.detectedSeasons, isNotEmpty);
    });

    test('data quality reflects log count', () {
      final logs = <CareLog>[];
      for (int i = 0; i < 200; i++) {
        logs.add(CareLog(
          id: 'log_$i', plantId: 'p1', type: TaskType.water,
          timestamp: _now.subtract(Duration(days: i)),
          note: null, linkedPhotoId: null,
        ));
      }
      final report = MicroSeasonDetector.detect(logs: logs, now: _now);
      expect(report.dataQuality, 'good');
    });
  });
}
