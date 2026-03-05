import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:botanica/core/widgets/botanica_nav_pill.dart';
import 'package:botanica/core/widgets/botanica_search_field.dart';
import 'package:botanica/main.dart' as app;

import 'helpers/test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke: onboarding -> garden -> navigate tabs',
      (WidgetTester tester) async {
    await app.main();
    await skipOnboardingAndPermissions(tester);

    final navPill = find.byType(BotanicaNavPill);
    await pumpUntilFound(tester, navPill);
    expect(navPill, findsOneWidget);

    // Navigate to Discover and assert the unified search field renders.
    await tester.tap(
      find.descendant(of: navPill, matching: find.byIcon(Icons.search_rounded)),
    );
    await pumpUntilFound(tester, find.byType(BotanicaSearchField));
    expect(find.byType(BotanicaSearchField), findsOneWidget);

    // Navigate back to Garden (spa icon).
    final gardenIcon = find.descendant(
      of: navPill,
      matching: find.byIcon(Icons.spa_outlined),
    );
    final gardenSelectedIcon = find.descendant(
      of: navPill,
      matching: find.byIcon(Icons.spa_rounded),
    );

    await tester.tap(
      gardenIcon.evaluate().isNotEmpty ? gardenIcon : gardenSelectedIcon,
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(BotanicaNavPill), findsOneWidget);
  });
}
