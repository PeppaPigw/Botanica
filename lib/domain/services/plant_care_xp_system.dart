import '../models/care_log.dart';
import '../models/photo_entry.dart';
import '../models/plant.dart';
import '../models/task_instance.dart';

class XpEvent {
  const XpEvent({
    required this.action,
    required this.xp,
    required this.timestamp,
    this.plantId,
    this.bonus,
  });

  final String action;
  final int xp;
  final DateTime timestamp;
  final String? plantId;
  final String? bonus;
}

class GardenerLevel {
  const GardenerLevel({
    required this.level,
    required this.title,
    required this.totalXp,
    required this.xpForNextLevel,
    required this.xpInCurrentLevel,
    required this.progressToNext,
    required this.recentXpEvents,
  });

  final int level;
  final String title;
  final int totalXp;
  final int xpForNextLevel;
  final int xpInCurrentLevel;
  final double progressToNext;
  final List<XpEvent> recentXpEvents;
}

class PlantCareXpSystem {
  const PlantCareXpSystem._();

  static const _xpPerAction = <String, int>{
    'water': 10,
    'fertilize': 15,
    'mist': 8,
    'rotate': 8,
    'prune': 20,
    'repot': 30,
    'clean': 12,
    'photo': 15,
    'addPlant': 25,
  };

  static const _levelTitles = [
    'Seed Starter',
    'Sprout Tender',
    'Leaf Whisperer',
    'Root Nurturer',
    'Bloom Keeper',
    'Garden Sage',
    'Plant Wizard',
    'Forest Guardian',
    'Nature\'s Champion',
    'Botanical Legend',
  ];

  static GardenerLevel compute({
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required List<PhotoEntry> photos,
    required List<Plant> plants,
    required int streakDays,
    required DateTime now,
  }) {
    final events = <XpEvent>[];
    int totalXp = 0;

    for (final log in logs) {
      final baseXp = _xpPerAction[log.type.name] ?? 10;
      final bonus = _calculateBonus(log, logs, streakDays);
      final xp = baseXp + bonus.xp;
      totalXp += xp;
      events.add(XpEvent(
        action: log.type.name,
        xp: xp,
        timestamp: log.timestamp,
        plantId: log.plantId,
        bonus: bonus.reason,
      ));
    }

    for (final photo in photos) {
      final xp = _xpPerAction['photo']!;
      totalXp += xp;
      events.add(XpEvent(
        action: 'photo',
        xp: xp,
        timestamp: photo.createdAt,
        plantId: photo.plantId,
      ));
    }

    for (final plant in plants) {
      final xp = _xpPerAction['addPlant']!;
      totalXp += xp;
      events.add(XpEvent(
        action: 'addPlant',
        xp: xp,
        timestamp: plant.createdAt,
        plantId: plant.id,
      ));
    }

    final onTimeTasks = tasks.where((t) =>
        t.isDone &&
        t.completedAt != null &&
        t.completedAt!.difference(t.dueAt).inHours <= 12).length;
    totalXp += onTimeTasks * 5;

    final level = _levelFromXp(totalXp);
    final xpForCurrentLevel = _xpRequiredForLevel(level);
    final xpForNextLevel = _xpRequiredForLevel(level + 1);
    final xpInLevel = totalXp - xpForCurrentLevel;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    final progress = xpNeeded > 0 ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 1.0;

    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recentEvents = events.take(10).toList();

    return GardenerLevel(
      level: level,
      title: _levelTitles[level.clamp(0, _levelTitles.length - 1)],
      totalXp: totalXp,
      xpForNextLevel: xpForNextLevel,
      xpInCurrentLevel: xpInLevel,
      progressToNext: progress,
      recentXpEvents: recentEvents,
    );
  }

  static ({int xp, String? reason}) _calculateBonus(
      CareLog log, List<CareLog> allLogs, int streakDays) {
    int bonus = 0;
    String? reason;

    if (streakDays >= 7) {
      bonus += 3;
      reason = 'streakBonus';
    }
    if (streakDays >= 30) {
      bonus += 5;
      reason = 'longStreakBonus';
    }

    if (log.timestamp.hour >= 5 && log.timestamp.hour < 8) {
      bonus += 2;
      reason ??= 'earlyBirdBonus';
    }

    return (xp: bonus, reason: reason);
  }

  static int _levelFromXp(int xp) {
    int level = 0;
    while (level < _levelTitles.length - 1 && xp >= _xpRequiredForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  static int _xpRequiredForLevel(int level) {
    if (level <= 0) return 0;
    return (100 * level * level * 0.8).round();
  }
}
