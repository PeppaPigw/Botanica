import 'package:flutter/material.dart';
import 'package:botanica/core/widgets/glass_card.dart';
import 'package:botanica/app/theme/botanica_tokens.dart';
import 'package:botanica/core/widgets/botanica_gaps.dart';

import '../../domain/models/care_schedule_snapshot.dart';
import '../../domain/models/enums.dart';
import '../../gen/l10n/app_localizations.dart';
import '../i18n/task_labels.dart';

CareAdjustmentReason? _reasonFromId(String id) {
  for (final reason in CareAdjustmentReason.values) {
    if (reason.id == id) return reason;
  }
  return null;
}

class CareTransparencyCard extends StatelessWidget {
  const CareTransparencyCard({
    super.key,
    required this.snapshot,
    required this.baseDays,
  });

  final CareScheduleSnapshot snapshot;
  final int baseDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final reasons = snapshot.reasonIds
        .map(_reasonFromId)
        .whereType<CareAdjustmentReason>()
        .map((r) => localizeReason(l10n, r))
        .toList(growable: false);

    return BotanicaGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.plantDetailEnvironmentImpactTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.insights_rounded,
                color: scheme.primary,
                size: BotanicaTokens.iconSizeMd,
              ),
            ],
          ),
          BotanicaGaps.vXs,
          Text(
            l10n.plantDetailEnvironmentImpactBaseAdjusted(
              baseDays,
              snapshot.adjustedDays,
            ),
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          BotanicaGaps.vSm,
          Text(
            l10n.commonWhy,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface.withValues(alpha: 0.74),
            ),
          ),
          BotanicaGaps.vXs,
          if (reasons.isEmpty)
            Text(
              l10n.plantDetailEnvironmentStable,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.70),
                height: 1.35,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reasons
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        '• $r',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                          height: 1.35,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}
