import 'dart:math' as math;

import '../models/care_log.dart';
import '../models/plant.dart';

enum QuickCheckInResponse {
  thriving,
  okay,
  worried,
}

class QuickCheckIn {
  const QuickCheckIn._();

  static bool shouldPrompt({
    required Plant plant,
    required List<CareLog> recentLogs,
    required DateTime now,
    int? seed,
  }) {
    if (plant.isArchived) return false;

    final plantLogs = recentLogs
        .where((l) => l.plantId == plant.id)
        .toList();

    if (plantLogs.length < 3) return false;

    final lastCheckIn = plantLogs
        .where((l) => l.note != null && l.note!.startsWith('checkin:'))
        .fold<DateTime?>(null, (latest, l) =>
            latest == null || l.timestamp.isAfter(latest) ? l.timestamp : latest);

    if (lastCheckIn != null && now.difference(lastCheckIn).inDays < 3) {
      return false;
    }

    final rng = math.Random(seed ?? now.millisecondsSinceEpoch);
    return rng.nextInt(4) == 0;
  }

  static String responseToNote(QuickCheckInResponse response) {
    return 'checkin:${response.name}';
  }

  static QuickCheckInResponse? noteToResponse(String? note) {
    if (note == null || !note.startsWith('checkin:')) return null;
    final value = note.substring(8);
    return QuickCheckInResponse.values
        .where((r) => r.name == value)
        .fold<QuickCheckInResponse?>(null, (_, r) => r);
  }
}
