import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/models/daily_flower.dart';
import 'package:botanica/domain/models/enums.dart';
import 'package:botanica/domain/services/daily_flower_selector.dart';

void main() {
  group('DailyFlowerSelector', () {
    final pool = List.generate(
      10,
      (i) => DailyFlowerContent(
        key: 'k$i',
        name: 'Flower $i',
        imagePath: null,
        meaningKeywords: const ['Calm'],
        symbolism: 'Symbolism $i',
        careBasics: const {'light': 'Bright'},
        appreciation: 'Appreciation $i',
      ),
    );

    test('is deterministic for the same inputs', () {
      const selector = DailyFlowerSelector();
      final date = DateTime(2026, 2, 20);

      final first = selector.select(
        date: date,
        localeCode: 'en',
        beliefMode: BeliefMode.westernZodiac,
        pool: pool,
      );
      final second = selector.select(
        date: date,
        localeCode: 'en',
        beliefMode: BeliefMode.westernZodiac,
        pool: pool,
      );

      expect(first.content.key, second.content.key);
      expect(first.date, DateTime(2026, 2, 20));
    });

    test('seed inputs map to the expected pool index', () {
      const selector = DailyFlowerSelector();
      final date = DateTime(2026, 2, 20);

      final entry = selector.select(
        date: date,
        localeCode: 'en',
        beliefMode: BeliefMode.tarot,
        variantKey: 'gemini',
        pool: pool,
      );

      final expectedIndex = _expectedIndex(
        date: date,
        localeCode: 'en',
        beliefMode: BeliefMode.tarot,
        variantKey: 'gemini',
        personalizationKey: null,
        poolSize: pool.length,
      );

      expect(entry.content.key, 'k$expectedIndex');
    });

    test('variantKey participates in selection', () {
      const selector = DailyFlowerSelector();
      final date = DateTime(2026, 2, 20);

      final withoutVariant = selector.select(
        date: date,
        localeCode: 'en',
        beliefMode: BeliefMode.tarot,
        pool: pool,
      );
      final withVariant = selector.select(
        date: date,
        localeCode: 'en',
        beliefMode: BeliefMode.tarot,
        variantKey: 'gemini',
        pool: pool,
      );

      expect(withVariant.content.key, isNot(withoutVariant.content.key));
    });

    test('personalizationKey participates in selection', () {
      const selector = DailyFlowerSelector();
      final date = DateTime(2026, 2, 20);

      final baseIndex = _expectedIndex(
        date: date,
        localeCode: 'en',
        beliefMode: BeliefMode.tarot,
        variantKey: 'gemini',
        personalizationKey: null,
        poolSize: pool.length,
      );

      var chosenKey = '';
      var chosenIndex = baseIndex;
      for (var i = 0; i < 200 && chosenIndex == baseIndex; i++) {
        chosenKey = 'birth:1998-07-${(10 + i).toString().padLeft(2, '0')}';
        chosenIndex = _expectedIndex(
          date: date,
          localeCode: 'en',
          beliefMode: BeliefMode.tarot,
          variantKey: 'gemini',
          personalizationKey: chosenKey,
          poolSize: pool.length,
        );
      }

      expect(chosenKey, isNotEmpty);
      expect(chosenIndex, isNot(baseIndex));

      final entry = selector.select(
        date: date,
        localeCode: 'en',
        beliefMode: BeliefMode.tarot,
        variantKey: 'gemini',
        personalizationKey: chosenKey,
        pool: pool,
      );

      expect(entry.content.key, 'k$chosenIndex');
    });
  });
}

int _expectedIndex({
  required DateTime date,
  required String localeCode,
  required BeliefMode beliefMode,
  required String? variantKey,
  required String? personalizationKey,
  required int poolSize,
}) {
  final day = DateTime(date.year, date.month, date.day);
  final seed = <String>[
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
    localeCode,
    beliefMode.id,
    if (variantKey != null && variantKey.trim().isNotEmpty) variantKey.trim(),
    if (personalizationKey != null && personalizationKey.trim().isNotEmpty)
      personalizationKey.trim(),
  ].join('|');

  final index = _fnv1a32(seed) % poolSize;
  return index;
}

int _fnv1a32(String input) {
  const int fnvPrime = 0x01000193;
  const int fnvOffsetBasis = 0x811C9DC5;

  var hash = fnvOffsetBasis;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  return (hash & 0x7FFFFFFF);
}
