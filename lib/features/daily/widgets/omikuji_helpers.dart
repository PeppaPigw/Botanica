import '../../../gen/l10n/app_localizations.dart';

String omikujiLabel(AppLocalizations l10n, String id) => switch (id) {
      'daikichi' => l10n.omikujiDaikichi,
      'chukichi' => l10n.omikujiChukichi,
      'shokichi' => l10n.omikujiShokichi,
      'kichi' => l10n.omikujiKichi,
      'hankichi' => l10n.omikujiHankichi,
      'suekichi' => l10n.omikujiSuekichi,
      'kyo' => l10n.omikujiKyo,
      'daikyo' => l10n.omikujiDaikyo,
      _ => id,
    };
