import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/species.dart';
import '../models/task_instance.dart';

enum SkillLevel { beginner, intermediate, advanced, expert }

class SkillProgression {
  const SkillProgression({
    required this.level,
    required this.score,
    required this.nextLevelScore,
    required this.strengths,
    required this.readyForHarder,
    required this.suggestedDifficulty,
  });

  final SkillLevel level;
  final double score;
  final double nextLevelScore;
  final List<String> strengths;
  final bool readyForHarder;
  final int suggestedDifficulty;
}

class CareDifficultyProgression {
  const CareDifficultyProgression._();

  static SkillProgression? evaluate({
    required List<Plant> plants,
    required List<Species> species,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.isEmpty) return null;
    if (logs.length < 10) return null;

    final completedTasks = tasks.where((t) => t.isDone).toList();
    final totalTasks = tasks.where((t) => t.isDone || t.status == TaskStatus.pending).toList();

    final consistencyScore = _consistencyScore(completedTasks, totalTasks);
    final diversityScore = _diversityScore(logs);
    final longevityScore = _longevityScore(activePlants, now);
    final difficultyScore = _currentDifficultyScore(activePlants, species);
    final volumeScore = _volumeScore(activePlants.length);

    final totalScore = (consistencyScore * 0.3 +
            diversityScore * 0.15 +
            longevityScore * 0.25 +
            difficultyScore * 0.2 +
            volumeScore * 0.1)
        .clamp(0.0, 1.0);

    final level = _levelFromScore(totalScore);
    final nextLevelScore = _nextLevelThreshold(level);
    final strengths = _identifyStrengths(
      consistencyScore,
      diversityScore,
      longevityScore,
      difficultyScore,
      volumeScore,
    );

    final maxDifficulty = _maxCurrentDifficulty(activePlants, species);
    final readyForHarder = totalScore >= 0.5 && consistencyScore >= 0.6;
    final suggestedDifficulty = readyForHarder
        ? (maxDifficulty + 1).clamp(1, 5)
        : maxDifficulty.clamp(1, 5);

    return SkillProgression(
      level: level,
      score: totalScore,
      nextLevelScore: nextLevelScore,
      strengths: strengths,
      readyForHarder: readyForHarder,
      suggestedDifficulty: suggestedDifficulty,
    );
  }

  static double _consistencyScore(
      List<TaskInstance> completed, List<TaskInstance> total) {
    if (total.isEmpty) return 0;
    final ratio = completed.length / total.length;

    final onTime = completed.where((t) =>
        t.completedAt != null &&
        t.completedAt!.difference(t.dueAt).inHours <= 24).length;
    final onTimeRatio = completed.isEmpty ? 0.0 : onTime / completed.length;

    return (ratio * 0.5 + onTimeRatio * 0.5).clamp(0.0, 1.0);
  }

  static double _diversityScore(List<CareLog> logs) {
    final types = logs.map((l) => l.type).toSet();
    return (types.length / 6.0).clamp(0.0, 1.0);
  }

  static double _longevityScore(List<Plant> plants, DateTime now) {
    if (plants.isEmpty) return 0;
    final ages = plants.map((p) => now.difference(p.createdAt).inDays).toList();
    final maxAge = ages.reduce((a, b) => a > b ? a : b);
    final avgAge = ages.fold<int>(0, (s, a) => s + a) / ages.length;

    final maxScore = (maxAge / 365.0).clamp(0.0, 1.0);
    final avgScore = (avgAge / 180.0).clamp(0.0, 1.0);
    return (maxScore * 0.6 + avgScore * 0.4).clamp(0.0, 1.0);
  }

  static double _currentDifficultyScore(
      List<Plant> plants, List<Species> species) {
    final difficulties = <int>[];
    for (final plant in plants) {
      final sp = species.where((s) => s.id == plant.speciesId).firstOrNull;
      if (sp != null) {
        final d = int.tryParse(sp.difficulty) ?? 3;
        difficulties.add(d);
      }
    }
    if (difficulties.isEmpty) return 0.3;
    final avg = difficulties.fold<int>(0, (s, d) => s + d) / difficulties.length;
    return (avg / 5.0).clamp(0.0, 1.0);
  }

  static double _volumeScore(int plantCount) {
    if (plantCount >= 15) return 1.0;
    if (plantCount >= 10) return 0.8;
    if (plantCount >= 5) return 0.6;
    if (plantCount >= 3) return 0.4;
    return 0.2;
  }

  static SkillLevel _levelFromScore(double score) {
    if (score >= 0.8) return SkillLevel.expert;
    if (score >= 0.6) return SkillLevel.advanced;
    if (score >= 0.35) return SkillLevel.intermediate;
    return SkillLevel.beginner;
  }

  static double _nextLevelThreshold(SkillLevel level) {
    return switch (level) {
      SkillLevel.beginner => 0.35,
      SkillLevel.intermediate => 0.6,
      SkillLevel.advanced => 0.8,
      SkillLevel.expert => 1.0,
    };
  }

  static List<String> _identifyStrengths(
    double consistency,
    double diversity,
    double longevity,
    double difficulty,
    double volume,
  ) {
    final strengths = <String>[];
    if (consistency >= 0.7) strengths.add('consistent');
    if (diversity >= 0.7) strengths.add('diverse');
    if (longevity >= 0.7) strengths.add('experienced');
    if (difficulty >= 0.6) strengths.add('adventurous');
    if (volume >= 0.8) strengths.add('collector');
    return strengths;
  }

  static int _maxCurrentDifficulty(List<Plant> plants, List<Species> species) {
    int max = 1;
    for (final plant in plants) {
      final sp = species.where((s) => s.id == plant.speciesId).firstOrNull;
      if (sp != null) {
        final d = int.tryParse(sp.difficulty) ?? 3;
        if (d > max) max = d;
      }
    }
    return max;
  }
}
