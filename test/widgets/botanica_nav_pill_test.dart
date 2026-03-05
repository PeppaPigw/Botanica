import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/app/theme/botanica_tokens.dart';
import 'package:botanica/core/widgets/botanica_nav_pill.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('BotanicaNavPill uses 72px outer height and 48px+ hit targets',
      (WidgetTester tester) async {
    var selectedIndex = -1;

    final destinations = <BotanicaNavDestination>[
      const BotanicaNavDestination(
        icon: Icons.spa_outlined,
        selectedIcon: Icons.spa_rounded,
        label: 'Garden',
      ),
      const BotanicaNavDestination(
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        label: 'Calendar',
      ),
      const BotanicaNavDestination(
        icon: Icons.search_rounded,
        selectedIcon: Icons.search_rounded,
        label: 'Discover',
      ),
      const BotanicaNavDestination(
        icon: Icons.auto_awesome_outlined,
        selectedIcon: Icons.auto_awesome_rounded,
        label: 'Daily',
      ),
      const BotanicaNavDestination(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: BotanicaTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: BotanicaTokens.maxContentWidth,
              child: BotanicaNavPill(
                currentIndex: 0,
                destinations: destinations,
                onSelect: (index) => selectedIndex = index,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final pillSize = tester.getSize(find.byType(BotanicaNavPill));
    expect(pillSize.height, BotanicaTokens.navPillHeight);

    final inkWells = find.descendant(
      of: find.byType(BotanicaNavPill),
      matching: find.byType(InkWell),
    );
    expect(inkWells, findsNWidgets(destinations.length));

    for (var i = 0; i < destinations.length; i++) {
      final size = tester.getSize(inkWells.at(i));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }

    // Tapping an icon triggers selection callback.
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pump();
    expect(selectedIndex, 1);
  });
}
