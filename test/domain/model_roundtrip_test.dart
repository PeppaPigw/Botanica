import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/diary_entry.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';

void main() {
  test('Plant toJson/fromJson round-trip', () {
    final plant = Plant(
      id: 'p1',
      nickname: 'Fiddle',
      speciesId: 'ficus_lyrata',
      room: 'living-room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: 'photos/p1.jpg',
      createdAt: DateTime.utc(2026, 2, 1),
      meta: const PlantMeta(
        potDiameterCm: 14,
        soilType: 'all-purpose',
        lightLevel: 'bright-indirect',
      ),
    );

    final restored = Plant.fromJson(Map<String, dynamic>.from(plant.toJson()));
    expect(restored.id, plant.id);
    expect(restored.nickname, plant.nickname);
    expect(restored.speciesId, plant.speciesId);
    expect(restored.room, plant.room);
    expect(restored.environmentMode, plant.environmentMode);
    expect(restored.coverAsset, plant.coverAsset);
    expect(restored.createdAt, plant.createdAt);
    expect(restored.meta.potDiameterCm, plant.meta.potDiameterCm);
    expect(restored.meta.soilType, plant.meta.soilType);
    expect(restored.meta.lightLevel, plant.meta.lightLevel);
  });

  test('Species toJson/fromJson round-trip', () {
    const species = Species(
      id: 'ficus_lyrata',
      scientificName: 'Ficus lyrata',
      commonNamesByLocale: <String, List<String>>{
        'en': <String>['Fiddle-leaf fig'],
        'zh': <String>['琴叶榕'],
      },
      difficulty: 'medium',
      petSafe: false,
      light: 'bright_indirect',
      careDefaults: CareDefaults(
        waterBaseDays: 7,
        fertilizeBaseDays: 28,
        mistBaseDays: 2,
        rotateBaseDays: 10,
        pruneBaseDays: 90,
      ),
      imagePath: 'assets/placeholders/species/ficus_lyrata.png',
      historyByLocale: <String, String>{
        'en':
            'A popular houseplant celebrated for its bold, violin-shaped leaves.',
        'zh': '因叶片形似小提琴而得名的经典观叶植物。',
      },
      habitByLocale: <String, String>{
        'en':
            'An upright woody plant that prefers stable light and consistent watering.',
        'zh': '木质直立生长，喜欢稳定光照与规律浇水。',
      },
    );

    final restored =
        Species.fromJson(Map<String, dynamic>.from(species.toJson()));
    expect(restored.id, species.id);
    expect(restored.scientificName, species.scientificName);
    expect(restored.commonNamesByLocale, species.commonNamesByLocale);
    expect(restored.difficulty, species.difficulty);
    expect(restored.petSafe, species.petSafe);
    expect(restored.light, species.light);
    expect(restored.careDefaults.waterBaseDays,
        species.careDefaults.waterBaseDays);
    expect(restored.imagePath, species.imagePath);
    expect(restored.historyByLocale, species.historyByLocale);
    expect(restored.habitByLocale, species.habitByLocale);
  });

  test('TaskInstance toJson/fromJson round-trip', () {
    final task = TaskInstance(
      id: 't1',
      plantId: 'p1',
      type: TaskType.water,
      dueAt: DateTime.utc(2026, 2, 10),
      status: TaskStatus.pending,
      createdAt: DateTime.utc(2026, 2, 1),
      completedAt: null,
      adjustmentReasonIds: const <String>['humidity_low', 'winter_season'],
    );

    final restored =
        TaskInstance.fromJson(Map<String, dynamic>.from(task.toJson()));
    expect(restored.id, task.id);
    expect(restored.plantId, task.plantId);
    expect(restored.type, task.type);
    expect(restored.dueAt, task.dueAt);
    expect(restored.status, task.status);
    expect(restored.createdAt, task.createdAt);
    expect(restored.completedAt, task.completedAt);
    expect(restored.adjustmentReasonIds, task.adjustmentReasonIds);
  });

  test('CareLog toJson/fromJson round-trip', () {
    final log = CareLog(
      id: 'l1',
      plantId: 'p1',
      type: TaskType.water,
      timestamp: DateTime.utc(2026, 2, 10),
      note: 'Light watering',
      linkedPhotoId: null,
    );

    final restored = CareLog.fromJson(Map<String, dynamic>.from(log.toJson()));
    expect(restored.id, log.id);
    expect(restored.plantId, log.plantId);
    expect(restored.type, log.type);
    expect(restored.timestamp, log.timestamp);
    expect(restored.note, log.note);
    expect(restored.linkedPhotoId, log.linkedPhotoId);
  });

  test('PhotoEntry toJson/fromJson round-trip', () {
    final entry = PhotoEntry(
      id: 'ph1',
      plantId: 'p1',
      filePath: 'photos/p1.jpg',
      createdAt: DateTime.utc(2026, 2, 10),
      note: 'Day 1',
      hash: 'abc',
    );

    final restored =
        PhotoEntry.fromJson(Map<String, dynamic>.from(entry.toJson()));
    expect(restored.id, entry.id);
    expect(restored.plantId, entry.plantId);
    expect(restored.filePath, entry.filePath);
    expect(restored.createdAt, entry.createdAt);
    expect(restored.note, entry.note);
    expect(restored.hash, entry.hash);
  });

  test('DiaryEntry toJson/fromJson round-trip', () {
    final entry = DiaryEntry(
      id: 'd1',
      plantId: 'p1',
      createdAt: DateTime.utc(2026, 2, 12),
      text: 'Today: a new leaf unfurled.',
    );

    final restored =
        DiaryEntry.fromJson(Map<String, dynamic>.from(entry.toJson()));
    expect(restored.id, entry.id);
    expect(restored.plantId, entry.plantId);
    expect(restored.createdAt, entry.createdAt);
    expect(restored.text, entry.text);
  });

  test('UserSettings toJson/fromJson round-trip', () {
    final settings = UserSettings(
      hasCompletedOnboarding: true,
      temperatureUnit: TemperatureUnit.fahrenheit,
      beliefMode: BeliefMode.tarot,
      reminderTimePreference: ReminderTimePreference.evening,
      hemisphere: Hemisphere.southern,
      localeCode: 'es',
      enableDynamicColor: false,
      enableAiInsights: true,
      careStreakDays: 4,
      lastCareDate: DateTime(2026, 2, 20),
      birthDate: DateTime(1996, 5, 16),
      westernZodiacSignId: 'leo',
    );

    final restored =
        UserSettings.fromJson(Map<String, dynamic>.from(settings.toJson()));
    expect(restored.hasCompletedOnboarding, settings.hasCompletedOnboarding);
    expect(restored.temperatureUnit, settings.temperatureUnit);
    expect(restored.beliefMode, settings.beliefMode);
    expect(restored.reminderTimePreference, settings.reminderTimePreference);
    expect(restored.hemisphere, settings.hemisphere);
    expect(restored.localeCode, settings.localeCode);
    expect(restored.enableDynamicColor, settings.enableDynamicColor);
    expect(restored.enableAiInsights, settings.enableAiInsights);
    expect(restored.birthDate, settings.birthDate);
    expect(restored.westernZodiacSignId, settings.westernZodiacSignId);
  });
}
