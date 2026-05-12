import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/daily_flower.dart';
import 'package:botanica/domain/models/diary_entry.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/environment_snapshot.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';

void main() {
  group('Model equality', () {
    test('PlantMeta value equality', () {
      const a = PlantMeta(soilType: 'peat', lightLevel: 'bright');
      const b = PlantMeta(soilType: 'peat', lightLevel: 'bright');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('PlantMeta inequality', () {
      const a = PlantMeta(soilType: 'peat');
      const b = PlantMeta(soilType: 'clay');
      expect(a, isNot(equals(b)));
    });

    test('Plant value equality', () {
      final now = DateTime(2025, 6, 15);
      final a = Plant(
        id: '1',
        nickname: 'Fern',
        speciesId: 's1',
        room: 'Living',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: now,
        meta: const PlantMeta(),
      );
      final b = Plant(
        id: '1',
        nickname: 'Fern',
        speciesId: 's1',
        room: 'Living',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: now,
        meta: const PlantMeta(),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('Plant inequality on different nickname', () {
      final now = DateTime(2025, 6, 15);
      final a = Plant(
        id: '1',
        nickname: 'Fern',
        speciesId: 's1',
        room: 'Living',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: now,
        meta: const PlantMeta(),
      );
      final b = Plant(
        id: '1',
        nickname: 'Ivy',
        speciesId: 's1',
        room: 'Living',
        environmentMode: EnvironmentMode.indoor,
        coverAsset: null,
        createdAt: now,
        meta: const PlantMeta(),
      );
      expect(a, isNot(equals(b)));
    });

    test('TaskInstance value equality', () {
      final now = DateTime(2025, 6, 15);
      final a = TaskInstance(
        id: 't1',
        plantId: 'p1',
        type: TaskType.water,
        dueAt: now,
        status: TaskStatus.pending,
        createdAt: now,
        completedAt: null,
        adjustmentReasonIds: const ['humidity_low'],
      );
      final b = TaskInstance(
        id: 't1',
        plantId: 'p1',
        type: TaskType.water,
        dueAt: now,
        status: TaskStatus.pending,
        createdAt: now,
        completedAt: null,
        adjustmentReasonIds: const ['humidity_low'],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('TaskInstance inequality on different adjustmentReasonIds', () {
      final now = DateTime(2025, 6, 15);
      final a = TaskInstance(
        id: 't1',
        plantId: 'p1',
        type: TaskType.water,
        dueAt: now,
        status: TaskStatus.pending,
        createdAt: now,
        completedAt: null,
        adjustmentReasonIds: const ['humidity_low'],
      );
      final b = TaskInstance(
        id: 't1',
        plantId: 'p1',
        type: TaskType.water,
        dueAt: now,
        status: TaskStatus.pending,
        createdAt: now,
        completedAt: null,
        adjustmentReasonIds: const ['hot_temperature'],
      );
      expect(a, isNot(equals(b)));
    });

    test('CareLog value equality', () {
      final now = DateTime(2025, 6, 15);
      final a = CareLog(
        id: 'l1',
        plantId: 'p1',
        type: TaskType.water,
        timestamp: now,
        note: null,
        linkedPhotoId: null,
      );
      final b = CareLog(
        id: 'l1',
        plantId: 'p1',
        type: TaskType.water,
        timestamp: now,
        note: null,
        linkedPhotoId: null,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('EnvironmentSnapshot value equality', () {
      final now = DateTime(2025, 6, 15);
      final a = EnvironmentSnapshot(timestamp: now, tempC: 24.0, humidity: 48);
      final b = EnvironmentSnapshot(timestamp: now, tempC: 24.0, humidity: 48);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('PhotoEntry value equality', () {
      final now = DateTime(2025, 6, 15);
      final a = PhotoEntry(
        id: 'ph1',
        plantId: 'p1',
        filePath: '/tmp/a.jpg',
        createdAt: now,
        note: null,
        hash: null,
      );
      final b = PhotoEntry(
        id: 'ph1',
        plantId: 'p1',
        filePath: '/tmp/a.jpg',
        createdAt: now,
        note: null,
        hash: null,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('DiaryEntry value equality', () {
      final now = DateTime(2025, 6, 15);
      final a = DiaryEntry(
        id: 'd1',
        plantId: 'p1',
        createdAt: now,
        text: 'Hello',
      );
      final b = DiaryEntry(
        id: 'd1',
        plantId: 'p1',
        createdAt: now,
        text: 'Hello',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('DailyFlowerContent value equality', () {
      const a = DailyFlowerContent(
        key: 'rose',
        name: 'Rose',
        imagePath: null,
        meaningKeywords: ['love'],
        symbolism: 'Love and beauty',
        careBasics: {'water': 'daily'},
        appreciation: 'Enjoy the bloom',
      );
      const b = DailyFlowerContent(
        key: 'rose',
        name: 'Rose',
        imagePath: null,
        meaningKeywords: ['love'],
        symbolism: 'Love and beauty',
        careBasics: {'water': 'daily'},
        appreciation: 'Enjoy the bloom',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('UserSettings value equality', () {
      final birthDate = DateTime(1996, 5, 16);
      const dailySeed = 'seed-123';

      final a = UserSettings(
        hasCompletedOnboarding: true,
        temperatureUnit: TemperatureUnit.fahrenheit,
        beliefMode: BeliefMode.westernZodiac,
        reminderTimePreference: ReminderTimePreference.evening,
        hemisphere: Hemisphere.southern,
        localeCode: 'es',
        enableDynamicColor: false,
        enableAiInsights: true,
        aiPreferredEndpointIndex: 0,
        careStreakDays: 3,
        lastCareDate: DateTime(2026, 2, 20),
        dailySeed: dailySeed,
        birthDate: birthDate,
        westernZodiacSignId: 'leo',
      );

      final b = UserSettings(
        hasCompletedOnboarding: true,
        temperatureUnit: TemperatureUnit.fahrenheit,
        beliefMode: BeliefMode.westernZodiac,
        reminderTimePreference: ReminderTimePreference.evening,
        hemisphere: Hemisphere.southern,
        localeCode: 'es',
        enableDynamicColor: false,
        enableAiInsights: true,
        aiPreferredEndpointIndex: 0,
        careStreakDays: 3,
        lastCareDate: DateTime(2026, 2, 20),
        dailySeed: dailySeed,
        birthDate: birthDate,
        westernZodiacSignId: 'leo',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('UserSettings inequality when dailySeed differs', () {
      final a = UserSettings.defaults();
      final b = UserSettings.defaults().copyWith(dailySeed: 'different');
      expect(a, isNot(equals(b)));
    });
  });

  group('PlantMeta.copyWith nullable reset', () {
    test('can reset soilType to null', () {
      const meta = PlantMeta(soilType: 'peat');
      final cleared = meta.copyWith(soilType: null);
      expect(cleared.soilType, isNull);
    });

    test('can reset lastRepotDate to null', () {
      final meta = PlantMeta(lastRepotDate: DateTime(2025, 1, 1));
      final cleared = meta.copyWith(lastRepotDate: null);
      expect(cleared.lastRepotDate, isNull);
    });

    test('omitted fields are preserved', () {
      const meta = PlantMeta(soilType: 'peat', lightLevel: 'bright');
      final updated = meta.copyWith(soilType: null);
      expect(updated.soilType, isNull);
      expect(updated.lightLevel, 'bright');
    });
  });
}
