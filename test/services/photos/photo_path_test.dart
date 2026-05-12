import 'package:botanica/services/photos/photo_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('journal photo path includes plant ID and timestamp', () {
    final timestamp = DateTime.utc(2026, 5, 12, 8, 30);

    final path = const PhotoStorage().journalPhotoPath(
      documentsDirectoryPath: '/app/documents',
      plantId: 'plant_42',
      timestamp: timestamp,
      uniqueId: 'fixed-id',
      sourcePath: '/tmp/source.PNG',
    );

    expect(
      path,
      p.join(
        '/app/documents',
        'photos',
        'plant_42',
        '${timestamp.millisecondsSinceEpoch}_fixed-id.png',
      ),
    );
  });
}
