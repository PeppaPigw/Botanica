import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/services/care_plan_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarePlanEngine.seasonalTipKeys', () {
    test('Northern hemisphere March -> spring tips', () {
      final tips = CarePlanEngine.seasonalTipKeys(
        Hemisphere.northern,
        DateTime(2026, 3, 10),
      );
      expect(tips, contains('tipSpringRepot'));
      expect(tips, contains('tipSpringFertilize'));
    });

    test('Southern hemisphere March -> autumn tips', () {
      final tips = CarePlanEngine.seasonalTipKeys(
        Hemisphere.southern,
        DateTime(2026, 3, 10),
      );
      expect(tips, contains('tipAutumnReduceWater'));
      expect(tips, contains('tipAutumnBringIndoor'));
    });

    test('Northern hemisphere December -> winter tips', () {
      final tips = CarePlanEngine.seasonalTipKeys(
        Hemisphere.northern,
        DateTime(2026, 12, 25),
      );
      expect(tips, contains('tipWinterReduceFertilize'));
      expect(tips, contains('tipWinterLowLight'));
    });

    test('Tip keys are non-empty for all seasons and hemispheres', () {
      for (final hemisphere in Hemisphere.values) {
        for (var month = 1; month <= 12; month++) {
          final tips = CarePlanEngine.seasonalTipKeys(
            hemisphere,
            DateTime(2026, month, 1),
          );
          expect(tips, isNotEmpty, reason: '$hemisphere month=$month');
        }
      }
    });
  });
}
