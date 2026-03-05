import 'dart:convert';

import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/data/repositories/plant_idea_repository.dart';
import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/discover/discover_screen.dart';
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

Species _species(String id, String name) {
  return Species(
    id: id,
    scientificName: 'Plantae $id',
    commonNamesByLocale: <String, List<String>>{
      'en': <String>[name],
    },
    difficulty: 'easy',
    petSafe: true,
    light: 'bright_indirect',
    careDefaults: const CareDefaults(
      waterBaseDays: 7,
      fertilizeBaseDays: 28,
      mistBaseDays: 0,
      rotateBaseDays: 10,
      pruneBaseDays: 90,
    ),
    imagePath: 'assets/placeholders/species/unknown.png',
    historyByLocale: const <String, String>{
      'en': 'History',
    },
    habitByLocale: const <String, String>{
      'en': 'Habit',
    },
  );
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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Discover shows curated top 6 when query is empty',
      (WidgetTester tester) async {
    final list = List.generate(10, (i) => _species('s$i', 'Plant $i'));
    final repo = PlantIdeaRepository(
      loader: (_) async => jsonEncode(<String, dynamic>{
        'plants': [
          _ideaJson('idea_0', 'Idea plant'),
        ],
      }),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(UserSettings.defaults()),
          ),
          speciesListProvider.overrideWith((ref) async => list),
          plantIdeaRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DiscoverScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    for (var i = 0; i < 6; i++) {
      expect(find.text('Plant $i'), findsOneWidget);
    }
    expect(find.text('Plant 6'), findsNothing);
    expect(find.text('Plant 9'), findsNothing);
  });

  testWidgets('Discover shows full list when filters are active (empty query)',
      (WidgetTester tester) async {
    final list = List.generate(10, (i) => _species('s$i', 'Plant $i'));
    final repo = PlantIdeaRepository(
      loader: (_) async => jsonEncode(<String, dynamic>{
        'plants': [
          _ideaJson('idea_0', 'Idea plant'),
        ],
      }),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(UserSettings.defaults()),
          ),
          speciesListProvider.overrideWith((ref) async => list),
          plantIdeaRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DiscoverScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Enable a filter chip without entering a query.
    await tester.tap(find.byKey(const ValueKey('discover-filter-pets')));
    await tester.pumpAndSettle();

    // Filter is active, so results should not be truncated to 6.
    expect(find.text('Plant 9'), findsOneWidget);
  });

  testWidgets('Discover keeps filter selection when filter sheet is dismissed',
      (WidgetTester tester) async {
    final list = List.generate(10, (i) => _species('s$i', 'Plant $i'));
    final repo = PlantIdeaRepository(
      loader: (_) async => jsonEncode(<String, dynamic>{
        'plants': [
          _ideaJson('idea_0', 'Idea plant'),
        ],
      }),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(UserSettings.defaults()),
          ),
          speciesListProvider.overrideWith((ref) async => list),
          plantIdeaRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DiscoverScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Curated mode: only top 6 visible.
    expect(find.text('Plant 9'), findsNothing);

    // Apply a sheet-backed filter (difficulty) to activate full list mode.
    await tester.tap(find.byKey(const ValueKey('discover-filter-difficulty')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('discover-filter-difficulty-easy')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Plant 9'), findsOneWidget);

    // Re-open the sheet, then dismiss it by tapping outside.
    await tester.tap(find.byKey(const ValueKey('discover-filter-difficulty')));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Dismissal should not clear the active filter selection.
    expect(find.text('Plant 9'), findsOneWidget);
  });

  testWidgets('Discover shows all matches when searching',
      (WidgetTester tester) async {
    final list = List.generate(10, (i) => _species('s$i', 'Plant $i'));
    final repo = PlantIdeaRepository(
      loader: (_) async => jsonEncode(<String, dynamic>{
        'plants': [
          _ideaJson('idea_0', 'Idea plant'),
        ],
      }),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(UserSettings.defaults()),
          ),
          speciesListProvider.overrideWith((ref) async => list),
          plantIdeaRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DiscoverScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Plant');
    await tester.pumpAndSettle();

    expect(find.text('Plant 0'), findsOneWidget);
    expect(find.text('Plant 6'), findsOneWidget);
    expect(find.text('Plant 9'), findsOneWidget);
  });

  testWidgets('Discover shows a no-results card for unmatched queries',
      (WidgetTester tester) async {
    final list = List.generate(3, (i) => _species('s$i', 'Plant $i'));
    final repo = PlantIdeaRepository(
      loader: (_) async => jsonEncode(<String, dynamic>{
        'plants': [
          _ideaJson('idea_0', 'Idea plant'),
        ],
      }),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(UserSettings.defaults()),
          ),
          speciesListProvider.overrideWith((ref) async => list),
          plantIdeaRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DiscoverScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    // Curated section no-results state is visible first.
    expect(find.text('No matches'), findsOneWidget);

    // The library section may be lazily built below the fold (ListView), so
    // scroll down to ensure it is built before asserting both states exist.
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    // Both curated and library sections surface their own no-results state.
    expect(find.text('No matches'), findsNWidgets(2));
  });

  testWidgets('Discover search matches names across locales',
      (WidgetTester tester) async {
    final list = [
      const Species(
        id: 'pothos',
        scientificName: 'Epipremnum aureum',
        commonNamesByLocale: <String, List<String>>{
          'en': <String>['Pothos'],
          'zh': <String>['绿萝'],
        },
        difficulty: 'easy',
        petSafe: false,
        light: 'low_to_bright_indirect',
        careDefaults: CareDefaults(
          waterBaseDays: 7,
          fertilizeBaseDays: 30,
          mistBaseDays: 0,
          rotateBaseDays: 14,
          pruneBaseDays: 90,
        ),
        imagePath: 'assets/placeholders/species/unknown.png',
        historyByLocale: <String, String>{
          'en': 'History',
        },
        habitByLocale: <String, String>{
          'en': 'Habit',
        },
      ),
    ];
    final repo = PlantIdeaRepository(
      loader: (_) async => jsonEncode(<String, dynamic>{
        'plants': [
          _ideaJson('idea_0', 'Idea plant'),
        ],
      }),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(
              UserSettings.defaults().copyWith(localeCode: 'zh'),
            ),
          ),
          speciesListProvider.overrideWith((ref) async => list),
          plantIdeaRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DiscoverScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Pothos');
    await tester.pumpAndSettle();

    // UI renders Chinese bestCommonName (settings locale is zh),
    // but search should still match the English common name.
    expect(find.text('绿萝'), findsOneWidget);
  });
}
