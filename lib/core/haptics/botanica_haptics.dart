import 'package:flutter/services.dart';

class BotanicaHaptics {
  const BotanicaHaptics._();

  static void selectionTick() => HapticFeedback.selectionClick();

  static void primaryPress() => HapticFeedback.lightImpact();

  static void completion() => HapticFeedback.lightImpact();

  static void success() => HapticFeedback.mediumImpact();

  static Future<void> milestone() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.lightImpact();
  }

  static Future<void> streakCelebration() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.mediumImpact();
  }

  static void revealClimax() => HapticFeedback.mediumImpact();

  static void subtleError() => HapticFeedback.selectionClick();

  static Future<void> allDone() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    HapticFeedback.mediumImpact();
  }
}
