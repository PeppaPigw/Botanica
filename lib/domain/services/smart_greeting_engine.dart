import '../models/care_log.dart';
import '../models/plant.dart';
import '../models/user_settings.dart';

class SmartGreeting {
  const SmartGreeting({
    required this.messageKey,
    required this.args,
  });

  final String messageKey;
  final Map<String, String> args;
}

class SmartGreetingEngine {
  const SmartGreetingEngine._();

  static SmartGreeting generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required UserSettings settings,
    required DateTime now,
    bool isRaining = false,
  }) {
    final hour = now.hour;
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final streak = settings.careStreakDays;

    final candidates = <SmartGreeting>[];

    candidates.add(_timeBasedGreeting(hour));

    if (streak >= 7) {
      candidates.add(SmartGreeting(
        messageKey: 'greetingStreak',
        args: {'days': streak.toString()},
      ));
    }

    if (isRaining) {
      candidates.add(const SmartGreeting(
        messageKey: 'greetingRainy',
        args: {},
      ));
    }

    if (activePlants.isNotEmpty) {
      final recentlyAdded = activePlants.where(
          (p) => now.difference(p.createdAt).inDays <= 3).toList();
      if (recentlyAdded.isNotEmpty) {
        candidates.add(SmartGreeting(
          messageKey: 'greetingNewPlant',
          args: {'plant': recentlyAdded.first.nickname},
        ));
      }
    }

    final todayLogs = logs.where(
        (l) => _isSameDay(l.timestamp, now)).toList();
    if (todayLogs.length >= 3) {
      candidates.add(const SmartGreeting(
        messageKey: 'greetingProductiveDay',
        args: {},
      ));
    }

    if (hour >= 5 && hour < 8 && streak >= 3) {
      candidates.add(const SmartGreeting(
        messageKey: 'greetingEarlyBird',
        args: {},
      ));
    }

    if (hour >= 21) {
      candidates.add(SmartGreeting(
        messageKey: 'greetingLateNight',
        args: {'count': activePlants.length.toString()},
      ));
    }

    if (activePlants.length >= 10) {
      candidates.add(SmartGreeting(
        messageKey: 'greetingBigGarden',
        args: {'count': activePlants.length.toString()},
      ));
    }

    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = (dayOfYear + hour ~/ 6) % candidates.length;
    return candidates[index];
  }

  static SmartGreeting _timeBasedGreeting(int hour) {
    if (hour >= 5 && hour < 12) {
      return const SmartGreeting(messageKey: 'greetingMorning', args: {});
    }
    if (hour >= 12 && hour < 18) {
      return const SmartGreeting(messageKey: 'greetingAfternoon', args: {});
    }
    return const SmartGreeting(messageKey: 'greetingEvening', args: {});
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
