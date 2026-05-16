import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_cost_tracker.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/enums.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

Plant _plant() => Plant(
      id: 'p1', nickname: 'Fern', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

CareCostEntry _cost(int daysAgo, double amount, {String category = 'plants'}) =>
    CareCostEntry(
      category: category, amount: amount,
      date: _now.subtract(Duration(days: daysAgo)),
    );

void main() {
  group('CareCostTracker', () {
    test('empty summary with no entries', () {
      final result = CareCostTracker.computeSummary(
        entries: [], activePlants: [_plant()], now: _now);
      expect(result.totalSpent, 0);
      expect(result.costEfficiencyScore, 1.0);
    });

    test('computes total correctly', () {
      final entries = [_cost(10, 25.0), _cost(5, 15.0), _cost(1, 10.0)];
      final result = CareCostTracker.computeSummary(
        entries: entries, activePlants: [_plant()], now: _now);
      expect(result.totalSpent, 50.0);
    });

    test('category breakdown sums correctly', () {
      final entries = [
        _cost(10, 20.0, category: 'soil'),
        _cost(5, 30.0, category: 'pots'),
        _cost(1, 10.0, category: 'soil'),
      ];
      final result = CareCostTracker.computeSummary(
        entries: entries, activePlants: [_plant()], now: _now);
      expect(result.categoryBreakdown['soil'], 30.0);
      expect(result.categoryBreakdown['pots'], 30.0);
    });

    test('monthly trend has 6 entries', () {
      final entries = List.generate(6, (i) => _cost(i * 30, 10.0));
      final result = CareCostTracker.computeSummary(
        entries: entries, activePlants: [_plant()], now: _now);
      expect(result.monthlyTrend.length, 6);
    });

    test('cost per plant divides by active count', () {
      final plants = List.generate(5, (i) => Plant(
            id: 'p$i', nickname: 'P$i', speciesId: 'sp1',
            room: 'Room', environmentMode: EnvironmentMode.indoor,
            coverAsset: null, coverPhotoPath: null,
            createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
          ));
      final entries = [_cost(1, 50.0)];
      final result = CareCostTracker.computeSummary(
        entries: entries, activePlants: plants, now: _now);
      expect(result.costPerPlant, 10.0);
    });

    test('projected annual is 12x monthly average', () {
      final entries = [_cost(15, 100.0)];
      final result = CareCostTracker.computeSummary(
        entries: entries, activePlants: [_plant()], now: _now);
      expect(result.projectedAnnual, closeTo(result.monthlyAverage * 12, 0.01));
    });
  });
}
