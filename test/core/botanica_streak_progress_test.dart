import 'package:botanica/core/widgets/botanica_streak_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('BotanicaStreakProgress', () {
    testWidgets('displays current streak days', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaStreakProgress(currentStreak: 3),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('3 days'), findsOneWidget);
    });

    testWidgets('shows singular for 1 day', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaStreakProgress(currentStreak: 1),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1 day'), findsOneWidget);
    });

    testWidgets('shows remaining days to next milestone', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaStreakProgress(currentStreak: 3),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('4 to next'), findsOneWidget);
    });

    testWidgets('hides remaining when milestone reached', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaStreakProgress(currentStreak: 7),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('0 to next'), findsNothing);
    });

    testWidgets('animates progress bar fill', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaStreakProgress(currentStreak: 3),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(BotanicaStreakProgress), findsOneWidget);
    });

    testWidgets('shows all milestone markers', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaStreakProgress(currentStreak: 35),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('7d'), findsOneWidget);
      expect(find.text('30d'), findsOneWidget);
      expect(find.text('90d'), findsOneWidget);
      expect(find.text('1y'), findsOneWidget);
    });

    testWidgets('marks reached milestones with check icon', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaStreakProgress(currentStreak: 35),
      ));
      await tester.pump(const Duration(seconds: 1));
      final checkIcons = find.byIcon(Icons.check_circle_rounded);
      final circleIcons = find.byIcon(Icons.circle_outlined);
      expect(checkIcons, findsNWidgets(2));
      expect(circleIcons, findsNWidgets(2));
    });
  });
}
