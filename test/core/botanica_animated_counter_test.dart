import 'package:botanica/core/widgets/botanica_animated_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('BotanicaAnimatedCounter', () {
    testWidgets('displays the target value after animation', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaAnimatedCounter(value: 42),
      ));
      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('displays prefix and suffix', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaAnimatedCounter(value: 7, prefix: '+', suffix: 'd'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('+7d'), findsOneWidget);
    });

    testWidgets('updates when value changes', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaAnimatedCounter(value: 10),
      ));
      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget);

      await tester.pumpWidget(wrap(
        const BotanicaAnimatedCounter(value: 20),
      ));
      await tester.pumpAndSettle();
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('starts at 0 during animation', (tester) async {
      await tester.pumpWidget(wrap(
        const BotanicaAnimatedCounter(value: 100),
      ));
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
    });
  });
}
