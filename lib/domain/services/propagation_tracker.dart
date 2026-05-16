enum PropagationMethod { cutting, division, layering, seed, offset }

enum PropagationStage { started, rooting, sprouting, established, failed }

class PropagationEntry {
  const PropagationEntry({
    required this.id,
    required this.parentPlantId,
    required this.method,
    required this.stage,
    required this.startedAt,
    required this.notes,
    this.childPlantId,
    this.lastUpdatedAt,
    this.photoIds = const [],
  });

  final String id;
  final String parentPlantId;
  final String? childPlantId;
  final PropagationMethod method;
  final PropagationStage stage;
  final DateTime startedAt;
  final DateTime? lastUpdatedAt;
  final List<String> notes;
  final List<String> photoIds;

  bool get isActive =>
      stage != PropagationStage.established && stage != PropagationStage.failed;

  int daysElapsed(DateTime now) => now.difference(startedAt).inDays;
}

class PropagationStats {
  const PropagationStats({
    required this.totalAttempts,
    required this.successCount,
    required this.failedCount,
    required this.activeCount,
    required this.successRate,
    required this.averageDaysToEstablish,
    required this.bestMethod,
  });

  final int totalAttempts;
  final int successCount;
  final int failedCount;
  final int activeCount;
  final double successRate;
  final int averageDaysToEstablish;
  final PropagationMethod? bestMethod;
}

class PropagationMilestone {
  const PropagationMilestone({
    required this.stage,
    required this.expectedDay,
    required this.description,
  });

  final PropagationStage stage;
  final int expectedDay;
  final String description;
}

class PropagationTracker {
  const PropagationTracker._();

  static PropagationStats computeStats(List<PropagationEntry> entries) {
    if (entries.isEmpty) {
      return const PropagationStats(
        totalAttempts: 0,
        successCount: 0,
        failedCount: 0,
        activeCount: 0,
        successRate: 0,
        averageDaysToEstablish: 0,
        bestMethod: null,
      );
    }

    final successful =
        entries.where((e) => e.stage == PropagationStage.established).toList();
    final failed =
        entries.where((e) => e.stage == PropagationStage.failed).toList();
    final active = entries.where((e) => e.isActive).toList();

    final successRate = entries.isEmpty
        ? 0.0
        : successful.length / (successful.length + failed.length).clamp(1, 999);

    final avgDays = successful.isEmpty
        ? 0
        : successful
                .map((e) => e.lastUpdatedAt?.difference(e.startedAt).inDays ?? 30)
                .reduce((a, b) => a + b) ~/
            successful.length;

    final methodCounts = <PropagationMethod, int>{};
    for (final e in successful) {
      methodCounts[e.method] = (methodCounts[e.method] ?? 0) + 1;
    }
    PropagationMethod? bestMethod;
    int bestCount = 0;
    for (final entry in methodCounts.entries) {
      if (entry.value > bestCount) {
        bestCount = entry.value;
        bestMethod = entry.key;
      }
    }

    return PropagationStats(
      totalAttempts: entries.length,
      successCount: successful.length,
      failedCount: failed.length,
      activeCount: active.length,
      successRate: successRate,
      averageDaysToEstablish: avgDays,
      bestMethod: bestMethod,
    );
  }

  static List<PropagationMilestone> milestonesFor(PropagationMethod method) {
    switch (method) {
      case PropagationMethod.cutting:
        return const [
          PropagationMilestone(
              stage: PropagationStage.rooting,
              expectedDay: 14,
              description: 'propagationRootsExpected'),
          PropagationMilestone(
              stage: PropagationStage.sprouting,
              expectedDay: 28,
              description: 'propagationNewGrowthExpected'),
          PropagationMilestone(
              stage: PropagationStage.established,
              expectedDay: 56,
              description: 'propagationReadyToPot'),
        ];
      case PropagationMethod.division:
        return const [
          PropagationMilestone(
              stage: PropagationStage.rooting,
              expectedDay: 7,
              description: 'propagationSettlingIn'),
          PropagationMilestone(
              stage: PropagationStage.established,
              expectedDay: 21,
              description: 'propagationEstablished'),
        ];
      case PropagationMethod.layering:
        return const [
          PropagationMilestone(
              stage: PropagationStage.rooting,
              expectedDay: 21,
              description: 'propagationRootsForming'),
          PropagationMilestone(
              stage: PropagationStage.established,
              expectedDay: 42,
              description: 'propagationReadyToSeparate'),
        ];
      case PropagationMethod.seed:
        return const [
          PropagationMilestone(
              stage: PropagationStage.sprouting,
              expectedDay: 14,
              description: 'propagationGerminationExpected'),
          PropagationMilestone(
              stage: PropagationStage.rooting,
              expectedDay: 28,
              description: 'propagationSeedlingGrowing'),
          PropagationMilestone(
              stage: PropagationStage.established,
              expectedDay: 60,
              description: 'propagationReadyToTransplant'),
        ];
      case PropagationMethod.offset:
        return const [
          PropagationMilestone(
              stage: PropagationStage.rooting,
              expectedDay: 10,
              description: 'propagationOffsetRooting'),
          PropagationMilestone(
              stage: PropagationStage.established,
              expectedDay: 28,
              description: 'propagationOffsetIndependent'),
        ];
    }
  }

  static PropagationStage? suggestNextStage(
      PropagationEntry entry, DateTime now) {
    final milestones = milestonesFor(entry.method);
    final elapsed = entry.daysElapsed(now);

    for (final milestone in milestones) {
      if (milestone.stage.index > entry.stage.index &&
          elapsed >= milestone.expectedDay) {
        return milestone.stage;
      }
    }
    return null;
  }
}
