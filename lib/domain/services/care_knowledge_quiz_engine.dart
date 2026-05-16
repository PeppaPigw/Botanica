import '../models/plant.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.questionKey,
    required this.category,
    required this.difficulty,
    required this.correctAnswer,
    required this.options,
    required this.relatedPlantId,
  });

  final String questionKey;
  final String category;
  final int difficulty;
  final int correctAnswer;
  final List<String> options;
  final String? relatedPlantId;
}

class QuizResult {
  const QuizResult({
    required this.questions,
    required this.totalQuestions,
    required this.estimatedDifficulty,
    required this.categories,
  });

  final List<QuizQuestion> questions;
  final int totalQuestions;
  final int estimatedDifficulty;
  final List<String> categories;
}

class CareKnowledgeQuizEngine {
  const CareKnowledgeQuizEngine._();

  static QuizResult generate({
    required List<Plant> plants,
    required Map<String, String> speciesLight,
    required Map<String, int> speciesWaterDays,
    required int userLevel,
    required int questionCount,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final questions = <QuizQuestion>[];
    final categories = <String>{};

    final difficulty = _targetDifficulty(userLevel);

    if (activePlants.isNotEmpty) {
      _addWateringQuestions(activePlants, speciesWaterDays, difficulty, questions);
      _addLightQuestions(activePlants, speciesLight, difficulty, questions);
      _addGeneralQuestions(difficulty, questions);
    } else {
      _addGeneralQuestions(difficulty, questions);
    }

    questions.shuffle();
    final selected = questions.take(questionCount).toList();
    for (final q in selected) {
      categories.add(q.category);
    }

    return QuizResult(
      questions: selected,
      totalQuestions: selected.length,
      estimatedDifficulty: difficulty,
      categories: categories.toList(),
    );
  }

  static int _targetDifficulty(int level) {
    if (level >= 20) return 3;
    if (level >= 10) return 2;
    return 1;
  }

  static void _addWateringQuestions(List<Plant> plants,
      Map<String, int> waterDays, int difficulty, List<QuizQuestion> out) {
    for (final plant in plants.take(3)) {
      final days = waterDays[plant.speciesId] ?? 7;
      out.add(QuizQuestion(
        questionKey: 'quizWaterFrequency',
        category: 'watering',
        difficulty: difficulty,
        correctAnswer: 0,
        options: [
          'Every $days days',
          'Every ${days + 3} days',
          'Every ${(days * 2)} days',
          'Daily',
        ],
        relatedPlantId: plant.id,
      ));
    }
  }

  static void _addLightQuestions(List<Plant> plants,
      Map<String, String> speciesLight, int difficulty, List<QuizQuestion> out) {
    for (final plant in plants.take(2)) {
      final light = speciesLight[plant.speciesId] ?? 'medium';
      out.add(QuizQuestion(
        questionKey: 'quizLightNeeds',
        category: 'light',
        difficulty: difficulty,
        correctAnswer: 0,
        options: [light, 'direct', 'low', 'any'],
        relatedPlantId: plant.id,
      ));
    }
  }

  static void _addGeneralQuestions(int difficulty, List<QuizQuestion> out) {
    out.add(const QuizQuestion(
      questionKey: 'quizOverwateringSign',
      category: 'diagnosis',
      difficulty: 1,
      correctAnswer: 0,
      options: ['Yellow leaves', 'Dry soil', 'New growth', 'Tall stems'],
      relatedPlantId: null,
    ));

    if (difficulty >= 2) {
      out.add(const QuizQuestion(
        questionKey: 'quizBestRepotSeason',
        category: 'maintenance',
        difficulty: 2,
        correctAnswer: 0,
        options: ['Spring', 'Winter', 'Summer', 'Autumn'],
        relatedPlantId: null,
      ));
    }

    if (difficulty >= 3) {
      out.add(const QuizQuestion(
        questionKey: 'quizNitrogenDeficiency',
        category: 'nutrition',
        difficulty: 3,
        correctAnswer: 0,
        options: ['Pale lower leaves', 'Brown tips', 'Curling', 'Spots'],
        relatedPlantId: null,
      ));
    }
  }
}
