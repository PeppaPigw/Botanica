import 'dart:io';

import '../../data/repositories/diary_repository.dart';
import '../../data/repositories/photos_repository.dart';
import '../../data/repositories/plants_repository.dart';
import '../../domain/models/diary_entry.dart';
import '../../domain/models/photo_entry.dart';
import '../../domain/models/plant.dart';
import '../photos/photo_storage.dart';

class JournalActions {
  const JournalActions._();

  static const String fallbackCoverAsset =
      'assets/images/placeholder_plant.jpg';

  /// Deletes one journal photo and keeps the plant cover from pointing at a
  /// removed local file.
  static Future<void> deletePhoto({
    required PhotoEntry entry,
    required Plant plant,
    required PlantsRepository plantsRepository,
    required PhotosRepository photosRepository,
    PhotoStorage photoStorage = const PhotoStorage(),
  }) async {
    await removePhotoEntry(
      entry: entry,
      plant: plant,
      plantsRepository: plantsRepository,
      photosRepository: photosRepository,
    );
    await photoStorage.deleteEntryFile(entry);
  }

  static Future<void> removePhotoEntry({
    required PhotoEntry entry,
    required Plant plant,
    required PlantsRepository plantsRepository,
    required PhotosRepository photosRepository,
  }) async {
    final existingPhotos = photosRepository.forPlant(plant.id);
    await photosRepository.delete(entry.id);

    final currentCover = (plant.coverAsset ?? '').trim();
    if (currentCover != entry.filePath.trim()) return;

    final nextCover = _nextCoverPath(
          existingPhotos.where((photo) => photo.id != entry.id),
        ) ??
        fallbackCoverAsset;

    await plantsRepository.upsert(plant.copyWith(coverAsset: nextCover));
  }

  static Future<void> restorePhotoEntry({
    required PhotoEntry entry,
    required Plant plant,
    required PlantsRepository plantsRepository,
    required PhotosRepository photosRepository,
  }) async {
    await photosRepository.add(entry);
    if ((plant.coverAsset ?? '').trim() != entry.filePath.trim()) return;

    final current = plantsRepository.byId(plant.id) ?? plant;
    await plantsRepository.upsert(
      current.copyWith(coverAsset: plant.coverAsset),
    );
  }

  static Future<void> deletePhotoFile({
    required PhotoEntry entry,
    PhotoStorage photoStorage = const PhotoStorage(),
  }) async {
    await photoStorage.deleteEntryFile(entry);
  }

  static Future<DiaryEntry> updateDiaryEntry({
    required DiaryEntry entry,
    required String text,
    required DiaryRepository diaryRepository,
  }) async {
    final updated = DiaryEntry(
      id: entry.id,
      plantId: entry.plantId,
      createdAt: entry.createdAt,
      text: text.trim(),
    );
    await diaryRepository.add(updated);
    return updated;
  }

  static Future<void> deleteDiaryEntry({
    required DiaryEntry entry,
    required DiaryRepository diaryRepository,
  }) {
    return diaryRepository.delete(entry.id);
  }

  static String? _nextCoverPath(Iterable<PhotoEntry> photos) {
    final candidates = photos.toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (final photo in candidates) {
      final path = photo.filePath.trim();
      if (path.isEmpty) continue;
      if (path.startsWith('assets/')) return path;
      if (File(path).existsSync()) return path;
    }

    return null;
  }
}
