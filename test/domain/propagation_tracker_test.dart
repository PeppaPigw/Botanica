import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/propagation_tracker.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

PropagationEntry _entry({
  PropagationMethod method = PropagationMethod.cutting,
  PropagationStage stage = PropagationStage.started,
  int daysAgo = 0,
  DateTime? lastUpdated,
}) =>
    PropagationEntry(
      id: 'prop_$daysAgo',
      parentPlantId: 'p1',
      method: method,
      stage: stage,
      startedAt: _now.subtract(Duration(days: daysAgo)),
      lastUpdatedAt: lastUpdated,
      notes: const [],
    );

void main() {
  group('PropagationTracker', () {
    test('empty stats with no entries', () {
      final stats = PropagationTracker.computeStats([]);
      expect(stats.totalAttempts, 0);
      expect(stats.successRate, 0);
      expect(stats.bestMethod, isNull);
    });

    test('counts active entries correctly', () {
      final entries = [
        _entry(stage: PropagationStage.started, daysAgo: 5),
        _entry(stage: PropagationStage.rooting, daysAgo: 10),
        _entry(stage: PropagationStage.established, daysAgo: 60),
      ];
      final stats = PropagationTracker.computeStats(entries);
      expect(stats.activeCount, 2);
      expect(stats.successCount, 1);
    });

    test('calculates success rate', () {
      final entries = [
        _entry(stage: PropagationStage.established, daysAgo: 60,
            lastUpdated: _now.subtract(const Duration(days: 30))),
        _entry(stage: PropagationStage.established, daysAgo: 90,
            lastUpdated: _now.subtract(const Duration(days: 50))),
        _entry(stage: PropagationStage.failed, daysAgo: 45),
      ];
      final stats = PropagationTracker.computeStats(entries);
      expect(stats.successCount, 2);
      expect(stats.failedCount, 1);
      expect(stats.successRate, closeTo(0.67, 0.01));
    });

    test('identifies best propagation method', () {
      final entries = [
        _entry(method: PropagationMethod.cutting,
            stage: PropagationStage.established, daysAgo: 60,
            lastUpdated: _now.subtract(const Duration(days: 30))),
        _entry(method: PropagationMethod.cutting,
            stage: PropagationStage.established, daysAgo: 90,
            lastUpdated: _now.subtract(const Duration(days: 50))),
        _entry(method: PropagationMethod.division,
            stage: PropagationStage.established, daysAgo: 30,
            lastUpdated: _now.subtract(const Duration(days: 10))),
      ];
      final stats = PropagationTracker.computeStats(entries);
      expect(stats.bestMethod, PropagationMethod.cutting);
    });

    test('milestones for cutting method', () {
      final milestones = PropagationTracker.milestonesFor(PropagationMethod.cutting);
      expect(milestones.length, 3);
      expect(milestones.first.stage, PropagationStage.rooting);
      expect(milestones.last.stage, PropagationStage.established);
    });

    test('milestones for seed method', () {
      final milestones = PropagationTracker.milestonesFor(PropagationMethod.seed);
      expect(milestones.length, 3);
      expect(milestones.first.expectedDay, 14);
    });

    test('suggests next stage when time has passed', () {
      final entry = _entry(
        method: PropagationMethod.cutting,
        stage: PropagationStage.started,
        daysAgo: 20,
      );
      final suggestion = PropagationTracker.suggestNextStage(entry, _now);
      expect(suggestion, PropagationStage.rooting);
    });

    test('no suggestion when too early', () {
      final entry = _entry(
        method: PropagationMethod.cutting,
        stage: PropagationStage.started,
        daysAgo: 5,
      );
      final suggestion = PropagationTracker.suggestNextStage(entry, _now);
      expect(suggestion, isNull);
    });

    test('days elapsed calculation', () {
      final entry = _entry(daysAgo: 10);
      expect(entry.daysElapsed(_now), 10);
    });

    test('isActive returns false for established', () {
      final entry = _entry(stage: PropagationStage.established);
      expect(entry.isActive, isFalse);
    });
  });
}
