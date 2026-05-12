import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/photo_entry.dart';
import 'image_compression.dart';

class PhotoStorageStats {
  const PhotoStorageStats({
    required this.existingFiles,
    required this.missingFiles,
    required this.skippedReferences,
    required this.totalBytes,
  });

  final int existingFiles;
  final int missingFiles;
  final int skippedReferences;
  final int totalBytes;
}

class PhotoStorage {
  const PhotoStorage({
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  final Uuid _uuid;

  Future<PhotoEntry> importToJournal({
    required XFile file,
    required String plantId,
    String? note,
    DateTime? now,
  }) async {
    final time = now ?? DateTime.now();
    final dir = await getApplicationDocumentsDirectory();
    final prepared = await ImageCompression.prepareForStorage(
      file: file,
      preset: ImageCompressionPresets.journalPhoto,
    );

    final plantDir = Directory(p.join(dir.path, 'photos', plantId));
    await plantDir.create(recursive: true);

    final destPath = journalPhotoPath(
      documentsDirectoryPath: dir.path,
      plantId: plantId,
      timestamp: time,
      uniqueId: _uuid.v4(),
      sourcePath: prepared.path,
    );

    await File(prepared.path).copy(destPath);

    final bytes = await File(destPath).readAsBytes();
    final digest = sha1.convert(bytes).toString();

    return PhotoEntry(
      id: _uuid.v4(),
      plantId: plantId,
      filePath: destPath,
      createdAt: time,
      note: note,
      hash: digest,
    );
  }

  String journalPhotoPath({
    required String documentsDirectoryPath,
    required String plantId,
    required DateTime timestamp,
    required String uniqueId,
    required String sourcePath,
  }) {
    return p.join(
      documentsDirectoryPath,
      'photos',
      plantId,
      '${timestamp.millisecondsSinceEpoch}_$uniqueId'
      '${_extensionFromPath(sourcePath)}',
    );
  }

  Future<int> deleteEntryFiles(Iterable<PhotoEntry> entries) async {
    var deleted = 0;
    for (final entry in entries) {
      final didDelete = await deleteEntryFile(entry);
      if (didDelete) deleted++;
    }
    return deleted;
  }

  Future<PhotoStorageStats> statsForEntries(
    Iterable<PhotoEntry> entries,
  ) async {
    var existingFiles = 0;
    var missingFiles = 0;
    var skippedReferences = 0;
    var totalBytes = 0;

    for (final entry in entries) {
      final path = entry.filePath.trim();
      if (path.isEmpty || !p.isAbsolute(path)) {
        skippedReferences++;
        continue;
      }

      final file = File(path);
      if (!await file.exists()) {
        missingFiles++;
        continue;
      }

      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file) {
        skippedReferences++;
        continue;
      }

      existingFiles++;
      totalBytes += stat.size;
    }

    return PhotoStorageStats(
      existingFiles: existingFiles,
      missingFiles: missingFiles,
      skippedReferences: skippedReferences,
      totalBytes: totalBytes,
    );
  }

  Future<bool> deleteEntryFile(PhotoEntry entry) async {
    final path = entry.filePath.trim();
    if (path.isEmpty) return false;
    if (!p.isAbsolute(path)) return false;

    final file = File(path);
    if (!await file.exists()) return false;

    final parent = file.parent;
    await file.delete();
    await _deleteDirectoryIfEmpty(parent);
    return true;
  }

  Future<int> clearTemporaryCache() async {
    final dir = await getTemporaryDirectory();
    if (!await dir.exists()) return 0;

    var deleted = 0;
    await for (final entity in dir.list()) {
      try {
        if (entity is File) {
          await entity.delete();
          deleted++;
        } else if (entity is Directory) {
          deleted += await _deleteDirectoryRecursive(entity);
        }
      } on FileSystemException catch (error) {
        _ignoreFileSystemException(error);
      }
    }
    return deleted;
  }

  String _extensionFromPath(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext.isEmpty) return '.jpg';
    if (ext.length > 8) return '.jpg';
    return ext;
  }

  Future<void> _deleteDirectoryIfEmpty(Directory directory) async {
    if (!await directory.exists()) return;
    final isEmpty = await directory.list().isEmpty;
    if (isEmpty) {
      await directory.delete();
    }
  }

  Future<int> _deleteDirectoryRecursive(Directory directory) async {
    if (!await directory.exists()) return 0;
    var deleted = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) deleted++;
    }
    try {
      await directory.delete(recursive: true);
    } on FileSystemException catch (error) {
      _ignoreFileSystemException(error);
    }
    return deleted;
  }

  void _ignoreFileSystemException(FileSystemException error) {
    error.message;
  }
}
