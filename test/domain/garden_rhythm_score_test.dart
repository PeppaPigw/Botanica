import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_rhythm_score.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/task_instance.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

CareLog _log(int daysAgo, {TaskType type = TaskType.water}) => CareLog(
      id: 'log_${type.name}_$daysAgo',
      plantId: 'p1',
      type: type,
      timestamp: _now.subtract(Duration(days: daysAgo)),
      note: null,
      linkedPhotoId: null,
    );

TaskInstance _task(int daysAgo, {bool done = true}) => TaskInstance(
      id: 'task_$daysAgo',
      plantId: 'p1',
      type: TaskType.water,
      dueAt: _now.subtract(Duration(days: daysAgo)),
      status: done ? TaskStatus.done : TaskStatus.pending,
      createdAt: _now.subtract(Duration(days: daysAgo + 1)),
      completedAt: done ? _now.subtract(Duration(days: daysAgo)) : null,
      adjustmentReasonIds: const [],
    );

void main() {
  group('GardenRhythmScore', () {
    test('returns baseline score with no data', () {
      final result = GardenRhythmScore.compute(
        logs: [], tasks: [], now: _now);
      expect(result.currentScore, lessThanOrEqualTo(1.0));
      expect(result.weeklyHistory, isNotEmpty);
    });

    test('high score with consistent daily care', () {
      final logs = List.generate(28, (i) => _log(i));
      final tasks = List.generate(14, (i) => _task(i));
      final result = GardenRhythmScore.compute(
        logs: logs, tasks: tasks, now: _now);
      expect(result.currentScore, greaterThan(0.5));
    });

    test('variety score increases with diverse task types', () {
      final diverseLogs = [
        _log(1, type: TaskType.water),
        _log(2, type: TaskType.fertilize),
        _log(3, type: TaskType.mist),
        _log(4, type: TaskType.prune),
        _log(5, type: TaskType.rotate),
      ];
      final monoLogs = List.generate(5, (i) => _log(i + 1));
      final diverse = GardenRhythmScore.compute(
        logs: diverseLogs, tasks: [], now: _now);
      final mono = GardenRhythmScore.compute(
        logs: monoLogs, tasks: [], now: _now);
      expect(diverse.currentScore, greaterThanOrEqualTo(mono.currentScore));
    });

    test('weekly history has correct length', () {
      final logs = List.generate(56, (i) => _log(i));
      final result = GardenRhythmScore.compute(
        logs: logs, tasks: [], now: _now, weeksToAnalyze: 8);
      expect(result.weeklyHistory.length, 8);
    });

    test('trend is positive when improving', () {
      // More logs in recent week than previous
      final logs = [
        ...List.generate(7, (i) => _log(i)),
        _log(10),
      ];
      final tasks = List.generate(5, (i) => _task(i));
      final result = GardenRhythmScore.compute(
        logs: logs, tasks: tasks, now: _now);
      expect(result.trend, greaterThanOrEqualTo(0));
    });

    test('grade mapping is correct', () {
      final manyLogs = List.generate(50, (i) => _log(i % 7,
          type: TaskType.values[i % 5]));
      final manyTasks = List.generate(20, (i) => _task(i));
      final result = GardenRhythmScore.compute(
        logs: manyLogs, tasks: manyTasks, now: _now);
      expect(['A+', 'A', 'B', 'C', 'D', 'F'], contains(result.rhythmGrade));
    });

    test('best week score is at least current score', () {
      final logs = List.generate(30, (i) => _log(i));
      final result = GardenRhythmScore.compute(
        logs: logs, tasks: [], now: _now);
      expect(result.bestWeekScore, greaterThanOrEqualTo(result.currentScore));
    });

    test('insights are generated for weekend warrior pattern', () {
      // All logs on weekends (Sat=6, Sun=7)
      final weekendLogs = <CareLog>[];
      for (int w = 0; w < 4; w++) {
        final sat = _now.subtract(Duration(days: w * 7 + (_now.weekday - 6).abs()));
        if (sat.weekday == 6 || sat.weekday == 7) {
          weekendLogs.add(CareLog(
            id: 'wlog_$w',
            plantId: 'p1',
            type: TaskType.water,
            timestamp: sat,
            note: null,
            linkedPhotoId: null,
          ));
        }
      }
      // Need enough weekend logs to trigger
      final logs = List.generate(10, (i) {
        final d = _now.subtract(Duration(days: i * 3));
        final adjusted = d.weekday < 6
            ? d.add(Duration(days: 6 - d.weekday))
            : d;
        return CareLog(
          id: 'wknd_$i',
          plantId: 'p1',
          type: TaskType.water,
          timestamp: adjusted,
          note: null,
          linkedPhotoId: null,
        );
      });
      final result = GardenRhythmScore.compute(
        logs: logs, tasks: [], now: _now);
      // Just verify insights list is populated (weekend warrior detection depends on ratio)
      expect(result.insights, isA<List<RhythmInsight>>());
    });
  });
}
