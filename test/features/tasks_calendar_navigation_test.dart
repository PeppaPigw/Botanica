import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/tasks/tasks_screen.dart';
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

  testWidgets('Tasks calendar button navigates to calendar',
      (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/garden/tasks',
      routes: [
        GoRoute(
          path: '/garden/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Calendar')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(UserSettings.defaults()),
          ),
          plantsStreamProvider.overrideWith(
            (ref) => Stream.value(const <Plant>[]),
          ),
          tasksStreamProvider.overrideWith(
            (ref) => Stream.value(const <TaskInstance>[]),
          ),
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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.calendar_month_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Calendar'), findsOneWidget);
  });

  testWidgets('Tasks tile navigates to plant detail',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final task = TaskInstance(
      id: 't1',
      plantId: 'p1',
      type: TaskType.water,
      dueAt: now,
      status: TaskStatus.pending,
      createdAt: now,
      completedAt: null,
      adjustmentReasonIds: const <String>[],
    );

    final plant = Plant(
      id: 'p1',
      nickname: 'Aloe',
      speciesId: 'aloe_vera',
      room: 'Living room',
      environmentMode: EnvironmentMode.indoor,
      coverAsset: 'assets/placeholders/species/unknown.png',
      createdAt: now,
      meta: const PlantMeta(),
    );

    final router = GoRouter(
      initialLocation: '/garden/tasks',
      routes: [
        GoRoute(
          path: '/garden/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/garden/plant/:id',
          builder: (context, state) => Scaffold(
            body: Center(
              child: Text('Plant ${state.pathParameters['id']}'),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(UserSettings.defaults()),
          ),
          plantsStreamProvider.overrideWith(
            (ref) => Stream.value(<Plant>[plant]),
          ),
          tasksStreamProvider.overrideWith(
            (ref) => Stream.value(<TaskInstance>[task]),
          ),
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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Aloe · Water'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Plant p1'), findsOneWidget);
  });
}
