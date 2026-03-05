import 'package:flutter_test/flutter_test.dart';

import 'package:botanica/domain/services/zodiac.dart';

void main() {
  group('westernZodiacIdForDate', () {
    test('maps boundary dates correctly', () {
      expect(westernZodiacIdForDate(DateTime(2026, 3, 21)), 'aries');
      expect(westernZodiacIdForDate(DateTime(2026, 4, 19)), 'aries');
      expect(westernZodiacIdForDate(DateTime(2026, 4, 20)), 'taurus');

      expect(westernZodiacIdForDate(DateTime(2026, 6, 21)), 'cancer');
      expect(westernZodiacIdForDate(DateTime(2026, 12, 22)), 'capricorn');
      expect(westernZodiacIdForDate(DateTime(2026, 1, 19)), 'capricorn');
      expect(westernZodiacIdForDate(DateTime(2026, 2, 18)), 'aquarius');
      expect(westernZodiacIdForDate(DateTime(2026, 2, 19)), 'pisces');
    });
  });

  group('chineseZodiacIdForYear', () {
    test('uses 2020 as rat baseline', () {
      expect(chineseZodiacIdForYear(2020), 'rat');
      expect(chineseZodiacIdForYear(2021), 'ox');
      expect(chineseZodiacIdForYear(2024), 'dragon');
      expect(chineseZodiacIdForYear(2026), 'horse');
      expect(chineseZodiacIdForYear(2031), 'pig');
    });
  });
}
