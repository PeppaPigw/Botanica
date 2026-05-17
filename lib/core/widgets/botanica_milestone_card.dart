import 'package:flutter/material.dart';

import '../../app/theme/botanica_tokens.dart';
import '../../domain/services/plant_milestone_engine.dart';
import 'botanica_gaps.dart';
import 'glass_card.dart';
import '../../gen/l10n/app_localizations.dart';

class BotanicaMilestoneCard extends StatelessWidget {
  const BotanicaMilestoneCard({
    super.key,
    required this.milestones,
  });

  final List<PlantMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) return const SizedBox.shrink();

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
              const Icon(Icons.flag_rounded,
                  size: BotanicaTokens.iconSizeMd, color: Color(0xFF9C27B0)),
              BotanicaGaps.hXs,
              Expanded(
                child: Text(
                  l10n.milestonesTitle,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${milestones.length} reached',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          BotanicaGaps.vSm,
          ...milestones.take(4).map((m) => Padding(
                padding: const EdgeInsets.only(bottom: BotanicaTokens.spacingMicro),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12,
                        color: const Color(0xFF9C27B0).withValues(alpha: 0.7)),
                    BotanicaGaps.hXxs,
                    Expanded(
                      child: Text(
                        m.type.name.replaceAllMapped(
                          RegExp(r'[A-Z]'),
                          (match) => ' ${match.group(0)!.toLowerCase()}',
                        ),
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
