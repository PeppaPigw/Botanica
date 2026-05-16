import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:botanica/app/providers.dart';
import 'package:botanica/app/routing/app_shell.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/core/widgets/botanica_nav_pill.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('AppShell keeps nav pill close to the bottom safe area',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final logicalHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksStreamProvider
              .overrideWith((ref) => Stream.value(<TaskInstance>[])),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light().copyWith(platform: TargetPlatform.iOS),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MediaQuery(
            data: MediaQueryData(
              padding: EdgeInsets.only(bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
              viewInsets: EdgeInsets.zero,
            ),
            child: AppShell(location: '/garden', child: SizedBox.expand()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final navFinder = find.byType(BotanicaNavPill);
    expect(navFinder, findsOneWidget);

    final rect = tester.getRect(navFinder);
    final gap = logicalHeight - rect.bottom;

    // If the nav pill floats too high, it can look like it's in the middle of
    // the screen on compact devices. This guards against accidental double
    // application of safe-area padding.
    expect(gap, inInclusiveRange(0, 12));
  });
}
