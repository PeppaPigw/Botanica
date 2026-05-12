import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/domain/models/environment_snapshot.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_idea.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/garden/garden_screen.dart';
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

Plant _plant(String id, String nickname, String room) => Plant(
      id: id,
      nickname: nickname,
      speciesId: 'species_$id',
      room: room,
      environmentMode: EnvironmentMode.indoor,
      coverAsset: 'assets/placeholders/species/unknown.png',
      createdAt: DateTime(2026, 3, 7),
      meta: const PlantMeta(),
    );

Future<void> _pumpGarden(
  WidgetTester tester, {
  required List<Plant> plants,
  String? initialSelectedRoom,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsControllerProvider.overrideWith(
          () => _TestSettingsController(UserSettings.defaults()),
        ),
        plantsStreamProvider.overrideWith((ref) => Stream.value(plants)),
        tasksStreamProvider
            .overrideWith((ref) => Stream.value(const <TaskInstance>[])),
        speciesListProvider.overrideWith((ref) async => const <Species>[]),
        plantIdeaMapProvider
            .overrideWith((ref) async => const <String, PlantIdea>{}),
        environmentSnapshotProvider.overrideWithValue(
          EnvironmentSnapshot(
            timestamp: DateTime(2026, 3, 7),
            tempC: 22,
            humidity: 50,
            weatherCode: 1,
          ),
        ),
      ],
      child: MaterialApp(
        theme: BotanicaTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: GardenScreen(initialSelectedRoom: initialSelectedRoom)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _showPlant(WidgetTester tester, String name) async {
  final finder = find.text(name);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('filters visible plants by selected room',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await _pumpGarden(
      tester,
      plants: <Plant>[
        _plant('a', 'Aloe', 'Living room'),
        _plant('b', 'Pothos', 'Bedroom'),
        _plant('c', 'Fern', 'Living room'),
      ],
    );

    final l10n = AppLocalizations.of(tester.element(find.byType(GardenScreen)));

    expect(find.text(l10n.gardenRoomsTitle), findsOneWidget);
    expect(find.text(l10n.gardenRoomsAll), findsOneWidget);
    expect(find.text('Living room'), findsOneWidget);
    expect(find.text('Bedroom'), findsOneWidget);

    await _showPlant(tester, 'Aloe');
    await _showPlant(tester, 'Pothos');
    await _showPlant(tester, 'Fern');
    expect(find.text('Aloe'), findsOneWidget);
    expect(find.text('Pothos'), findsOneWidget);
    expect(find.text('Fern'), findsOneWidget);

    await tester.tap(find.text('Living room').first);
    await tester.pumpAndSettle();
    expect(find.text('Aloe'), findsOneWidget);
    expect(find.text('Fern'), findsOneWidget);
    expect(find.text('Pothos'), findsNothing);

    await tester.tap(find.text('Bedroom').first);
    await tester.pumpAndSettle();
    expect(find.text('Pothos'), findsOneWidget);
    expect(find.text('Aloe'), findsNothing);
    expect(find.text('Fern'), findsNothing);

    await tester.tap(find.text(l10n.gardenRoomsAll).first);
    await tester.pumpAndSettle();
    await _showPlant(tester, 'Aloe');
    await _showPlant(tester, 'Pothos');
    await _showPlant(tester, 'Fern');
    expect(find.text('Aloe'), findsOneWidget);
    expect(find.text('Pothos'), findsOneWidget);
    expect(find.text('Fern'), findsOneWidget);
  });

  testWidgets('applies initial selected room filter on first render',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await _pumpGarden(
      tester,
      plants: <Plant>[
        _plant('a', 'Aloe', 'Living room'),
        _plant('b', 'Pothos', 'Bedroom'),
        _plant('c', 'Fern', 'Living room'),
      ],
      initialSelectedRoom: 'Living room',
    );

    await _showPlant(tester, 'Aloe');
    await _showPlant(tester, 'Fern');
    expect(find.text('Aloe'), findsOneWidget);
    expect(find.text('Fern'), findsOneWidget);
    expect(find.text('Pothos'), findsNothing);
  });

  testWidgets('applies initial unassigned room filter on first render',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await _pumpGarden(
      tester,
      plants: <Plant>[
        _plant('a', 'Nameless', ''),
        _plant('b', 'Pothos', 'Bedroom'),
        _plant('c', 'Fern', ''),
      ],
      initialSelectedRoom: 'Unassigned',
    );

    await _showPlant(tester, 'Nameless');
    await _showPlant(tester, 'Fern');
    expect(find.text('Nameless'), findsOneWidget);
    expect(find.text('Fern'), findsOneWidget);
    expect(find.text('Pothos'), findsNothing);
  });

  testWidgets('renders localized unassigned room label in Spanish',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await _pumpGarden(
      tester,
      plants: <Plant>[
        _plant('a', 'Nameless', ''),
        _plant('b', 'Pothos', 'Bedroom'),
        _plant('c', 'Fern', ''),
      ],
      initialSelectedRoom: 'Unassigned',
      locale: const Locale('es'),
    );

    final l10n = AppLocalizations.of(tester.element(find.byType(GardenScreen)));

    expect(find.text(l10n.gardenWellnessRoomUnassigned), findsOneWidget);
    expect(find.text('Unassigned'), findsNothing);
    expect(find.text('Pothos'), findsNothing);
  });

  testWidgets('hides filter row when only one distinct room exists',
      (WidgetTester tester) async {
    await _pumpGarden(
      tester,
      plants: <Plant>[
        _plant('a', 'Aloe', 'Living room'),
        _plant('b', 'Fern', 'Living room'),
      ],
    );

    final l10n = AppLocalizations.of(tester.element(find.byType(GardenScreen)));

    expect(find.text(l10n.gardenRoomsTitle), findsNothing);
    expect(find.text(l10n.gardenRoomsAll), findsNothing);
    expect(find.text('Living room'), findsNothing);
  });
}
