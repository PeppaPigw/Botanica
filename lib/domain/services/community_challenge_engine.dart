class CommunityChallenge {
  const CommunityChallenge({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.targetValue,
    required this.currentValue,
    required this.durationDays,
    required this.difficulty,
    required this.rewardKey,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final int targetValue;
  final int currentValue;
  final int durationDays;
  final String difficulty;
  final String rewardKey;

  double get progress => targetValue > 0
      ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isComplete => currentValue >= targetValue;
}

class CommunityChallengeResult {
  const CommunityChallengeResult({
    required this.activeChallenges,
    required this.userContribution,
    required this.completedCount,
  });

  final List<CommunityChallenge> activeChallenges;
  final int userContribution;
  final int completedCount;
}

class CommunityChallengeEngine {
  const CommunityChallengeEngine._();

  static CommunityChallengeResult generate({
    required int weekOfYear,
    required int userCareActionsThisWeek,
    required int userPlantCount,
    required int userStreakDays,
  }) {
    final challenges = _weekChallenges(weekOfYear, userPlantCount);
    final contribution = userCareActionsThisWeek;
    final completed = challenges.where((c) => c.isComplete).length;

    return CommunityChallengeResult(
      activeChallenges: challenges,
      userContribution: contribution,
      completedCount: completed,
    );
  }

  static List<CommunityChallenge> _weekChallenges(int week, int plantCount) {
    final seed = week % 4;
    final challenges = <CommunityChallenge>[];

    switch (seed) {
      case 0:
        challenges.add(CommunityChallenge(
          id: 'cc_water_$week',
          titleKey: 'challengeWaterMarathon',
          descriptionKey: 'challengeWaterMarathonDesc',
          targetValue: 50,
          currentValue: plantCount * 3,
          durationDays: 7,
          difficulty: 'easy',
          rewardKey: 'challengeRewardBadge',
        ));
      case 1:
        challenges.add(CommunityChallenge(
          id: 'cc_streak_$week',
          titleKey: 'challengeStreakWeek',
          descriptionKey: 'challengeStreakWeekDesc',
          targetValue: 7,
          currentValue: 0,
          durationDays: 7,
          difficulty: 'medium',
          rewardKey: 'challengeRewardTitle',
        ));
      case 2:
        challenges.add(CommunityChallenge(
          id: 'cc_variety_$week',
          titleKey: 'challengeCareVariety',
          descriptionKey: 'challengeCareVarietyDesc',
          targetValue: 5,
          currentValue: 0,
          durationDays: 7,
          difficulty: 'medium',
          rewardKey: 'challengeRewardXp',
        ));
      case 3:
        challenges.add(CommunityChallenge(
          id: 'cc_photo_$week',
          titleKey: 'challengePhotoWeek',
          descriptionKey: 'challengePhotoWeekDesc',
          targetValue: 3,
          currentValue: 0,
          durationDays: 7,
          difficulty: 'easy',
          rewardKey: 'challengeRewardFrame',
        ));
    }

    challenges.add(CommunityChallenge(
      id: 'cc_global_$week',
      titleKey: 'challengeGlobalCare',
      descriptionKey: 'challengeGlobalCareDesc',
      targetValue: 1000,
      currentValue: plantCount * 10,
      durationDays: 7,
      difficulty: 'community',
      rewardKey: 'challengeRewardCommunity',
    ));

    return challenges;
  }
}
