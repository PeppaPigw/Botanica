import 'package:botanica/core/widgets/botanica_nav_pill.dart';
import 'package:botanica/core/widgets/botanica_search_field.dart';
import 'package:botanica/data/local/local_db.dart';
import 'package:botanica/features/species/species_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:botanica/main.dart' as app;

import 'helpers/test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('journey: discover -> add plant -> complete a task',
      (WidgetTester tester) async {
    await app.main();
    await skipOnboardingAndPermissions(tester);
    await LocalDb.plantsBox.clear();
    await LocalDb.tasksBox.clear();
    await LocalDb.logsBox.clear();
    await tester.pump(const Duration(seconds: 1));

    final navPill = find.byType(BotanicaNavPill);
    await pumpUntilFound(tester, navPill);
    expect(navPill, findsOneWidget);

    await tapNavIcon(
      tester,
      navPill: navPill,
      icon: Icons.search_rounded,
      selectedIcon: Icons.search_rounded,
    );

    final searchField = find.byType(BotanicaSearchField);
    expect(searchField, findsOneWidget);

    await tester.enterText(
      find.descendant(of: searchField, matching: find.byType(TextField)),
      'Monstera',
    );
    await tester.pump(const Duration(seconds: 2));

    // Tap the first PlantIdea result from the library section.
    final ideas = byKeyPrefix('discover-idea-');
    await pumpUntilFound(tester, ideas);
    expect(ideas, findsWidgets);
    final firstIdea = ideas.first;
    await tester.ensureVisible(firstIdea);
    final ideaTapTarget =
        find.descendant(of: firstIdea, matching: find.byType(InkWell)).first;
    await tester.tap(ideaTapTarget);
    await tester.pump(const Duration(seconds: 2));
    // If the keyboard was open, the first tap can dismiss it without triggering
    // navigation (platform-dependent). Tap again if we're still in the shell.
    if (navPill.evaluate().isNotEmpty) {
      await tester.tap(ideaTapTarget);
      await tester.pump(const Duration(seconds: 2));
    }

    final speciesDetail = find.byType(SpeciesDetailScreen);
    await pumpUntilFound(tester, speciesDetail);
    expect(speciesDetail, findsOneWidget);

    final addToGarden = find.byKey(const ValueKey('add-to-garden'));
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 20 && addToGarden.evaluate().isEmpty; i++) {
      await tester.drag(scrollable, const Offset(0, -520));
      await tester.pump(const Duration(milliseconds: 250));
    }
    await pumpUntilFound(
      tester,
      addToGarden,
      timeout: const Duration(seconds: 30),
    );
    await tester.tap(addToGarden);
    await tester.pump(const Duration(seconds: 2));

    final save = find.byKey(const ValueKey('add-plant-save'));
    await pumpUntilFound(tester, save);
    await tester.tap(save);
    await tester.pump(const Duration(seconds: 2));

    // The Add Plant screen pops back to Species Detail (root navigator). Return
    // to the shell so the bottom nav is available.
    final backButton = find.byType(BackButton);
    await pumpUntilFound(tester, backButton);
    await tester.tap(backButton.first);
    await tester.pump(const Duration(seconds: 2));
    await pumpUntilFound(tester, navPill);

    // Navigate to Garden and verify we have at least one plant card.
    await tapNavIcon(
      tester,
      navPill: navPill,
      icon: Icons.spa_outlined,
      selectedIcon: Icons.spa_rounded,
    );

    expect(byKeyPrefix('plant-'), findsWidgets);

    // Open Tasks from the Garden header.
    await tester.tap(find.byIcon(Icons.today_rounded));
    await tester.pump(const Duration(seconds: 2));

    // Upcoming tab (schedule icon).
    await tester.tap(find.byIcon(Icons.schedule_rounded));
    await tester.pump(const Duration(seconds: 2));

    final taskFinder = byKeyPrefix('task-');
    expect(taskFinder, findsWidgets);

    final firstTask = taskFinder.first;
    final taskKey = (tester.widget(firstTask).key as ValueKey).value.toString();
    final taskId = taskKey.startsWith('task-') ? taskKey.substring(5) : taskKey;

    // Swipe right to reveal the "Done" action and complete the task.
    await tester.drag(firstTask, const Offset(320, 0));
    await tester.pump(const Duration(seconds: 1));

    final doneAction = find.byKey(ValueKey('task-action-$taskId-done'));
    expect(doneAction, findsOneWidget);
    await tester.tap(doneAction);
    await tester.pump(const Duration(seconds: 2));

    // The completed task instance should no longer be present.
    expect(find.byKey(ValueKey(taskKey)), findsNothing);
  });
}
