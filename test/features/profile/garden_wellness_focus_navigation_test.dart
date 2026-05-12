import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/profile/garden_wellness_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  testWidgets('tapping a focus plant opens plant detail',
      (WidgetTester tester) async {
    final plants = <Plant>[
      _plant('p1', 'Monstera', 'Living room'),
      _plant('p2', 'Fern', 'Bathroom'),
      _plant('p3', 'ZZ Plant', 'Bedroom'),
    ];
    final tasks = <TaskInstance>[
      _task(id: 't1', plantId: 'p1', dueAt: DateTime(2026, 3, 7, 18)),
      _task(id: 't2', plantId: 'p2', dueAt: DateTime(2026, 3, 6, 7)),
      _task(id: 't3', plantId: 'p2', dueAt: DateTime(2026, 3, 5, 7)),
      _task(id: 't4', plantId: 'p3', dueAt: DateTime(2026, 3, 9, 10)),
    ];
    final logs = <CareLog>[
      _log('l1', 'p1', DateTime(2026, 3, 5, 8)),
      _log('l2', 'p2', DateTime(2026, 2, 10, 8)),
      _log('l3', 'p3', DateTime(2026, 3, 6, 8)),
    ];

    final router = GoRouter(
      initialLocation: '/profile/wellness',
      routes: [
        GoRoute(
          path: '/profile/wellness',
          builder: (context, state) => const GardenWellnessScreen(
            now: _fixedNow,
          ),
        ),
        GoRoute(
          path: '/garden/plant/:id',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('Plant ${state.pathParameters['id']}')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(
              UserSettings.defaults().copyWith(hasCompletedOnboarding: true),
            ),
          ),
          plantsStreamProvider.overrideWith((ref) => Stream.value(plants)),
          tasksStreamProvider.overrideWith((ref) => Stream.value(tasks)),
          careLogsStreamProvider.overrideWith((ref) => Stream.value(logs)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: BotanicaTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final focusFinder = find.byKey(const ValueKey('focus-plant-p2'));
    await tester.scrollUntilVisible(
      focusFinder,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(focusFinder);
    await tester.pumpAndSettle();

    expect(find.text('Plant p2'), findsOneWidget);
  });
}

DateTime _fixedNow() => DateTime(2026, 3, 7, 9);

Plant _plant(String id, String nickname, String room) {
  return Plant(
    id: id,
    nickname: nickname,
    speciesId: 'unknown',
    room: room,
    environmentMode: EnvironmentMode.indoor,
    coverAsset: 'assets/placeholders/species/unknown.png',
    createdAt: DateTime(2026, 1, 1),
    meta: const PlantMeta(),
  );
}

TaskInstance _task({
  required String id,
  required String plantId,
  required DateTime dueAt,
}) {
  return TaskInstance(
    id: id,
    plantId: plantId,
    type: TaskType.water,
    dueAt: dueAt,
    status: TaskStatus.pending,
    createdAt: DateTime(2026, 3, 1),
    completedAt: null,
    adjustmentReasonIds: const <String>[],
  );
}

CareLog _log(String id, String plantId, DateTime timestamp) {
  return CareLog(
    id: id,
    plantId: plantId,
    type: TaskType.water,
    timestamp: timestamp,
    note: null,
    linkedPhotoId: null,
  );
}
