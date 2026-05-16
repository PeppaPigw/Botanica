import 'package:flutter/widgets.dart';

import 'enums.dart';

class UserSettings {
  const UserSettings({
    required this.hasCompletedOnboarding,
    required this.temperatureUnit,
    required this.beliefMode,
    required this.reminderTimePreference,
    required this.hemisphere,
    required this.localeCode,
    required this.enableDynamicColor,
    required this.enableAiInsights,
    required this.aiPreferredEndpointIndex,
    required this.careStreakDays,
    required this.longestStreak,
    required this.lastCareDate,
    required this.lastMilestoneCelebrated,
    this.consecutivePerfectDays = 0,
    this.lastPerfectDate,
    this.streakFreezeCount = 0,
    this.lastStreakFreezeUsed,
    this.lastReviewPromptDate,
    this.lastWeeklyRecapShown,
    this.dailySeed,
    this.birthDate,
    this.westernZodiacSignId,
    this.dismissedSeasonTipKey,
    this.dismissedCoachingDate,
    this.vacationEndDate,
  });

  factory UserSettings.defaults() => const UserSettings(
        hasCompletedOnboarding: false,
        temperatureUnit: TemperatureUnit.celsius,
        beliefMode: BeliefMode.unselected,
        reminderTimePreference: ReminderTimePreference.morning,
        hemisphere: Hemisphere.northern,
        localeCode: null,
        enableDynamicColor: true,
        enableAiInsights: false,
        aiPreferredEndpointIndex: 0,
        careStreakDays: 0,
        longestStreak: 0,
        lastCareDate: null,
        lastMilestoneCelebrated: 0,
        dailySeed: null,
        birthDate: null,
        westernZodiacSignId: null,
      );

  final bool hasCompletedOnboarding;
  final TemperatureUnit temperatureUnit;
  final BeliefMode beliefMode;
  final ReminderTimePreference reminderTimePreference;
  final Hemisphere hemisphere;
  final String? localeCode;
  final bool enableDynamicColor;
  final bool enableAiInsights;
  final int aiPreferredEndpointIndex;
  final int careStreakDays;
  final int longestStreak;
  final DateTime? lastCareDate;
  final int lastMilestoneCelebrated;
  final int streakFreezeCount;
  final int consecutivePerfectDays;
  final DateTime? lastPerfectDate;
  final DateTime? lastStreakFreezeUsed;
  final DateTime? lastReviewPromptDate;
  final DateTime? lastWeeklyRecapShown;
  final String? dailySeed;
  final DateTime? birthDate;
  final String? westernZodiacSignId;
  final String? dismissedSeasonTipKey;
  final DateTime? dismissedCoachingDate;
  final DateTime? vacationEndDate;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  bool get isOnVacation {
    if (vacationEndDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(
      vacationEndDate!.year,
      vacationEndDate!.month,
      vacationEndDate!.day,
    );
    return !today.isAfter(end);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserSettings &&
            other.hasCompletedOnboarding == hasCompletedOnboarding &&
            other.temperatureUnit == temperatureUnit &&
            other.beliefMode == beliefMode &&
            other.reminderTimePreference == reminderTimePreference &&
            other.hemisphere == hemisphere &&
            other.localeCode == localeCode &&
            other.enableDynamicColor == enableDynamicColor &&
            other.enableAiInsights == enableAiInsights &&
            other.aiPreferredEndpointIndex == aiPreferredEndpointIndex &&
            other.careStreakDays == careStreakDays &&
            other.longestStreak == longestStreak &&
            other.lastCareDate == lastCareDate &&
            other.lastMilestoneCelebrated == lastMilestoneCelebrated &&
            other.streakFreezeCount == streakFreezeCount &&
            other.consecutivePerfectDays == consecutivePerfectDays &&
            other.lastPerfectDate == lastPerfectDate &&
            other.lastStreakFreezeUsed == lastStreakFreezeUsed &&
            other.lastReviewPromptDate == lastReviewPromptDate &&
            other.lastWeeklyRecapShown == lastWeeklyRecapShown &&
            other.dailySeed == dailySeed &&
            other.birthDate == birthDate &&
            other.westernZodiacSignId == westernZodiacSignId &&
            other.dismissedSeasonTipKey == dismissedSeasonTipKey &&
            other.dismissedCoachingDate == dismissedCoachingDate &&
            other.vacationEndDate == vacationEndDate);
  }

  @override
  int get hashCode => Object.hash(
        hasCompletedOnboarding,
        temperatureUnit,
        beliefMode,
        reminderTimePreference,
        hemisphere,
        localeCode,
        enableDynamicColor,
        enableAiInsights,
        aiPreferredEndpointIndex,
        careStreakDays,
        longestStreak,
        lastCareDate,
        lastMilestoneCelebrated,
        streakFreezeCount,
        consecutivePerfectDays,
        lastPerfectDate,
        lastStreakFreezeUsed,
        lastReviewPromptDate,
        dailySeed,
        Object.hash(birthDate, westernZodiacSignId, dismissedSeasonTipKey, dismissedCoachingDate, lastWeeklyRecapShown, vacationEndDate),
      );

  static const Object _unset = Object();

  UserSettings copyWith({
    bool? hasCompletedOnboarding,
    TemperatureUnit? temperatureUnit,
    BeliefMode? beliefMode,
    ReminderTimePreference? reminderTimePreference,
    Hemisphere? hemisphere,
    Object? localeCode = _unset,
    bool? enableDynamicColor,
    bool? enableAiInsights,
    int? aiPreferredEndpointIndex,
    int? careStreakDays,
    int? longestStreak,
    Object? lastCareDate = _unset,
    int? lastMilestoneCelebrated,
    int? streakFreezeCount,
    int? consecutivePerfectDays,
    Object? lastPerfectDate = _unset,
    Object? lastStreakFreezeUsed = _unset,
    Object? lastReviewPromptDate = _unset,
    Object? lastWeeklyRecapShown = _unset,
    Object? dailySeed = _unset,
    Object? birthDate = _unset,
    Object? westernZodiacSignId = _unset,
    Object? dismissedSeasonTipKey = _unset,
    Object? dismissedCoachingDate = _unset,
    Object? vacationEndDate = _unset,
  }) {
    return UserSettings(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      beliefMode: beliefMode ?? this.beliefMode,
      reminderTimePreference:
          reminderTimePreference ?? this.reminderTimePreference,
      hemisphere: hemisphere ?? this.hemisphere,
      localeCode: identical(localeCode, _unset)
          ? this.localeCode
          : localeCode as String?,
      enableDynamicColor: enableDynamicColor ?? this.enableDynamicColor,
      enableAiInsights: enableAiInsights ?? this.enableAiInsights,
      aiPreferredEndpointIndex:
          aiPreferredEndpointIndex ?? this.aiPreferredEndpointIndex,
      careStreakDays: careStreakDays ?? this.careStreakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCareDate: identical(lastCareDate, _unset)
          ? this.lastCareDate
          : lastCareDate as DateTime?,
      lastMilestoneCelebrated:
          lastMilestoneCelebrated ?? this.lastMilestoneCelebrated,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      consecutivePerfectDays:
          consecutivePerfectDays ?? this.consecutivePerfectDays,
      lastPerfectDate: identical(lastPerfectDate, _unset)
          ? this.lastPerfectDate
          : lastPerfectDate as DateTime?,
      lastStreakFreezeUsed: identical(lastStreakFreezeUsed, _unset)
          ? this.lastStreakFreezeUsed
          : lastStreakFreezeUsed as DateTime?,
      lastReviewPromptDate: identical(lastReviewPromptDate, _unset)
          ? this.lastReviewPromptDate
          : lastReviewPromptDate as DateTime?,
      lastWeeklyRecapShown: identical(lastWeeklyRecapShown, _unset)
          ? this.lastWeeklyRecapShown
          : lastWeeklyRecapShown as DateTime?,
      dailySeed:
          identical(dailySeed, _unset) ? this.dailySeed : dailySeed as String?,
      birthDate: identical(birthDate, _unset)
          ? this.birthDate
          : birthDate as DateTime?,
      westernZodiacSignId: identical(westernZodiacSignId, _unset)
          ? this.westernZodiacSignId
          : westernZodiacSignId as String?,
      dismissedSeasonTipKey: identical(dismissedSeasonTipKey, _unset)
          ? this.dismissedSeasonTipKey
          : dismissedSeasonTipKey as String?,
      dismissedCoachingDate: identical(dismissedCoachingDate, _unset)
          ? this.dismissedCoachingDate
          : dismissedCoachingDate as DateTime?,
      vacationEndDate: identical(vacationEndDate, _unset)
          ? this.vacationEndDate
          : vacationEndDate as DateTime?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'temperatureUnit': temperatureUnit.id,
        'beliefMode': beliefMode.id,
        'reminderTimePreference': reminderTimePreference.id,
        'hemisphere': hemisphere.id,
        'localeCode': localeCode,
        'enableDynamicColor': enableDynamicColor,
        'enableAiInsights': enableAiInsights,
        'aiPreferredEndpointIndex': aiPreferredEndpointIndex,
        'careStreakDays': careStreakDays,
        'longestStreak': longestStreak,
        'lastCareDate':
            lastCareDate == null ? null : _formatDateOnly(lastCareDate!),
        'lastMilestoneCelebrated': lastMilestoneCelebrated,
        'streakFreezeCount': streakFreezeCount,
        'consecutivePerfectDays': consecutivePerfectDays,
        'lastPerfectDate':
            lastPerfectDate == null ? null : _formatDateOnly(lastPerfectDate!),
        'lastStreakFreezeUsed': lastStreakFreezeUsed == null
            ? null
            : _formatDateOnly(lastStreakFreezeUsed!),
        'lastReviewPromptDate': lastReviewPromptDate == null
            ? null
            : _formatDateOnly(lastReviewPromptDate!),
        'lastWeeklyRecapShown': lastWeeklyRecapShown == null
            ? null
            : _formatDateOnly(lastWeeklyRecapShown!),
        'dailySeed': dailySeed,
        'birthDate': birthDate == null ? null : _formatDateOnly(birthDate!),
        'westernZodiacSignId': westernZodiacSignId,
        'dismissedSeasonTipKey': dismissedSeasonTipKey,
        'dismissedCoachingDate': dismissedCoachingDate == null
            ? null
            : _formatDateOnly(dismissedCoachingDate!),
        'vacationEndDate':
            vacationEndDate == null ? null : _formatDateOnly(vacationEndDate!),
      };

  static UserSettings fromJson(Map<String, dynamic> json) {
    return UserSettings(
      hasCompletedOnboarding:
          (json['hasCompletedOnboarding'] as bool?) ?? false,
      temperatureUnit:
          TemperatureUnit.fromId(json['temperatureUnit'] as String?),
      beliefMode: BeliefMode.fromId(json['beliefMode'] as String?),
      reminderTimePreference: ReminderTimePreference.fromId(
        json['reminderTimePreference'] as String?,
      ),
      hemisphere: Hemisphere.fromId(json['hemisphere'] as String?),
      localeCode: json['localeCode'] as String?,
      enableDynamicColor: (json['enableDynamicColor'] as bool?) ?? true,
      enableAiInsights: (json['enableAiInsights'] as bool?) ?? false,
      aiPreferredEndpointIndex:
          (json['aiPreferredEndpointIndex'] as num?)?.toInt() ?? 0,
      careStreakDays: (json['careStreakDays'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastCareDate: _parseDateOnly(json['lastCareDate']),
      lastMilestoneCelebrated:
          (json['lastMilestoneCelebrated'] as num?)?.toInt() ?? 0,
      streakFreezeCount: (json['streakFreezeCount'] as num?)?.toInt() ?? 0,
      consecutivePerfectDays:
          (json['consecutivePerfectDays'] as num?)?.toInt() ?? 0,
      lastPerfectDate: _parseDateOnly(json['lastPerfectDate']),
      lastStreakFreezeUsed: _parseDateOnly(json['lastStreakFreezeUsed']),
      lastReviewPromptDate: _parseDateOnly(json['lastReviewPromptDate']),
      lastWeeklyRecapShown: _parseDateOnly(json['lastWeeklyRecapShown']),
      dailySeed: json['dailySeed'] as String?,
      birthDate: _parseDateOnly(json['birthDate']),
      westernZodiacSignId: json['westernZodiacSignId'] as String?,
      dismissedSeasonTipKey: json['dismissedSeasonTipKey'] as String?,
      dismissedCoachingDate: _parseDateOnly(json['dismissedCoachingDate']),
      vacationEndDate: _parseDateOnly(json['vacationEndDate']),
    );
  }
}

String _formatDateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime? _parseDateOnly(Object? raw) {
  final s = raw is String ? raw.trim() : null;
  if (s == null || s.isEmpty) return null;
  final parsed = DateTime.tryParse(s);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}
