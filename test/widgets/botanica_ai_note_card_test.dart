import 'package:botanica/core/widgets/botanica_ai_note_card.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BotanicaAiNoteCard copies text and shows snackbar',
      (WidgetTester tester) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (methodCall) async {
      if (methodCall.method == 'Clipboard.setData') {
        final args = Map<Object?, Object?>.from(methodCall.arguments as Map);
        copiedText = args['text'] as String?;
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: BotanicaAiNoteCard(
            title: 'Botanica note',
            textToCopy: 'Water less this week.',
            copyTooltip: 'Copy note',
            copiedMessage: 'Copied',
            child: Text('Water less this week.'),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.content_copy_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(copiedText, 'Water less this week.');
    expect(find.text('Copied'), findsOneWidget);
  });
}
