import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/community_challenge_engine.dart';

void main() {
  group('CommunityChallengeEngine', () {
    test('generates challenges for any week', () {
      final result = CommunityChallengeEngine.generate(
        weekOfYear: 20, userCareActionsThisWeek: 10,
        userPlantCount: 5, userStreakDays: 7,
      );
      expect(result.activeChallenges, isNotEmpty);
      expect(result.activeChallenges.length, 2);
    });

    test('always includes global challenge', () {
      for (int w = 0; w < 4; w++) {
        final result = CommunityChallengeEngine.generate(
          weekOfYear: w, userCareActionsThisWeek: 5,
          userPlantCount: 3, userStreakDays: 3,
        );
        final global = result.activeChallenges.where(
          (c) => c.difficulty == 'community');
        expect(global, isNotEmpty);
      }
    });

    test('progress calculation works', () {
      final result = CommunityChallengeEngine.generate(
        weekOfYear: 0, userCareActionsThisWeek: 20,
        userPlantCount: 10, userStreakDays: 5,
      );
      for (final c in result.activeChallenges) {
        expect(c.progress, greaterThanOrEqualTo(0.0));
        expect(c.progress, lessThanOrEqualTo(1.0));
      }
    });

    test('different weeks produce different challenges', () {
      final w0 = CommunityChallengeEngine.generate(
        weekOfYear: 0, userCareActionsThisWeek: 5,
        userPlantCount: 3, userStreakDays: 3,
      );
      final w1 = CommunityChallengeEngine.generate(
        weekOfYear: 1, userCareActionsThisWeek: 5,
        userPlantCount: 3, userStreakDays: 3,
      );
      expect(w0.activeChallenges.first.titleKey,
          isNot(w1.activeChallenges.first.titleKey));
    });

    test('tracks user contribution', () {
      final result = CommunityChallengeEngine.generate(
        weekOfYear: 10, userCareActionsThisWeek: 15,
        userPlantCount: 8, userStreakDays: 10,
      );
      expect(result.userContribution, 15);
    });
  });
}
