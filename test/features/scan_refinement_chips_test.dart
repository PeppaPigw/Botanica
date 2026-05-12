import 'dart:async';
import 'dart:io';

import 'package:botanica/app/providers.dart';
import 'package:botanica/data/repositories/species_repository.dart';
import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/domain/services/plant_id/plant_identifier.dart';
import 'package:botanica/features/scan/scan_flow_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:botanica/services/permissions/permissions_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

class _FakePermissionsService implements PermissionsService {
  const _FakePermissionsService();
  @override
  Future<AppPermissionsSnapshot> snapshot() async =>
      const AppPermissionsSnapshot(
        notifications: AppPermissionDecision.denied,
        location: LocationPermissionSnapshot(
          serviceEnabled: true,
          decision: AppPermissionDecision.denied,
        ),
        camera: AppPermissionDecision.granted,
        photos: AppPermissionDecision.denied,
      );
  @override
  Future<AppPermissionDecision> requestNotifications() async =>
      AppPermissionDecision.denied;
  @override
  Future<LocationPermissionSnapshot> requestLocationWhenInUse() async =>
      const LocationPermissionSnapshot(
        serviceEnabled: true,
        decision: AppPermissionDecision.denied,
      );
  @override
  Future<AppPermissionDecision> requestCamera() async =>
      AppPermissionDecision.granted;
  @override
  Future<AppPermissionDecision> requestPhotos() async =>
      AppPermissionDecision.denied;
  @override
  Future<void> openSystemSettings() async {}
}

class _FakeSpeciesRepository extends SpeciesRepository {
  _FakeSpeciesRepository(this._species);
  final List<Species> _species;
  @override
  Future<List<Species>> getAll() async => _species;
  @override
  Future<Species?> byId(String id) async {
    for (final species in _species) {
      if (species.id == id) return species;
    }
    return null;
  }
}

Species _species({
  required String id,
  required String name,
  required bool petSafe,
  required String difficulty,
  required String light,
  List<String> tags = const <String>[],
}) {
  return Species(
    id: id,
    scientificName: 'Plantae $id',
    commonNamesByLocale: <String, List<String>>{
      'en': <String>[name]
    },
    difficulty: difficulty,
    petSafe: petSafe,
    light: light,
    tags: tags,
    careDefaults: const CareDefaults(
      waterBaseDays: 7,
      fertilizeBaseDays: 30,
      mistBaseDays: 0,
      rotateBaseDays: 14,
      pruneBaseDays: 90,
    ),
  );
}

Future<void> _settleUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

Future<void> _waitForFinder(WidgetTester tester, Finder finder,
    {int attempts = 120}) async {
  for (var i = 0; i < attempts; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  Future<XFile?> fakeCapture(BuildContext context,
      {required String title}) async {
    final dir = Directory.systemTemp.createTempSync('botanica_scan_refine_');
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });
    final imageFile = File('${dir.path}/scan.jpg')
      ..writeAsBytesSync(<int>[0, 1, 2, 3]);
    return XFile(imageFile.path);
  }

  Future<void> pumpFlow(
    WidgetTester tester,
    List<Species> species,
    Future<List<PlantIdCandidate>> Function(XFile, List<Species>) resolver,
    {bool waitForResults = true},
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          permissionsServiceProvider
              .overrideWithValue(const _FakePermissionsService()),
          speciesRepositoryProvider
              .overrideWithValue(_FakeSpeciesRepository(species)),
          settingsControllerProvider.overrideWith(
              () => _TestSettingsController(UserSettings.defaults())),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ScanFlowScreen(
            captureImage: fakeCapture,
            candidateResolver: resolver,
          ),
        ),
      ),
    );

    await _settleUi(tester);
    if (!waitForResults) return;
    final chooseFinder = find.text('Choose a match');
    await _waitForFinder(tester, chooseFinder);
    expect(chooseFinder, findsOneWidget);
  }

  testWidgets('scan refinement chips filter by intersection',
      (WidgetTester tester) async {
    final species = <Species>[
      _species(
          id: 'phalaenopsis_orchid',
          name: 'Orchid',
          petSafe: true,
          difficulty: 'moderate',
          light: 'bright_indirect'),
      _species(
          id: 'aloe_vera',
          name: 'Aloe Vera',
          petSafe: false,
          difficulty: 'easy',
          light: 'bright_indirect'),
      _species(
          id: 'hoya_carnosa',
          name: 'Hoya',
          petSafe: true,
          difficulty: 'easy',
          light: 'bright_indirect',
          tags: const <String>['drought-tolerant']),
    ];

    Future<List<PlantIdCandidate>> resolver(
            XFile _, List<Species> pool) async =>
        <PlantIdCandidate>[
          PlantIdCandidate(species: pool[0], confidence: 0.91),
          PlantIdCandidate(species: pool[1], confidence: 0.76),
          PlantIdCandidate(species: pool[2], confidence: 0.62),
        ];

    await pumpFlow(tester, species, resolver);

    expect(find.text('Orchid'), findsOneWidget);
    expect(find.text('Aloe Vera'), findsOneWidget);
    expect(find.text('Hoya'), findsOneWidget);
    expect(find.text('Not sure? Refine results'), findsOneWidget);
    expect(
        find.text('Answer a quick question to narrow the list.'),
        findsOneWidget);

    await tester.tap(find.text('Is it flowering?').first);
    await _settleUi(tester);
    expect(find.text('Aloe Vera'), findsNothing);
    expect(find.text('Orchid'), findsOneWidget);
    expect(find.text('Hoya'), findsOneWidget);

    await tester.tap(find.text('Succulent type?').first);
    await _settleUi(tester);
    expect(find.text('Orchid'), findsNothing);
    expect(find.text('Hoya'), findsOneWidget);
  });

  testWidgets(
      'scan refinement shows fallback note when filters yield no exact matches',
      (WidgetTester tester) async {
    final species = <Species>[
      _species(
          id: 'phalaenopsis_orchid',
          name: 'Orchid',
          petSafe: true,
          difficulty: 'moderate',
          light: 'bright_indirect'),
      _species(
          id: 'aloe_vera',
          name: 'Aloe Vera',
          petSafe: false,
          difficulty: 'easy',
          light: 'bright_indirect'),
      _species(
          id: 'c',
          name: 'Peperomia',
          petSafe: true,
          difficulty: 'easy',
          light: 'bright_indirect'),
    ];

    Future<List<PlantIdCandidate>> resolver(
            XFile _, List<Species> pool) async =>
        <PlantIdCandidate>[
          PlantIdCandidate(species: pool[0], confidence: 0.91),
          PlantIdCandidate(species: pool[1], confidence: 0.76),
          PlantIdCandidate(species: pool[2], confidence: 0.62),
        ];

    await pumpFlow(tester, species, resolver);

    await tester.tap(find.text('Is it flowering?').first);
    await _settleUi(tester);
    await tester.tap(find.text('Succulent type?').first);
    await _settleUi(tester);

    expect(
        find.text(
            'No exact matches for these filters yet—showing closest results.'),
        findsOneWidget);
    expect(find.text('Orchid'), findsOneWidget);
    expect(find.text('Aloe Vera'), findsOneWidget);
    expect(find.text('Peperomia'), findsOneWidget);
  });

  testWidgets('scan failure shows browse-library fallback',
      (WidgetTester tester) async {
    final species = <Species>[
      _species(
        id: 'a',
        name: 'Moon Fern',
        petSafe: true,
        difficulty: 'moderate',
        light: 'low_light',
      ),
    ];

    Future<List<PlantIdCandidate>> resolver(
      XFile _,
      List<Species> __,
    ) async {
      throw StateError('offline');
    }

    await pumpFlow(tester, species, resolver, waitForResults: false);
    await _settleUi(tester);

    expect(find.text('Could not identify this plant'), findsOneWidget);
    expect(find.text('Browse library instead'), findsOneWidget);
    expect(find.text('Try again'), findsWidgets);
  });

  testWidgets('scan timeout shows retry and browse-library fallback',
      (WidgetTester tester) async {
    final species = <Species>[
      _species(
        id: 'a',
        name: 'Moon Fern',
        petSafe: true,
        difficulty: 'moderate',
        light: 'low_light',
      ),
    ];

    Future<List<PlantIdCandidate>> resolver(
      XFile _,
      List<Species> __,
    ) async {
      return Completer<List<PlantIdCandidate>>().future;
    }

    await pumpFlow(tester, species, resolver, waitForResults: false);
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Taking longer than expected'), findsOneWidget);
    expect(find.text('Browse library instead'), findsOneWidget);
    expect(find.text('Try again'), findsWidgets);
  });
}
