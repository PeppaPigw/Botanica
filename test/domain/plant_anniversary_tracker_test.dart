import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_anniversary_tracker.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id, {required DateTime createdAt}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: createdAt, meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('PlantAnniversaryTracker', () {
    test('empty report with no plants', () {
      final report = PlantAnniversaryTracker.check(
        plants: [], now: _now, lookAheadDays: 14,
      );
      expect(report.upcoming, isEmpty);
      expect(report.today, isEmpty);
    });

    test('detects today anniversary', () {
      final plant = _plant('p1', createdAt: DateTime(2025, 5, 17));
      final report = PlantAnniversaryTracker.check(
        plants: [plant], now: _now, lookAheadDays: 14,
      );
      expect(report.today, isNotEmpty);
      expect(report.today.first.years, 1);
      expect(report.today.first.milestone, isTrue);
    });

    test('detects upcoming anniversary', () {
      final plant = _plant('p1', createdAt: DateTime(2025, 5, 25));
      final report = PlantAnniversaryTracker.check(
        plants: [plant], now: _now, lookAheadDays: 14,
      );
      expect(report.upcoming.any((a) => a.plantId == 'p1'), isTrue);
    });

    test('calculates oldest plant', () {
      final plants = [
        _plant('p1', createdAt: DateTime(2024, 1, 1)),
        _plant('p2', createdAt: DateTime(2025, 6, 1)),
      ];
      final report = PlantAnniversaryTracker.check(
        plants: plants, now: _now, lookAheadDays: 14,
      );
      expect(report.oldestPlantDays, greaterThan(500));
    });

    test('skips very new plants', () {
      final plant = _plant('p1', createdAt: _now.subtract(const Duration(days: 10)));
      final report = PlantAnniversaryTracker.check(
        plants: [plant], now: _now, lookAheadDays: 14,
      );
      expect(report.upcoming, isEmpty);
      expect(report.today, isEmpty);
    });
  });
}
