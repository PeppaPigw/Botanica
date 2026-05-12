import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/botanica_glass_theme.dart';
import '../../../app/theme/botanica_tokens.dart';
import '../../../core/i18n/task_labels.dart';
import '../../../core/widgets/botanica_gaps.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/plant.dart';
import '../../../domain/models/plant_idea.dart';
import '../../../gen/l10n/app_localizations.dart';

class CareAdjustmentCard extends ConsumerWidget {
  const CareAdjustmentCard({
    super.key,
    required this.plant,
    this.plantIdea,
    this.fallbackWaterBaseDays,
  });

  final Plant plant;
  final PlantIdea? plantIdea;
  final int? fallbackWaterBaseDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final environment = ref.watch(environmentSnapshotProvider);
    final decision = ref.read(seasonalCareEngineProvider).computeSchedule(
          taskType: TaskType.water,
          now: DateTime.now(),
          environment: environment,
          hemisphere: settings.hemisphere,
          environmentMode: plant.environmentMode,
          plantIdea: plantIdea,
          fallbackBaseDays: fallbackWaterBaseDays,
        );

    final snapshot = decision.snapshot;
    if (snapshot.seasonalBaseDays <= 0 ||
        snapshot.adjustedDays == snapshot.seasonalBaseDays ||
        snapshot.reasonIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reasons = snapshot.reasonIds
        .map(_reasonFromId)
        .whereType<CareAdjustmentReason>()
        .map((reason) => localizeReason(l10n, reason))
        .toList(growable: false);

    if (reasons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BotanicaGlassCard(
          tier: GlassTier.subtle,
          padding: BotanicaTokens.cardPaddingDense,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: scheme.onSurface.withValues(alpha: 0.78),
              ),
              BotanicaGaps.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why care changed',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    BotanicaGaps.vXxs,
                    Text(
                      'Watering interval changed from '
                      '${snapshot.seasonalBaseDays} to '
                      '${snapshot.adjustedDays} days because: '
                      '${reasons.join(', ')}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.74),
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        BotanicaGaps.vSm,
      ],
    );
  }
}

CareAdjustmentReason? _reasonFromId(String id) {
  for (final reason in CareAdjustmentReason.values) {
    if (reason.id == id) return reason;
  }
  return null;
}
