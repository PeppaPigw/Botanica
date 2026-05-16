import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = CareLog(
    id: 'log-1',
    plantId: 'plant-1',
    type: TaskType.water,
    timestamp: DateTime(2026, 5, 15, 10, 30),
    note: 'Leaves look healthy',
    linkedPhotoId: 'photo-1',
  );

  group('CareLog.copyWith', () {
    test('preserves all fields when no arguments given', () {
      final copy = base.copyWith();
      expect(copy, equals(base));
    });

    test('updates note', () {
      final copy = base.copyWith(note: 'New note');
      expect(copy.note, 'New note');
      expect(copy.id, base.id);
      expect(copy.plantId, base.plantId);
      expect(copy.type, base.type);
      expect(copy.timestamp, base.timestamp);
      expect(copy.linkedPhotoId, base.linkedPhotoId);
    });

    test('clears note to null', () {
      final copy = base.copyWith(note: null);
      expect(copy.note, isNull);
      expect(copy.linkedPhotoId, 'photo-1');
    });

    test('clears linkedPhotoId to null', () {
      final copy = base.copyWith(linkedPhotoId: null);
      expect(copy.linkedPhotoId, isNull);
      expect(copy.note, 'Leaves look healthy');
    });

    test('clears both nullable fields', () {
      final copy = base.copyWith(note: null, linkedPhotoId: null);
      expect(copy.note, isNull);
      expect(copy.linkedPhotoId, isNull);
    });
  });

  group('CareLog serialization', () {
    test('roundtrips through JSON', () {
      final json = base.toJson();
      final restored = CareLog.fromJson(json);
      expect(restored, equals(base));
    });

    test('handles null note in JSON', () {
      final log = CareLog(
        id: 'log-2',
        plantId: 'plant-1',
        type: TaskType.fertilize,
        timestamp: DateTime(2026, 5, 10),
        note: null,
        linkedPhotoId: null,
      );
      final json = log.toJson();
      final restored = CareLog.fromJson(json);
      expect(restored.note, isNull);
      expect(restored.linkedPhotoId, isNull);
    });
  });
}
