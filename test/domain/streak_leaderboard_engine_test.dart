import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/streak_leaderboard_engine.dart';

void main() {
  group('StreakLeaderboardEngine', () {
    test('places user on leaderboard', () {
      final result = StreakLeaderboardEngine.compute(
        userStreakDays: 15, userCareActions: 50,
        userDisplayName: 'TestUser', simulatedParticipants: 20,
      );
      expect(result.entries, isNotEmpty);
      expect(result.entries.any((e) => e.isCurrentUser), isTrue);
      expect(result.userRank, greaterThan(0));
    });

    test('limits display to 10 entries', () {
      final result = StreakLeaderboardEngine.compute(
        userStreakDays: 30, userCareActions: 100,
        userDisplayName: 'Pro', simulatedParticipants: 50,
      );
      expect(result.entries.length, lessThanOrEqualTo(10));
    });

    test('percentile between 0 and 1', () {
      final result = StreakLeaderboardEngine.compute(
        userStreakDays: 7, userCareActions: 20,
        userDisplayName: 'User', simulatedParticipants: 30,
      );
      expect(result.userPercentile, greaterThanOrEqualTo(0.0));
      expect(result.userPercentile, lessThanOrEqualTo(1.0));
    });

    test('high streak gives better rank', () {
      final low = StreakLeaderboardEngine.compute(
        userStreakDays: 1, userCareActions: 5,
        userDisplayName: 'Low', simulatedParticipants: 20,
      );
      final high = StreakLeaderboardEngine.compute(
        userStreakDays: 60, userCareActions: 200,
        userDisplayName: 'High', simulatedParticipants: 20,
      );
      expect(high.userRank, lessThanOrEqualTo(low.userRank));
    });
  });
}
