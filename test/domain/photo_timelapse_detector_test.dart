import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/photo_timelapse_detector.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant({String id = 'p1', bool isArchived = false}) => Plant(
      id: id,
      nickname: 'Plant $id',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: isArchived,
    );

PhotoEntry _photo({
  required String plantId,
  required DateTime createdAt,
  String? id,
}) =>
    PhotoEntry(
      id: id ?? 'photo_${createdAt.millisecondsSinceEpoch}_$plantId',
      plantId: plantId,
      filePath: '/photos/$plantId/${createdAt.millisecondsSinceEpoch}.jpg',
      createdAt: createdAt,
      note: null,
      hash: 'hash_${createdAt.millisecondsSinceEpoch}',
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('PhotoTimelapseDetector', () {
    test('returns empty with no active plants', () {
      final result = PhotoTimelapseDetector.detect(
        plants: [], photos: [], now: now);
      expect(result, isEmpty);
    });

    test('excludes archived plants', () {
      final plants = [_plant(id: 'p1', isArchived: true)];
      final photos = List.generate(10, (i) => _photo(
        plantId: 'p1',
        createdAt: now.subtract(Duration(days: i * 7)),
      ));
      final result = PhotoTimelapseDetector.detect(
        plants: plants, photos: photos, now: now);
      expect(result, isEmpty);
    });

    test('requires at least 3 photos', () {
      final plants = [_plant()];
      final photos = [
        _photo(plantId: 'p1', createdAt: now.subtract(const Duration(days: 30))),
        _photo(plantId: 'p1', createdAt: now.subtract(const Duration(days: 15))),
      ];
      final result = PhotoTimelapseDetector.detect(
        plants: plants, photos: photos, now: now);
      expect(result, isEmpty);
    });

    test('requires span of at least 7 days', () {
      final plants = [_plant()];
      final photos = [
        _photo(plantId: 'p1', createdAt: now.subtract(const Duration(days: 3))),
        _photo(plantId: 'p1', createdAt: now.subtract(const Duration(days: 2))),
        _photo(plantId: 'p1', createdAt: now.subtract(const Duration(days: 1))),
      ];
      final result = PhotoTimelapseDetector.detect(
        plants: plants, photos: photos, now: now);
      expect(result, isEmpty);
    });

    test('detects minimal quality timelapse', () {
      final plants = [_plant()];
      final photos = [
        _photo(plantId: 'p1', createdAt: now.subtract(const Duration(days: 14))),
        _photo(plantId: 'p1', createdAt: now.subtract(const Duration(days: 10))),
        _photo(plantId: 'p1', createdAt: now.subtract(const Duration(days: 5))),
      ];
      final result = PhotoTimelapseDetector.detect(
        plants: plants, photos: photos, now: now);
      expect(result, hasLength(1));
      expect(result.first.quality, TimelapseQuality.minimal);
      expect(result.first.photoCount, 3);
    });

    test('detects good quality timelapse', () {
      final plants = [_plant()];
      final photos = List.generate(6, (i) => _photo(
        plantId: 'p1',
        createdAt: now.subtract(Duration(days: i * 5)),
      ));
      final result = PhotoTimelapseDetector.detect(
        plants: plants, photos: photos, now: now);
      expect(result, hasLength(1));
      expect(result.first.quality, TimelapseQuality.good);
    });

    test('detects excellent quality timelapse', () {
      final plants = [_plant()];
      final photos = List.generate(12, (i) => _photo(
        plantId: 'p1',
        createdAt: now.subtract(Duration(days: i * 7)),
      ));
      final result = PhotoTimelapseDetector.detect(
        plants: plants, photos: photos, now: now);
      expect(result, hasLength(1));
      expect(result.first.quality, TimelapseQuality.excellent);
    });

    test('sorts by quality then photo count', () {
      final plants = [_plant(id: 'p1'), _plant(id: 'p2')];
      final photos = [
        // p1: 3 photos over 10 days (minimal)
        ...List.generate(3, (i) => _photo(
          plantId: 'p1',
          createdAt: now.subtract(Duration(days: i * 5)),
        )),
        // p2: 12 photos over 84 days (excellent)
        ...List.generate(12, (i) => _photo(
          plantId: 'p2',
          createdAt: now.subtract(Duration(days: i * 7)),
        )),
      ];
      final result = PhotoTimelapseDetector.detect(
        plants: plants, photos: photos, now: now);
      expect(result.length, 2);
      expect(result.first.plantId, 'p2');
    });

    test('bestCandidate returns top result', () {
      final plants = [_plant()];
      final photos = List.generate(6, (i) => _photo(
        plantId: 'p1',
        createdAt: now.subtract(Duration(days: i * 5)),
      ));
      final result = PhotoTimelapseDetector.bestCandidate(
        plants: plants, photos: photos, now: now);
      expect(result, isNotNull);
      expect(result!.plantId, 'p1');
    });

    test('bestCandidate returns null with no candidates', () {
      final result = PhotoTimelapseDetector.bestCandidate(
        plants: [_plant()], photos: [], now: now);
      expect(result, isNull);
    });
  });
}
