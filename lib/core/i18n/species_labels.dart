import '../../gen/l10n/app_localizations.dart';

String difficultyLabel(AppLocalizations l10n, String code) => switch (code) {
      'easy' => l10n.difficultyEasy,
      'medium' => l10n.difficultyMedium,
      'hard' => l10n.difficultyHard,
      _ => code,
    };

String lightLabel(AppLocalizations l10n, String code) => switch (code) {
      'bright_direct' => l10n.lightBrightDirect,
      'bright_indirect' => l10n.lightBrightIndirect,
      'medium_indirect' => l10n.lightMediumIndirect,
      'low_to_bright_indirect' => l10n.lightLowToBrightIndirect,
      'low_to_bright' => l10n.lightLowToBright,
      _ => code,
    };
