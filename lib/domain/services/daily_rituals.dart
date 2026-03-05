class DailyRituals {
  const DailyRituals._();

  static const List<String> tarotMajorArcana = <String>[
    'the_fool',
    'the_magician',
    'the_high_priestess',
    'the_empress',
    'the_emperor',
    'the_hierophant',
    'the_lovers',
    'the_chariot',
    'strength',
    'the_hermit',
    'wheel_of_fortune',
    'justice',
    'the_hanged_man',
    'death',
    'temperance',
    'the_devil',
    'the_tower',
    'the_star',
    'the_moon',
    'the_sun',
    'judgement',
    'the_world',
  ];

  static const List<RuneEntry> elderFuthark = <RuneEntry>[
    RuneEntry(id: 'fehu', glyph: 'ᚠ', name: 'Fehu'),
    RuneEntry(id: 'uruz', glyph: 'ᚢ', name: 'Uruz'),
    RuneEntry(id: 'thurisaz', glyph: 'ᚦ', name: 'Thurisaz'),
    RuneEntry(id: 'ansuz', glyph: 'ᚨ', name: 'Ansuz'),
    RuneEntry(id: 'raidho', glyph: 'ᚱ', name: 'Raidho'),
    RuneEntry(id: 'kenaz', glyph: 'ᚲ', name: 'Kenaz'),
    RuneEntry(id: 'gebo', glyph: 'ᚷ', name: 'Gebo'),
    RuneEntry(id: 'wunjo', glyph: 'ᚹ', name: 'Wunjo'),
    RuneEntry(id: 'hagalaz', glyph: 'ᚺ', name: 'Hagalaz'),
    RuneEntry(id: 'nauthiz', glyph: 'ᚾ', name: 'Nauthiz'),
    RuneEntry(id: 'isa', glyph: 'ᛁ', name: 'Isa'),
    RuneEntry(id: 'jera', glyph: 'ᛃ', name: 'Jera'),
    RuneEntry(id: 'eihwaz', glyph: 'ᛇ', name: 'Eihwaz'),
    RuneEntry(id: 'perthro', glyph: 'ᛈ', name: 'Perthro'),
    RuneEntry(id: 'algiz', glyph: 'ᛉ', name: 'Algiz'),
    RuneEntry(id: 'sowilo', glyph: 'ᛋ', name: 'Sowilo'),
    RuneEntry(id: 'tiwaz', glyph: 'ᛏ', name: 'Tiwaz'),
    RuneEntry(id: 'berkanan', glyph: 'ᛒ', name: 'Berkanan'),
    RuneEntry(id: 'ehwaz', glyph: 'ᛖ', name: 'Ehwaz'),
    RuneEntry(id: 'mannaz', glyph: 'ᛗ', name: 'Mannaz'),
    RuneEntry(id: 'laguz', glyph: 'ᛚ', name: 'Laguz'),
    RuneEntry(id: 'ingwaz', glyph: 'ᛜ', name: 'Ingwaz'),
    RuneEntry(id: 'dagaz', glyph: 'ᛞ', name: 'Dagaz'),
    RuneEntry(id: 'othala', glyph: 'ᛟ', name: 'Othala'),
  ];

  static const List<String> ogham = <String>[
    'beith',
    'luis',
    'fearn',
    'saille',
    'nuin',
    'huath',
    'duir',
    'tinne',
    'coll',
    'ceirt',
    'muin',
    'gort',
    'ngetal',
    'straif',
    'ruis',
    'ailm',
    'onn',
    'ur',
    'edad',
    'idad',
  ];

  static const List<String> omikujiFortunes = <String>[
    'daikichi',
    'chukichi',
    'shokichi',
    'kichi',
    'hankichi',
    'suekichi',
    'kyo',
    'daikyo',
  ];

  static List<String> tarotDrawOptions(DateTime date) {
    final day = _dateKey(date);
    final cards = List<String>.of(tarotMajorArcana);
    cards.sort(
      (a, b) => _hash32('tarot_draw_v1|$day|$a')
          .compareTo(_hash32('tarot_draw_v1|$day|$b')),
    );
    return cards.take(4).toList(growable: false);
  }

  static String runeIdForDate(DateTime date) {
    final idx = _hash32('rune_v1|${_dateKey(date)}') % elderFuthark.length;
    return elderFuthark[idx].id;
  }

  static RuneEntry runeForId(String id) {
    for (final r in elderFuthark) {
      if (r.id == id) return r;
    }
    return elderFuthark.first;
  }

  static String oghamIdForDate(DateTime date) {
    final idx = _hash32('ogham_v1|${_dateKey(date)}') % ogham.length;
    return ogham[idx];
  }

  static String omikujiIdForDate(DateTime date) {
    final idx =
        _hash32('omikuji_v1|${_dateKey(date)}') % omikujiFortunes.length;
    return omikujiFortunes[idx];
  }

  /// Simplified placeholder: maps each day onto a 60-step Ganzhi cycle.
  ///
  /// Note: real almanac calculations are lunar-calendar based and more complex.
  static Ganzhi almanacGanzhiForDate(DateTime date) {
    // A stable, deterministic baseline (not historically guaranteed).
    final base = DateTime(1984, 2, 2);
    final day = DateTime(date.year, date.month, date.day);
    final diffDays = day.difference(base).inDays;
    final index = ((diffDays % 60) + 60) % 60;

    const stemsEn = <String>[
      'Jia',
      'Yi',
      'Bing',
      'Ding',
      'Wu',
      'Ji',
      'Geng',
      'Xin',
      'Ren',
      'Gui',
    ];
    const stemsZh = <String>['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const branchesEn = <String>[
      'Zi',
      'Chou',
      'Yin',
      'Mao',
      'Chen',
      'Si',
      'Wu',
      'Wei',
      'Shen',
      'You',
      'Xu',
      'Hai',
    ];
    const branchesZh = <String>[
      '子',
      '丑',
      '寅',
      '卯',
      '辰',
      '巳',
      '午',
      '未',
      '申',
      '酉',
      '戌',
      '亥'
    ];

    final stemIndex = index % 10;
    final branchIndex = index % 12;
    final id =
        '${stemsEn[stemIndex].toLowerCase()}_${branchesEn[branchIndex].toLowerCase()}';

    return Ganzhi(
      id: id,
      labelEn: '${stemsEn[stemIndex]}-${branchesEn[branchIndex]}',
      labelZh: '${stemsZh[stemIndex]}${branchesZh[branchIndex]}',
    );
  }
}

class RuneEntry {
  const RuneEntry({
    required this.id,
    required this.glyph,
    required this.name,
  });

  final String id;
  final String glyph;
  final String name;
}

class Ganzhi {
  const Ganzhi({
    required this.id,
    required this.labelEn,
    required this.labelZh,
  });

  final String id;
  final String labelEn;
  final String labelZh;
}

String _dateKey(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

int _hash32(String input) {
  const int fnvPrime = 0x01000193;
  const int fnvOffsetBasis = 0x811C9DC5;

  var hash = fnvOffsetBasis;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }

  // Avoid negative indexes in modulo.
  final positive = hash & 0x7FFFFFFF;
  return positive == 0 ? 1 : positive;
}
