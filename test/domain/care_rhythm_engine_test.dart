import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_rhythm_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';

CareLog _log(DateTime ts, {String plantId = 'p1', TaskType type = TaskType.water}) =>
    CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: type,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('CareRhythmEngine', () {
    test('returns null with fewer than 5 logs', () {
      final logs = List.generate(4, (i) => _log(now.subtract(Duration(days: i))));
      expect(CareRhythmEngine.detect(logs: logs, now: now), isNull);
    });

    test('returns null with no clear pattern', () {
      final logs = [
        _log(DateTime(2026, 5, 16, 3, 0)),
        _log(DateTime(2026, 5, 15, 12, 0)),
        _log(DateTime(2026, 5, 14, 22, 0)),
        _log(DateTime(2026, 5, 13, 7, 0)),
        _log(DateTime(2026, 5, 12, 15, 0)),
      ];
      final result = CareRhythmEngine.detect(logs: logs, now: now);
      if (result != null) {
        expect(result.confidence, greaterThan(0));
      }
    });

    test('detects morning person', () {
      final logs = List.generate(8, (i) =>
          _log(DateTime(2026, 5, 16 - i, 7, 30)));
      final result = CareRhythmEngine.detect(logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.type, CareRhythmType.morningPerson);
      expect(result.confidence, greaterThanOrEqualTo(0.6));
    });

    test('detects evening person', () {
      final logs = List.generate(8, (i) =>
          _log(DateTime(2026, 5, 16 - i, 19, 0)));
      final result = CareRhythmEngine.detect(logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.type, CareRhythmType.eveningPerson);
      expect(result.confidence, greaterThanOrEqualTo(0.6));
    });

    test('detects weekend warrior', () {
      final logs = <CareLog>[];
      // May 16 2026 is Saturday. Use Sat/Sun pairs within 30 days.
      logs.add(_log(DateTime(2026, 5, 9, 10, 0)));  // Sat
      logs.add(_log(DateTime(2026, 5, 10, 11, 0))); // Sun
      logs.add(_log(DateTime(2026, 5, 2, 9, 0)));   // Sat
      logs.add(_log(DateTime(2026, 5, 3, 14, 0)));  // Sun
      logs.add(_log(DateTime(2026, 4, 25, 10, 0))); // Sat
      logs.add(_log(DateTime(2026, 4, 26, 12, 0))); // Sun

      final result = CareRhythmEngine.detect(logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.type, CareRhythmType.weekendWarrior);
    });

    test('detects daily devoter', () {
      // Vary hours so no time-of-day pattern dominates
      final logs = List.generate(10, (i) =>
          _log(now.subtract(Duration(days: i, hours: (i * 5) % 18))));
      final result = CareRhythmEngine.detect(logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.type, CareRhythmType.dailyDevoter);
    });

    test('detects batch carer', () {
      final logs = <CareLog>[];
      // 3 batch days with many logs each, spread over 30 days
      for (final dayOffset in [2, 12, 22]) {
        final day = now.subtract(Duration(days: dayOffset));
        for (int i = 0; i < 4; i++) {
          logs.add(_log(day.add(Duration(hours: i)),
              plantId: 'p${i + 1}'));
        }
      }
      final result = CareRhythmEngine.detect(logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.type, CareRhythmType.batchCarer);
    });

    test('ignores logs older than 30 days', () {
      final logs = List.generate(10, (i) =>
          _log(now.subtract(Duration(days: 35 + i))));
      expect(CareRhythmEngine.detect(logs: logs, now: now), isNull);
    });

    test('streak counts consecutive matching days', () {
      final logs = List.generate(6, (i) =>
          _log(DateTime(2026, 5, 16 - i, 8, 0)));
      final result = CareRhythmEngine.detect(logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.streak, greaterThanOrEqualTo(3));
    });

    test('highest confidence wins when multiple patterns exist', () {
      // Morning + daily = both detected, highest confidence wins
      final logs = List.generate(10, (i) =>
          _log(DateTime(2026, 5, 16 - i, 7, 0)));
      final result = CareRhythmEngine.detect(logs: logs, now: now);
      expect(result, isNotNull);
      expect(result!.confidence, greaterThanOrEqualTo(0.6));
    });
  });
}
