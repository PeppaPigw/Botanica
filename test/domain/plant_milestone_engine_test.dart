import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/plant_milestone_engine.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant({String id = 'p1', DateTime? createdAt}) => Plant(
      id: id,
      nickname: 'Monstera',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: false,
    );

CareLog _log(DateTime ts, {String plantId = 'p1'}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      timestamp: ts,
      note: null,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PlantMilestoneEngine', () {
    test('returns empty for plant with no logs', () {
      final plant = _plant(createdAt: now);
      final milestones = PlantMilestoneEngine.computeMilestones(
        plant: plant, logs: [], now: now);
      expect(milestones.where((m) => m.type == MilestoneType.firstCare), isEmpty);
    });

    test('includes firstCare milestone', () {
      final plant = _plant();
      final logs = [_log(DateTime(2025, 1, 5))];
      final milestones = PlantMilestoneEngine.computeMilestones(
        plant: plant, logs: logs, now: now);
      expect(milestones.any((m) => m.type == MilestoneType.firstCare), isTrue);
      expect(
        milestones.firstWhere((m) => m.type == MilestoneType.firstCare).achievedAt,
        DateTime(2025, 1, 5),
      );
    });

    test('includes age milestones based on createdAt', () {
      final plant = _plant(createdAt: DateTime(2025, 1, 1));
      final milestones = PlantMilestoneEngine.computeMilestones(
        plant: plant, logs: [], now: now);

      expect(milestones.any((m) => m.type == MilestoneType.oneWeek), isTrue);
      expect(milestones.any((m) => m.type == MilestoneType.oneMonth), isTrue);
      expect(milestones.any((m) => m.type == MilestoneType.threeMonths), isTrue);
      expect(milestones.any((m) => m.type == MilestoneType.sixMonths), isTrue);
      expect(milestones.any((m) => m.type == MilestoneType.oneYear), isTrue);
    });

    test('does not include future age milestones', () {
      final plant = _plant(createdAt: now.subtract(const Duration(days: 10)));
      final milestones = PlantMilestoneEngine.computeMilestones(
        plant: plant, logs: [], now: now);

      expect(milestones.any((m) => m.type == MilestoneType.oneWeek), isTrue);
      expect(milestones.any((m) => m.type == MilestoneType.oneMonth), isFalse);
    });

    test('includes 10th care milestone', () {
      final plant = _plant();
      final logs = List.generate(12, (i) =>
          _log(now.subtract(Duration(days: i))));
      final milestones = PlantMilestoneEngine.computeMilestones(
        plant: plant, logs: logs, now: now);

      expect(milestones.any((m) => m.type == MilestoneType.tenthCare), isTrue);
    });

    test('does not include 50th care with only 12 logs', () {
      final plant = _plant();
      final logs = List.generate(12, (i) =>
          _log(now.subtract(Duration(days: i))));
      final milestones = PlantMilestoneEngine.computeMilestones(
        plant: plant, logs: logs, now: now);

      expect(milestones.any((m) => m.type == MilestoneType.fiftiethCare), isFalse);
    });

    test('includes 50th and 100th care milestones', () {
      final plant = _plant();
      final logs = List.generate(105, (i) =>
          _log(now.subtract(Duration(hours: i * 8))));
      final milestones = PlantMilestoneEngine.computeMilestones(
        plant: plant, logs: logs, now: now);

      expect(milestones.any((m) => m.type == MilestoneType.fiftiethCare), isTrue);
      expect(milestones.any((m) => m.type == MilestoneType.hundredthCare), isTrue);
    });

    test('milestones are sorted chronologically', () {
      final plant = _plant(createdAt: DateTime(2025, 1, 1));
      final logs = List.generate(15, (i) =>
          _log(DateTime(2025, 1, 5 + i)));
      final milestones = PlantMilestoneEngine.computeMilestones(
        plant: plant, logs: logs, now: now);

      for (int i = 1; i < milestones.length; i++) {
        expect(
          milestones[i].achievedAt.isAfter(milestones[i - 1].achievedAt) ||
              milestones[i].achievedAt == milestones[i - 1].achievedAt,
          isTrue,
        );
      }
    });

    test('ignores logs from other plants', () {
      final plant = _plant(id: 'target');
      final logs = List.generate(15, (i) =>
          _log(now.subtract(Duration(days: i)), plantId: 'other'));
      final milestones = PlantMilestoneEngine.computeMilestones(
        plant: plant, logs: logs, now: now);

      expect(milestones.any((m) => m.type == MilestoneType.firstCare), isFalse);
      expect(milestones.any((m) => m.type == MilestoneType.tenthCare), isFalse);
    });

    test('latestUnseenMilestone returns newest unseen', () {
      final plant = _plant(createdAt: DateTime(2025, 1, 1));
      final logs = List.generate(12, (i) =>
          _log(DateTime(2025, 2, 1 + i)));

      final unseen = PlantMilestoneEngine.latestUnseenMilestone(
        plant: plant,
        logs: logs,
        now: now,
        seenMilestones: {MilestoneType.firstCare, MilestoneType.oneWeek},
      );

      expect(unseen, isNotNull);
      expect(unseen!.type, isNot(MilestoneType.firstCare));
      expect(unseen.type, isNot(MilestoneType.oneWeek));
    });

    test('latestUnseenMilestone returns null when all seen', () {
      final plant = _plant(createdAt: now.subtract(const Duration(days: 5)));
      final logs = [_log(now.subtract(const Duration(days: 1)))];

      final unseen = PlantMilestoneEngine.latestUnseenMilestone(
        plant: plant,
        logs: logs,
        now: now,
        seenMilestones: {MilestoneType.firstCare},
      );

      expect(unseen, isNull);
    });
  });
}
