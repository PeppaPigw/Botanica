import '../models/care_log.dart';
import '../models/enums.dart';
import '../models/plant.dart';

class PlantNeedPrediction {
  const PlantNeedPrediction({
    required this.plantId,
    required this.predictedNeed,
    required this.confidence,
    required this.daysUntil,
    required this.basedOn,
  });

  final String plantId;
  final TaskType predictedNeed;
  final double confidence;
  final int daysUntil;
  final String basedOn;
}

class PredictiveNeedsReport {
  const PredictiveNeedsReport({
    required this.predictions,
    required this.nextUrgent,
    required this.accuracy,
  });

  final List<PlantNeedPrediction> predictions;
  final PlantNeedPrediction? nextUrgent;
  final double accuracy;
}

class PredictiveNeedsEngine {
  const PredictiveNeedsEngine._();

  static PredictiveNeedsReport predict({
    required List<Plant> plants,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final active = plants.where((p) => !p.isArchived).toList();
    final predictions = <PlantNeedPrediction>[];

    for (final plant in active) {
      final plantLogs = logs.where((l) => l.plantId == plant.id).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (plantLogs.length < 3) continue;

      final waterPred = _predictNext(plant.id, TaskType.water, plantLogs, now);
      if (waterPred != null) predictions.add(waterPred);

      final fertPred = _predictNext(plant.id, TaskType.fertilize, plantLogs, now);
      if (fertPred != null) predictions.add(fertPred);
    }

    predictions.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    final urgent = predictions.isNotEmpty ? predictions.first : null;
    final accuracy = _estimateAccuracy(logs.length);

    return PredictiveNeedsReport(
      predictions: predictions.take(10).toList(),
      nextUrgent: urgent,
      accuracy: accuracy,
    );
  }

  static PlantNeedPrediction? _predictNext(
      String plantId, TaskType type, List<CareLog> logs, DateTime now) {
    final typeLogs = logs.where((l) => l.type == type).take(5).toList();
    if (typeLogs.length < 2) return null;

    final intervals = <int>[];
    for (int i = 0; i < typeLogs.length - 1; i++) {
      intervals.add(typeLogs[i].timestamp.difference(typeLogs[i + 1].timestamp).inDays);
    }

    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    final daysSinceLast = now.difference(typeLogs.first.timestamp).inDays;
    final daysUntil = (avgInterval - daysSinceLast).round();

    if (daysUntil > 14) return null;

    final variance = intervals.length > 1
        ? intervals.map((i) => (i - avgInterval).abs()).reduce((a, b) => a + b) / intervals.length
        : avgInterval * 0.3;
    final confidence = (1.0 - variance / avgInterval).clamp(0.3, 0.95);

    return PlantNeedPrediction(
      plantId: plantId,
      predictedNeed: type,
      confidence: confidence,
      daysUntil: daysUntil.clamp(0, 14),
      basedOn: 'predictBasedOnHistory',
    );
  }

  static double _estimateAccuracy(int totalLogs) {
    if (totalLogs >= 100) return 0.85;
    if (totalLogs >= 50) return 0.7;
    if (totalLogs >= 20) return 0.55;
    return 0.4;
  }
}
