import 'package:botanica/core/widgets/botanica_nav_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:botanica/main.dart' as app;

import 'helpers/test_harness.dart';
import 'helpers/test_seed.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('journey: complete task -> see log in Plant Detail',
      (WidgetTester tester) async {
    await app.main();
    await skipOnboardingAndPermissions(tester);

    final now = DateTime.now();
    await seedOnePlantWithWaterTaskDueToday(now: now);
    await tester.pump(const Duration(seconds: 2));

    final navPill = find.byType(BotanicaNavPill);
    await pumpUntilFound(tester, navPill);
    expect(navPill, findsOneWidget);

    // Open Tasks from the Garden header.
    await tester.tap(find.byIcon(Icons.today_rounded));
    await tester.pump(const Duration(seconds: 2));

    final taskFinder = find.byKey(const ValueKey('task-t1'));
    await pumpUntilFound(tester, taskFinder);
    expect(taskFinder, findsOneWidget);

    // Complete the task (swipe -> Done).
    await tester.drag(taskFinder, const Offset(320, 0));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const ValueKey('task-action-t1-done')));
    await tester.pump(const Duration(seconds: 2));

    // Return to Garden, open the plant.
    final backButton = find.byType(BackButton);
    await pumpUntilFound(tester, backButton);
    await tester.tap(backButton.first);
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byKey(const ValueKey('plant-p1')));
    await tester.pump(const Duration(seconds: 2));

    // Open Logs tab and verify a log exists.
    await tester.tap(find.byKey(const ValueKey('plant-detail-tab-logs')));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byIcon(Icons.water_drop_rounded), findsWidgets);
  });
}
