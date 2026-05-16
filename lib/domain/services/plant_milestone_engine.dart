import '../models/care_log.dart';
import '../models/plant.dart';

enum MilestoneType {
  firstCare,
  oneWeek,
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  tenthCare,
  fiftiethCare,
  hundredthCare,
}

class PlantMilestone {
  const PlantMilestone({
    required this.type,
    required this.achievedAt,
    required this.plantId,
  });

  final MilestoneType type;
  final DateTime achievedAt;
  final String plantId;
}

class PlantMilestoneEngine {
  const PlantMilestoneEngine._();

  static List<PlantMilestone> computeMilestones({
    required Plant plant,
    required List<CareLog> logs,
    required DateTime now,
  }) {
    final plantLogs = logs
        .where((l) => l.plantId == plant.id)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final milestones = <PlantMilestone>[];

    if (plantLogs.isNotEmpty) {
      milestones.add(PlantMilestone(
        type: MilestoneType.firstCare,
        achievedAt: plantLogs.first.timestamp,
        plantId: plant.id,
      ));
    }

    _addCountMilestone(milestones, plantLogs, 10, MilestoneType.tenthCare);
    _addCountMilestone(milestones, plantLogs, 50, MilestoneType.fiftiethCare);
    _addCountMilestone(milestones, plantLogs, 100, MilestoneType.hundredthCare);

    _addAgeMilestone(milestones, plant, now, 7, MilestoneType.oneWeek);
    _addAgeMilestone(milestones, plant, now, 30, MilestoneType.oneMonth);
    _addAgeMilestone(milestones, plant, now, 90, MilestoneType.threeMonths);
    _addAgeMilestone(milestones, plant, now, 180, MilestoneType.sixMonths);
    _addAgeMilestone(milestones, plant, now, 365, MilestoneType.oneYear);

    milestones.sort((a, b) => a.achievedAt.compareTo(b.achievedAt));
    return milestones;
  }

  static PlantMilestone? latestUnseenMilestone({
    required Plant plant,
    required List<CareLog> logs,
    required DateTime now,
    required Set<MilestoneType> seenMilestones,
  }) {
    final all = computeMilestones(plant: plant, logs: logs, now: now);
    final unseen = all.where((m) => !seenMilestones.contains(m.type)).toList();
    if (unseen.isEmpty) return null;
    return unseen.last;
  }

  static void _addCountMilestone(
    List<PlantMilestone> milestones,
    List<CareLog> logs,
    int count,
    MilestoneType type,
  ) {
    if (logs.length >= count) {
      milestones.add(PlantMilestone(
        type: type,
        achievedAt: logs[count - 1].timestamp,
        plantId: logs.first.plantId,
      ));
    }
  }

  static void _addAgeMilestone(
    List<PlantMilestone> milestones,
    Plant plant,
    DateTime now,
    int days,
    MilestoneType type,
  ) {
    final age = now.difference(plant.createdAt).inDays;
    if (age >= days) {
      milestones.add(PlantMilestone(
        type: type,
        achievedAt: plant.createdAt.add(Duration(days: days)),
        plantId: plant.id,
      ));
    }
  }
}
