import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/local_time.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/services/care/care_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('snoozeUntilTomorrow aligns to evening reminder time', () {
    final previousLocation = tz.local;
    tz.setLocalLocation(tz.getLocation('UTC'));
    addTearDown(() => tz.setLocalLocation(previousLocation));

    final target = CareActions.snoozeUntilTomorrow(
      now: DateTime(2026, 5, 12, 13, 20),
      plant: _plant(),
      settings: UserSettings.defaults().copyWith(
        reminderTimePreference: ReminderTimePreference.evening,
      ),
    );

    expect(target, DateTime(2026, 5, 13, 19));
  });

  test('snoozeUntilTomorrow prefers plant reminder override', () {
    final previousLocation = tz.local;
    tz.setLocalLocation(tz.getLocation('UTC'));
    addTearDown(() => tz.setLocalLocation(previousLocation));

    final target = CareActions.snoozeUntilTomorrow(
      now: DateTime(2026, 5, 12, 13, 20),
      plant: _plant(
        reminderTimeOverride: const LocalTime(hour: 8, minute: 45),
      ),
      settings: UserSettings.defaults().copyWith(
        reminderTimePreference: ReminderTimePreference.evening,
      ),
    );

    expect(target, DateTime(2026, 5, 13, 8, 45));
  });
}

Plant _plant({LocalTime? reminderTimeOverride}) {
  return Plant(
    id: 'plant-1',
    nickname: 'Aloe',
    speciesId: 'aloe_vera',
    room: 'Living room',
    environmentMode: EnvironmentMode.indoor,
    coverAsset: 'assets/placeholders/species/unknown.png',
    createdAt: DateTime(2026, 5, 1),
    meta: const PlantMeta(),
    reminderTimeOverride: reminderTimeOverride,
  );
}
