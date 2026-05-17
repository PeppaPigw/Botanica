import '../models/plant.dart';

class CareCostEntry {
  const CareCostEntry({
    required this.category,
    required this.amount,
    required this.date,
    this.plantId,
    this.note,
  });

  final String category;
  final double amount;
  final DateTime date;
  final String? plantId;
  final String? note;
}

class CostSummary {
  const CostSummary({
    required this.totalSpent,
    required this.monthlyAverage,
    required this.costPerPlant,
    required this.categoryBreakdown,
    required this.monthlyTrend,
    required this.projectedAnnual,
    required this.costEfficiencyScore,
  });

  final double totalSpent;
  final double monthlyAverage;
  final double costPerPlant;
  final Map<String, double> categoryBreakdown;
  final List<double> monthlyTrend;
  final double projectedAnnual;
  final double costEfficiencyScore;
}

class CareCostTracker {
  const CareCostTracker._();

  static const defaultCategories = [
    'plants',
    'soil',
    'pots',
    'fertilizer',
    'tools',
    'pesticide',
    'accessories',
  ];

  static CostSummary computeSummary({
    required List<CareCostEntry> entries,
    required List<Plant> activePlants,
    required DateTime now,
  }) {
    if (entries.isEmpty) {
      return const CostSummary(
        totalSpent: 0,
        monthlyAverage: 0,
        costPerPlant: 0,
        categoryBreakdown: {},
        monthlyTrend: [],
        projectedAnnual: 0,
        costEfficiencyScore: 1.0,
      );
    }

    final total = entries.fold<double>(0, (s, e) => s + e.amount);

    final earliest = entries.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final months = (now.difference(earliest).inDays / 30.0).clamp(1.0, 999.0);
    final monthlyAvg = total / months;

    final plantCount = activePlants.length.clamp(1, 999);
    final costPerPlant = total / plantCount;

    final categoryBreakdown = <String, double>{};
    for (final entry in entries) {
      categoryBreakdown[entry.category] =
          (categoryBreakdown[entry.category] ?? 0) + entry.amount;
    }

    final monthlyTrend = _computeMonthlyTrend(entries, now);
    final projectedAnnual = monthlyAvg * 12;

    final efficiency = _computeEfficiency(entries, activePlants, now);

    return CostSummary(
      totalSpent: total,
      monthlyAverage: monthlyAvg,
      costPerPlant: costPerPlant,
      categoryBreakdown: categoryBreakdown,
      monthlyTrend: monthlyTrend,
      projectedAnnual: projectedAnnual,
      costEfficiencyScore: efficiency,
    );
  }

  static List<double> _computeMonthlyTrend(List<CareCostEntry> entries, DateTime now) {
    final trend = <double>[];
    for (int m = 5; m >= 0; m--) {
      final monthStart = DateTime(now.year, now.month - m, 1);
      final monthEnd = DateTime(now.year, now.month - m + 1, 1);
      final monthTotal = entries
          .where((e) => e.date.isAfter(monthStart) && e.date.isBefore(monthEnd))
          .fold<double>(0, (s, e) => s + e.amount);
      trend.add(monthTotal);
    }
    return trend;
  }

  static double _computeEfficiency(
      List<CareCostEntry> entries, List<Plant> plants, DateTime now) {
    final recentSpend = entries
        .where((e) => now.difference(e.date).inDays <= 90)
        .fold<double>(0, (s, e) => s + e.amount);
    final plantCount = plants.length.clamp(1, 999);
    final spendPerPlant = recentSpend / plantCount;

    if (spendPerPlant < 5) return 1.0;
    if (spendPerPlant < 15) return 0.8;
    if (spendPerPlant < 30) return 0.6;
    return 0.4;
  }
}
