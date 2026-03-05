import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/botanica_tokens.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/models/care_log.dart';
import '../../domain/models/enums.dart';
import '../../gen/l10n/app_localizations.dart';

class PlantLogsTab extends ConsumerWidget {
  const PlantLogsTab({super.key, required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final logsRepo = ref.read(logsRepositoryProvider);

    return StreamBuilder(
      stream: logsRepo.watchForPlant(plantId),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const <CareLog>[];
        return ListView(
          padding: BotanicaTokens.pagePadding.copyWith(bottom: 120),
          children: [
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 40,
                      color: scheme.onSurface.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.plantDetailLogsEmptyTitle,
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.plantDetailLogsEmptyBody,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...logs.map(
                (log) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BotanicaGlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          _iconForTask(log.type),
                          color: scheme.onSurface.withValues(alpha: 0.78),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${_taskTypeLabel(l10n, log.type)} · ${MaterialLocalizations.of(context).formatShortMonthDay(log.timestamp)}',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

IconData _iconForTask(TaskType type) => switch (type) {
      TaskType.water => Icons.water_drop_rounded,
      TaskType.fertilize => Icons.science_rounded,
      TaskType.mist => Icons.blur_on_rounded,
      TaskType.rotate => Icons.rotate_right_rounded,
      TaskType.prune => Icons.content_cut_rounded,
      TaskType.repot => Icons.local_florist_rounded,
      TaskType.checkPests => Icons.bug_report_rounded,
      TaskType.wipeLeaves => Icons.cleaning_services_rounded,
      TaskType.sunlightAdjustment => Icons.wb_sunny_rounded,
    };

String _taskTypeLabel(AppLocalizations l10n, TaskType type) => switch (type) {
      TaskType.water => l10n.taskTypeWater,
      TaskType.fertilize => l10n.taskTypeFertilize,
      TaskType.mist => l10n.taskTypeMist,
      TaskType.rotate => l10n.taskTypeRotate,
      TaskType.prune => l10n.taskTypePrune,
      TaskType.repot => l10n.taskTypeRepot,
      TaskType.checkPests => l10n.taskTypeCheckPests,
      TaskType.wipeLeaves => l10n.taskTypeWipeLeaves,
      TaskType.sunlightAdjustment => l10n.taskTypeSunlightAdjustment,
    };
