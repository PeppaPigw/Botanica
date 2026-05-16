import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/care_knowledge_quiz_engine.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant(String id, {String speciesId = 'sp1'}) => Plant(
      id: id, nickname: 'Plant $id', speciesId: speciesId,
      room: 'Room', environmentMode: EnvironmentMode.indoor,
      coverAsset: null, coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1), meta: const PlantMeta(), isArchived: false,
    );

void main() {
  group('CareKnowledgeQuizEngine', () {
    test('generates questions for beginner', () {
      final result = CareKnowledgeQuizEngine.generate(
        plants: [_plant('p1')],
        speciesLight: {'sp1': 'medium'},
        speciesWaterDays: {'sp1': 7},
        userLevel: 1, questionCount: 5,
      );
      expect(result.questions, isNotEmpty);
      expect(result.estimatedDifficulty, 1);
    });

    test('harder questions at higher levels', () {
      final result = CareKnowledgeQuizEngine.generate(
        plants: [_plant('p1')],
        speciesLight: {'sp1': 'bright'},
        speciesWaterDays: {'sp1': 5},
        userLevel: 25, questionCount: 5,
      );
      expect(result.estimatedDifficulty, 3);
    });

    test('respects question count limit', () {
      final result = CareKnowledgeQuizEngine.generate(
        plants: List.generate(5, (i) => _plant('p$i')),
        speciesLight: {'sp1': 'medium'},
        speciesWaterDays: {'sp1': 7},
        userLevel: 5, questionCount: 3,
      );
      expect(result.totalQuestions, lessThanOrEqualTo(3));
    });

    test('generates general questions with no plants', () {
      final result = CareKnowledgeQuizEngine.generate(
        plants: [],
        speciesLight: {},
        speciesWaterDays: {},
        userLevel: 5, questionCount: 5,
      );
      expect(result.questions, isNotEmpty);
    });

    test('each question has 4 options', () {
      final result = CareKnowledgeQuizEngine.generate(
        plants: [_plant('p1')],
        speciesLight: {'sp1': 'bright'},
        speciesWaterDays: {'sp1': 3},
        userLevel: 10, questionCount: 5,
      );
      for (final q in result.questions) {
        expect(q.options.length, 4);
      }
    });
  });
}
