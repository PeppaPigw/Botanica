import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/data/repositories/logs_repository.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/calendar/calendar_screen.dart';
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

class _FakeLogsRepository implements LogsRepository {
  const _FakeLogsRepository();

  @override
  List<CareLog> all() => const <CareLog>[];

  @override
  Future<void> add(CareLog log) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> deleteMany(Iterable<String> ids) async {}

  @override
  Future<int> deleteForPlant(String plantId) async => 0;

  @override
  List<CareLog> forPlant(String plantId) => const <CareLog>[];

  @override
  Stream<List<CareLog>> watchAll() => Stream.value(const <CareLog>[]);

  @override
  Stream<List<CareLog>> watchForPlant(String plantId) =>
      Stream.value(const <CareLog>[]);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('calendar renders in RTL without overflow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(
              UserSettings.defaults().copyWith(localeCode: 'ar'),
            ),
          ),
          plantsStreamProvider.overrideWith(
            (ref) => Stream.value(const <Plant>[]),
          ),
          tasksStreamProvider.overrideWith(
            (ref) => Stream.value(const <TaskInstance>[]),
          ),
          logsRepositoryProvider.overrideWithValue(const _FakeLogsRepository()),
        ],
        child: MaterialApp(
          theme: BotanicaTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: CalendarScreen(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
