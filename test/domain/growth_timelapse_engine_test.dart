import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/growth_timelapse_engine.dart';
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

void main() {
  group('GrowthTimelapseEngine', () {
    test('returns no-photos status with empty list', () {
      final result = GrowthTimelapseEngine.analyze(
        plant: _plant(), photoDates: [], now: _now,
      );
      expect(result.statusKey, 'timelapseNoPhotos');
      expect(result.photoCount, 0);
    });

    test('need-more status with few photos', () {
      final result = GrowthTimelapseEngine.analyze(
        plant: _plant(),
        photoDates: [_now.subtract(const Duration(days: 10)), _now],
        now: _now,
      );
      expect(result.statusKey, 'timelapseNeedMore');
    });

    test('detects milestones from photo gaps', () {
      final dates = [
        _now.subtract(const Duration(days: 90)),
        _now.subtract(const Duration(days: 60)),
        _now.subtract(const Duration(days: 20)),
        _now,
      ];
      final result = GrowthTimelapseEngine.analyze(
        plant: _plant(), photoDates: dates, now: _now,
      );
      expect(result.milestones, isNotEmpty);
      expect(result.spanDays, 90);
    });

    test('computes growth rate', () {
      final dates = List.generate(10, (i) =>
          _now.subtract(Duration(days: (9 - i) * 7)));
      final result = GrowthTimelapseEngine.analyze(
        plant: _plant(), photoDates: dates, now: _now,
      );
      expect(result.growthRate, greaterThan(0));
    });

    test('frequent status with many photos', () {
      final dates = List.generate(20, (i) =>
          _now.subtract(Duration(days: (19 - i) * 3)));
      final result = GrowthTimelapseEngine.analyze(
        plant: _plant(), photoDates: dates, now: _now,
      );
      expect(result.statusKey, 'timelapseFrequent');
    });

    test('caps milestones at 10', () {
      final dates = List.generate(30, (i) =>
          _now.subtract(Duration(days: (29 - i) * 10)));
      final result = GrowthTimelapseEngine.analyze(
        plant: _plant(), photoDates: dates, now: _now,
      );
      expect(result.milestones.length, lessThanOrEqualTo(10));
    });
  });
}
