import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/profile/daily_profile_section.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _TestSettingsController extends SettingsController {
  _TestSettingsController(this._settings);

  UserSettings _settings;

  @override
  UserSettings build() => _settings;

  @override
  Future<void> update(UserSettings settings) async {
    _settings = settings;
    state = settings;
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Picking birthdate does not dispose seed controller prematurely',
      (WidgetTester tester) async {
    final initial = UserSettings.defaults().copyWith(
      beliefMode: BeliefMode.almanac,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(initial),
          ),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DailyProfileSection()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final context = tester.element(find.byType(DailyProfileSection));
    final l10n = AppLocalizations.of(context);
    final okLabel = MaterialLocalizations.of(context).okButtonLabel;

    // Open the Daily Profile sheet.
    await tester.tap(find.text(l10n.profileDailyProfileTitle));
    await tester.pumpAndSettle();

    // Open the date picker ("Add" birthdate).
    await tester.tap(find.widgetWithText(TextButton, l10n.commonAdd));
    await tester.pumpAndSettle();

    // Accept the default selected date (no need to change the day).
    await tester.tap(find.text(okLabel));
    await tester.pumpAndSettle();

    // The seed TextField should still be usable after setting birthdate.
    final seedField = find.byType(TextField).first;
    expect(seedField, findsOneWidget);
    await tester.enterText(seedField, 'my seed');
    await tester.pump();
  });

  testWidgets('Closing sheet after birthdate keeps controllers safe',
      (WidgetTester tester) async {
    final initial = UserSettings.defaults().copyWith(
      beliefMode: BeliefMode.almanac,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(initial),
          ),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DailyProfileSection()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final context = tester.element(find.byType(DailyProfileSection));
    final l10n = AppLocalizations.of(context);
    final okLabel = MaterialLocalizations.of(context).okButtonLabel;

    // Open the Daily Profile sheet.
    await tester.tap(find.text(l10n.profileDailyProfileTitle));
    await tester.pumpAndSettle();

    // Pick a birthdate.
    await tester.tap(find.widgetWithText(TextButton, l10n.commonAdd));
    await tester.pumpAndSettle();
    await tester.tap(find.text(okLabel));
    await tester.pumpAndSettle();

    // Close the sheet and ensure no disposed-controller exceptions are thrown.
    Navigator.of(context).pop();
    await tester.pumpAndSettle();

    // Re-open and type into the seed field.
    await tester.tap(find.text(l10n.profileDailyProfileTitle));
    await tester.pumpAndSettle();

    final seedField = find.byType(TextField).first;
    expect(seedField, findsOneWidget);
    await tester.enterText(seedField, 'seed again');
    await tester.pump();
  });
}
