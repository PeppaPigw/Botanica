import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/photo_timelapse_detector.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaPhotoTimelapseCard extends StatelessWidget {
  const BotanicaPhotoTimelapseCard({
    super.key,
    required this.candidates,
  });

  final List<TimelapseCandidate> candidates;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BotanicaGlassCard(
      padding: BotanicaTokens.cardPaddingDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.movie_creation_rounded,
                  size: BotanicaTokens.iconSizeMd, color: scheme.secondary),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.timelapseReadyTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${candidates.length} plants',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...candidates.take(4).map((c) {
            final qualityColor = switch (c.quality) {
              TimelapseQuality.excellent => const Color(0xFF66BB6A),
              TimelapseQuality.good => scheme.primary,
              _ => scheme.onSurface.withValues(alpha: 0.5),
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
              child: Row(
                children: [
                  Icon(Icons.photo_library_rounded, size: 12, color: qualityColor),
                  BotanicaGaps.hXxs,
                  Expanded(
                    child: Text(
                      c.plantNickname,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${c.photoCount} photos · ${c.spanDays}d',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
