import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily and calendar error cards use outlined BotanicaButton actions',
      () {
    const targets = <String>[
      'lib/features/daily/daily_screen.dart',
      'lib/features/calendar/calendar_screen.dart',
    ];

    for (final path in targets) {
      final source = File(path).readAsStringSync();

      expect(
        source,
        contains('primaryAction: BotanicaButton('),
        reason: '$path should use BotanicaButton for state-card primaryAction.',
      );
      expect(
        source,
        contains('variant: BotanicaButtonVariant.outlined'),
        reason: '$path should keep the retry action outlined.',
      );
      expect(
        source,
        isNot(contains('primaryAction: OutlinedButton.icon(')),
        reason:
            '$path should not use raw OutlinedButton.icon for the state card retry action.',
      );
    }
  });
}
