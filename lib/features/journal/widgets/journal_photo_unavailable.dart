import 'package:flutter/material.dart';

import '../../../app/theme/botanica_tokens.dart';
import '../../../gen/l10n/app_localizations.dart';

class JournalPhotoUnavailable extends StatelessWidget {
  const JournalPhotoUnavailable({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.65),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? 4 : BotanicaTokens.spacingSm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_rounded,
                size: compact ? 18 : 44,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
              SizedBox(height: compact ? 2 : BotanicaTokens.spacingXs),
              Text(
                l10n.journalPhotoUnavailable,
                maxLines: compact ? 2 : 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: (compact ? textTheme.labelSmall : textTheme.bodySmall)
                    ?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
