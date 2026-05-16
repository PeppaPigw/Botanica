import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Care stats consistency calculation', () {
    List<CareLog> waterLogs(List<DateTime> timestamps) {
      return timestamps.asMap().entries.map((e) => CareLog(
            id: 'log-${e.key}',
            plantId: 'plant-1',
            type: TaskType.water,
            timestamp: e.value,
            note: null,
            linkedPhotoId: null,
          )).toList();
    }

    int computeConsistency(List<CareLog> waterLogs) {
      waterLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final intervals = <int>[];
      for (int i = 1; i < waterLogs.length; i++) {
        intervals.add(
          waterLogs[i].timestamp.difference(waterLogs[i - 1].timestamp).inDays,
        );
      }
      if (intervals.isEmpty) return 0;
      final avg = intervals.fold<int>(0, (s, v) => s + v) / intervals.length;
      final consistentCount = intervals.where((d) {
        return (d - avg).abs() <= 2;
      }).length;
      return consistentCount * 100 ~/ intervals.length;
    }

    test('perfectly consistent intervals yield 100%', () {
      final logs = waterLogs([
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 8),
        DateTime(2026, 5, 15),
        DateTime(2026, 5, 22),
      ]);
      expect(computeConsistency(logs), 100);
    });

    test('slightly varied intervals within tolerance yield 100%', () {
      final logs = waterLogs([
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 8),
        DateTime(2026, 5, 14), // 6 days instead of 7
        DateTime(2026, 5, 22), // 8 days instead of 7
      ]);
      expect(computeConsistency(logs), 100);
    });

    test('one outlier among many consistent intervals reduces but does not zero consistency', () {
      final logs = waterLogs([
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 8),  // 7 days
        DateTime(2026, 5, 15), // 7 days
        DateTime(2026, 5, 22), // 7 days
        DateTime(2026, 5, 29), // 7 days
        DateTime(2026, 6, 12), // 14 days — outlier
      ]);
      final consistency = computeConsistency(logs);
      expect(consistency, lessThan(100));
      expect(consistency, greaterThan(0));
    });

    test('completely irregular intervals yield 0% consistency', () {
      final logs = waterLogs([
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 3),  // 2 days
        DateTime(2026, 5, 20), // 17 days
        DateTime(2026, 5, 22), // 2 days
      ]);
      final consistency = computeConsistency(logs);
      expect(consistency, 0);
    });

    test('two logs yield single interval at 100%', () {
      final logs = waterLogs([
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 8),
      ]);
      expect(computeConsistency(logs), 100);
    });
  });
}
