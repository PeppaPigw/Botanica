import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/src/hive_impl.dart';

import 'package:botanica/data/repositories/diary_repository.dart';
import 'package:botanica/data/repositories/photos_repository.dart';
import 'package:botanica/data/repositories/plants_repository.dart';
import 'package:botanica/domain/models/diary_entry.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/services/journal/journal_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deletePhoto removes file, Hive record, and moves cover to next photo',
      () async {
    final harness = await _JournalHarness.create();
    final now = DateTime.utc(2026, 4, 25, 12);
    final oldPhotoFile = await harness.writePhoto('old.png');
    final coverPhotoFile = await harness.writePhoto('cover.png');

    final plant = _plant(coverAsset: coverPhotoFile.path, now: now);
    await harness.plants.upsert(plant);

    final oldPhoto = PhotoEntry(
      id: 'photo_old',
      plantId: plant.id,
      filePath: oldPhotoFile.path,
      createdAt: now.subtract(const Duration(days: 4)),
      note: null,
      hash: null,
    );
    final coverPhoto = PhotoEntry(
      id: 'photo_cover',
      plantId: plant.id,
      filePath: coverPhotoFile.path,
      createdAt: now,
      note: null,
      hash: null,
    );

    await harness.photos.add(oldPhoto);
    await harness.photos.add(coverPhoto);

    await JournalActions.deletePhoto(
      entry: coverPhoto,
      plant: plant,
      plantsRepository: harness.plants,
      photosRepository: harness.photos,
    );

    expect(coverPhotoFile.existsSync(), isFalse);
    expect(oldPhotoFile.existsSync(), isTrue);
    expect(harness.photos.forPlant(plant.id), [oldPhoto]);
    expect(harness.plants.byId(plant.id)?.coverAsset, oldPhotoFile.path);
  });

  test('deletePhoto resets cover when removing the last photo', () async {
    final harness = await _JournalHarness.create();
    final now = DateTime.utc(2026, 4, 25, 12);
    final photoFile = await harness.writePhoto('only.png');

    final plant = _plant(coverAsset: photoFile.path, now: now);
    await harness.plants.upsert(plant);

    final entry = PhotoEntry(
      id: 'photo_only',
      plantId: plant.id,
      filePath: photoFile.path,
      createdAt: now,
      note: null,
      hash: null,
    );
    await harness.photos.add(entry);

    await JournalActions.deletePhoto(
      entry: entry,
      plant: plant,
      plantsRepository: harness.plants,
      photosRepository: harness.photos,
    );

    expect(photoFile.existsSync(), isFalse);
    expect(harness.photos.forPlant(plant.id), isEmpty);
    expect(
      harness.plants.byId(plant.id)?.coverAsset,
      JournalActions.fallbackCoverAsset,
    );
  });

  test('updateDiaryEntry and deleteDiaryEntry preserve timeline identity',
      () async {
    final harness = await _JournalHarness.create();
    final now = DateTime.utc(2026, 4, 25, 12);
    final entry = DiaryEntry(
      id: 'diary_1',
      plantId: 'plant_1',
      createdAt: now,
      text: 'First note',
    );
    await harness.diary.add(entry);

    final updated = await JournalActions.updateDiaryEntry(
      entry: entry,
      text: '  New leaf opened  ',
      diaryRepository: harness.diary,
    );

    expect(updated.id, entry.id);
    expect(updated.plantId, entry.plantId);
    expect(updated.createdAt, entry.createdAt);
    expect(updated.text, 'New leaf opened');
    expect(harness.diary.forPlant(entry.plantId), [updated]);

    await JournalActions.deleteDiaryEntry(
      entry: updated,
      diaryRepository: harness.diary,
    );

    expect(harness.diary.forPlant(entry.plantId), isEmpty);
  });
}

Plant _plant({
  required String coverAsset,
  required DateTime now,
}) {
  return Plant(
    id: 'plant_1',
    nickname: 'Fern',
    speciesId: 'unknown',
    room: 'Living',
    environmentMode: EnvironmentMode.indoor,
    coverAsset: coverAsset,
    createdAt: now,
    meta: const PlantMeta(),
  );
}

class _JournalHarness {
  _JournalHarness({
    required this.dir,
    required this.hive,
    required this.plants,
    required this.photos,
    required this.diary,
  });

  final Directory dir;
  final HiveImpl hive;
  final PlantsRepository plants;
  final PhotosRepository photos;
  final DiaryRepository diary;

  static Future<_JournalHarness> create() async {
    final dir =
        await Directory.systemTemp.createTemp('botanica_journal_actions_');
    final hive = HiveImpl()..init(dir.path);
    final suffix = DateTime.now().microsecondsSinceEpoch.toString();

    final plantsBox = await hive.openBox<Map>('plants_$suffix');
    final photosBox = await hive.openBox<Map>('photos_$suffix');
    final diaryBox = await hive.openBox<Map>('diary_$suffix');

    final harness = _JournalHarness(
      dir: dir,
      hive: hive,
      plants: PlantsRepository(plantsBox),
      photos: PhotosRepository(photosBox),
      diary: DiaryRepository(diaryBox),
    );

    addTearDown(harness.dispose);
    return harness;
  }

  Future<File> writePhoto(String name) async {
    final plantDir = Directory('${dir.path}/photos/plant_1');
    await plantDir.create(recursive: true);
    final file = File('${plantDir.path}/$name');
    await file.writeAsBytes(<int>[1, 2, 3, 4]);
    return file;
  }

  Future<void> dispose() async {
    await hive.close();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
