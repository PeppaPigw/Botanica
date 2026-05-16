import '../models/care_log.dart';
import '../models/plant.dart';
import 'care_burnout_detector.dart';
import 'garden_momentum_engine.dart';
import 'weekly_insight_engine.dart';

class DailyBriefingItem {
  const DailyBriefingItem({
    required this.type,
    required this.titleKey,
    required this.bodyKey,
    required this.priority,
    required this.iconHint,
    this.plantId,
    this.metric,
    this.actionKey,
  });

  final String type;
  final String titleKey;
  final String bodyKey;
  final int priority;
  final String iconHint;
  final String? plantId;
  final double? metric;
  final String? actionKey;
}

class DailyBriefing {
  const DailyBriefing({
    required this.greeting,
    required this.items,
    required this.momentumScore,
    required this.burnoutRisk,
    required this.topPriority,
  });

  final String greeting;
  final List<DailyBriefingItem> items;
  final double momentumScore;
  final String burnoutRisk;
  final DailyBriefingItem? topPriority;
}

class DailyBriefingEngine {
  const DailyBriefingEngine._();

  static DailyBriefing generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required Map<String, double> healthScores,
    required int streakDays,
    required int plantsAddedThisMonth,
    required int missedTasksThisWeek,
    required int missedTasksLastWeek,
    required int totalDailyTasks,
    required DateTime now,
  }) {
    final items = <DailyBriefingItem>[];

    final momentum = GardenMomentumEngine.compute(
      plants: plants, logs: logs, streakDays: streakDays,
      plantsAddedThisMonth: plantsAddedThisMonth, now: now,
    );

    final burnout = CareBurnoutDetector.assess(
      plants: plants, logs: logs,
      missedTasksThisWeek: missedTasksThisWeek,
      missedTasksLastWeek: missedTasksLastWeek,
      totalDailyTasks: totalDailyTasks, now: now,
    );

    final insights = WeeklyInsightEngine.generate(
      plants: plants, logs: logs, healthScores: healthScores, now: now,
    );

    _addMomentumItem(momentum, items);
    _addBurnoutWarning(burnout, items);
    _addInsightItems(insights, items);
    _addHealthAlerts(plants, healthScores, items);
    _addStreakItem(streakDays, items);

    items.sort((a, b) => b.priority.compareTo(a.priority));
    final displayed = items.take(5).toList();

    final greeting = _greeting(now.hour);

    return DailyBriefing(
      greeting: greeting,
      items: displayed,
      momentumScore: momentum.score,
      burnoutRisk: burnout.riskLevel,
      topPriority: displayed.isNotEmpty ? displayed.first : null,
    );
  }

  static void _addMomentumItem(GardenMomentum m, List<DailyBriefingItem> out) {
    if (m.score >= 0.8) {
      out.add(DailyBriefingItem(
        type: 'momentum', titleKey: 'briefingMomentumHigh',
        bodyKey: m.encouragement, priority: 6, iconHint: 'fire',
        metric: m.score,
      ));
    } else if (m.score < 0.3) {
      out.add(DailyBriefingItem(
        type: 'momentum', titleKey: 'briefingMomentumLow',
        bodyKey: 'briefingMomentumLowBody', priority: 7, iconHint: 'seedling',
        metric: m.score, actionKey: 'briefingActionCareToday',
      ));
    }
  }

  static void _addBurnoutWarning(BurnoutReport b, List<DailyBriefingItem> out) {
    if (b.riskLevel == 'burnoutHigh') {
      out.add(DailyBriefingItem(
        type: 'burnout', titleKey: 'briefingBurnoutWarning',
        bodyKey: 'briefingBurnoutBody', priority: 9, iconHint: 'warning',
        actionKey: b.suggestions.isNotEmpty ? b.suggestions.first : null,
      ));
    }
  }

  static void _addInsightItems(WeeklyInsightDigest d, List<DailyBriefingItem> out) {
    if (d.topInsight != null) {
      out.add(DailyBriefingItem(
        type: 'insight', titleKey: d.topInsight!.titleKey,
        bodyKey: d.topInsight!.bodyKey, priority: 5, iconHint: 'lightbulb',
        metric: d.topInsight!.metric,
      ));
    }
  }

  static void _addHealthAlerts(
      List<Plant> plants, Map<String, double> scores, List<DailyBriefingItem> out) {
    final critical = plants.where((p) =>
        !p.isArchived && (scores[p.id] ?? 0.5) < 0.3).toList();
    if (critical.isNotEmpty) {
      out.add(DailyBriefingItem(
        type: 'healthAlert', titleKey: 'briefingHealthCritical',
        bodyKey: 'briefingHealthCriticalBody', priority: 8, iconHint: 'heart',
        plantId: critical.first.id, metric: critical.length.toDouble(),
        actionKey: 'briefingActionCheckPlant',
      ));
    }
  }

  static void _addStreakItem(int days, List<DailyBriefingItem> out) {
    if (days == 6 || days == 13 || days == 29 || days == 89) {
      out.add(DailyBriefingItem(
        type: 'streakMilestone', titleKey: 'briefingStreakAlmost',
        bodyKey: 'briefingStreakAlmostBody', priority: 7, iconHint: 'trophy',
        metric: (days + 1).toDouble(),
      ));
    }
  }

  static String _greeting(int hour) {
    if (hour < 12) return 'briefingGoodMorning';
    if (hour < 17) return 'briefingGoodAfternoon';
    return 'briefingGoodEvening';
  }
}
