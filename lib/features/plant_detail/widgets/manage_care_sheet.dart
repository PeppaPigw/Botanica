import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/botanica_tokens.dart';
import '../../../core/haptics/botanica_haptics.dart';
import '../../../core/i18n/task_labels.dart';
import '../../../core/widgets/botanica_gaps.dart';
import '../../../core/widgets/botanica_sheet.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/plant.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Shows a bottom sheet for managing per-plant care type overrides.
Future<void> showManageCareSheet({
  required BuildContext context,
  required Plant plant,
}) {
  return showBotanicaModalSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ManageCareSheetContent(plant: plant),
  );
}

class _ManageCareSheetContent extends ConsumerStatefulWidget {
  const _ManageCareSheetContent({required this.plant});

  final Plant plant;

  @override
  ConsumerState<_ManageCareSheetContent> createState() =>
      _ManageCareSheetContentState();
}

class _ManageCareSheetContentState
    extends ConsumerState<_ManageCareSheetContent> {
  late Plant _plant;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
  }


  Future<void> _toggleCareType(TaskType type, bool enabled) async {
    final l10n = AppLocalizations.of(context);
    final label = taskTypeLabel(l10n, type);

    if (!enabled) {
      // Confirm before disabling
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.manageCareDisableConfirm(label)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.manageCareDisabled),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final override =
        enabled ? CareTypeOverride.enabled : CareTypeOverride.disabled;
    final updated = _plant.withCareOverride(type, override);

    final plantsRepo = ref.read(plantsRepositoryProvider);
    await plantsRepo.upsert(updated);

    // If disabling, skip pending tasks of this type
    if (!enabled) {
      final tasksRepo = ref.read(tasksRepositoryProvider);
      final pending = tasksRepo
          .getAll()
          .where((t) =>
              t.plantId == _plant.id &&
              t.type == type &&
              t.status == TaskStatus.pending)
          .toList();
      for (final task in pending) {
        await tasksRepo.upsert(task.copyWith(status: TaskStatus.skipped));
      }
    }

    BotanicaHaptics.selectionTick();
    setState(() => _plant = updated);
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BotanicaSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.manageCareTitle,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          BotanicaGaps.vSm,
          ...TaskType.values.map((type) {
            final override = _plant.careOverrideFor(type);
            final isEnabled = override != CareTypeOverride.disabled;
            final subtitle = switch (override) {
              CareTypeOverride.useDefault => l10n.manageCareSpeciesDefault,
              CareTypeOverride.enabled => l10n.manageCareEnabledByYou,
              CareTypeOverride.disabled => l10n.manageCareDisabledByYou,
            };

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: BotanicaTokens.spacingXxs,
              ),
              child: Row(
                children: [
                  Icon(
                    iconForTask(type),
                    color: isEnabled
                        ? scheme.onSurface.withValues(alpha: 0.78)
                        : scheme.onSurface.withValues(alpha: 0.35),
                    size: BotanicaTokens.iconSizeMd,
                  ),
                  BotanicaGaps.hSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          taskTypeLabel(l10n, type),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isEnabled
                                ? scheme.onSurface
                                : scheme.onSurface.withValues(alpha: 0.50),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: taskTypeLabel(l10n, type),
                    value: isEnabled
                        ? l10n.manageCareEnabled
                        : l10n.manageCareDisabled,
                    child: Switch.adaptive(
                      value: isEnabled,
                      onChanged: (value) => _toggleCareType(type, value),
                    ),
                  ),
                ],
              ),
            );
          }),
          BotanicaGaps.vSm,
        ],
      ),
    );
  }
}
