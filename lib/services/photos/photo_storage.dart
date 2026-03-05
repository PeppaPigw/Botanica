import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/photo_entry.dart';

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

    final plantDir = Directory(p.join(dir.path, 'photos', plantId));
    await plantDir.create(recursive: true);

    final extension = _extensionFromPath(file.path);
    final destPath = p.join(
      plantDir.path,
      '${time.millisecondsSinceEpoch}_${_uuid.v4()}$extension',
    );

    await File(file.path).copy(destPath);

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

  String _extensionFromPath(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext.isEmpty) return '.jpg';
    if (ext.length > 8) return '.jpg';
    return ext;
  }
}
