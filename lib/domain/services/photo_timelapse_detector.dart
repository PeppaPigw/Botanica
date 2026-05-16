import '../models/photo_entry.dart';
import '../models/plant.dart';

class TimelapseCandidate {
  const TimelapseCandidate({
    required this.plantId,
    required this.plantNickname,
    required this.photoCount,
    required this.spanDays,
    required this.photoIds,
    required this.quality,
  });

  final String plantId;
  final String plantNickname;
  final int photoCount;
  final int spanDays;
  final List<String> photoIds;
  final TimelapseQuality quality;
}

enum TimelapseQuality { minimal, good, excellent }

class PhotoTimelapseDetector {
  const PhotoTimelapseDetector._();

  static List<TimelapseCandidate> detect({
    required List<Plant> plants,
    required List<PhotoEntry> photos,
    required DateTime now,
  }) {
    final activePlants = plants.where((p) => !p.isArchived).toList();
    if (activePlants.isEmpty) return [];

    final candidates = <TimelapseCandidate>[];

    for (final plant in activePlants) {
      final plantPhotos = photos
          .where((p) => p.plantId == plant.id)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (plantPhotos.length < 3) continue;

      final spanDays = plantPhotos.last.createdAt
          .difference(plantPhotos.first.createdAt)
          .inDays;

      if (spanDays < 7) continue;

      final quality = _assessQuality(plantPhotos.length, spanDays);

      candidates.add(TimelapseCandidate(
        plantId: plant.id,
        plantNickname: plant.nickname,
        photoCount: plantPhotos.length,
        spanDays: spanDays,
        photoIds: plantPhotos.map((p) => p.id).toList(),
        quality: quality,
      ));
    }

    candidates.sort((a, b) {
      final qualityCompare = b.quality.index.compareTo(a.quality.index);
      if (qualityCompare != 0) return qualityCompare;
      return b.photoCount.compareTo(a.photoCount);
    });

    return candidates;
  }

  static TimelapseQuality _assessQuality(int photoCount, int spanDays) {
    final density = photoCount / (spanDays / 7.0);

    if (photoCount >= 10 && spanDays >= 60 && density >= 1.0) {
      return TimelapseQuality.excellent;
    }
    if (photoCount >= 5 && spanDays >= 21 && density >= 0.5) {
      return TimelapseQuality.good;
    }
    return TimelapseQuality.minimal;
  }

  static TimelapseCandidate? bestCandidate({
    required List<Plant> plants,
    required List<PhotoEntry> photos,
    required DateTime now,
  }) {
    final all = detect(plants: plants, photos: photos, now: now);
    if (all.isEmpty) return null;
    return all.first;
  }
}
