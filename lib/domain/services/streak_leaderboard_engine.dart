class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.score,
    required this.streakDays,
    required this.isCurrentUser,
  });

  final int rank;
  final String displayName;
  final int score;
  final int streakDays;
  final bool isCurrentUser;
}

class LeaderboardResult {
  const LeaderboardResult({
    required this.entries,
    required this.userRank,
    required this.userPercentile,
    required this.totalParticipants,
  });

  final List<LeaderboardEntry> entries;
  final int userRank;
  final double userPercentile;
  final int totalParticipants;
}

class StreakLeaderboardEngine {
  const StreakLeaderboardEngine._();

  static LeaderboardResult compute({
    required int userStreakDays,
    required int userCareActions,
    required String userDisplayName,
    required int simulatedParticipants,
  }) {
    final userScore = userStreakDays * 10 + userCareActions;
    final entries = _generateBoard(
      userScore, userDisplayName, userStreakDays, simulatedParticipants,
    );

    final userRank = entries.indexWhere((e) => e.isCurrentUser) + 1;
    final percentile = 1.0 - (userRank / entries.length);

    return LeaderboardResult(
      entries: entries.take(10).toList(),
      userRank: userRank,
      userPercentile: percentile.clamp(0.0, 1.0),
      totalParticipants: entries.length,
    );
  }

  static List<LeaderboardEntry> _generateBoard(
      int userScore, String userName, int userStreak, int participants) {
    final entries = <LeaderboardEntry>[];

    final scores = <int>[];
    for (int i = 0; i < participants; i++) {
      final simScore = ((participants - i) * 15 * 0.8).round();
      scores.add(simScore);
    }
    scores.add(userScore);
    scores.sort((a, b) => b.compareTo(a));

    for (int i = 0; i < scores.length; i++) {
      final isUser = scores[i] == userScore && !entries.any((e) => e.isCurrentUser);
      entries.add(LeaderboardEntry(
        rank: i + 1,
        displayName: isUser ? userName : 'Gardener ${i + 1}',
        score: scores[i],
        streakDays: isUser ? userStreak : (scores[i] / 10).round(),
        isCurrentUser: isUser,
      ));
    }

    return entries;
  }
}
