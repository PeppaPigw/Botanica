import 'dart:math' as math;

import '../models/care_log.dart';
import '../models/enums.dart';

class CarePrediction {
  const CarePrediction({
    required this.predictedDate,
    required this.confidence,
    required this.basedOnLogs,
    required this.averageInterval,
  });

  final DateTime predictedDate;
  final double confidence;
  final int basedOnLogs;
  final double averageInterval;
}

class CarePredictionEngine {
  const CarePredictionEngine._();

  static CarePrediction? predictNextWatering({
    required String plantId,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final waterLogs = logs
        .where((l) => l.plantId == plantId && l.type == TaskType.water)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (waterLogs.length < 3) return null;

    final intervals = <double>[];
    final recentCount = math.min(waterLogs.length - 1, 10);

    for (int i = 0; i < recentCount; i++) {
      final diff = waterLogs[i].timestamp
          .difference(waterLogs[i + 1].timestamp)
          .inHours / 24.0;
      if (diff > 0 && diff < 60) {
        intervals.add(diff);
      }
    }

    if (intervals.length < 2) return null;

    final weights = List.generate(
      intervals.length,
      (i) => math.pow(0.8, i).toDouble(),
    );
    final totalWeight = weights.fold<double>(0, (s, w) => s + w);

    double weightedSum = 0;
    for (int i = 0; i < intervals.length; i++) {
      weightedSum += intervals[i] * weights[i];
    }
    final weightedAvg = weightedSum / totalWeight;

    final variance = intervals.fold<double>(0, (sum, v) {
          final diff = v - weightedAvg;
          return sum + diff * diff;
        }) /
        intervals.length;
    final stdDev = math.sqrt(variance);

    final confidence = (1.0 - (stdDev / weightedAvg)).clamp(0.2, 0.95);

    final lastWater = waterLogs.first.timestamp;
    final predictedHours = (weightedAvg * 24).round();
    final predictedDate = lastWater.add(Duration(hours: predictedHours));

    return CarePrediction(
      predictedDate: predictedDate,
      confidence: confidence,
      basedOnLogs: intervals.length + 1,
      averageInterval: weightedAvg,
    );
  }

  static String? humanReadablePrediction({
    required CarePrediction prediction,
    required DateTime now,
  }) {
    final daysUntil = prediction.predictedDate.difference(now).inHours / 24.0;

    if (daysUntil < -1) return null;
    if (daysUntil < 0) return 'predictOverdue';
    if (daysUntil < 1) return 'predictToday';
    if (daysUntil < 2) return 'predictTomorrow';
    return 'predictInDays';
  }

  static int daysUntil(CarePrediction prediction, DateTime now) {
    return prediction.predictedDate.difference(now).inDays;
  }
}
