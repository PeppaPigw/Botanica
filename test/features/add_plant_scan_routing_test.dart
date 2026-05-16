import 'dart:convert';
import 'dart:io';

import 'package:botanica/app/providers.dart';
import 'package:botanica/data/repositories/plant_idea_repository.dart';
import 'package:botanica/data/repositories/scan_result_cache_repository.dart';
import 'package:botanica/data/repositories/species_repository.dart';
import 'package:botanica/domain/models/care_defaults.dart';
import 'package:botanica/domain/models/species.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/domain/services/plant_id/plant_identifier.dart';
import 'package:botanica/features/add_plant/add_plant_screen.dart';
import 'package:botanica/features/scan/scan_flow_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:botanica/services/permissions/permissions_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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

class _FakeScanResultCacheRepository implements ScanResultCacheRepository {
  CachedScanResult? _last;
  @override
  CachedScanResult? readLast() => _last;
  @override
  Stream<CachedScanResult?> watchLast() => Stream.value(_last);
  @override
  Future<void> save({required String speciesId, required double confidence}) async {
    _last = CachedScanResult(
      speciesId: speciesId,
      confidence: confidence,
      scannedAt: DateTime.now(),
    );
  }
}

class _ResultHost extends StatefulWidget {
  const _ResultHost({required this.builder});
  final Widget Function(ValueChanged<ScanResult?> setResult) builder;
  @override
  State<_ResultHost> createState() => _ResultHostState();
}

class _ResultHostState extends State<_ResultHost> {
  ScanResult? result;
  @override
  Widget build(BuildContext context) => widget.builder((value) {
        setState(() => result = value);
      });
}

Future<void> _settleUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

Future<void> _waitForFinder(WidgetTester tester, Finder finder,
    {int attempts = 30}) async {
  for (var i = 0; i < attempts; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Map<String, dynamic> _ideaJson(String id, String name) {
  return <String, dynamic>{
    'plant_id': id,
    'scientific_name': 'Plantae $id',
    'common_names': <String, dynamic>{
      'en': <String>[name]
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

Species _species(String id, String name) {
  return Species(
    id: id,
    scientificName: 'Plantae $id',
    commonNamesByLocale: <String, List<String>>{
      'en': <String>[name]
    },
    difficulty: 'easy',
    petSafe: false,
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

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(800, 1600);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('ScanFlowScreen returns ScanResult after candidate selection',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    final species = <Species>[
      _species('epipremnum_aureum', 'Pothos'),
      _species('monstera_deliciosa', 'Monstera'),
    ];
    final speciesRepo = _FakeSpeciesRepository(species);

    final imageDir =
        Directory.systemTemp.createTempSync('botanica_scan_route_');
    addTearDown(() {
      if (imageDir.existsSync()) imageDir.deleteSync(recursive: true);
    });
    final imageFile = File('${imageDir.path}/scan.jpg')
      ..writeAsBytesSync(<int>[0, 1, 2, 3]);

    Future<XFile?> fakeCapture(BuildContext context,
            {required String title}) async =>
        XFile(imageFile.path);
    Future<List<PlantIdCandidate>> resolveCandidates(
        XFile imageFile, List<Species> speciesPool) async {
      Species speciesFor(String id) =>
          speciesPool.firstWhere((species) => species.id == id);
      return <PlantIdCandidate>[
        PlantIdCandidate(
            species: speciesFor('epipremnum_aureum'), confidence: 0.91),
        PlantIdCandidate(
            species: speciesFor('monstera_deliciosa'), confidence: 0.76),
      ];
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          permissionsServiceProvider
              .overrideWithValue(const _FakePermissionsService()),
          speciesRepositoryProvider.overrideWithValue(speciesRepo),
          settingsControllerProvider.overrideWith(
              () => _TestSettingsController(UserSettings.defaults())),
          lastScanResultProvider.overrideWith(
            (ref) => Stream.value(null),
          ),
          scanResultCacheRepositoryProvider
              .overrideWithValue(_FakeScanResultCacheRepository()),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _ResultHost(
            builder: (setResult) => Scaffold(
              body: Builder(
                builder: (context) => FilledButton(
                  onPressed: () async {
                    final result =
                        await Navigator.of(context).push<ScanResult?>(
                      PageRouteBuilder<ScanResult?>(
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (_, __, ___) => ScanFlowScreen(
                          captureImage: fakeCapture,
                          candidateResolver: resolveCandidates,
                        ),
                      ),
                    );
                    setResult(result);
                  },
                  child: const Text('Open scan'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await _settleUi(tester);
    await tester.tap(find.text('Open scan'));
    await _settleUi(tester);

    final scanRouteFinder = find.byType(ScanFlowScreen, skipOffstage: false);
    await _waitForFinder(tester, scanRouteFinder);
    final scanL10n = AppLocalizations.of(tester.element(scanRouteFinder));
    final chooseFinder =
        find.text(scanL10n.scanChooseCandidate, skipOffstage: false);
    await _waitForFinder(tester, chooseFinder);
    expect(chooseFinder, findsOneWidget);
    expect(find.text('Pothos', skipOffstage: false), findsWidgets);

    final addFinder = find.text(scanL10n.scanAddToGarden, skipOffstage: false);

    await tester.tap(find.text('Pothos', skipOffstage: false).last);
    await _settleUi(tester);
    await tester.tap(addFinder);
    await _settleUi(tester);

    expect(find.byType(ScanFlowScreen, skipOffstage: false), findsNothing);
    final hostState = tester.state<_ResultHostState>(find.byType(_ResultHost));
    expect(hostState.result, isNotNull);
    expect(hostState.result!.speciesId, 'epipremnum_aureum');
    expect(hostState.result!.imagePath, imageFile.path);
  });

  testWidgets('AddPlantScreen applies returned ScanResult from opener seam',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    final species = <Species>[
      _species('epipremnum_aureum', 'Pothos'),
      _species('monstera_deliciosa', 'Monstera'),
    ];
    final speciesRepo = _FakeSpeciesRepository(species);
    final ideaRepo = PlantIdeaRepository(
      loader: (_) async => jsonEncode(<String, dynamic>{
        'plants': <Map<String, dynamic>>[
          _ideaJson('epipremnum_aureum', 'Pothos'),
          _ideaJson('monstera_deliciosa', 'Monstera'),
        ],
      }),
    );

    final imageDir =
        Directory.systemTemp.createTempSync('botanica_scan_apply_');
    addTearDown(() {
      if (imageDir.existsSync()) imageDir.deleteSync(recursive: true);
    });
    final imageFile = File('${imageDir.path}/scan.jpg')
      ..writeAsBytesSync(<int>[0, 1, 2, 3]);

    Future<ScanResult?> openScan(BuildContext context) async {
      return ScanResult(
          speciesId: 'epipremnum_aureum', imagePath: imageFile.path);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
              () => _TestSettingsController(UserSettings.defaults())),
          speciesRepositoryProvider.overrideWithValue(speciesRepo),
          plantIdeaRepositoryProvider.overrideWithValue(ideaRepo),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AddPlantScreen(scanFlowOpener: openScan)),
        ),
      ),
    );

    await _settleUi(tester);
    await tester.tap(find.text('Scan'));
    await _settleUi(tester);
    await tester.tap(find.text('Scan now'));
    await _settleUi(tester);

    final nicknameFinder = find.byWidgetPredicate((widget) {
      if (widget is! TextField) return false;
      final prefix = widget.decoration?.prefixIcon;
      return prefix is Icon && prefix.icon == Icons.badge_rounded;
    });
    await _waitForFinder(tester, nicknameFinder);
    expect(nicknameFinder, findsOneWidget);
    final nicknameField = tester.widget<TextField>(nicknameFinder);
    expect(nicknameField.controller?.text, 'Pothos');

    final saveFinder = find.widgetWithText(FilledButton, 'Save to Garden');
    expect(saveFinder, findsOneWidget);
    final saveButton = tester.widget<FilledButton>(saveFinder);
    expect(saveButton.onPressed, isNotNull);

    final scanImageFinder = find.byWidgetPredicate((widget) {
      if (widget is! Image) return false;
      final provider = widget.image;
      return provider is FileImage && provider.file.path == imageFile.path;
    });
    expect(scanImageFinder, findsOneWidget);
  });
}
