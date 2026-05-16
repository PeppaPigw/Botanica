import '../models/care_log.dart';
import '../models/plant.dart';

class EnvironmentReading {
  const EnvironmentReading({
    required this.date,
    required this.temperatureC,
    required this.humidity,
    this.lightHours,
  });

  final DateTime date;
  final double temperatureC;
  final double humidity;
  final double? lightHours;
}

class EnvironmentCorrelation {
  const EnvironmentCorrelation({
    required this.plantId,
    required this.plantNickname,
    required this.factor,
    required this.correlation,
    required this.insight,
    required this.recommendation,
  });

  final String plantId;
  final String plantNickname;
  final String factor;
  final double correlation;
  final String insight;
  final String recommendation;

  bool get isStrong => correlation.abs() > 0.6;
  bool get isPositive => correlation > 0;
}

class EnvironmentSummary {
  const EnvironmentSummary({
    required this.avgTemperature,
    required this.avgHumidity,
    required this.temperatureRange,
    required this.humidityRange,
    required this.correlations,
    required this.alerts,
  });

  final double avgTemperature;
  final double avgHumidity;
  final ({double min, double max}) temperatureRange;
  final ({double min, double max}) humidityRange;
  final List<EnvironmentCorrelation> correlations;
  final List<String> alerts;
}

class EnvironmentCorrelationEngine {
  const EnvironmentCorrelationEngine._();

  static EnvironmentSummary analyze({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<EnvironmentReading> readings,
    required DateTime now,
  }) {
    if (readings.isEmpty) {
      return const EnvironmentSummary(
        avgTemperature: 0,
        avgHumidity: 0,
        temperatureRange: (min: 0, max: 0),
        humidityRange: (min: 0, max: 0),
        correlations: [],
        alerts: [],
      );
    }

    final temps = readings.map((r) => r.temperatureC).toList();
    final humids = readings.map((r) => r.humidity).toList();

    final avgTemp = temps.reduce((a, b) => a + b) / temps.length;
    final avgHumid = humids.reduce((a, b) => a + b) / humids.length;
    final tempRange = (
      min: temps.reduce((a, b) => a < b ? a : b),
      max: temps.reduce((a, b) => a > b ? a : b),
    );
    final humidRange = (
      min: humids.reduce((a, b) => a < b ? a : b),
      max: humids.reduce((a, b) => a > b ? a : b),
    );

    final correlations = <EnvironmentCorrelation>[];
    for (final plant in plants.where((p) => !p.isArchived)) {
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
      if (plantLogs.length < 5) continue;

      final tempCorr = _correlateWithCareFrequency(plantLogs, readings, now, 'temperature');
      if (tempCorr != null && tempCorr.abs() > 0.3) {
        correlations.add(EnvironmentCorrelation(
          plantId: plant.id,
          plantNickname: plant.nickname,
          factor: 'temperature',
          correlation: tempCorr,
          insight: tempCorr > 0 ? 'envTempIncreasesNeed' : 'envTempDecreasesNeed',
          recommendation: tempCorr > 0
              ? 'envRecommendMoreCareInHeat'
              : 'envRecommendLessCareInCold',
        ));
      }

      final humidCorr = _correlateWithCareFrequency(plantLogs, readings, now, 'humidity');
      if (humidCorr != null && humidCorr.abs() > 0.3) {
        correlations.add(EnvironmentCorrelation(
          plantId: plant.id,
          plantNickname: plant.nickname,
          factor: 'humidity',
          correlation: humidCorr,
          insight: humidCorr > 0 ? 'envHumidityIncreasesNeed' : 'envHumidityDecreasesNeed',
          recommendation: humidCorr < 0
              ? 'envRecommendMistInDryAir'
              : 'envRecommendReduceMisting',
        ));
      }
    }

    final alerts = _generateAlerts(avgTemp, avgHumid, tempRange, humidRange);

    correlations.sort((a, b) => b.correlation.abs().compareTo(a.correlation.abs()));

    return EnvironmentSummary(
      avgTemperature: avgTemp,
      avgHumidity: avgHumid,
      temperatureRange: tempRange,
      humidityRange: humidRange,
      correlations: correlations.take(10).toList(),
      alerts: alerts,
    );
  }

  static double? _correlateWithCareFrequency(
    List<CareLog> logs,
    List<EnvironmentReading> readings,
    DateTime now,
    String factor,
  ) {
    final weeklyBuckets = <int, List<double>>{};
    final weeklyCare = <int, int>{};

    for (final reading in readings) {
      final weekNum = now.difference(reading.date).inDays ~/ 7;
      if (weekNum > 8) continue;
      weeklyBuckets.putIfAbsent(weekNum, () => []);
      final value = factor == 'temperature' ? reading.temperatureC : reading.humidity;
      weeklyBuckets[weekNum]!.add(value);
    }

    for (final log in logs) {
      final weekNum = now.difference(log.timestamp).inDays ~/ 7;
      if (weekNum > 8) continue;
      weeklyCare[weekNum] = (weeklyCare[weekNum] ?? 0) + 1;
    }

    final commonWeeks = weeklyBuckets.keys.where((w) => weeklyCare.containsKey(w)).toList();
    if (commonWeeks.length < 3) return null;

    final envValues = commonWeeks.map((w) =>
        weeklyBuckets[w]!.reduce((a, b) => a + b) / weeklyBuckets[w]!.length).toList();
    final careValues = commonWeeks.map((w) => weeklyCare[w]!.toDouble()).toList();

    return _pearsonCorrelation(envValues, careValues);
  }

  static double _pearsonCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 3) return 0;
    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;

    double sumXY = 0, sumX2 = 0, sumY2 = 0;
    for (int i = 0; i < n; i++) {
      final dx = x[i] - meanX;
      final dy = y[i] - meanY;
      sumXY += dx * dy;
      sumX2 += dx * dx;
      sumY2 += dy * dy;
    }

    final denom = (sumX2 * sumY2);
    if (denom <= 0) return 0;
    return sumXY / (denom > 0 ? _sqrt(denom) : 1);
  }

  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static List<String> _generateAlerts(
      double avgTemp, double avgHumid,
      ({double min, double max}) tempRange,
      ({double min, double max}) humidRange) {
    final alerts = <String>[];
    if (avgTemp > 30) alerts.add('envAlertHighTemp');
    if (avgTemp < 10) alerts.add('envAlertLowTemp');
    if (avgHumid < 30) alerts.add('envAlertLowHumidity');
    if (tempRange.max - tempRange.min > 15) alerts.add('envAlertTempSwings');
    return alerts;
  }
}
