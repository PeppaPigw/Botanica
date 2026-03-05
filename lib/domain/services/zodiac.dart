String? westernZodiacIdForDate(DateTime date) {
  final m = date.month;
  final d = date.day;
  final md = (m * 100) + d;

  if (md >= 321 && md <= 419) return 'aries';
  if (md >= 420 && md <= 520) return 'taurus';
  if (md >= 521 && md <= 620) return 'gemini';
  if (md >= 621 && md <= 722) return 'cancer';
  if (md >= 723 && md <= 822) return 'leo';
  if (md >= 823 && md <= 922) return 'virgo';
  if (md >= 923 && md <= 1022) return 'libra';
  if (md >= 1023 && md <= 1121) return 'scorpio';
  if (md >= 1122 && md <= 1221) return 'sagittarius';
  if (md >= 1222 || md <= 119) return 'capricorn';
  if (md >= 120 && md <= 218) return 'aquarius';
  if (md >= 219 && md <= 320) return 'pisces';

  return null;
}

String chineseZodiacIdForYear(int year) {
  const ids = <String>[
    'rat',
    'ox',
    'tiger',
    'rabbit',
    'dragon',
    'snake',
    'horse',
    'goat',
    'monkey',
    'rooster',
    'dog',
    'pig',
  ];

  final offset = year - 2020; // 2020 is Rat in the 12-year cycle.
  final index = ((offset % 12) + 12) % 12;
  return ids[index];
}
