import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/services/plant_milestone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Plant makePlant(String id, {required DateTime createdAt, bool archived = false}) => Plant(
        id: id,
        nickname: 'Plant $id',
        speciesId: 'species-1',
        room: 'Living Room',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: createdAt,
        meta: const PlantMeta(),
        isArchived: archived,
      );

  group('PlantMilestoneEngine.todaysMilestone', () {
    test('returns null when plant is too young', () {
      final plant = makePlant('p1', createdAt: DateTime(2025, 5, 1));
      final result = PlantMilestoneEngine.todaysMilestone(plant, now: DateTime(2025, 5, 10));
      expect(result, isNull);
    });

    test('returns oneMonth at exactly 30 days', () {
      final plant = makePlant('p1', createdAt: DateTime(2025, 1, 1));
      final result = PlantMilestoneEngine.todaysMilestone(plant, now: DateTime(2025, 1, 31));
      expect(result, isNotNull);
      expect(result!.type, PlantMilestoneType.oneMonth);
      expect(result.daysOwned, 30);
    });

    test('returns null at 31 days (window is 1 day)', () {
      final plant = makePlant('p1', createdAt: DateTime(2025, 1, 1));
      final result = PlantMilestoneEngine.todaysMilestone(plant, now: DateTime(2025, 2, 1));
      expect(result, isNull);
    });

    test('returns oneYear at 365 days', () {
      final plant = makePlant('p1', createdAt: DateTime(2024, 1, 1));
      final result = PlantMilestoneEngine.todaysMilestone(plant, now: DateTime(2024, 12, 31));
      expect(result, isNotNull);
      expect(result!.type, PlantMilestoneType.oneYear);
    });

    test('returns twoYears at 730 days', () {
      final plant = makePlant('p1', createdAt: DateTime(2023, 5, 1));
      final result = PlantMilestoneEngine.todaysMilestone(plant, now: DateTime(2025, 4, 30));
      expect(result, isNotNull);
      expect(result!.type, PlantMilestoneType.twoYears);
      expect(result.daysOwned, 730);
    });
  });

  group('PlantMilestoneEngine.currentTier', () {
    test('returns null for new plant', () {
      final plant = makePlant('p1', createdAt: DateTime(2025, 5, 1));
      expect(PlantMilestoneEngine.currentTier(plant, now: DateTime(2025, 5, 10)), isNull);
    });

    test('returns oneMonth after 30+ days', () {
      final plant = makePlant('p1', createdAt: DateTime(2025, 1, 1));
      expect(PlantMilestoneEngine.currentTier(plant, now: DateTime(2025, 3, 1)), PlantMilestoneType.oneMonth);
    });

    test('returns sixMonths after 180+ days', () {
      final plant = makePlant('p1', createdAt: DateTime(2024, 1, 1));
      expect(PlantMilestoneEngine.currentTier(plant, now: DateTime(2024, 7, 15)), PlantMilestoneType.sixMonths);
    });
  });

  group('PlantMilestoneEngine.todaysMilestones', () {
    test('excludes archived plants', () {
      final plants = [
        makePlant('p1', createdAt: DateTime(2025, 1, 1), archived: true),
      ];
      final result = PlantMilestoneEngine.todaysMilestones(plants, now: DateTime(2025, 1, 31));
      expect(result, isEmpty);
    });

    test('returns milestones for multiple plants', () {
      final plants = [
        makePlant('p1', createdAt: DateTime(2025, 1, 1)),
        makePlant('p2', createdAt: DateTime(2024, 7, 4)),
      ];
      // p1 is at 30 days, p2 is at 211 days (no milestone window)
      final result = PlantMilestoneEngine.todaysMilestones(plants, now: DateTime(2025, 1, 31));
      expect(result.length, 1);
      expect(result.first.plant.id, 'p1');
    });
  });
}
