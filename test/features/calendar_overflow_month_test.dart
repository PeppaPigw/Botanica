import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/data/repositories/logs_repository.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/features/calendar/calendar_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeLogsRepository implements LogsRepository {
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

String _dateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Calendar selecting overflow day updates month header',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            plantsStreamProvider.overrideWith(
              (ref) => Stream.value(const <Plant>[]),
            ),
            tasksStreamProvider.overrideWith(
              (ref) => Stream.value(const <TaskInstance>[]),
            ),
            logsRepositoryProvider.overrideWithValue(_FakeLogsRepository()),
          ],
          child: MaterialApp(
            theme: BotanicaTheme.light(),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final context = tester.element(find.byType(CalendarScreen));
      final loc = MaterialLocalizations.of(context);

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);

      final currentLabel = loc.formatMonthYear(currentMonth);
      final nextLabel = loc.formatMonthYear(nextMonth);

      expect(find.text(currentLabel), findsOneWidget);

      final nextMonthDayFinder =
          find.byKey(ValueKey('cal-day-${_dateKey(nextMonth)}')).first;
      await tester.tap(nextMonthDayFinder);
      await tester.pumpAndSettle();

      expect(find.text(nextLabel), findsOneWidget);
    } finally {
      await tester.binding.setSurfaceSize(null);
    }
  });
}
