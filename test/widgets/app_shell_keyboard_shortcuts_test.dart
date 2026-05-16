import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:botanica/app/providers.dart';
import 'package:botanica/app/routing/app_shell.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';

/// Finds the Shortcuts widget whose map contains an intent of [intentType].
Shortcuts _findShortcutsWithIntent(WidgetTester tester, Type intentType) {
  final allShortcuts = tester.widgetList<Shortcuts>(find.byType(Shortcuts));
  return allShortcuts.firstWhere(
    (s) => s.shortcuts.values.any((intent) => intent.runtimeType == intentType),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildShell() {
    return ProviderScope(
      overrides: [
        tasksStreamProvider
            .overrideWith((ref) => Stream.value(<TaskInstance>[])),
      ],
      child: MaterialApp(
        theme: BotanicaTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MediaQuery(
          data: MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 34),
            viewInsets: EdgeInsets.zero,
          ),
          child: AppShell(
            location: '/garden',
            child: SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  group('AppShell keyboard shortcuts', () {
    testWidgets('Shortcuts widget maps Cmd+N to AddPlantIntent',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildShell());
      await tester.pumpAndSettle();

      final shortcutsWidget =
          _findShortcutsWithIntent(tester, AddPlantIntent);
      final shortcuts = shortcutsWidget.shortcuts;

      final cmdN = shortcuts.entries.firstWhere(
        (e) =>
            e.key is SingleActivator &&
            (e.key as SingleActivator).trigger == LogicalKeyboardKey.keyN &&
            (e.key as SingleActivator).meta,
      );
      expect(cmdN.value, isA<AddPlantIntent>());
    });

    testWidgets('Shortcuts widget maps Cmd+W to WaterFirstDueIntent',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildShell());
      await tester.pumpAndSettle();

      final shortcutsWidget =
          _findShortcutsWithIntent(tester, WaterFirstDueIntent);
      final shortcuts = shortcutsWidget.shortcuts;

      final cmdW = shortcuts.entries.firstWhere(
        (e) =>
            e.key is SingleActivator &&
            (e.key as SingleActivator).trigger == LogicalKeyboardKey.keyW &&
            (e.key as SingleActivator).meta,
      );
      expect(cmdW.value, isA<WaterFirstDueIntent>());
    });

    test('AddPlantIntent and WaterFirstDueIntent are distinct intents', () {
      const addIntent = AddPlantIntent();
      const waterIntent = WaterFirstDueIntent();
      expect(addIntent, isA<Intent>());
      expect(waterIntent, isA<Intent>());
      expect(addIntent.runtimeType, isNot(waterIntent.runtimeType));
    });
  });
}
