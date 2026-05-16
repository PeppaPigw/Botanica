import '../models/plant.dart';

class GrowthMilestone {
  const GrowthMilestone({
    required this.photoIndex,
    required this.date,
    required this.changeScore,
    required this.label,
  });

  final int photoIndex;
  final DateTime date;
  final double changeScore;
  final String label;
}

class GrowthTimelapseResult {
  const GrowthTimelapseResult({
    required this.plantId,
    required this.photoCount,
    required this.spanDays,
    required this.milestones,
    required this.growthRate,
    required this.statusKey,
  });

  final String plantId;
  final int photoCount;
  final int spanDays;
  final List<GrowthMilestone> milestones;
  final double growthRate;
  final String statusKey;
}

class GrowthTimelapseEngine {
  const GrowthTimelapseEngine._();

  static GrowthTimelapseResult analyze({
    required Plant plant,
    required List<DateTime> photoDates,
    required DateTime now,
  }) {
    if (photoDates.isEmpty) {
      return GrowthTimelapseResult(
        plantId: plant.id,
        photoCount: 0,
        spanDays: 0,
        milestones: const [],
        growthRate: 0.0,
        statusKey: 'timelapseNoPhotos',
      );
    }

    final sorted = List<DateTime>.from(photoDates)..sort();
    final spanDays = sorted.length > 1
        ? sorted.last.difference(sorted.first).inDays
        : 0;

    final milestones = _detectMilestones(sorted);
    final growthRate = _computeGrowthRate(sorted, spanDays);
    final statusKey = _status(photoDates.length, spanDays, growthRate);

    return GrowthTimelapseResult(
      plantId: plant.id,
      photoCount: photoDates.length,
      spanDays: spanDays,
      milestones: milestones,
      growthRate: growthRate,
      statusKey: statusKey,
    );
  }

  static List<GrowthMilestone> _detectMilestones(List<DateTime> dates) {
    final milestones = <GrowthMilestone>[];
    if (dates.length < 3) return milestones;

    for (int i = 1; i < dates.length; i++) {
      final gap = dates[i].difference(dates[i - 1]).inDays;
      if (gap >= 7) {
        final changeScore = (gap / 30.0).clamp(0.0, 1.0);
        milestones.add(GrowthMilestone(
          photoIndex: i,
          date: dates[i],
          changeScore: changeScore,
          label: gap >= 30 ? 'milestoneMajorGrowth' : 'milestoneVisibleChange',
        ));
      }
    }

    if (milestones.length > 10) {
      milestones.sort((a, b) => b.changeScore.compareTo(a.changeScore));
      return milestones.take(10).toList();
    }
    return milestones;
  }

  static double _computeGrowthRate(List<DateTime> dates, int spanDays) {
    if (spanDays == 0 || dates.length < 2) return 0.0;
    return dates.length / (spanDays / 30.0);
  }

  static String _status(int count, int span, double rate) {
    if (count < 3) return 'timelapseNeedMore';
    if (span < 14) return 'timelapseTooShort';
    if (rate >= 4) return 'timelapseFrequent';
    if (rate >= 2) return 'timelapseGood';
    return 'timelapseSparse';
  }
}
