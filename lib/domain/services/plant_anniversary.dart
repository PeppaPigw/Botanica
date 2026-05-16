/// Detects plant care anniversary milestones (1 month, 3 months, 6 months, 1 year).
class PlantAnniversary {
  const PlantAnniversary._();

  static const milestones = [30, 90, 180, 365];

  /// Returns the milestone days if the plant hits one today and hasn't been
  /// shown yet. Returns `null` if no milestone applies.
  static int? checkMilestone({
    required DateTime plantCreatedAt,
    required DateTime? lastShown,
    required DateTime now,
  }) {
    final daysInCare = now.difference(plantCreatedAt).inDays;
    final today = DateTime(now.year, now.month, now.day);

    // Already shown today — skip.
    if (lastShown != null) {
      final lastShownDay =
          DateTime(lastShown.year, lastShown.month, lastShown.day);
      if (lastShownDay == today) return null;
    }

    // Check if we're on a milestone day (within a 1-day window).
    for (final milestone in milestones) {
      if (daysInCare >= milestone && daysInCare <= milestone + 1) {
        // Don't re-show within a week of the last celebration.
        if (lastShown != null) {
          final daysSinceShown = now.difference(lastShown).inDays;
          if (daysSinceShown < 7) return null;
        }
        return milestone;
      }
    }
    return null;
  }

  /// Human-readable label for a milestone day count.
  static String milestoneLabel(int days) {
    if (days >= 365) return '1 year';
    if (days >= 180) return '6 months';
    if (days >= 90) return '3 months';
    return '1 month';
  }
}
