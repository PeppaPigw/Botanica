import 'dart:io';

import 'package:botanica/app/providers.dart';
import 'package:botanica/app/theme/botanica_theme.dart';
import 'package:botanica/data/repositories/logs_repository.dart';
import 'package:botanica/domain/models/care_log.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/models/plant.dart';
import 'package:botanica/domain/models/plant_meta.dart';
import 'package:botanica/domain/models/task_instance.dart';
import 'package:botanica/domain/models/user_settings.dart';
import 'package:botanica/features/calendar/calendar_screen.dart';
import 'package:botanica/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/src/hive_impl.dart';

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

Future<LogsRepository> _createMemoryLogsRepo(List<CareLog> logs) async {
  final tempDir = await Directory.systemTemp.createTemp('botanica_cal_test_');
  final hiveInstance = HiveImpl()..init(tempDir.path);
  final suffix = DateTime.now().microsecondsSinceEpoch.toString();
  final logsBox = await hiveInstance.openBox<Map>('logs_$suffix');
  final repo = LogsRepository(logsBox);
  for (final log in logs) {
    await repo.add(log);
  }
  return repo;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestApp({
    List<Plant> plants = const [],
    List<TaskInstance> tasks = const [],
    LogsRepository? logsRepository,
  }) {
    return ProviderScope(
      overrides: [
        settingsControllerProvider.overrideWith(
          () => _TestSettingsController(UserSettings.defaults()),
        ),
        plantsStreamProvider.overrideWith(
          (ref) => Stream.value(plants),
        ),
        tasksStreamProvider.overrideWith(
          (ref) => Stream.value(tasks),
        ),
        if (logsRepository != null)
          logsRepositoryProvider.overrideWithValue(logsRepository),
      ],
      child: MaterialApp(
        theme: BotanicaTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
  }

  testWidgets('Jump to today button visibility and functionality', (WidgetTester tester) async {
    final logsRepo = (await tester.runAsync(() => _createMemoryLogsRepo([])))!;
    await tester.pumpWidget(buildTestApp(logsRepository: logsRepo));
    await tester.pump(const Duration(milliseconds: 500));

    final todayButtonFinder = find.byKey(const ValueKey('calendar-jump-today'));

    expect(todayButtonFinder, findsNothing);

    // Tap the previous month button
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump(const Duration(milliseconds: 500));
    
    // Tap a specific date '15'. TableCalendar definitely has '15', maybe not immediately if animation is slow.
    await tester.pump(const Duration(milliseconds: 500));
    
    final dayFinder = find.descendant(
      of: find.byType(CalendarScreen),
      matching: find.text('15'),
    ).first;
    
    await tester.tap(dayFinder);
    await tester.pump(const Duration(milliseconds: 500));

    // Close the day agenda sheet by tapping out
    await tester.tapAt(const Offset(10, 10)); 
    await tester.pump(const Duration(milliseconds: 500));
    
    // Ensure the button is visible by scrolling if needed
    await tester.ensureVisible(todayButtonFinder);
    await tester.pump(const Duration(milliseconds: 500));

    expect(todayButtonFinder, findsOneWidget);

    await tester.tap(todayButtonFinder);
    await tester.pump(const Duration(milliseconds: 500));

    expect(todayButtonFinder, findsNothing);
  });

  testWidgets('Calendar log tracking and filtering works', (WidgetTester tester) async {
    final now = DateTime.now();
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

    final logWater = CareLog(
        id: 'l1',
        plantId: 'p1',
        linkedPhotoId: null,
        type: TaskType.water,
        timestamp: now,
        note: 'Watered it',
      );
      
    final logFertilize = CareLog(
        id: 'l2',
        plantId: 'p1',
        linkedPhotoId: null,
        type: TaskType.fertilize,
        timestamp: now,
        note: 'Fertilized it',
      );

    final logsRepo = (await tester.runAsync(() => _createMemoryLogsRepo([logWater, logFertilize])))!;

    await tester.pumpWidget(buildTestApp(plants: [plant], logsRepository: logsRepo));
    await tester.pump(const Duration(milliseconds: 500));

    final listFinder = find.byKey(const ValueKey('calendar-list'));

    // Check filters - scroll to them first
    final scrollable = find.descendant(
      of: listFinder,
      matching: find.byType(Scrollable),
    ).first;
    final filterAllFinder = find.byKey(const ValueKey('calendar-filter-all'));
    await tester.scrollUntilVisible(
      filterAllFinder,
      300,
      scrollable: scrollable,
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(filterAllFinder, findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-filter-water')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-filter-fertilize')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-filter-mist')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-filter-other')), findsOneWidget);

    // Scroll back to top to find the calendar day
    final scrollState = tester.state<ScrollableState>(scrollable);
    scrollState.position.jumpTo(0);
    await tester.pump(const Duration(milliseconds: 500));

    // Tap on the day that has the logs (today)
    final todayDayStr = now.day.toString();
    await tester.tap(find.text(todayDayStr).first);
    await tester.pump(const Duration(milliseconds: 500));

    // Expect the agenda sheet to be visible with the logs shown
    expect(find.byKey(const ValueKey('calendar-day-sheet')), findsOneWidget);

    // Should see both logs' titles
    expect(find.text('Water · Aloe'), findsOneWidget);
    expect(find.text('Fertilize · Aloe'), findsOneWidget);

    // Close sheet
    Navigator.of(tester.element(find.byKey(const ValueKey('calendar-day-sheet')))).pop();
    await tester.pump(const Duration(seconds: 1));

    // Tap 'Water' filter
    final filterWaterFinder = find.byKey(const ValueKey('calendar-filter-water'));
    await tester.scrollUntilVisible(
      filterWaterFinder,
      300,
      scrollable: scrollable,
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(filterWaterFinder);
    await tester.pump(const Duration(seconds: 1));

    // Scroll back to top and tap today again
    scrollState.position.jumpTo(0);
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text(todayDayStr).first);
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const ValueKey('calendar-day-sheet')), findsOneWidget);

    // Only 'Water · Aloe' should be visible
    expect(find.text('Water · Aloe'), findsOneWidget);
    expect(find.text('Fertilize · Aloe'), findsNothing);
  });
}
