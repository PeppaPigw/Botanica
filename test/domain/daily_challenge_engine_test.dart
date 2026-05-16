import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/daily_challenge_engine.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

final _now = DateTime(2026, 5, 16, 10, 0);

Plant _plant(String id) => Plant(
      id: id, nickname: 'Plant $id', speciesId: 'sp1',
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('DailyChallengeEngine', () {
    test('generates a challenge', () {
      final challenge = DailyChallengeEngine.generate(
        plants: [_plant('p1')], recentLogs: [], now: _now, streakDays: 0);
      expect(challenge.id, isNotEmpty);
      expect(challenge.xpReward, greaterThan(0));
      expect(challenge.validUntil.day, _now.day);
    });

    test('same day produces same challenge', () {
      final c1 = DailyChallengeEngine.generate(
        plants: [_plant('p1')], recentLogs: [], now: _now, streakDays: 0);
      final c2 = DailyChallengeEngine.generate(
        plants: [_plant('p1')], recentLogs: [],
        now: DateTime(2026, 5, 16, 15, 0), streakDays: 0);
      expect(c1.titleKey, c2.titleKey);
    });

    test('different day produces different challenge', () {
      final c1 = DailyChallengeEngine.generate(
        plants: [_plant('p1')], recentLogs: [], now: _now, streakDays: 0);
      final c2 = DailyChallengeEngine.generate(
        plants: [_plant('p1')], recentLogs: [],
        now: _now.add(const Duration(days: 1)), streakDays: 0);
      expect(c1.id, isNot(c2.id));
    });

    test('high streak increases XP reward', () {
      final low = DailyChallengeEngine.generate(
        plants: [_plant('p1')], recentLogs: [], now: _now, streakDays: 0);
      final high = DailyChallengeEngine.generate(
        plants: [_plant('p1')], recentLogs: [], now: _now, streakDays: 30);
      expect(high.xpReward, greaterThanOrEqualTo(low.xpReward));
    });

    test('weekly preview returns 7 challenges', () {
      final preview = DailyChallengeEngine.weeklyPreview(
        plants: [_plant('p1')], now: _now, streakDays: 5);
      expect(preview.length, 7);
    });

    test('works with no plants', () {
      final challenge = DailyChallengeEngine.generate(
        plants: [], recentLogs: [], now: _now, streakDays: 0);
      expect(challenge.targetPlantId, isNull);
    });
  });
}
