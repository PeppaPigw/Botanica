import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

enum ChallengeCategory { care, observation, learning, social, creative }

enum ChallengeDifficulty { easy, medium, hard }

class DailyChallenge {
  const DailyChallenge({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    required this.targetPlantId,
    required this.validUntil,
    this.requiredAction,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final ChallengeCategory category;
  final ChallengeDifficulty difficulty;
  final int xpReward;
  final String? targetPlantId;
  final DateTime validUntil;
  final TaskType? requiredAction;
}

class DailyChallengeEngine {
  const DailyChallengeEngine._();

  static const _challenges = [
    _ChallengeTemplate('earlyBird', 'challengeEarlyBird', 'challengeEarlyBirdDesc',
        ChallengeCategory.care, ChallengeDifficulty.easy, 20, TaskType.water),
    _ChallengeTemplate('photoDay', 'challengePhotoDay', 'challengePhotoDayDesc',
        ChallengeCategory.creative, ChallengeDifficulty.easy, 15, null),
    _ChallengeTemplate('fullRotation', 'challengeFullRotation', 'challengeFullRotationDesc',
        ChallengeCategory.care, ChallengeDifficulty.medium, 25, TaskType.rotate),
    _ChallengeTemplate('leafInspector', 'challengeLeafInspector', 'challengeLeafInspectorDesc',
        ChallengeCategory.observation, ChallengeDifficulty.easy, 15, null),
    _ChallengeTemplate('mistMaster', 'challengeMistMaster', 'challengeMistMasterDesc',
        ChallengeCategory.care, ChallengeDifficulty.easy, 20, TaskType.mist),
    _ChallengeTemplate('pruneDay', 'challengePruneDay', 'challengePruneDayDesc',
        ChallengeCategory.care, ChallengeDifficulty.hard, 35, TaskType.prune),
    _ChallengeTemplate('journalEntry', 'challengeJournal', 'challengeJournalDesc',
        ChallengeCategory.creative, ChallengeDifficulty.medium, 25, null),
    _ChallengeTemplate('waterAll', 'challengeWaterAll', 'challengeWaterAllDesc',
        ChallengeCategory.care, ChallengeDifficulty.medium, 30, TaskType.water),
    _ChallengeTemplate('cleanLeaves', 'challengeCleanLeaves', 'challengeCleanLeavesDesc',
        ChallengeCategory.care, ChallengeDifficulty.easy, 20, TaskType.wipeLeaves),
    _ChallengeTemplate('newSpot', 'challengeNewSpot', 'challengeNewSpotDesc',
        ChallengeCategory.observation, ChallengeDifficulty.medium, 25, null),
    _ChallengeTemplate('fertilizeBoost', 'challengeFertilize', 'challengeFertilizeDesc',
        ChallengeCategory.care, ChallengeDifficulty.medium, 30, TaskType.fertilize),
    _ChallengeTemplate('sunBath', 'challengeSunBath', 'challengeSunBathDesc',
        ChallengeCategory.care, ChallengeDifficulty.easy, 15, null),
  ];

  static DailyChallenge generate({
    required List<Plant> plants,
    required List<CareLog> recentLogs,
    required DateTime now,
    required int streakDays,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final index = seed % _challenges.length;

    final template = _challenges[index];
    final targetPlant = activePlants.isNotEmpty
        ? activePlants[seed % activePlants.length]
        : null;

    final difficulty = streakDays >= 30
        ? ChallengeDifficulty.hard
        : streakDays >= 7
            ? ChallengeDifficulty.medium
            : template.difficulty;

    final xpMultiplier = difficulty == ChallengeDifficulty.hard
        ? 1.5
        : difficulty == ChallengeDifficulty.medium
            ? 1.2
            : 1.0;

    return DailyChallenge(
      id: '${template.id}_${now.year}${now.month}${now.day}',
      titleKey: template.titleKey,
      descriptionKey: template.descriptionKey,
      category: template.category,
      difficulty: difficulty,
      xpReward: (template.baseXp * xpMultiplier).round(),
      targetPlantId: targetPlant?.id,
      validUntil: DateTime(now.year, now.month, now.day, 23, 59, 59),
      requiredAction: template.requiredAction,
    );
  }

  static List<DailyChallenge> weeklyPreview({
    required List<Plant> plants,
    required DateTime now,
    required int streakDays,
  }) {
    return List.generate(7, (i) => generate(
      plants: plants,
      recentLogs: const [],
      now: now.add(Duration(days: i)),
      streakDays: streakDays,
    ));
  }
}

class _ChallengeTemplate {
  const _ChallengeTemplate(
    this.id, this.titleKey, this.descriptionKey,
    this.category, this.difficulty, this.baseXp, this.requiredAction,
  );

  final String id;
  final String titleKey;
  final String descriptionKey;
  final ChallengeCategory category;
  final ChallengeDifficulty difficulty;
  final int baseXp;
  final TaskType? requiredAction;
}
