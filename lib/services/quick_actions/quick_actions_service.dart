import 'dart:io';

import 'package:quick_actions_platform_interface/quick_actions_platform_interface.dart';

enum QuickActionType {
  addPlant,
  waterNow,
  scanPlant,
}

class BotanicaQuickActionsService {
  BotanicaQuickActionsService({required this.onAction});

  final void Function(QuickActionType action) onAction;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!Platform.isIOS && !Platform.isAndroid) return;
    _initialized = true;

    final platform = QuickActionsPlatform.instance;

    await platform.initialize((type) {
      final action = _parseType(type);
      if (action != null) onAction(action);
    });

    await platform.setShortcutItems([
      ShortcutItem(
        type: QuickActionType.addPlant.name,
        localizedTitle: 'Add Plant',
        icon: Platform.isIOS ? 'plus.circle' : 'ic_shortcut_add',
      ),
      ShortcutItem(
        type: QuickActionType.waterNow.name,
        localizedTitle: 'Water Now',
        icon: Platform.isIOS ? 'drop.fill' : 'ic_shortcut_water',
      ),
      ShortcutItem(
        type: QuickActionType.scanPlant.name,
        localizedTitle: 'Scan Plant',
        icon: Platform.isIOS ? 'camera.viewfinder' : 'ic_shortcut_scan',
      ),
    ]);
  }

  QuickActionType? _parseType(String type) => switch (type) {
        'addPlant' => QuickActionType.addPlant,
        'waterNow' => QuickActionType.waterNow,
        'scanPlant' => QuickActionType.scanPlant,
        _ => null,
      };
}
