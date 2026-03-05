import '../models/daily_flower.dart';
import '../models/enums.dart';

class DailyFlowerSelector {
  const DailyFlowerSelector();

  DailyFlowerEntry select({
    required DateTime date,
    required String localeCode,
    required BeliefMode beliefMode,
    String? variantKey,
    String? personalizationKey,
    required List<DailyFlowerContent> pool,
  }) {
    if (pool.isEmpty) {
      throw ArgumentError.value(pool, 'pool', 'Daily flower pool is empty.');
    }

    final day = DateTime(date.year, date.month, date.day);
    final seed = <String>[
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
      localeCode,
      beliefMode.id,
      if (variantKey != null && variantKey.trim().isNotEmpty) variantKey.trim(),
      if (personalizationKey != null && personalizationKey.trim().isNotEmpty)
        personalizationKey.trim(),
    ].join('|');

    final index = _fnv1a32(seed) % pool.length;

    return DailyFlowerEntry(
      date: day,
      localeCode: localeCode,
      beliefMode: beliefMode,
      content: pool[index],
    );
  }
}

int _fnv1a32(String input) {
  const int fnvPrime = 0x01000193;
  const int fnvOffsetBasis = 0x811C9DC5;

  var hash = fnvOffsetBasis;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}
