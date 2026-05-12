import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/core/widgets/botanica_button.dart';
import 'package:botanica/features/onboarding/permissions_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:botanica/services/permissions/permissions_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakePermissionsService implements PermissionsService {
  const _FakePermissionsService(this.snapshotValue);

  final AppPermissionsSnapshot snapshotValue;

  @override
  Future<AppPermissionsSnapshot> snapshot() async => snapshotValue;

  @override
  Future<AppPermissionDecision> requestNotifications() async {
    return snapshotValue.notifications;
  }

  @override
  Future<LocationPermissionSnapshot> requestLocationWhenInUse() async {
    return snapshotValue.location;
  }

  @override
  Future<AppPermissionDecision> requestCamera() async {
    return snapshotValue.camera;
  }

  @override
  Future<AppPermissionDecision> requestPhotos() async {
    return snapshotValue.photos;
  }

  @override
  Future<void> openSystemSettings() async {}
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

Finder _outlinedButtonWithLabel(String label) =>
    _ancestorButtonWithLabel(label, (widget) => widget is OutlinedButton);

Finder _filledButtonWithLabel(String label) =>
    _ancestorButtonWithLabel(label, (widget) => widget is FilledButton);

Finder _textButtonWithLabel(String label) =>
    _ancestorButtonWithLabel(label, (widget) => widget is TextButton);

Finder _botanicaButtonWithLabel(String label) =>
    _ancestorButtonWithLabel(label, (widget) => widget is BotanicaButton);

Future<void> _pumpPermissionsScreen(
  WidgetTester tester, {
  required AppPermissionsSnapshot snapshot,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        permissionsServiceProvider.overrideWithValue(
          _FakePermissionsService(snapshot),
        ),
      ],
      child: MaterialApp(
        theme: BotanicaTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PermissionsScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('PermissionsScreen uses outlined, filled, and text hierarchy',
      (WidgetTester tester) async {
    await _pumpPermissionsScreen(
      tester,
      snapshot: const AppPermissionsSnapshot(
        notifications: AppPermissionDecision.denied,
        location: LocationPermissionSnapshot(
          serviceEnabled: true,
          decision: AppPermissionDecision.denied,
        ),
        camera: AppPermissionDecision.denied,
        photos: AppPermissionDecision.denied,
      ),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(PermissionsScreen)),
    );

    await tester.scrollUntilVisible(
      find.text(l10n.permissionsNotNow),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(_outlinedButtonWithLabel(l10n.permissionsNotNow), findsOneWidget);
    expect(_botanicaButtonWithLabel(l10n.permissionsNotNow), findsOneWidget);

    expect(_filledButtonWithLabel(l10n.permissionsEnableAll), findsOneWidget);
    expect(_botanicaButtonWithLabel(l10n.permissionsEnableAll), findsOneWidget);

    expect(_textButtonWithLabel(l10n.permActionEnable), findsNWidgets(3));
    expect(_botanicaButtonWithLabel(l10n.permActionEnable), findsNWidgets(3));
  });

  testWidgets('PermissionsScreen keeps open settings as a text card action',
      (WidgetTester tester) async {
    await _pumpPermissionsScreen(
      tester,
      snapshot: const AppPermissionsSnapshot(
        notifications: AppPermissionDecision.permanentlyDenied,
        location: LocationPermissionSnapshot(
          serviceEnabled: true,
          decision: AppPermissionDecision.denied,
        ),
        camera: AppPermissionDecision.denied,
        photos: AppPermissionDecision.denied,
      ),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(PermissionsScreen)),
    );

    expect(_textButtonWithLabel(l10n.permActionOpenSettings), findsOneWidget);
    expect(_outlinedButtonWithLabel(l10n.permActionOpenSettings), findsNothing);
    expect(_filledButtonWithLabel(l10n.permActionOpenSettings), findsNothing);
    expect(
        _botanicaButtonWithLabel(l10n.permActionOpenSettings), findsOneWidget);
  });
}
