import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/environment_snapshot.dart';
import 'package:botanica/domain/services/care_plan_engine.dart';

void main() {
  group('CarePlanEngine.adjustWatering', () {
    test('applies humidity + temperature + winter modifiers', () {
      final env = EnvironmentSnapshot(
        timestamp: DateTime.utc(2026, 1, 15),
        tempC: 29.0,
        humidity: 30,
      );

      final adjustment = const CarePlanEngine().adjustWatering(
        baseDays: 7,
        environment: env,
        environmentMode: EnvironmentMode.indoor,
        now: DateTime.utc(2026, 1, 15),
      );

      expect(adjustment.baseDays, 7);
      expect(adjustment.adjustedDays, 5);
      expect(adjustment.reasons, <CareAdjustmentReason>[
        CareAdjustmentReason.humidityLow,
        CareAdjustmentReason.hotTemperature,
        CareAdjustmentReason.winterSeason,
      ]);
    });

    test('uses hemisphere to detect winter (southern hemisphere)', () {
      final env = EnvironmentSnapshot(
        timestamp: DateTime.utc(2026, 7, 15),
        tempC: 29.0,
        humidity: 30,
      );

      final adjustment = const CarePlanEngine().adjustWatering(
        baseDays: 7,
        environment: env,
        environmentMode: EnvironmentMode.indoor,
        hemisphere: Hemisphere.southern,
        now: DateTime.utc(2026, 7, 15),
      );

      expect(adjustment.adjustedDays, 5);
      expect(adjustment.reasons, <CareAdjustmentReason>[
        CareAdjustmentReason.humidityLow,
        CareAdjustmentReason.hotTemperature,
        CareAdjustmentReason.winterSeason,
      ]);
    });

    test('does not apply winter in the opposite hemisphere', () {
      final env = EnvironmentSnapshot(
        timestamp: DateTime.utc(2026, 1, 15),
        tempC: 29.0,
        humidity: 30,
      );

      final adjustment = const CarePlanEngine().adjustWatering(
        baseDays: 7,
        environment: env,
        environmentMode: EnvironmentMode.indoor,
        hemisphere: Hemisphere.southern,
        now: DateTime.utc(2026, 1, 15),
      );

      expect(adjustment.adjustedDays, 4);
      expect(adjustment.reasons, <CareAdjustmentReason>[
        CareAdjustmentReason.humidityLow,
        CareAdjustmentReason.hotTemperature,
      ]);
    });

    test('adds an outdoor modifier and reason in outdoor mode', () {
      final env = EnvironmentSnapshot(
        timestamp: DateTime.utc(2026, 1, 15),
        tempC: 22.0,
        humidity: 50,
      );

      const engine = CarePlanEngine();
      final indoor = engine.adjustWatering(
        baseDays: 7,
        environment: env,
        environmentMode: EnvironmentMode.indoor,
        now: DateTime.utc(2026, 1, 15),
      );
      final outdoor = engine.adjustWatering(
        baseDays: 7,
        environment: env,
        environmentMode: EnvironmentMode.outdoor,
        now: DateTime.utc(2026, 1, 15),
      );

      expect(outdoor.multiplier, isNot(indoor.multiplier));
      expect(outdoor.adjustedDays, isNot(indoor.adjustedDays));
      expect(outdoor.reasons, contains(CareAdjustmentReason.outdoorMode));
    });

    test('clamps to safety limits for extreme adjustments', () {
      final env = EnvironmentSnapshot(
        timestamp: DateTime.utc(2026, 1, 15),
        tempC: 22.0,
        humidity: 80,
      );

      final adjustment = const CarePlanEngine().adjustWatering(
        baseDays: 60,
        environment: env,
        environmentMode: EnvironmentMode.indoor,
        now: DateTime.utc(2026, 1, 15),
      );

      expect(adjustment.adjustedDays, 60);
      expect(adjustment.reasons, contains(CareAdjustmentReason.humidityHigh));
      expect(adjustment.reasons, contains(CareAdjustmentReason.winterSeason));
    });
  });
}
