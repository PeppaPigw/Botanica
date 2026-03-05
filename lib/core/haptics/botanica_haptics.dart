import 'package:flutter/services.dart';

class BotanicaHaptics {
  const BotanicaHaptics._();

  static void selectionTick() => HapticFeedback.selectionClick();

  static void primaryPress() => HapticFeedback.lightImpact();

  static void completion() => HapticFeedback.lightImpact();

  static void revealClimax() => HapticFeedback.mediumImpact();

  static void subtleError() => HapticFeedback.selectionClick();
}
