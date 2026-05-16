import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../domain/models/user_settings.dart';

class ReviewPromptService {
  static const _minStreakToPrompt = 7;
  static const _cooldownDays = 90;

  static bool shouldPrompt(UserSettings settings) {
    if (settings.careStreakDays < _minStreakToPrompt) return false;

    if (settings.lastReviewPromptDate != null) {
      final daysSince = DateTime.now()
          .difference(settings.lastReviewPromptDate!)
          .inDays;
      if (daysSince < _cooldownDays) return false;
    }

    return true;
  }

  static Future<void> maybeRequestReview(BuildContext context) async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }
}
