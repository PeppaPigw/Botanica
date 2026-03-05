import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/core/widgets/glass_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('BotanicaGlassCard renders child content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BotanicaTheme.light(),
        home: const Scaffold(
          body: Center(
            child: BotanicaGlassCard(
              child: Text('Hello Botanica'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Hello Botanica'), findsOneWidget);
  });
}
