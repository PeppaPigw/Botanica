import 'package:botanica/services/quick_actions/quick_actions_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BotanicaQuickActionsService', () {
    test('onAction receives correct type for addPlant', () {
      QuickActionType? received;
      final service = BotanicaQuickActionsService(
        onAction: (action) => received = action,
      );

      service.onAction(QuickActionType.addPlant);
      expect(received, QuickActionType.addPlant);
    });

    test('onAction receives correct type for waterNow', () {
      QuickActionType? received;
      final service = BotanicaQuickActionsService(
        onAction: (action) => received = action,
      );

      service.onAction(QuickActionType.waterNow);
      expect(received, QuickActionType.waterNow);
    });

    test('onAction receives correct type for scanPlant', () {
      QuickActionType? received;
      final service = BotanicaQuickActionsService(
        onAction: (action) => received = action,
      );

      service.onAction(QuickActionType.scanPlant);
      expect(received, QuickActionType.scanPlant);
    });

    test('QuickActionType enum has expected values', () {
      expect(QuickActionType.values.length, 3);
      expect(QuickActionType.addPlant.name, 'addPlant');
      expect(QuickActionType.waterNow.name, 'waterNow');
      expect(QuickActionType.scanPlant.name, 'scanPlant');
    });
  });
}
