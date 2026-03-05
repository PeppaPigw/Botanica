import 'package:botanica/data/local/local_db.dart';
import 'package:botanica/core/widgets/botanica_nav_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:botanica/main.dart' as app;

import 'helpers/test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('journey: set tarot mode -> draw -> reveal -> share',
      (WidgetTester tester) async {
    final shareCalls = <MethodCall>[];
    const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shareChannel, (call) async {
      shareCalls.add(call);
      return null;
    });

    await app.main();
    await skipOnboardingAndPermissions(tester);
    await LocalDb.dailyDrawsBox.clear();
    await tester.pump(const Duration(seconds: 1));

    final navPill = find.byType(BotanicaNavPill);
    await pumpUntilFound(tester, navPill);
    expect(navPill, findsOneWidget);

    // Ensure Daily mode is set to Tarot via Profile.
    await tapNavIcon(
      tester,
      navPill: navPill,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    );

    await tester.tap(find.byKey(const ValueKey('profile-belief-mode')));
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byKey(const ValueKey('belief-mode-tarot')));
    await tester.pump(const Duration(seconds: 2));

    // Navigate to Daily and perform the draw.
    await tapNavIcon(
      tester,
      navPill: navPill,
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
    );

    await tester.tap(find.byKey(const ValueKey('tarot-draw-cta')));
    await tester.pump(const Duration(seconds: 2));

    // Tap the top-most card in the initial fan so the hit test is reliable.
    final card = find.byKey(const ValueKey('tarot-card-2'));
    await pumpUntilFound(tester, card);
    await tester.tap(card);
    await tester.pump(const Duration(seconds: 4));

    expect(find.byKey(const ValueKey('daily-flower-card')), findsOneWidget);

    // Open the share card screen, then share.
    await tester.tap(find.byKey(const ValueKey('daily-share-btn')));
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byKey(const ValueKey('daily-share-card-share')));
    await tester.pump(const Duration(seconds: 2));

    expect(shareCalls, isNotEmpty);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shareChannel, null);
  });
}
