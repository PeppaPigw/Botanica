import '../models/care_log.dart';
import '../models/plant.dart';

class HealthForecastPoint {
  const HealthForecastPoint({
    required this.date,
    required this.predictedHealth,
    required this.confidence,
  });

  final DateTime date;
  final double predictedHealth;
  final double confidence;
}

class PlantHealthForecast {
  const PlantHealthForecast({
    required this.plantId,
    required this.currentHealth,
    required this.forecastPoints,
    required this.trendDirection,
    required this.riskLevel,
    required this.primaryFactor,
  });

  final String plantId;
  final double currentHealth;
  final List<HealthForecastPoint> forecastPoints;
  final String trendDirection;
  final String riskLevel;
  final String primaryFactor;
}

class PlantHealthForecastEngine {
  const PlantHealthForecastEngine._();

  static PlantHealthForecast predict({
    required Plant plant,
    required List<CareLog> logs,
    required double currentHealth,
    required int forecastDays,
    required DateTime now,
  }) {
    final plantLogs = logs.where((l) => l.plantId == plant.id).toList();
    final recentLogs = plantLogs.where(
        (l) => now.difference(l.timestamp).inDays <= 14).toList();
    final olderLogs = plantLogs.where((l) {
      final d = now.difference(l.timestamp).inDays;
      return d > 14 && d <= 28;
    }).toList();

    final careFrequency = recentLogs.isNotEmpty
        ? 14.0 / recentLogs.length
        : 14.0;
    final trend = _computeTrend(recentLogs.length, olderLogs.length);
    final decay = _decayRate(careFrequency);

    final points = <HealthForecastPoint>[];
    var health = currentHealth;

    for (int day = 1; day <= forecastDays; day++) {
      health = (health + trend * 0.01 - decay).clamp(0.0, 1.0);
      final confidence = (1.0 - day / (forecastDays * 2)).clamp(0.3, 0.95);
      points.add(HealthForecastPoint(
        date: now.add(Duration(days: day)),
        predictedHealth: health,
        confidence: confidence,
      ));
    }

    final finalHealth = points.last.predictedHealth;
    final trendDirection = finalHealth > currentHealth + 0.05
        ? 'improving'
        : finalHealth < currentHealth - 0.05
            ? 'declining'
            : 'stable';

    final riskLevel = _riskLevel(finalHealth, trendDirection);
    final primaryFactor = _primaryFactor(careFrequency, trend, currentHealth);

    return PlantHealthForecast(
      plantId: plant.id,
      currentHealth: currentHealth,
      forecastPoints: points,
      trendDirection: trendDirection,
      riskLevel: riskLevel,
      primaryFactor: primaryFactor,
    );
  }

  static double _computeTrend(int recent, int older) {
    if (older == 0) return recent > 0 ? 1.0 : -1.0;
    return (recent - older) / older;
  }

  static double _decayRate(double avgDaysBetweenCare) {
    if (avgDaysBetweenCare <= 3) return 0.005;
    if (avgDaysBetweenCare <= 7) return 0.01;
    if (avgDaysBetweenCare <= 14) return 0.02;
    return 0.04;
  }

  static String _riskLevel(double finalHealth, String trend) {
    if (finalHealth < 0.3) return 'forecastHighRisk';
    if (finalHealth < 0.5 || trend == 'declining') return 'forecastModerateRisk';
    return 'forecastLowRisk';
  }

  static String _primaryFactor(double freq, double trend, double health) {
    if (freq > 10) return 'forecastFactorInfrequentCare';
    if (trend < -0.3) return 'forecastFactorDecliningAttention';
    if (health < 0.4) return 'forecastFactorLowBaseline';
    return 'forecastFactorSteadyCare';
  }
}
