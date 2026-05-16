import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_habit_predictor.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/task_instance.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

CareLog _log(int daysAgo, {int hour = 9}) => CareLog(
      id: 'log_$daysAgo', plantId: 'p1', type: TaskType.water,
      timestamp: DateTime(
        _now.year, _now.month, _now.day - daysAgo, hour, 0),
      note: null, linkedPhotoId: null,
    );

TaskInstance _task(int daysAgo, {bool done = true}) => TaskInstance(
      id: 'task_$daysAgo', plantId: 'p1', type: TaskType.water,
      dueAt: _now.subtract(Duration(days: daysAgo)),
      status: done ? TaskStatus.done : TaskStatus.pending,
      createdAt: _now.subtract(Duration(days: daysAgo + 1)),
      completedAt: done ? _now.subtract(Duration(days: daysAgo)) : null,
      adjustmentReasonIds: const [],
    );

void main() {
  group('CareHabitPredictor', () {
    test('returns 7 day predictions', () {
      final result = CareHabitPredictor.predict(
        logs: [], tasks: [], now: _now);
      expect(result.predictions.length, 7);
    });

    test('identifies best and worst days', () {
      final logs = List.generate(30, (i) => _log(i));
      final tasks = List.generate(30, (i) => _task(i, done: i % 3 != 0));
      final result = CareHabitPredictor.predict(
        logs: logs, tasks: tasks, now: _now);
      expect(result.bestDay, greaterThanOrEqualTo(1));
      expect(result.bestDay, lessThanOrEqualTo(7));
      expect(result.worstDay, greaterThanOrEqualTo(1));
      expect(result.worstDay, lessThanOrEqualTo(7));
    });

    test('preferred time slot is valid', () {
      final logs = List.generate(20, (i) => _log(i, hour: 8));
      final result = CareHabitPredictor.predict(
        logs: logs, tasks: [], now: _now);
      expect(result.preferredTimeSlot, 'habitSlotMorning');
    });

    test('miss risk between 0 and 1', () {
      final tasks = List.generate(20, (i) => _task(i, done: i % 2 == 0));
      final result = CareHabitPredictor.predict(
        logs: [], tasks: tasks, now: _now);
      for (final p in result.predictions) {
        expect(p.missRisk, greaterThanOrEqualTo(0.0));
        expect(p.missRisk, lessThanOrEqualTo(1.0));
      }
    });

    test('weekend vs weekday ratio computed', () {
      final logs = List.generate(30, (i) => _log(i));
      final result = CareHabitPredictor.predict(
        logs: logs, tasks: [], now: _now);
      expect(result.weekendVsWeekday, greaterThanOrEqualTo(0));
    });

    test('evening time slot detected', () {
      final logs = List.generate(20, (i) => _log(i, hour: 19));
      final result = CareHabitPredictor.predict(
        logs: logs, tasks: [], now: _now);
      expect(result.preferredTimeSlot, 'habitSlotEvening');
    });
  });
}
