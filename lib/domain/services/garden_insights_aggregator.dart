import '../models/care_log.dart';
import '../models/plant.dart';
import '../models/species.dart';
import '../models/task_instance.dart';
import '../models/user_settings.dart';
import 'environment_stress_detector.dart';
import 'next_action_recommender.dart';
import 'seasonal_care_advisor.dart';
import 'smart_greeting_engine.dart';
import 'weekly_report_engine.dart';

class GardenInsight {
  const GardenInsight({
    required this.type,
    required this.title,
    required this.body,
    required this.priority,
    this.plantId,
    this.actionRoute,
  });

  final GardenInsightType type;
  final String title;
  final String body;
  final int priority;
  final String? plantId;
  final String? actionRoute;
}

enum GardenInsightType {
  greeting,
  nextAction,
  stressAlert,
  seasonalTip,
  weeklyHighlight,
}

class GardenInsightsFeed {
  const GardenInsightsFeed({
    required this.greeting,
    required this.insights,
  });

  final SmartGreeting greeting;
  final List<GardenInsight> insights;
}

class GardenInsightsAggregator {
  const GardenInsightsAggregator._();

  static GardenInsightsFeed generate({
    required List<Plant> plants,
    required List<CareLog> logs,
    required List<TaskInstance> tasks,
    required UserSettings settings,
    required Map<String, Species> speciesMap,
    required DateTime now,
    bool isRaining = false,
  }) {
    final greeting = SmartGreetingEngine.generate(
      plants: plants,
      logs: logs,
      settings: settings,
      now: now,
      isRaining: isRaining,
    );

    final insights = <GardenInsight>[];

    final action = NextActionRecommender.recommend(
      plants: plants,
      tasks: tasks,
      logs: logs,
      settings: settings,
      now: now,
    );
    if (action.type != ActionType.rest) {
      insights.add(GardenInsight(
        type: GardenInsightType.nextAction,
        title: action.messageKey,
        body: action.plantNickname,
        priority: action.priority,
        plantId: action.plantId,
      ));
    }

    final stressResults = EnvironmentStressDetector.detectAll(
      plants: plants,
      logs: logs,
      tasks: tasks,
      now: now,
    );
    for (final stress in stressResults.take(2)) {
      insights.add(GardenInsight(
        type: GardenInsightType.stressAlert,
        title: stress.suggestion,
        body: stress.plantNickname,
        priority: stress.level == StressLevel.high ? 9 : 6,
        plantId: stress.plantId,
      ));
    }

    final seasonalTips = SeasonalCareAdvisor.advise(
      plants: plants,
      speciesMap: speciesMap,
      settings: settings,
      now: now,
    );
    if (seasonalTips.isNotEmpty) {
      final tip = seasonalTips.first;
      insights.add(GardenInsight(
        type: GardenInsightType.seasonalTip,
        title: tip.messageKey,
        body: tip.plantNickname,
        priority: tip.priority,
        plantId: tip.plantId,
      ));
    }

    final report = WeeklyReportEngine.generate(
      plants: plants,
      logs: logs,
      tasks: tasks,
      settings: settings,
      now: now,
    );
    for (final highlight in report.highlights.take(1)) {
      insights.add(GardenInsight(
        type: GardenInsightType.weeklyHighlight,
        title: highlight.messageKey,
        body: highlight.args.values.join(', '),
        priority: 4,
      ));
    }

    insights.sort((a, b) => b.priority.compareTo(a.priority));
    return GardenInsightsFeed(
      greeting: greeting,
      insights: insights.take(4).toList(),
    );
  }
}
