import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('targeted high-traffic cards use Botanica padding tokens', () {
    const targetedFiles = <String, List<String>>{
      'lib/core/widgets/botanica_state_card.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/calendar/calendar_screen.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/daily/daily_screen.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/daily/widgets/daily_ai_note_section.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/daily/widgets/daily_flower_card.dart': <String>[
        'padding: const EdgeInsets.all(16)',
      ],
      'lib/features/daily/widgets/tarot_helpers.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/daily/daily_share_card_screen.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/journal/photo_share_card_screen.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/journal/diary_share_card_screen.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/add_plant/add_plant_screen.dart': <String>[
        'padding: const EdgeInsets.all(14)',
        'padding: const EdgeInsets.all(16)',
      ],
      'lib/features/onboarding/permissions_screen.dart': <String>[
        'padding: const EdgeInsets.all(16)',
      ],
      'lib/features/plant_detail/plant_overview_tab.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/profile/permissions_section.dart': <String>[
        'padding: const EdgeInsets.all(16)',
      ],
      'lib/features/species/species_detail_screen.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
      'lib/features/scan/scan_flow_screen.dart': <String>[
        'padding: const EdgeInsets.all(14)',
      ],
    };

    for (final entry in targetedFiles.entries) {
      final source = File(entry.key).readAsStringSync();
      for (final rawPadding in entry.value) {
        expect(
          source,
          isNot(contains(rawPadding)),
          reason: '${entry.key} should use BotanicaTokens card padding.',
        );
      }
    }
  });

  test('flagship Daily surfaces use BotanicaTokens.cardPaddingDense', () {
    const dailyDenseFiles = <String>[
      'lib/features/daily/daily_screen.dart',
      'lib/features/daily/widgets/daily_ai_note_section.dart',
      'lib/features/daily/widgets/tarot_helpers.dart',
    ];

    for (final path in dailyDenseFiles) {
      final source = File(path).readAsStringSync();
      expect(
        source,
        contains('BotanicaTokens.cardPaddingDense'),
        reason: '$path should use BotanicaTokens.cardPaddingDense.',
      );
      expect(
        source,
        isNot(contains('padding: const EdgeInsets.all(14)')),
        reason: '$path should not hardcode 14px card padding.',
      );
    }
  });

  test('scan candidate cards use BotanicaTokens.cardPaddingDense', () {
    const path = 'lib/features/scan/scan_flow_screen.dart';

    final source = File(path).readAsStringSync();

    expect(
      source,
      contains('padding: BotanicaTokens.cardPaddingDense'),
      reason: '$path should use BotanicaTokens.cardPaddingDense.',
    );
    expect(
      source,
      isNot(contains('padding: const EdgeInsets.all(14)')),
      reason: '$path should not hardcode 14px card padding.',
    );
  });
}
