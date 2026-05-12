import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';
import '../../gen/l10n/app_localizations.dart';

String taskTypeLabel(AppLocalizations l10n, TaskType type) => switch (type) {
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

IconData iconForTask(TaskType type) => switch (type) {
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

String localizeReason(AppLocalizations l10n, CareAdjustmentReason reason) {
  return switch (reason) {
    CareAdjustmentReason.humidityLow => l10n.reasonHumidityLow,
    CareAdjustmentReason.humidityHigh => l10n.reasonHumidityHigh,
    CareAdjustmentReason.hotTemperature => l10n.reasonHot,
    CareAdjustmentReason.springSeason => l10n.reasonSpring,
    CareAdjustmentReason.summerSeason => l10n.reasonSummer,
    CareAdjustmentReason.autumnSeason => l10n.reasonAutumn,
    CareAdjustmentReason.winterSeason => l10n.reasonWinter,
    CareAdjustmentReason.outdoorMode => l10n.reasonOutdoor,
  };
}
