import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/care_pattern_analyzer.dart';
import '../domain/services/plant_health_forecaster.dart';
import '../domain/services/plant_health_timeline.dart';
import '../domain/services/smart_notification_engine.dart';
import 'providers.dart';

final carePatternProvider = Provider<List<CarePattern>>((ref) {
  final plantsAsync = ref.watch(plantsStreamProvider);
  final logsAsync = ref.watch(careLogsStreamProvider);

  final plants = plantsAsync.valueOrNull ?? [];
  final logs = logsAsync.valueOrNull ?? [];

  if (plants.isEmpty || logs.isEmpty) return [];

  return CarePatternAnalyzer.analyze(
    plants: plants,
    logs: logs,
    now: DateTime.now(),
  );
});

final plantForecastProvider =
    Provider.family<PlantHealthForecastResult?, String>((ref, plantId) {
  final plantsAsync = ref.watch(plantsStreamProvider);
  final logsAsync = ref.watch(careLogsStreamProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);

  final plants = plantsAsync.valueOrNull ?? [];
  final logs = logsAsync.valueOrNull ?? [];
  final tasks = tasksAsync.valueOrNull ?? [];

  final plant = plants.where((p) => p.id == plantId).firstOrNull;
  if (plant == null) return null;

  return PlantHealthForecaster.forecast(
    plant: plant,
    logs: logs,
    tasks: tasks,
    now: DateTime.now(),
  );
});

final gardenForecastsProvider =
    Provider<List<PlantHealthForecastResult>>((ref) {
  final plantsAsync = ref.watch(plantsStreamProvider);
  final logsAsync = ref.watch(careLogsStreamProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);

  final plants = plantsAsync.valueOrNull ?? [];
  final logs = logsAsync.valueOrNull ?? [];
  final tasks = tasksAsync.valueOrNull ?? [];

  if (plants.isEmpty) return [];

  return PlantHealthForecaster.forecastAll(
    plants: plants,
    logs: logs,
    tasks: tasks,
    now: DateTime.now(),
  );
});

final plantHealthTimelineProvider =
    Provider.family<HealthTimeline?, String>((ref, plantId) {
  final plantsAsync = ref.watch(plantsStreamProvider);
  final logsAsync = ref.watch(careLogsStreamProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);

  final plants = plantsAsync.valueOrNull ?? [];
  final logs = logsAsync.valueOrNull ?? [];
  final tasks = tasksAsync.valueOrNull ?? [];

  final plant = plants.where((p) => p.id == plantId).firstOrNull;
  if (plant == null) return null;

  return PlantHealthTimeline.generate(
    plant: plant,
    logs: logs,
    tasks: tasks,
    now: DateTime.now(),
  );
});

final smartNotificationsProvider = Provider<List<SmartNotification>>((ref) {
  final plantsAsync = ref.watch(plantsStreamProvider);
  final logsAsync = ref.watch(careLogsStreamProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);
  final settings = ref.watch(settingsControllerProvider);

  final plants = plantsAsync.valueOrNull ?? [];
  final logs = logsAsync.valueOrNull ?? [];
  final tasks = tasksAsync.valueOrNull ?? [];

  if (plants.isEmpty) return [];

  return SmartNotificationEngine.generate(
    plants: plants,
    logs: logs,
    tasks: tasks,
    settings: settings,
    now: DateTime.now(),
  );
});
