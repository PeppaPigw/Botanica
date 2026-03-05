import '../models/care_log.dart';
import '../models/task_instance.dart';

class PlantHealthScore {
  const PlantHealthScore._();

  static int compute({
    required List<TaskInstance> allTasks,
    required List<CareLog> recentLogs,
    required DateTime now,
  }) {
    var score = 100;

    final overdueCount = allTasks.where((t) => t.isOverdueAt(now)).length;
    score -= (overdueCount * 10).clamp(0, 50);

    final hasRecentLog = recentLogs.any(
      (l) => now.difference(l.timestamp).inDays <= 14,
    );
    if (!hasRecentLog) score -= 10;

    return score.clamp(0, 100);
  }
}
