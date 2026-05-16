import 'package:flutter_test/flutter_test.dart';
import 'package:botanica/domain/services/quick_check_in.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';

Plant _plant({String id = 'p1', bool archived = false}) => Plant(
      id: id,
      nickname: 'Monstera',
      speciesId: 'sp1',
      room: 'Room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: null,
      coverPhotoPath: null,
      createdAt: DateTime(2025, 1, 1),
      meta: const PlantMeta(),
      isArchived: archived,
    );

CareLog _log(String plantId, DateTime ts, {String? note}) => CareLog(
      id: 'log_${ts.millisecondsSinceEpoch}',
      plantId: plantId,
      type: TaskType.water,
      timestamp: ts,
      note: note,
      linkedPhotoId: null,
    );

void main() {
  final now = DateTime(2026, 5, 16, 10, 0);

  group('QuickCheckIn', () {
    test('does not prompt for archived plants', () {
      final plant = _plant(archived: true);
      final logs = List.generate(5, (i) => _log('p1', now.subtract(Duration(days: i))));
      expect(
        QuickCheckIn.shouldPrompt(plant: plant, recentLogs: logs, now: now, seed: 0),
        isFalse,
      );
    });

    test('does not prompt with fewer than 3 logs', () {
      final plant = _plant();
      final logs = [_log('p1', now.subtract(const Duration(days: 1)))];
      expect(
        QuickCheckIn.shouldPrompt(plant: plant, recentLogs: logs, now: now, seed: 0),
        isFalse,
      );
    });

    test('does not prompt if recent check-in exists', () {
      final plant = _plant();
      final logs = [
        _log('p1', now.subtract(const Duration(days: 1)), note: 'checkin:thriving'),
        _log('p1', now.subtract(const Duration(days: 2))),
        _log('p1', now.subtract(const Duration(days: 3))),
        _log('p1', now.subtract(const Duration(days: 4))),
      ];
      expect(
        QuickCheckIn.shouldPrompt(plant: plant, recentLogs: logs, now: now, seed: 0),
        isFalse,
      );
    });

    test('can prompt when conditions are met and seed aligns', () {
      final plant = _plant();
      final logs = List.generate(5, (i) => _log('p1', now.subtract(Duration(days: i + 1))));

      // Try multiple seeds to find one that triggers (1 in 4 chance)
      bool triggered = false;
      for (int seed = 0; seed < 20; seed++) {
        if (QuickCheckIn.shouldPrompt(plant: plant, recentLogs: logs, now: now, seed: seed)) {
          triggered = true;
          break;
        }
      }
      expect(triggered, isTrue);
    });

    test('responseToNote encodes correctly', () {
      expect(QuickCheckIn.responseToNote(QuickCheckInResponse.thriving), 'checkin:thriving');
      expect(QuickCheckIn.responseToNote(QuickCheckInResponse.okay), 'checkin:okay');
      expect(QuickCheckIn.responseToNote(QuickCheckInResponse.worried), 'checkin:worried');
    });

    test('noteToResponse decodes correctly', () {
      expect(QuickCheckIn.noteToResponse('checkin:thriving'), QuickCheckInResponse.thriving);
      expect(QuickCheckIn.noteToResponse('checkin:okay'), QuickCheckInResponse.okay);
      expect(QuickCheckIn.noteToResponse('checkin:worried'), QuickCheckInResponse.worried);
    });

    test('noteToResponse returns null for non-checkin notes', () {
      expect(QuickCheckIn.noteToResponse(null), isNull);
      expect(QuickCheckIn.noteToResponse('regular note'), isNull);
      expect(QuickCheckIn.noteToResponse('checkin:invalid'), isNull);
    });
  });
}
