import '../models/enums.dart';
import '../models/plant.dart';

class CalendarEvent {
  const CalendarEvent({
    required this.date,
    required this.plantId,
    required this.plantNickname,
    required this.taskType,
    required this.isOverdue,
    required this.priority,
  });

  final DateTime date;
  final String plantId;
  final String plantNickname;
  final TaskType taskType;
  final bool isOverdue;
  final int priority;
}

class WeekCalendar {
  const WeekCalendar({
    required this.startDate,
    required this.events,
    required this.busiestDay,
    required this.totalTasks,
    required this.overdueCount,
  });

  final DateTime startDate;
  final List<CalendarEvent> events;
  final int busiestDay;
  final int totalTasks;
  final int overdueCount;
}

class CareCalendarEngine {
  const CareCalendarEngine._();

  static WeekCalendar generateWeek({
    required List<Plant> plants,
    required Map<String, int> speciesWaterDays,
    required Map<String, DateTime> lastWatered,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    final events = <CalendarEvent>[];
    final startDate = now;

    for (final plant in activePlants) {
      final waterDays = speciesWaterDays[plant.speciesId] ?? 7;
      final lastDate = lastWatered[plant.id];

      if (lastDate == null) {
        events.add(CalendarEvent(
          date: now,
          plantId: plant.id,
          plantNickname: plant.nickname,
          taskType: TaskType.water,
          isOverdue: true,
          priority: 9,
        ));
        continue;
      }

      final nextDue = lastDate.add(Duration(days: waterDays));
      final daysUntilDue = nextDue.difference(now).inDays;

      if (daysUntilDue < 0) {
        events.add(CalendarEvent(
          date: now,
          plantId: plant.id,
          plantNickname: plant.nickname,
          taskType: TaskType.water,
          isOverdue: true,
          priority: 9,
        ));
      } else if (daysUntilDue <= 7) {
        events.add(CalendarEvent(
          date: nextDue,
          plantId: plant.id,
          plantNickname: plant.nickname,
          taskType: TaskType.water,
          isOverdue: false,
          priority: 7 - daysUntilDue.clamp(0, 6),
        ));
      }
    }

    events.sort((a, b) {
      final dateComp = a.date.compareTo(b.date);
      if (dateComp != 0) return dateComp;
      return b.priority.compareTo(a.priority);
    });

    final dayCounts = <int, int>{};
    for (final e in events) {
      final day = e.date.weekday;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    final busiestDay = dayCounts.isEmpty ? 1
        : dayCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final overdueCount = events.where((e) => e.isOverdue).length;

    return WeekCalendar(
      startDate: startDate,
      events: events,
      busiestDay: busiestDay,
      totalTasks: events.length,
      overdueCount: overdueCount,
    );
  }
}
