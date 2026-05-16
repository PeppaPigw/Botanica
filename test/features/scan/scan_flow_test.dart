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

void main() {
  testWidgets('scan flow moves from initial to scanning to result',
      (tester) async {
    // Use a tall viewport so the 4:3 image doesn't push content offscreen.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final completer = Completer<List<PlantIdCandidate>>();
    final species = <Species>[_species('pilea', 'Pilea')];

    await _pumpFlow(
      tester,
      species: species,
      resolver: (_, __) => completer.future,
    );

    final l10n = _l10n(tester);
    expect(find.text(l10n.commonLoading), findsOneWidget);

    await _waitForAbsent(tester, find.text(l10n.commonLoading));
    expect(find.text(l10n.commonLoading), findsNothing);
    expect(find.text(l10n.scanProcessingBody), findsOneWidget);

    completer.complete(
      <PlantIdCandidate>[
        PlantIdCandidate(species: species.first, confidence: 0.91),
      ],
    );
    await _waitFor(tester, find.text(l10n.scanChooseCandidate));

    expect(find.text('Pilea'), findsOneWidget);

    // Let entrance animations finish to avoid pending timer assertions.
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('scan flow moves to timeout state', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpFlow(
      tester,
      species: <Species>[_species('pilea', 'Pilea')],
      resolver: (_, __) => Completer<List<PlantIdCandidate>>().future,
    );

    final l10n = _l10n(tester);
    await _waitForAbsent(tester, find.text(l10n.commonLoading));
    expect(find.text(l10n.scanProcessingBody), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(l10n.scanTakingLongerTitle), findsOneWidget);
  });

  testWidgets('scan flow moves to error state', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpFlow(
      tester,
      species: <Species>[_species('pilea', 'Pilea')],
      resolver: (_, __) async => throw StateError('offline'),
    );

    final l10n = _l10n(tester);
    await _waitFor(tester, find.text(l10n.scanNoResultTitle));

    expect(find.text(l10n.scanNoResultTitle), findsOneWidget);
  });
}

Future<void> _pumpFlow(
  WidgetTester tester, {
  required List<Species> species,
  required ScanCandidateResolver resolver,
}) async {
  final dir = Directory.systemTemp.createTempSync('botanica_scan_flow_');
  addTearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });
  final image = File('${dir.path}/scan.jpg')..writeAsBytesSync(<int>[0, 1, 2]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        permissionsServiceProvider
            .overrideWithValue(const _FakePermissionsService()),
        speciesRepositoryProvider.overrideWithValue(
          _FakeSpeciesRepository(species),
        ),
        settingsControllerProvider.overrideWith(
          () => _TestSettingsController(UserSettings.defaults()),
        ),
        lastScanResultProvider.overrideWith(
          (ref) => Stream.value(null),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScanFlowScreen(
          captureImage: (_, {required String title}) async => XFile(image.path),
          candidateResolver: resolver,
        ),
      ),
    ),
  );
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
}

Future<void> _waitForAbsent(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isEmpty) return;
  }
}

AppLocalizations _l10n(WidgetTester tester) {
  return AppLocalizations.of(tester.element(find.byType(ScanFlowScreen)));
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
      fertilizeBaseDays: 30,
      mistBaseDays: 0,
      rotateBaseDays: 14,
      pruneBaseDays: 90,
    ),
  );
}
