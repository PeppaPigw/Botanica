import '../../domain/models/care_log.dart';

class PlantCareStreak {
  PlantCareStreak._();

  /// Computes the current consecutive-day care streak for a plant.
  /// A "streak day" is any day where at least one care log exists.
  /// The streak breaks if a full calendar day passes with no care.
  static int compute(List<CareLog> logs) {
    if (logs.isEmpty) return 0;

    final sorted = logs.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Collect unique care days (most recent first)
    final days = <DateTime>{};
    for (final log in sorted) {
      days.add(DateTime(
          log.timestamp.year, log.timestamp.month, log.timestamp.day));
    }
    final sortedDays = days.toList()..sort((a, b) => b.compareTo(a));

    // The streak must include today or yesterday to be "active"
    if (sortedDays.isEmpty) return 0;
    final mostRecent = sortedDays.first;
    final diff = today.difference(mostRecent).inDays;
    if (diff > 1) return 0; // streak broken

    int streak = 1;
    for (int i = 1; i < sortedDays.length; i++) {
      final gap = sortedDays[i - 1].difference(sortedDays[i]).inDays;
      if (gap == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
