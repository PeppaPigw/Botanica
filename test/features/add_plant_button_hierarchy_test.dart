import 'dart:convert';

import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/core/widgets/botanica_button.dart';
import 'package:botanica/data/repositories/plant_idea_repository.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/add_plant/add_plant_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _TestSettingsController extends SettingsController {
  _TestSettingsController(this._settings);

  final UserSettings _settings;

  @override
  UserSettings build() => _settings;
}

Map<String, dynamic> _ideaJson(String id, String name) {
  return <String, dynamic>{
    'plant_id': id,
    'scientific_name': 'Plantae $id',
    'common_names': <String, dynamic>{
      'en': <String>[name],
    },
    'category': 'indoor',
    'image_path': 'assets/placeholders/species/unknown.png',
    'difficulty': 'easy',
    'pet_safe': true,
    'light': 'bright_indirect',
    'history': const <String, String>{'en': 'History'},
    'habit': const <String, String>{'en': 'Habit'},
    'care_defaults': const <String, int>{
      'waterBaseDays': 7,
      'fertilizeBaseDays': 28,
      'mistBaseDays': 0,
      'rotateBaseDays': 10,
      'pruneBaseDays': 90,
    },
    'external_resources': const <String, String>{
      'wikipedia': 'https://example.com/wiki',
      'youtube_search': 'https://example.com/youtube',
      'baidu_baike_search': 'https://example.com/baike',
      'bilibili_search': 'https://example.com/bili',
      'care_guide': 'https://example.com/guide',
    },
  };
}

Finder _ancestorButtonWithLabel(
  String label,
  bool Function(Widget widget) matches,
) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate(matches),
  );
}

Finder _filledButtonWithLabel(String label) =>
    _ancestorButtonWithLabel(label, (widget) => widget is FilledButton);

Finder _outlinedButtonWithLabel(String label) =>
    _ancestorButtonWithLabel(label, (widget) => widget is OutlinedButton);

Finder _botanicaButtonWithLabel(String label) =>
    _ancestorButtonWithLabel(label, (widget) => widget is BotanicaButton);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Add Plant keeps save filled and scan launcher outlined',
      (WidgetTester tester) async {
    final repo = PlantIdeaRepository(
      loader: (_) async => jsonEncode(<String, dynamic>{
        'plants': [_ideaJson('monstera_deliciosa', 'Monstera')],
      }),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(UserSettings.defaults()),
          ),
          plantIdeaRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AddPlantScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final l10n =
        AppLocalizations.of(tester.element(find.byType(AddPlantScreen)));

    await tester.tap(find.text(l10n.addPlantMethodScan));
    await tester.pumpAndSettle();

    expect(find.text(l10n.addPlantSaveButton), findsOneWidget);
    expect(_filledButtonWithLabel(l10n.addPlantSaveButton), findsOneWidget);

    expect(find.text(l10n.addPlantScanButton), findsOneWidget);
    expect(_outlinedButtonWithLabel(l10n.addPlantScanButton), findsOneWidget);
    expect(_filledButtonWithLabel(l10n.addPlantScanButton), findsNothing);
    expect(_botanicaButtonWithLabel(l10n.addPlantScanButton), findsOneWidget);
  });
}
