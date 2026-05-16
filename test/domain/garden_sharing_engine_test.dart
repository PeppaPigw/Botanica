import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/garden_sharing_engine.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 17, 10, 0);

Plant _plant(String id) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('GardenSharingEngine', () {
    test('generates card with stats', () {
      final card = GardenSharingEngine.generate(
        plants: [_plant('p1'), _plant('p2')],
        streakDays: 14, totalCareActions: 50,
        momentumScore: 0.7, now: _now,
      );
      expect(card.plantCount, 2);
      expect(card.stats, isNotEmpty);
      expect(card.stats.length, 4);
    });

    test('dedicated title for high streak and plants', () {
      final card = GardenSharingEngine.generate(
        plants: List.generate(12, (i) => _plant('p$i')),
        streakDays: 45, totalCareActions: 200,
        momentumScore: 0.9, now: _now,
      );
      expect(card.titleKey, 'shareTitleDedicated');
    });

    test('collector title for many plants', () {
      final card = GardenSharingEngine.generate(
        plants: List.generate(25, (i) => _plant('p$i')),
        streakDays: 5, totalCareActions: 100,
        momentumScore: 0.5, now: _now,
      );
      expect(card.titleKey, 'shareTitleCollector');
    });

    test('badge reflects streak level', () {
      final card = GardenSharingEngine.generate(
        plants: [_plant('p1')],
        streakDays: 100, totalCareActions: 300,
        momentumScore: 0.8, now: _now,
      );
      expect(card.badgeKey, 'shareBadgeVeteran');
    });

    test('calculates garden age', () {
      final card = GardenSharingEngine.generate(
        plants: [_plant('p1')],
        streakDays: 10, totalCareActions: 30,
        momentumScore: 0.6, now: _now,
      );
      expect(card.gardenAge, greaterThan(0));
    });
  });
}
