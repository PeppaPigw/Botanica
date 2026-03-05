import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/environment_snapshot.dart';
import 'package:botanica/domain/services/dryness_index.dart';

void main() {
  group('EnvironmentSnapshot', () {
    test('toJson/fromJson round-trip', () {
      final snapshot = EnvironmentSnapshot(
        timestamp: DateTime.utc(2026, 2, 20, 12),
        tempC: 22.5,
        humidity: 55,
        weatherCode: 3,
      );

      final restored = EnvironmentSnapshot.fromJson(
          Map<String, dynamic>.from(snapshot.toJson()));
      expect(restored.timestamp, snapshot.timestamp);
      expect(restored.tempC, snapshot.tempC);
      expect(restored.humidity, snapshot.humidity);
      expect(restored.weatherCode, snapshot.weatherCode);
    });
  });

  group('DrynessIndex', () {
    test('stays within 0..1 and hits expected extremes', () {
      expect(DrynessIndex.compute(tempC: 10, humidityPercent: 100), 0);
      expect(DrynessIndex.compute(tempC: 35, humidityPercent: 0), 1);
    });
  });
}
