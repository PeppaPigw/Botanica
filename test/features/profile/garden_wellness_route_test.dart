import 'package:botanica/app/providers.dart';
import 'package:botanica/app/routing/app_router.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/profile/garden_wellness_screen.dart';
import 'package:botanica/features/profile/profile_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:botanica/services/permissions/permissions_service.dart';
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
        camera: AppPermissionDecision.denied,
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
      AppPermissionDecision.denied;

  @override
  Future<AppPermissionDecision> requestPhotos() async =>
      AppPermissionDecision.denied;

  @override
  Future<void> openSystemSettings() async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('profile route opens Garden Wellness screen',
      (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        settingsControllerProvider.overrideWith(
          () => _TestSettingsController(
            UserSettings.defaults().copyWith(hasCompletedOnboarding: true),
          ),
        ),
        permissionsServiceProvider.overrideWithValue(
          const _FakePermissionsService(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    router.go(ProfileScreen.location);
    await tester.pumpAndSettle();

    final l10n =
        AppLocalizations.of(tester.element(find.byType(ProfileScreen)));
    final tileFinder = find.text(l10n.gardenWellnessTitle);
    await tester.scrollUntilVisible(tileFinder, 200);
    expect(tileFinder, findsOneWidget);

    router.go('${ProfileScreen.location}/${GardenWellnessScreen.subLocation}');
    await tester.pumpAndSettle();

    expect(find.byType(GardenWellnessScreen), findsOneWidget);
  });
}
