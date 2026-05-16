import 'dart:convert';

import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/data/repositories/plant_idea_repository.dart';
import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/plant.dart';
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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(800, 2400);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('search respects pet-safe filter', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byKey(const ValueKey('discover-filter-pets')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(TextField).first, 'Pothos');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('discover-species-pothos')), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'Aloe');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('discover-species-aloe')), findsOneWidget);
  });

  testWidgets('search matches tags and care warnings with filters', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byKey(const ValueKey('discover-filter-pets')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(TextField).first, 'low-light');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('discover-species-fern')), findsOneWidget);
    expect(find.byKey(const ValueKey('discover-species-pothos')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('discover-filter-pets')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(TextField).first, 'children');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.byKey(const ValueKey('discover-species-pothos')),
      findsOneWidget,
    );
  });
}

Widget _app() {
  return ProviderScope(
    overrides: [
      settingsControllerProvider.overrideWith(
        () => _TestSettingsController(UserSettings.defaults()),
      ),
      speciesListProvider.overrideWith((ref) async => _species),
      plantsStreamProvider.overrideWith(
        (ref) => Stream.value(const <Plant>[]),
      ),
      plantIdeaRepositoryProvider.overrideWithValue(
        PlantIdeaRepository(
          loader: (_) async => jsonEncode(<String, dynamic>{'plants': []}),
        ),
      ),
    ],
    child: MaterialApp(
      theme: BotanicaTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: DiscoverScreen()),
    ),
  );
}

final _species = <Species>[
  _plant(
    id: 'aloe',
    name: 'Aloe',
    petSafe: true,
    tags: const <String>['beginner'],
  ),
  _plant(
    id: 'fern',
    name: 'Fern',
    petSafe: true,
    tags: const <String>['low-light'],
  ),
  _plant(
    id: 'pothos',
    name: 'Pothos',
    petSafe: false,
    tags: const <String>['low-light'],
    careWarningsByLocale: const <String, String>{
      'en': 'Keep away from pets and children',
    },
  ),
];

Species _plant({
  required String id,
  required String name,
  required bool petSafe,
  required List<String> tags,
  Map<String, String> careWarningsByLocale = const <String, String>{},
}) {
  return Species(
    id: id,
    scientificName: 'Plantae $id',
    commonNamesByLocale: <String, List<String>>{
      'en': <String>[name],
    },
    difficulty: 'easy',
    petSafe: petSafe,
    light: 'bright_indirect',
    careDefaults: const CareDefaults(
      waterBaseDays: 7,
      fertilizeBaseDays: 28,
      mistBaseDays: 0,
      rotateBaseDays: 10,
      pruneBaseDays: 90,
    ),
    tags: tags,
    imagePath: 'assets/placeholders/species/unknown.png',
    historyByLocale: const <String, String>{'en': 'History'},
    habitByLocale: const <String, String>{'en': 'Habit'},
    careWarningsByLocale: careWarningsByLocale,
  );
}
