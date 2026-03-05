import 'package:botanica/core/widgets/botanica_nav_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> skipOnboardingAndPermissions(WidgetTester tester) async {
  // Avoid `pumpAndSettle` because the app has intentional repeating animations
  // (e.g. shimmer loaders) that can prevent settling.
  //
  // The app starts at Splash, then redirects to either Onboarding/Permissions
  // or the main shell (NavPill). In tests we aggressively drive toward the
  // main shell by tapping the known skip buttons if/when they appear.
  final navPill = find.byType(BotanicaNavPill);
  final skipFinder = find.byKey(const ValueKey('onboarding-skip'));
  final notNowFinder = find.byKey(const ValueKey('permissions-not-now'));

  final end = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));

    if (skipFinder.evaluate().isNotEmpty) {
      await tester.tap(skipFinder);
      await tester.pump(const Duration(seconds: 1));
      continue;
    }

    if (notNowFinder.evaluate().isNotEmpty) {
      await tester.tap(notNowFinder);
      await tester.pump(const Duration(seconds: 1));
      continue;
    }

    if (navPill.evaluate().isNotEmpty) return;
  }

  throw TestFailure(
    'Timed out skipping onboarding/permissions (NavPill never appeared).',
  );
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 200),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for finder: $finder');
}

Future<void> tapNavIcon(
  WidgetTester tester, {
  required Finder navPill,
  required IconData icon,
  required IconData selectedIcon,
}) async {
  final unselected = find.descendant(of: navPill, matching: find.byIcon(icon));
  final selected =
      find.descendant(of: navPill, matching: find.byIcon(selectedIcon));

  await tester.tap(unselected.evaluate().isNotEmpty ? unselected : selected);
  await tester.pump(const Duration(seconds: 2));
}

Finder byKeyPrefix(String prefix) {
  return find.byWidgetPredicate((widget) {
    final key = widget.key;
    if (key is ValueKey<String>) {
      return key.value.startsWith(prefix);
    }
    if (key is ValueKey) {
      final value = key.value;
      return value is String && value.startsWith(prefix);
    }
    return false;
  });
}
