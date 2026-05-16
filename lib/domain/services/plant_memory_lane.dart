import '../models/care_log.dart';
import '../models/photo_entry.dart';
import '../models/plant.dart';

enum MemoryType {
  firstPhoto,
  firstCare,
  anniversaryMonth,
  busiestDay,
  longestGap,
  careComeback,
}

class PlantMemory {
  const PlantMemory({
    required this.type,
    required this.plantId,
    required this.messageKey,
    required this.args,
    this.photoPath,
    required this.occurredAt,
  });

  final MemoryType type;
  final String plantId;
  final String messageKey;
  final Map<String, String> args;
  final String? photoPath;
  final DateTime occurredAt;
}

class PlantMemoryLane {
  const PlantMemoryLane._();

  static PlantMemory? surfaceMemory({
    required Plant plant,
    required List<CareLog> logs,
    required List<PhotoEntry> photos,
    required DateTime now,
  }) {
    final plantLogs = logs.where((l) => l.plantId == plant.id).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final plantPhotos = photos.where((p) => p.plantId == plant.id).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final candidates = <PlantMemory>[];

    final anniversary = _checkMonthAnniversary(plant, now);
    if (anniversary != null) candidates.add(anniversary);

    final firstPhoto = _checkFirstPhoto(plant, plantPhotos, now);
    if (firstPhoto != null) candidates.add(firstPhoto);

    final comeback = _checkCareComeback(plant, plantLogs, now);
    if (comeback != null) candidates.add(comeback);

    final busiestDay = _checkBusiestDay(plant, plantLogs, now);
    if (busiestDay != null) candidates.add(busiestDay);

    if (candidates.isEmpty) return null;

    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return candidates[dayOfYear % candidates.length];
  }

  static PlantMemory? _checkMonthAnniversary(Plant plant, DateTime now) {
    final months = _monthsBetween(plant.createdAt, now);
    if (months < 1 || months > 24) return null;
    if (now.day != plant.createdAt.day) return null;

    return PlantMemory(
      type: MemoryType.anniversaryMonth,
      plantId: plant.id,
      messageKey: 'memoryAnniversary',
      args: {'plant': plant.nickname, 'months': months.toString()},
      occurredAt: plant.createdAt,
    );
  }

  static PlantMemory? _checkFirstPhoto(
      Plant plant, List<PhotoEntry> photos, DateTime now) {
    if (photos.isEmpty) return null;

    final first = photos.first;
    final daysSince = now.difference(first.createdAt).inDays;
    if (daysSince < 30) return null;

    return PlantMemory(
      type: MemoryType.firstPhoto,
      plantId: plant.id,
      messageKey: 'memoryFirstPhoto',
      args: {'plant': plant.nickname, 'days': daysSince.toString()},
      photoPath: first.filePath,
      occurredAt: first.createdAt,
    );
  }

  static PlantMemory? _checkCareComeback(
      Plant plant, List<CareLog> logs, DateTime now) {
    if (logs.length < 5) return null;

    int longestGapDays = 0;
    DateTime? gapEnd;

    for (int i = 1; i < logs.length; i++) {
      final gap = logs[i].timestamp.difference(logs[i - 1].timestamp).inDays;
      if (gap > longestGapDays) {
        longestGapDays = gap;
        gapEnd = logs[i].timestamp;
      }
    }

    if (longestGapDays < 10 || gapEnd == null) return null;
    final daysSinceComeback = now.difference(gapEnd).inDays;
    if (daysSinceComeback < 14) return null;

    return PlantMemory(
      type: MemoryType.careComeback,
      plantId: plant.id,
      messageKey: 'memoryCareComeback',
      args: {
        'plant': plant.nickname,
        'gapDays': longestGapDays.toString(),
      },
      occurredAt: gapEnd,
    );
  }

  static PlantMemory? _checkBusiestDay(
      Plant plant, List<CareLog> logs, DateTime now) {
    if (logs.length < 10) return null;

    final dayCounts = <int, int>{};
    for (final log in logs) {
      final dayKey = log.timestamp.millisecondsSinceEpoch ~/ 86400000;
      dayCounts[dayKey] = (dayCounts[dayKey] ?? 0) + 1;
    }

    int maxCount = 0;
    int? maxDay;
    for (final entry in dayCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        maxDay = entry.key;
      }
    }

    if (maxCount < 3 || maxDay == null) return null;
    final busiestDate =
        DateTime.fromMillisecondsSinceEpoch(maxDay * 86400000);
    final daysSince = now.difference(busiestDate).inDays;
    if (daysSince < 7) return null;

    return PlantMemory(
      type: MemoryType.busiestDay,
      plantId: plant.id,
      messageKey: 'memoryBusiestDay',
      args: {
        'plant': plant.nickname,
        'count': maxCount.toString(),
      },
      occurredAt: busiestDate,
    );
  }

  static int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + to.month - from.month;
  }
}
