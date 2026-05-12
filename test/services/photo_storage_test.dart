import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/photo_entry.dart';
import 'package:botanica/services/photos/photo_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deleteEntryFile removes an absolute file and empty parent directory',
      () async {
    final dir = await Directory.systemTemp.createTemp('botanica_photo_store_');
    addTearDown(() async {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    final plantDir = Directory('${dir.path}/photos/plant_1');
    await plantDir.create(recursive: true);
    final file = File('${plantDir.path}/photo.jpg');
    await file.writeAsBytes(<int>[1, 2, 3]);

    final deleted = await const PhotoStorage().deleteEntryFile(
      _entry(id: 'photo_1', filePath: file.path),
    );

    expect(deleted, isTrue);
    expect(file.existsSync(), isFalse);
    expect(plantDir.existsSync(), isFalse);
  });

  test('deleteEntryFile skips relative asset references', () async {
    final deleted = await const PhotoStorage().deleteEntryFile(
      _entry(
          id: 'asset_photo', filePath: 'assets/images/placeholder_plant.jpg'),
    );

    expect(deleted, isFalse);
  });

  test('statsForEntries counts existing, missing, skipped files and bytes',
      () async {
    final dir = await Directory.systemTemp.createTemp('botanica_photo_stats_');
    addTearDown(() async {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    final first = File('${dir.path}/first.jpg');
    final second = File('${dir.path}/second.jpg');
    await first.writeAsBytes(<int>[1, 2, 3]);
    await second.writeAsBytes(<int>[4, 5]);

    final stats = await const PhotoStorage().statsForEntries(
      [
        _entry(id: 'first', filePath: first.path),
        _entry(id: 'second', filePath: second.path),
        _entry(id: 'missing', filePath: '${dir.path}/missing.jpg'),
        _entry(id: 'asset', filePath: 'assets/images/placeholder_plant.jpg'),
        _entry(id: 'empty', filePath: ''),
      ],
    );

    expect(stats.existingFiles, 2);
    expect(stats.missingFiles, 1);
    expect(stats.skippedReferences, 2);
    expect(stats.totalBytes, 5);
  });
}

PhotoEntry _entry({
  required String id,
  required String filePath,
}) {
  return PhotoEntry(
    id: id,
    plantId: 'plant_1',
    filePath: filePath,
    createdAt: DateTime.utc(2026, 4, 25, 12),
    note: null,
    hash: null,
  );
}
