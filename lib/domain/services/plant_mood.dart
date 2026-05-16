import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/task_instance.dart';
import '../../gen/l10n/app_localizations.dart';

/// Represents the "mood" of a plant based on its health and care state.
enum PlantMood { thriving, happy, okay, thirsty, neglected, newHere }

/// Resolves a plant's mood from health score, tasks, and age.
class PlantMoodResolver {
  const PlantMoodResolver._();

  /// Determine the mood for a plant given its current state.
  static PlantMood resolve({
    required int healthScore,
    required List<TaskInstance> plantTasks,
    required DateTime plantCreatedAt,
    required DateTime now,
  }) {
    // New plant (less than 3 days old)
    if (now.difference(plantCreatedAt).inDays < 3) {
      return PlantMood.newHere;
    }

    // Check for overdue tasks
    final overdueTasks = plantTasks.where(
      (t) =>
          !t.isDismissed &&
          t.status == TaskStatus.pending &&
          t.dueAt.isBefore(now),
    );

    if (overdueTasks.isNotEmpty) {
      final oldestDue = overdueTasks
          .map((t) => t.dueAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final overdueDays = now.difference(oldestDue).inDays;

      if (overdueDays >= 7) return PlantMood.neglected;
      if (overdueDays >= 2) return PlantMood.thirsty;
    }

    // Health-based
    if (healthScore >= 90) return PlantMood.thriving;
    if (healthScore >= 70) return PlantMood.happy;
    return PlantMood.okay;
  }

  /// Get the localized display text for a mood.
  static String localizedText(AppLocalizations l10n, PlantMood mood) {
    return switch (mood) {
      PlantMood.thriving => l10n.plantMoodThriving,
      PlantMood.happy => l10n.plantMoodHappy,
      PlantMood.okay => l10n.plantMoodOkay,
      PlantMood.thirsty => l10n.plantMoodThirsty,
      PlantMood.neglected => l10n.plantMoodNeglected,
      PlantMood.newHere => l10n.plantMoodNewHere,
    };
  }

  /// Get the color for a mood relative to the color scheme.
  static Color moodColor(PlantMood mood, ColorScheme scheme) {
    return switch (mood) {
      PlantMood.thriving => scheme.primary,
      PlantMood.happy => scheme.primary.withValues(alpha: 0.8),
      PlantMood.okay => scheme.onSurface.withValues(alpha: 0.55),
      PlantMood.thirsty => Colors.orange.shade700,
      PlantMood.neglected => Colors.deepOrange.shade600,
      PlantMood.newHere => scheme.tertiary,
    };
  }
}
