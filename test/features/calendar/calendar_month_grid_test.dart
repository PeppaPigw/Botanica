import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/features/calendar/calendar_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('month grid renders month day cells', (tester) async {
    final cases = <DateTime, int>{
      DateTime(2026, 2): 28,
      DateTime(2026, 4): 30,
      DateTime(2026, 5): 31,
    };

    for (final entry in cases.entries) {
      await _pumpGrid(tester, month: entry.key);

      for (var day = 1; day <= entry.value; day++) {
        final date = DateTime(entry.key.year, entry.key.month, day);
        expect(
          find.byKey(ValueKey('cal-day-${_dateKey(date)}')),
          findsOneWidget,
        );
      }
    }
  });

  testWidgets('tapping a day cell triggers selection callback',
      (tester) async {
    final selected = <DateTime>[];
    final target = DateTime(2026, 5, 17);

    await _pumpGrid(
      tester,
      month: DateTime(2026, 5),
      onSelect: selected.add,
    );

    await tester.tap(find.byKey(ValueKey('cal-day-${_dateKey(target)}')));
    await tester.pump();

    expect(selected, <DateTime>[target]);
  });

  testWidgets('days with care logs show dot indicators', (tester) async {
    final day = DateTime(2026, 5, 17, 8);

    await _pumpGrid(
      tester,
      month: DateTime(2026, 5),
      logsByDay: <String, List<CareLog>>{
        _dateKey(day): <CareLog>[
          CareLog(
            id: 'log_1',
            plantId: 'plant_1',
            type: TaskType.water,
            timestamp: day,
            note: null,
            linkedPhotoId: null,
          ),
        ],
      },
    );

    expect(find.byKey(const ValueKey('calendar-dot-water')), findsOneWidget);
  });
}

Future<void> _pumpGrid(
  WidgetTester tester, {
  required DateTime month,
  Map<String, List<CareLog>> logsByDay = const <String, List<CareLog>>{},
  ValueChanged<DateTime>? onSelect,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: CalendarMonthGrid(
            month: month,
            selected: DateTime(month.year, month.month, 1),
            logsByDay: logsByDay,
            onSelect: onSelect ?? (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

String _dateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
