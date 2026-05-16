import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';

enum HealthForecast { improving, stable, declining, atRisk }

class PlantHealthForecastResult {
  const PlantHealthForecastResult({
    required this.plantId,
    required this.plantNickname,
    required this.forecast,
    required this.confidence,
    required this.daysUntilChange,
    required this.primaryFactor,
  });

  final String plantId;
  final String plantNickname;
  final HealthForecast forecast;
  final double confidence;
  final int daysUntilChange;
  final String primaryFactor;
}

class PlantHealthForecaster {
  const PlantHealthForecaster._();

  static PlantHealthForecastResult? forecast({
    required Plant plant,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
  }) {
    if (plant.isArchived) return null;

    final plantLogs = logs.where((l) => l.plantId == plant.id).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final plantTasks = tasks.where((t) => t.plantId == plant.id).toList();

    if (plantLogs.length < 5) return null;

    final recentCareFrequency = _recentCareFrequency(plantLogs, now);
    final olderCareFrequency = _olderCareFrequency(plantLogs, now);
    final overdueCount = _overdueTaskCount(plantTasks, now);
    final careGap = _daysSinceLastCare(plantLogs, now);
    final careVariety = _recentCareVariety(plantLogs, now);

    final signals = <_ForecastSignal>[];

    if (recentCareFrequency > olderCareFrequency * 1.3) {
      signals.add(const _ForecastSignal(HealthForecast.improving, 0.3, 'increasedCare'));
    } else if (recentCareFrequency < olderCareFrequency * 0.6) {
      signals.add(const _ForecastSignal(HealthForecast.declining, 0.3, 'decreasedCare'));
    }

    if (overdueCount >= 3) {
      signals.add(const _ForecastSignal(HealthForecast.atRisk, 0.4, 'manyOverdue'));
    } else if (overdueCount >= 1) {
      signals.add(const _ForecastSignal(HealthForecast.declining, 0.2, 'overdueTask'));
    }

    if (careGap > 14) {
      signals.add(const _ForecastSignal(HealthForecast.atRisk, 0.35, 'longGap'));
    } else if (careGap > 7) {
      signals.add(const _ForecastSignal(HealthForecast.declining, 0.2, 'careGap'));
    }

    if (careVariety >= 3) {
      signals.add(const _ForecastSignal(HealthForecast.improving, 0.2, 'diverseCare'));
    }

    if (signals.isEmpty) {
      return PlantHealthForecastResult(
        plantId: plant.id,
        plantNickname: plant.nickname,
        forecast: HealthForecast.stable,
        confidence: 0.6,
        daysUntilChange: 14,
        primaryFactor: 'consistentCare',
      );
    }

    signals.sort((a, b) => b.weight.compareTo(a.weight));
    final primary = signals.first;

    final daysUntilChange = switch (primary.forecast) {
      HealthForecast.atRisk => 3,
      HealthForecast.declining => 7,
      HealthForecast.improving => 14,
      HealthForecast.stable => 14,
    };

    final confidence = signals
        .map((s) => s.weight)
        .reduce((a, b) => a + b)
        .clamp(0.3, 0.95);

    return PlantHealthForecastResult(
      plantId: plant.id,
      plantNickname: plant.nickname,
      forecast: primary.forecast,
      confidence: confidence,
      daysUntilChange: daysUntilChange,
      primaryFactor: primary.factor,
    );
  }

  static List<PlantHealthForecastResult> forecastAll({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required DateTime now,
  }) {
    final results = <PlantHealthForecastResult>[];
    for (final plant in plants.where((p) => !p.isArchived)) {
      final result = forecast(plant: plant, logs: logs, tasks: tasks, now: now);
      if (result != null) results.add(result);
    }
    results.sort((a, b) => a.forecast.index.compareTo(b.forecast.index));
    return results;
  }

  static double _recentCareFrequency(List<CareLog> logs, DateTime now) {
    final recent = logs.where((l) =>
        now.difference(l.timestamp).inDays <= 14).length;
    return recent / 14.0;
  }

  static double _olderCareFrequency(List<CareLog> logs, DateTime now) {
    final older = logs.where((l) =>
        now.difference(l.timestamp).inDays > 14 &&
        now.difference(l.timestamp).inDays <= 28).length;
    return older / 14.0;
  }

  static int _overdueTaskCount(List<TaskInstance> tasks, DateTime now) {
    return tasks.where((t) =>
        t.status == TaskStatus.pending &&
        t.dueAt.isBefore(now)).length;
  }

  static int _daysSinceLastCare(List<CareLog> logs, DateTime now) {
    if (logs.isEmpty) return 999;
    final last = logs.last;
    return now.difference(last.timestamp).inDays;
  }

  static int _recentCareVariety(List<CareLog> logs, DateTime now) {
    return logs
        .where((l) => now.difference(l.timestamp).inDays <= 14)
        .map((l) => l.type)
        .toSet()
        .length;
  }
}

class _ForecastSignal {
  const _ForecastSignal(this.forecast, this.weight, this.factor);
  final HealthForecast forecast;
  final double weight;
  final String factor;
}
