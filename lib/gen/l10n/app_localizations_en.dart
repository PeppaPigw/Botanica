// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Botanica';

  @override
  String get appTagline =>
      'Your personal plant care companion — calm, beautiful, and thoughtful.';

  @override
  String get gardenNoScheduleYet => 'No schedule yet';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonStart => 'Start';

  @override
  String get commonDone => 'Done';

  @override
  String get commonOverdue => 'Overdue';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonShow => 'Show';

  @override
  String get commonHide => 'Hide';

  @override
  String get commonLater => 'Later';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonUnits => 'Units';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonAbout => 'About';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonErrorTryAgain => 'Something went wrong. Please try again.';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonViewAll => 'View all';

  @override
  String get commonWhy => 'Why?';

  @override
  String get commonIdeal => 'Ideal';

  @override
  String get commonTolerates => 'Tolerates';

  @override
  String get commonSoil => 'Soil';

  @override
  String get commonSoilPh => 'Soil pH';

  @override
  String get commonWhen => 'When';

  @override
  String get commonHow => 'How';

  @override
  String get commonPestsAndDiseases => 'Pests & diseases';

  @override
  String get commonPrevention => 'Prevention';

  @override
  String get commonHeatwave => 'Heatwave';

  @override
  String get commonFrost => 'Frost';

  @override
  String get commonStorm => 'Storm';

  @override
  String get commonHeavyRain => 'Heavy rain';

  @override
  String get commonClimateHotDry => 'Hot / Dry';

  @override
  String get commonClimateCoolWet => 'Cool / Wet';

  @override
  String get commonClimateStrategies => 'Climate strategies';

  @override
  String get resourcesTitle => 'Resources';

  @override
  String get resourceWikipedia => 'Wikipedia';

  @override
  String get resourceYouTube => 'YouTube';

  @override
  String get resourceBaiduBaike => 'Baidu Baike';

  @override
  String get resourceBilibili => 'Bilibili';

  @override
  String get resourceGbif => 'GBIF';

  @override
  String get resourceCareGuide => 'Care guide';

  @override
  String get resourceCopyLink => 'Copy link';

  @override
  String get resourceLinkCopied => 'Link copied';

  @override
  String get aiNoteCopied => 'Copied';

  @override
  String get aiNoteCopyAction => 'Copy note';

  @override
  String get stateLoadFailedTitle => 'Couldn’t load';

  @override
  String get stateLoadFailedBody => 'Check your connection and try again.';

  @override
  String get stateNotAvailableTitle => 'Not available';

  @override
  String get stateNotAvailableBody => 'This content isn’t available right now.';

  @override
  String get navGarden => 'Garden';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navDaily => 'Daily';

  @override
  String get navProfile => 'Profile';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarFilterAll => 'All';

  @override
  String get calendarFilterOther => 'Other';

  @override
  String get calendarSectionConsistency => 'Month consistency';

  @override
  String get calendarPrevMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarSectionHistory => 'Care history';

  @override
  String get calendarWeekAheadTitle => 'Week ahead';

  @override
  String calendarWeekAheadCount(int count) {
    return '$count tasks';
  }

  @override
  String get calendarNoEvents => 'No care logs for this day.';

  @override
  String get splashTagline => 'Calm care, beautifully organized.';

  @override
  String get onboardingTitle1 => 'Breathe life into your space';

  @override
  String get onboardingBody1 =>
      'Track your plants, build a beautiful timeline, and cultivate calm, one leaf at a time.';

  @override
  String get onboardingTitle2 => 'Botanica learns your light';

  @override
  String get onboardingBody2 =>
      'Care that adapts to your environment—season, humidity, and temperature.';

  @override
  String get onboardingTitle3 => 'A daily ritual of growth';

  @override
  String get onboardingBody3 =>
      'Gently discover new plants and center your mind with daily botanical inspiration.';

  @override
  String get onboardingCta => 'Enter your garden';

  @override
  String get permissionsTitle => 'Grow together';

  @override
  String get permissionsSubtitle =>
      'Allow Botanica to care for your plants seamlessly, or choose when you\'re ready.';

  @override
  String get permNotificationsTitle => 'Gentle Reminders';

  @override
  String get permNotificationsBody => 'So neither of you goes thirsty.';

  @override
  String get notificationsSoftAskTitle => 'Never miss watering day';

  @override
  String get notificationsSoftAskBody =>
      'Botanica sends calm reminders at your preferred time, so each plant gets care before leaves start to droop.';

  @override
  String get permLocationTitle => 'Climate Insight';

  @override
  String get permLocationBody => 'Care adapted exactly to your local weather.';

  @override
  String get permCameraTitle => 'Visual Journal';

  @override
  String get permCameraBody =>
      'Capture growth and identify plants with a glance.';

  @override
  String get permLocationServicesOff => 'Location services are turned off.';

  @override
  String get permStatusEnabled => 'Enabled';

  @override
  String get permStatusNotEnabled => 'Not enabled';

  @override
  String get permStatusLimited => 'Limited';

  @override
  String get permStatusProvisional => 'Provisional';

  @override
  String get permStatusRestricted => 'Restricted';

  @override
  String get permStatusBlocked => 'Blocked';

  @override
  String get permActionEnable => 'Enable';

  @override
  String get permActionOpenSettings => 'Open settings';

  @override
  String get permissionsEnableAll => 'Enable all now';

  @override
  String get permissionsNotNow => 'Not now';

  @override
  String get permissionsPrivacyNote =>
      'Botanica asks only when needed — you can change this later in Profile.';

  @override
  String get gardenTitle => 'Garden';

  @override
  String get gardenTodayCardTitle => 'Today';

  @override
  String get gardenGreetingMorning => 'Good morning';

  @override
  String get gardenGreetingAfternoon => 'Good afternoon';

  @override
  String get gardenGreetingEvening => 'Good evening';

  @override
  String get gardenLoadError => 'Failed to load plants.';

  @override
  String gardenTasksDueToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks due',
      one: '1 task due',
      zero: 'No tasks due',
    );
    return '$_temp0';
  }

  @override
  String get gardenAllCaughtUp => 'All caught up! Your plants are happy.';

  @override
  String allDoneQuietRunway(int days) {
    return 'Nothing due for $days days';
  }

  @override
  String allDoneTomorrowPreview(int count, String plants) {
    return 'Tomorrow · $count tasks for $plants';
  }

  @override
  String get gardenVacationBanner => 'Vacation mode — reminders paused';

  @override
  String get gardenWeeklySummaryTitle => 'This Week';

  @override
  String gardenWeeklyCareActions(int count) {
    return '$count care actions';
  }

  @override
  String gardenWeeklyWatered(int count) {
    return '$count watered';
  }

  @override
  String gardenWeeklyFertilized(int count) {
    return '$count fertilized';
  }

  @override
  String gardenCareStreakChip(int days) {
    return '$days-day streak';
  }

  @override
  String gardenStreakAtRisk(int days) {
    return 'Your $days-day streak ends today — care for a plant to keep it!';
  }

  @override
  String gardenWeatherChip(
      String condition, int temp, String unit, int humidity) {
    return '$condition · $temp°$unit · $humidity%';
  }

  @override
  String get weatherClear => 'Clear';

  @override
  String get weatherPartlyCloudy => 'Partly cloudy';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherFog => 'Fog';

  @override
  String get weatherDrizzle => 'Drizzle';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherSnow => 'Snow';

  @override
  String get weatherThunder => 'Thunderstorm';

  @override
  String get weatherUnknown => 'Weather';

  @override
  String get weatherTipRainy =>
      'Rainy outside — skip watering outdoor plants today';

  @override
  String get weatherTipStormy =>
      'Stormy weather — bring sensitive plants indoors';

  @override
  String get weatherTipExtremeHeat =>
      'Extreme heat — check soil moisture and mist leaves';

  @override
  String get weatherTipHotSunny =>
      'Hot and sunny — water early morning or evening';

  @override
  String get weatherTipNearFreezing =>
      'Near freezing — protect frost-sensitive plants';

  @override
  String get weatherTipSnow => 'Snow expected — move outdoor pots to shelter';

  @override
  String get weatherTipCool => 'Cool day — reduce watering frequency';

  @override
  String get weatherTipLowHumidity =>
      'Dry air today — mist tropical plants or group them together';

  @override
  String get weatherTipHighHumidity =>
      'High humidity — hold off on misting and watch for fungal issues';

  @override
  String get seasonalTipSpring =>
      'Spring is here — time to fertilize and repot if needed';

  @override
  String get seasonalTipSummer =>
      'Summer heat means more frequent watering for most plants';

  @override
  String get seasonalTipAutumn =>
      'Autumn — reduce fertilizing as plants slow their growth';

  @override
  String get seasonalTipWinter =>
      'Winter — most plants need less water and no fertilizer';

  @override
  String get gardenQuickWatered => 'Watered';

  @override
  String get gardenQuickSnooze => 'Snooze';

  @override
  String get gardenQuickLogCare => 'Log care';

  @override
  String get gardenQuickLogDone => 'Logged!';

  @override
  String get gardenViewDetails => 'View details';

  @override
  String get tasksSnoozeOneHour => '1 hour';

  @override
  String get tasksSnoozeThreeHours => '3 hours';

  @override
  String get tasksSnoozeTomorrow => 'Tomorrow';

  @override
  String get tasksSnoozeTomorrowMorning => 'Tomorrow morning';

  @override
  String get tasksSnoozeWeekend => 'This weekend';

  @override
  String get tasksSnoozeCustomTime => 'Custom time';

  @override
  String get gardenQuickAddPlant => 'Add plant';

  @override
  String get gardenRoomsTitle => 'Rooms';

  @override
  String get gardenRoomsAll => 'All rooms';

  @override
  String get gardenToggleCardMode => 'Toggle Card Mode';

  @override
  String get gardenToggleViewMode => 'Toggle View Mode';

  @override
  String gardenRoomPlantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plants',
      one: '1 plant',
    );
    return '$_temp0';
  }

  @override
  String profilePlantsInGarden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plants in your garden',
      one: '1 plant in your garden',
    );
    return '$_temp0';
  }

  @override
  String get discoverInYourGarden => 'in your garden';

  @override
  String get gardenRoomsWaterAll => 'Water all';

  @override
  String get gardenRoomsSnoozeAll => 'Snooze all';

  @override
  String gardenRoomsWateredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Watered $count plants',
      one: 'Watered 1 plant',
    );
    return '$_temp0';
  }

  @override
  String gardenRoomsSnoozedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Snoozed $count tasks',
      one: 'Snoozed 1 task',
    );
    return '$_temp0';
  }

  @override
  String get gardenEmptyTitle => 'Start your garden';

  @override
  String get gardenEmptyBody =>
      'Add your first plant to unlock a tailored care plan and daily tasks.';

  @override
  String get gardenEmptyCta => 'Add your first plant';

  @override
  String get gardenAddPlantFab => 'Add Plant';

  @override
  String get addPlantTitle => 'Add Plant';

  @override
  String get addPlantMethodScan => 'Scan';

  @override
  String get addPlantMethodLibrary => 'From library';

  @override
  String get addPlantMethodManual => 'Manual entry';

  @override
  String get addPlantScanTitle => 'Scan your plant';

  @override
  String get addPlantScanBody =>
      'Capture leaf + full plant for better results.';

  @override
  String get addPlantScanButton => 'Scan now';

  @override
  String get addPlantLibraryTitle => 'Choose a plant';

  @override
  String get addPlantManualTitle => 'Tell us about it';

  @override
  String get addPlantConfirmTitle => 'Confirm details';

  @override
  String get addPlantFieldNickname => 'Nickname';

  @override
  String get addPlantFieldRoom => 'Room';

  @override
  String get addPlantDefaultRoomLivingRoom => 'Living room';

  @override
  String get addPlantDefaultSpeciesUnknown => 'Unknown';

  @override
  String get addPlantFieldEnvironment => 'Environment';

  @override
  String get addPlantEnvIndoor => 'Indoor';

  @override
  String get addPlantEnvBalcony => 'Balcony';

  @override
  String get addPlantEnvOutdoor => 'Outdoor';

  @override
  String get addPlantReminderTime => 'Reminder time';

  @override
  String get addPlantReminderMorning => 'Morning';

  @override
  String get addPlantReminderEvening => 'Evening';

  @override
  String get addPlantReminderCustom => 'Custom';

  @override
  String get addPlantSaveButton => 'Save to Garden';

  @override
  String get plantDetailOverview => 'Overview';

  @override
  String get plantDetailCare => 'Care';

  @override
  String get plantDetailJournal => 'Journal';

  @override
  String get plantDetailLogs => 'Logs';

  @override
  String get plantDetailLogsEmptyTitle => 'No care logs yet';

  @override
  String get plantDetailLogsEmptyBody =>
      'Complete a watering or care task and it will appear here.';

  @override
  String get tasksEmptySoon => 'Nothing due soon. You\'re all caught up!';

  @override
  String get tasksEmptyWatch => 'No tasks to watch. Your garden is resting.';

  @override
  String get plantDetailWaterNow => 'Water now';

  @override
  String get plantDetailAddPhoto => 'Add photo';

  @override
  String get plantDetailAddNote => 'Add note';

  @override
  String get plantDetailMissingTitle => 'Plant unavailable';

  @override
  String get plantDetailMissingBody =>
      'This plant can’t be found. It may have been deleted.';

  @override
  String get plantDetailMissingCta => 'Back to Garden';

  @override
  String plantDetailNextWateringInDays(int days) {
    return 'Next watering in $days days';
  }

  @override
  String plantDetailCaringForDays(int days) {
    return 'Caring for $days days';
  }

  @override
  String get plantDetailEnvironmentImpactTitle => 'Environment impact';

  @override
  String plantDetailEnvironmentImpactBaseAdjusted(int base, int adjusted) {
    return 'Base: $base days · Adjusted: $adjusted days';
  }

  @override
  String get plantDetailEnvironmentStable =>
      'Stable conditions — no adjustment today.';

  @override
  String get plantDetailDrynessLow => 'Low dryness (slower drying)';

  @override
  String get plantDetailDrynessBalanced => 'Balanced dryness';

  @override
  String get plantDetailDrynessHigh => 'High dryness (faster drying)';

  @override
  String get plantDetailCareWaterBody =>
      'Next watering is calculated from a base interval and adjusted by humidity, temperature, and season.';

  @override
  String get plantDetailCareLightBody =>
      'Bright, indirect light is a great default for most indoor plants.';

  @override
  String get plantDetailCareTempTitle => 'Temperature';

  @override
  String get plantDetailCareTempBody =>
      'Avoid sudden cold drafts. Stable warmth helps predictable growth.';

  @override
  String get plantDetailJournalDesignNote =>
      'Match framing overlay and compare slider are designed here; plug in camera/gallery later.';

  @override
  String get plantDetailJournalIntro =>
      'A gentle timeline for photos and notes — your plant diary.';

  @override
  String get journalSectionPhotos => 'Photos';

  @override
  String get diarySectionTitle => 'Diary';

  @override
  String get diaryEmptyBody =>
      'No notes yet. Add one to remember what changed.';

  @override
  String get diaryAddEntryTitle => 'New diary entry';

  @override
  String get diaryAddEntryHint => 'Write what you noticed today…';

  @override
  String get diaryAddEntryButton => 'Add note';

  @override
  String get diaryEntryTitle => 'Diary entry';

  @override
  String get diaryEntrySaved => 'Saved to diary.';

  @override
  String get diaryEditEntryTitle => 'Edit diary entry';

  @override
  String get diaryEditConfirmTitle => 'Save changes?';

  @override
  String get diaryEditConfirmBody =>
      'Update this diary entry with your changes.';

  @override
  String get diaryEntryUpdated => 'Diary entry updated.';

  @override
  String get diaryEntryDeleted => 'Diary entry deleted.';

  @override
  String get diaryEntryDeleteTitle => 'Delete diary entry?';

  @override
  String get diaryEntryDeleteBody =>
      'This removes the diary entry from the timeline. You can undo right after deleting.';

  @override
  String get diaryPromptGrowingWell => 'Growing well';

  @override
  String get diaryPromptNewLeaf => 'New leaf';

  @override
  String get diaryPromptStruggling => 'Struggling';

  @override
  String get diaryPromptRepotted => 'Repotted';

  @override
  String get diaryPromptBlooming => 'Blooming';

  @override
  String get journalEntryActions => 'Entry actions';

  @override
  String get journalShareCardTitle => 'Share card';

  @override
  String get journalShareCardText => 'Made with Botanica';

  @override
  String get journalShareFailed => 'Could not share — please try again.';

  @override
  String get journalAddPhotoTitle => 'Add photo';

  @override
  String get journalAddPhotoCamera => 'Camera';

  @override
  String get journalAddPhotoCameraBody =>
      'Capture a new photo with an optional ghost overlay from your last shot.';

  @override
  String get journalAddPhotoGallery => 'Gallery';

  @override
  String get journalAddPhotoGalleryBody => 'Pick a photo from your library.';

  @override
  String get journalCaptureTitle => 'Capture';

  @override
  String get journalCaptureTip =>
      'Fill the frame and try to match your last photo for better comparisons.';

  @override
  String get journalFlash => 'Flash';

  @override
  String get journalCameraPermissionNeeded =>
      'Camera permission is required to capture photos.';

  @override
  String get journalPhotosPermissionNeeded =>
      'Photos permission is required to pick images.';

  @override
  String get journalPhotoSaved => 'Saved to journal.';

  @override
  String get journalPhotoDeleted => 'Photo deleted.';

  @override
  String get journalPhotoDeleteTitle => 'Delete photo?';

  @override
  String get journalPhotoDeleteBody =>
      'This removes the photo from this plant\'s journal and local storage. You can undo right after deleting.';

  @override
  String get journalEmptyBody =>
      'No photos yet. Add one to start your growth timeline.';

  @override
  String get journalPhotoTitle => 'Journal photo';

  @override
  String get journalPhotoNoNote => 'No note';

  @override
  String get journalAddNoteTitle => 'Add a note';

  @override
  String get journalAddNoteHint => 'Optional: new leaf, repotted, etc.';

  @override
  String get journalCompareTitle => 'Compare';

  @override
  String get journalCompareHint => 'Drag left/right to compare.';

  @override
  String get journalPhotoUnavailable => 'Photo unavailable';

  @override
  String get journalOverlayStrength => 'Overlay strength';

  @override
  String get journalPreviousPhoto => 'Previous photo';

  @override
  String get journalLimitedPhotosAccess =>
      'Selected Photos access is on. You can choose visible photos, or update access in iOS Settings.';

  @override
  String journalPhotoMeta(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get scanTitle => 'Scan';

  @override
  String get scanTryAgain => 'Try again';

  @override
  String get scanCaptureTitle => 'Scan your plant';

  @override
  String get scanCaptureTip => 'Capture leaf + full plant for best results.';

  @override
  String get scanCameraPermissionNeeded =>
      'Camera permission is required to scan plants.';

  @override
  String get scanCameraPermissionTitle => 'Camera access';

  @override
  String get scanCameraPermissionBody =>
      'Use the camera for a quick scan, or browse the plant library without granting access.';

  @override
  String get scanUseCamera => 'Use camera';

  @override
  String get scanProcessingBody => 'Identifying your plant…';

  @override
  String get scanChooseCandidate => 'Choose a match';

  @override
  String get scanRefineTitle => 'Not sure? Refine results';

  @override
  String get scanRefineHelper => 'Answer a quick question to narrow the list.';

  @override
  String get scanRefineFallbackNote =>
      'No exact matches for these filters yet—showing closest results.';

  @override
  String get scanConfidenceGuide =>
      'Confidence is a guide only—compare shape and care tags before adding.';

  @override
  String get scanConfidenceStrongLabel => 'High confidence';

  @override
  String get scanConfidenceStrongBody => 'Looks close to the captured plant.';

  @override
  String get scanConfidenceLikelyLabel => 'Moderate confidence';

  @override
  String get scanConfidenceLikelyBody => 'Compare details before adding.';

  @override
  String get scanConfidencePossibleLabel =>
      'Low confidence — try another angle';

  @override
  String get scanConfidencePossibleBody =>
      'Best guess only—capture another view if you can.';

  @override
  String get scanRefineFlowering => 'Is it flowering?';

  @override
  String get scanRefineIndoorOutdoor => 'Indoor or outdoor?';

  @override
  String get scanRefineSucculent => 'Succulent type?';

  @override
  String get scanRefinePetSafe => 'Pet‑safe';

  @override
  String get scanRefineEasy => 'Easy care';

  @override
  String get scanRefineLowLight => 'Low light';

  @override
  String get scanAddToGarden => 'Add to Garden';

  @override
  String get scanBrowseLibrary => 'Browse library instead';

  @override
  String get scanTakingLongerTitle => 'Taking longer than expected';

  @override
  String get scanTakingLongerBody =>
      'The scan did not finish in time. Try again or choose a plant manually.';

  @override
  String get scanNoResultTitle => 'Could not identify this plant';

  @override
  String get scanNoResultBody =>
      'Try another angle with leaf detail, or browse the library instead.';

  @override
  String get scanDeterministicNote =>
      'Demo mode: results are deterministic offline placeholders. Plug in Kindwise/Gemini later.';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksTabToday => 'Today';

  @override
  String get tasksTabSoon => 'Soon';

  @override
  String get tasksTabWatch => 'Watch';

  @override
  String get tasksCalendarToggle => 'Calendar';

  @override
  String get tasksSeasonalTipsTitle => 'Seasonal care tips';

  @override
  String get tipSpringRepot =>
      'Spring: Repot if roots are crowded and growth has resumed.';

  @override
  String get tipSpringFertilize =>
      'Spring: Resume light fertilizing as new growth starts.';

  @override
  String get tipSummerWaterMore =>
      'Summer: Check soil more often — pots dry faster in heat.';

  @override
  String get tipSummerShadeOutdoor =>
      'Summer: Protect balcony/outdoor plants from harsh midday sun.';

  @override
  String get tipAutumnReduceWater =>
      'Autumn: Reduce watering as light and growth slow down.';

  @override
  String get tipAutumnBringIndoor =>
      'Autumn: Bring sensitive plants indoors before cold nights.';

  @override
  String get tipWinterReduceFertilize =>
      'Winter: Fertilize less and water less — growth slows.';

  @override
  String get tipWinterLowLight =>
      'Winter: Move closer to light or use a grow light to prevent stretching.';

  @override
  String tasksSnoozedUntil(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Snoozed until $dateString';
  }

  @override
  String get tasksSkipped => 'Skipped';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverPlantOfTheDay => 'Plant of the Day';

  @override
  String get discoverSearchHint => 'Search plants, guides, and tips';

  @override
  String get discoverNoResultsTitle => 'No matches';

  @override
  String get discoverNoResultsBody =>
      'Try a different name, or search by scientific name.';

  @override
  String get discoverSectionCurated => 'Curated plants';

  @override
  String get discoverSectionLibrary => 'Plant library';

  @override
  String get discoverSectionGuides => 'Guides';

  @override
  String get discoverFilters => 'Filters';

  @override
  String get discoverFilterPetSafe => 'Pet‑safe';

  @override
  String get discoverFilterDifficulty => 'Difficulty';

  @override
  String get discoverFilterLight => 'Light';

  @override
  String get discoverTagPetSafe => 'Pet‑safe';

  @override
  String get discoverTagToxic => 'Toxic';

  @override
  String get discoverGuideWateringTitle => 'Watering basics';

  @override
  String get discoverGuideWateringBody =>
      'Learn how to read soil moisture and avoid overwatering.';

  @override
  String get discoverGuideSoilTitle => 'Soil & drainage';

  @override
  String get discoverGuideSoilBody =>
      'Why airy mixes reduce root rot and help growth.';

  @override
  String get discoverGuidePestTitle => 'Pest checklist';

  @override
  String get discoverGuidePestBody =>
      'A quick weekly routine to catch issues early.';

  @override
  String get discoverAddFavorite => 'Add to favorites';

  @override
  String get discoverRemoveFavorite => 'Remove from favorites';

  @override
  String get speciesDetailHistory => 'History';

  @override
  String get speciesDetailHabit => 'Growth habit';

  @override
  String get speciesDetailCareAtAGlance => 'Care at a glance';

  @override
  String speciesDetailWaterEvery(int days) {
    return 'Water every $days days';
  }

  @override
  String speciesDetailFertilizeEvery(int days) {
    return 'Fertilize every $days days';
  }

  @override
  String speciesDetailMistEvery(int days) {
    return 'Mist every $days days';
  }

  @override
  String get speciesDetailDetails => 'Details';

  @override
  String get speciesDetailOrigin => 'Origin';

  @override
  String get speciesDetailToxicity => 'Toxicity';

  @override
  String get speciesDetailGrowth => 'Growth';

  @override
  String get speciesDetailMatureSize => 'Mature size';

  @override
  String get speciesDetailSizeHeight => 'Height';

  @override
  String get speciesDetailSizeSpread => 'Spread';

  @override
  String get speciesDetailSizeVineLength => 'Vine length';

  @override
  String speciesDetailRangeCm(int min, int max) {
    return '$min–$max cm';
  }

  @override
  String speciesDetailCmValue(int value) {
    return '$value cm';
  }

  @override
  String get speciesDetailUnknown => 'Unknown';

  @override
  String get growthRateSlow => 'Slow';

  @override
  String get growthRateModerate => 'Moderate';

  @override
  String get growthRateFast => 'Fast';

  @override
  String get growthRateUnknown => 'Unknown';

  @override
  String get growthFormUpright => 'Upright';

  @override
  String get growthFormTrailing => 'Trailing';

  @override
  String get growthFormClimbing => 'Climbing';

  @override
  String get growthFormRosette => 'Rosette';

  @override
  String get growthFormTreeLike => 'Tree-like';

  @override
  String get growthFormClumping => 'Clumping';

  @override
  String get growthFormEpiphytic => 'Epiphytic';

  @override
  String get growthFormSucculent => 'Succulent';

  @override
  String get growthFormFern => 'Fern';

  @override
  String get growthFormOrchid => 'Orchid';

  @override
  String get growthFormOther => 'Other';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get lightBrightDirect => 'Bright, direct';

  @override
  String get lightBrightIndirect => 'Bright, indirect';

  @override
  String get lightMediumIndirect => 'Medium, indirect';

  @override
  String get lightLowToBrightIndirect => 'Low to bright, indirect';

  @override
  String get lightLowToBright => 'Low to bright';

  @override
  String get dailyTitle => 'Daily Flower';

  @override
  String get dailyReveal => 'Reveal';

  @override
  String get dailyRevealHintTap => 'Tap to reveal';

  @override
  String get dailyRevealHintSlide => 'Slide to reveal';

  @override
  String get dailyRevealHintHold => 'Hold to reveal';

  @override
  String get dailyRevealHintPull => 'Pull to reveal';

  @override
  String get dailyRevealHintStamp => 'Stamp to reveal';

  @override
  String get dailyRevealHintFlip => 'Flip to reveal';

  @override
  String get dailyRevealHintTrace => 'Trace to reveal';

  @override
  String get dailyInfoTitle => 'About Daily Flower';

  @override
  String get dailyInfoIntro =>
      'Daily Flower is a calm ritual that changes once per day.';

  @override
  String get dailyInfoModeWesternZodiac =>
      'Western zodiac uses your birth date or your selected sign.';

  @override
  String get dailyInfoModeTarot =>
      'Tarot is chosen by drawing four cards and selecting one.';

  @override
  String dailyInfoModeAuto(String mode) {
    return '$mode uses a daily draw from today’s date — personalized with your key.';
  }

  @override
  String get dailyInfoModeJustFlower =>
      'Just Flower is the simplest ritual. Tap to reveal a personalized bloom.';

  @override
  String dailyInfoHowToReveal(String hint) {
    return 'How to reveal: $hint';
  }

  @override
  String get dailyInfoChangeMode => 'Change mode';

  @override
  String get dailySave => 'Save';

  @override
  String get dailyShare => 'Share';

  @override
  String get dailyCareToday => 'Care today';

  @override
  String get dailyHowToAppreciate => 'How to appreciate today';

  @override
  String get dailyAiNoteTitle => 'Botanica note';

  @override
  String get plantCareAiTipTitle => 'Today\'s care tip';

  @override
  String get dailyModeMissingTitle => 'Choose your Daily mode';

  @override
  String get dailyModeMissingBody =>
      'Pick a tradition (tarot, almanac, rune…) and Botanica will personalize your Daily Flower.';

  @override
  String get dailyModeMissingCta => 'Choose a mode';

  @override
  String get dailyTarotNotDrawn => 'Draw today';

  @override
  String get dailyTarotDrawTitle => 'Tarot draw';

  @override
  String get dailyTarotDrawBody =>
      'Four cards are dealt. Choose one — Botanica will reveal today’s flower.';

  @override
  String get dailyTarotDrawCta => 'Deal 4 cards';

  @override
  String get dailyTarotCardLabel => 'Choose';

  @override
  String get dailyDeterministicNote =>
      'Daily Flower is deterministic: same day + locale + mode + your profile yields the same card (great for sharing).';

  @override
  String get dailyContentUnavailableTitle => 'Daily Flower unavailable';

  @override
  String get dailyContentUnavailableBody =>
      'Botanica couldn’t load today’s flower content. Please try again.';

  @override
  String get dailyProfileMissingTitle => 'Complete your profile';

  @override
  String get dailyProfileMissingBody =>
      'Set a personal key in Profile (like a short seed phrase or your birth date) so Daily Flower can be personalized.';

  @override
  String get dailyProfileMissingBodyZodiac =>
      'Set your birth date (or choose your sign) in Profile so Daily Flower can be personalized.';

  @override
  String get dailyProfileMissingCta => 'Set up now';

  @override
  String get careKeyLight => 'Light';

  @override
  String get careKeyWater => 'Water';

  @override
  String get careKeyTemperature => 'Temperature';

  @override
  String get careKeyPetSafety => 'Pet safety';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSectionPermissions => 'Permissions';

  @override
  String get profileSectionData => 'Data';

  @override
  String get profileSectionAbout => 'About';

  @override
  String get storageHealthTitle => 'Storage health';

  @override
  String get storageHealthSubtitle =>
      'Review journal media and clear temporary files.';

  @override
  String get storageJournalPhotos => 'Journal photos';

  @override
  String get storageUsed => 'Storage used';

  @override
  String get storagePhotoFiles => 'Photo files';

  @override
  String get storageJournalEntries => 'Journal entries';

  @override
  String get storagePhotoEntries => 'Photo entries';

  @override
  String get storageMissingPhotos => 'Missing photos';

  @override
  String get storageCacheTitle => 'Temporary cache';

  @override
  String get storageCacheBody =>
      'Clears generated share cards and temporary files without deleting your journal photos.';

  @override
  String get storageClearCache => 'Clear cache';

  @override
  String get storageCacheCleared => 'Temporary cache cleared.';

  @override
  String storageFileCount(int count) {
    return '$count files';
  }

  @override
  String storageEntryCount(int count) {
    return '$count entries';
  }

  @override
  String get exportDataTitle => 'Export care data';

  @override
  String get exportDataSubtitle =>
      'Save your plants and care history as a JSON file.';

  @override
  String get exportDataSuccess => 'Care data exported successfully.';

  @override
  String get exportDataEmpty =>
      'No data to export yet — add some plants first.';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileUnits => 'Units';

  @override
  String get profileHemisphereTitle => 'Hemisphere';

  @override
  String get profileHemisphereBody =>
      'Used for seasonal care adjustments (winter vs summer).';

  @override
  String get hemisphereNorthern => 'Northern';

  @override
  String get hemisphereSouthern => 'Southern';

  @override
  String get profileBeliefMode => 'Daily mode';

  @override
  String get profileDailyProfileTitle => 'Daily personalization';

  @override
  String profileDailyProfileBody(String mode) {
    return 'Choose your personal key for $mode.';
  }

  @override
  String get profileBirthdateTitle => 'Birthdate';

  @override
  String get profileBirthdateBody =>
      'Used for zodiac and almanac personalization.';

  @override
  String get profileDailySeedTitle => 'Personal key';

  @override
  String get profileDailySeedBody =>
      'A short seed phrase (like your nickname) that personalizes Daily Flower without changing your mode.';

  @override
  String get profileDailySeedHint => 'e.g. Aster';

  @override
  String get profileDailyProfileUseBirthdate => 'Use birthdate';

  @override
  String get profileDailyProfileNotSet => 'Not set';

  @override
  String get profileDailyProfileKeySet => 'Key set';

  @override
  String get profileDailyProfileNotNeeded => 'No personal info needed.';

  @override
  String get profileDailyProfilePickModeFirst =>
      'Choose your Daily mode first, then set up the details here.';

  @override
  String get profileDailyProfileTarotSubtitle => 'Draw in Daily';

  @override
  String get profileDailyProfileAutoSubtitle => 'Auto (today’s date)';

  @override
  String get profileDailyProfileTarotBody =>
      'Tarot mode is a daily ritual. Open Daily, deal four cards, and choose one — then today’s flower is revealed.';

  @override
  String get profileDailyProfileTarotCta => 'Open Daily';

  @override
  String profileDailyProfileAutoBody(String mode) {
    return '$mode uses a daily draw based on today’s date — personalized with your key.';
  }

  @override
  String get profileDailyProfileLocalDefault => 'Uses your language';

  @override
  String get profileLocalTraditionKeyTitle => 'Culture key';

  @override
  String get profileLocalTraditionKeyHint => 'e.g. global, china, japan…';

  @override
  String get profilePhotos => 'Photos';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileLocation => 'Location';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get profileBackup => 'Backup';

  @override
  String get profileCredits => 'Credits';

  @override
  String get profileDynamicColorTitle => 'Dynamic color';

  @override
  String get profileDynamicColorBody => 'Use device palette when available.';

  @override
  String get vacationModeTitle => 'Vacation mode';

  @override
  String get vacationModeOff => 'Pause all reminders while you\'re away.';

  @override
  String vacationModeActiveUntil(String date) {
    return 'Active until $date';
  }

  @override
  String get vacationModeEnd => 'End vacation mode';

  @override
  String get vacationModePickDate => 'Return date';

  @override
  String get profileAiInsightsTitle => 'AI insights';

  @override
  String get profileAiInsightsBody =>
      'Subtle on-page notes that personalize your Daily Flower ritual.';

  @override
  String get profileAiKeyTitle => 'AI API key';

  @override
  String get profileAiKeyConfigured => 'Configured';

  @override
  String get profileAiKeyNotSet => 'Not set';

  @override
  String get profileAiKeyNotRequired => 'Not required';

  @override
  String get profileAiKeySheetBody =>
      'Stored securely on this device. Used only to generate short, on-page insights in your selected language.';

  @override
  String get profileAiKeyNotRequiredBody =>
      'This build is configured to use an unauthenticated proxy, so no API key is needed.';

  @override
  String get profileAiKeySheetHint => 'Paste your API key';

  @override
  String get profileAiKeySaved => 'AI key saved.';

  @override
  String get profileAiKeyCleared => 'AI key removed.';

  @override
  String get profileLanguageSystem => 'System';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get creditsOpenSource => 'Open‑source';

  @override
  String get creditsFlutterCommunity => 'Flutter community references';

  @override
  String get creditsUiInspiration => 'UI inspiration';

  @override
  String get creditsPlaceholderNote =>
      'Note: this project uses white placeholder PNGs for imagery — replace assets later with real photography/illustrations.';

  @override
  String get unitsCelsius => 'Celsius (°C)';

  @override
  String get unitsFahrenheit => 'Fahrenheit (°F)';

  @override
  String get beliefModeWesternZodiac => 'Western zodiac';

  @override
  String get beliefModeChineseZodiac => 'Chinese zodiac';

  @override
  String get beliefModeTarot => 'Tarot draw';

  @override
  String get beliefModeLocalTraditions => 'Local traditions';

  @override
  String get beliefModeJustFlower => 'Just give me a flower';

  @override
  String get beliefModeNotSet => 'Not set';

  @override
  String get beliefModeAlmanac => 'Almanac';

  @override
  String get beliefModeOmikuji => 'Japan Omikuji';

  @override
  String get beliefModeRunes => 'Nordic runes';

  @override
  String get beliefModeOgham => 'Celtic ogham';

  @override
  String get zodiacAries => 'Aries';

  @override
  String get zodiacTaurus => 'Taurus';

  @override
  String get zodiacGemini => 'Gemini';

  @override
  String get zodiacCancer => 'Cancer';

  @override
  String get zodiacLeo => 'Leo';

  @override
  String get zodiacVirgo => 'Virgo';

  @override
  String get zodiacLibra => 'Libra';

  @override
  String get zodiacScorpio => 'Scorpio';

  @override
  String get zodiacSagittarius => 'Sagittarius';

  @override
  String get zodiacCapricorn => 'Capricorn';

  @override
  String get zodiacAquarius => 'Aquarius';

  @override
  String get zodiacPisces => 'Pisces';

  @override
  String get chineseZodiacRat => 'Rat';

  @override
  String get chineseZodiacOx => 'Ox';

  @override
  String get chineseZodiacTiger => 'Tiger';

  @override
  String get chineseZodiacRabbit => 'Rabbit';

  @override
  String get chineseZodiacDragon => 'Dragon';

  @override
  String get chineseZodiacSnake => 'Snake';

  @override
  String get chineseZodiacHorse => 'Horse';

  @override
  String get chineseZodiacGoat => 'Goat';

  @override
  String get chineseZodiacMonkey => 'Monkey';

  @override
  String get chineseZodiacRooster => 'Rooster';

  @override
  String get chineseZodiacDog => 'Dog';

  @override
  String get chineseZodiacPig => 'Pig';

  @override
  String get tarotTheFool => 'The Fool';

  @override
  String get tarotTheMagician => 'The Magician';

  @override
  String get tarotTheHighPriestess => 'The High Priestess';

  @override
  String get tarotTheEmpress => 'The Empress';

  @override
  String get tarotTheEmperor => 'The Emperor';

  @override
  String get tarotTheHierophant => 'The Hierophant';

  @override
  String get tarotTheLovers => 'The Lovers';

  @override
  String get tarotTheChariot => 'The Chariot';

  @override
  String get tarotStrength => 'Strength';

  @override
  String get tarotTheHermit => 'The Hermit';

  @override
  String get tarotWheelOfFortune => 'Wheel of Fortune';

  @override
  String get tarotJustice => 'Justice';

  @override
  String get tarotTheHangedMan => 'The Hanged Man';

  @override
  String get tarotDeath => 'Death';

  @override
  String get tarotTemperance => 'Temperance';

  @override
  String get tarotTheDevil => 'The Devil';

  @override
  String get tarotTheTower => 'The Tower';

  @override
  String get tarotTheStar => 'The Star';

  @override
  String get tarotTheMoon => 'The Moon';

  @override
  String get tarotTheSun => 'The Sun';

  @override
  String get tarotJudgement => 'Judgement';

  @override
  String get tarotTheWorld => 'The World';

  @override
  String get omikujiDaikichi => 'Great blessing (Daikichi)';

  @override
  String get omikujiChukichi => 'Middle blessing (Chūkichi)';

  @override
  String get omikujiShokichi => 'Small blessing (Shōkichi)';

  @override
  String get omikujiKichi => 'Blessing (Kichi)';

  @override
  String get omikujiHankichi => 'Half blessing (Hankichi)';

  @override
  String get omikujiSuekichi => 'Future blessing (Suekichi)';

  @override
  String get omikujiKyo => 'Curse (Kyō)';

  @override
  String get omikujiDaikyo => 'Great curse (Daikyō)';

  @override
  String get taskTypeWater => 'Water';

  @override
  String get taskTypeFertilize => 'Fertilize';

  @override
  String get taskTypeMist => 'Mist';

  @override
  String get taskTypeRotate => 'Rotate';

  @override
  String get taskTypePrune => 'Prune';

  @override
  String get taskTypeRepot => 'Repot';

  @override
  String get taskTypeCheckPests => 'Check pests';

  @override
  String get taskTypeWipeLeaves => 'Wipe leaves';

  @override
  String get taskTypeSunlightAdjustment => 'Sunlight adjustment';

  @override
  String notificationsTaskTitle(String plant, String task) {
    return '$plant · $task';
  }

  @override
  String notificationsTaskBodyRoom(String room) {
    return 'In $room';
  }

  @override
  String get notificationsTaskBodyNoRoom => 'Open Botanica to mark it done.';

  @override
  String notificationWaterTitle(String plant) {
    return 'Time to water $plant';
  }

  @override
  String notificationFertilizeTitle(String plant) {
    return 'Fertilize $plant today';
  }

  @override
  String notificationMistTitle(String plant) {
    return '$plant would love some misting';
  }

  @override
  String notificationRotateTitle(String plant) {
    return 'Give $plant a quarter turn';
  }

  @override
  String notificationPruneTitle(String plant) {
    return '$plant is ready for pruning';
  }

  @override
  String notificationWaterTitle2(String plant) {
    return '$plant is getting thirsty!';
  }

  @override
  String notificationWaterTitle3(String plant) {
    return 'Your $plant needs a drink';
  }

  @override
  String notificationFertilizeTitle2(String plant) {
    return '$plant could use some nutrients';
  }

  @override
  String notificationFertilizeTitle3(String plant) {
    return 'Feeding time for $plant';
  }

  @override
  String notificationMistTitle2(String plant) {
    return 'A little humidity boost for $plant?';
  }

  @override
  String notificationMistTitle3(String plant) {
    return 'Time to mist $plant';
  }

  @override
  String notificationRotateTitle2(String plant) {
    return 'Rotate $plant for even growth';
  }

  @override
  String notificationRotateTitle3(String plant) {
    return '$plant needs a turn today';
  }

  @override
  String notificationPruneTitle2(String plant) {
    return 'Time to tidy up $plant';
  }

  @override
  String notificationPruneTitle3(String plant) {
    return '$plant could use a trim';
  }

  @override
  String get notificationDailySummaryTitle => 'Good morning, plant parent!';

  @override
  String notificationDailySummaryBody(int count) {
    return 'You have $count care tasks today. Your plants are counting on you!';
  }

  @override
  String get reasonHumidityLow => 'Low humidity → soil dries faster';

  @override
  String get reasonHumidityHigh => 'High humidity → soil stays moist longer';

  @override
  String get reasonHot => 'Warm temperature → higher evaporation';

  @override
  String get reasonSpring => 'Spring season → active growth';

  @override
  String get reasonSummer => 'Summer heat → more frequent watering';

  @override
  String get reasonAutumn => 'Autumn season → easing into dormancy';

  @override
  String get reasonWinter => 'Winter season → slower growth';

  @override
  String get reasonOutdoor => 'Outdoor mode → forecast weighted more';

  @override
  String get reasonIndoor => 'Indoor mode → stable conditions assumed';

  @override
  String get envLightLow => 'Low Light';

  @override
  String get envLightMedium => 'Medium Light';

  @override
  String get envLightHigh => 'High Light';

  @override
  String get envLabelTemp => 'Temp';

  @override
  String get envLabelHumidity => 'Humidity';

  @override
  String get envLabelLight => 'Light';

  @override
  String get gardenWellnessTitle => 'Garden Wellness';

  @override
  String get gardenWellnessSubtitle => 'See score, focus plants, and care load';

  @override
  String get gardenWellnessEmptyTitle => 'No plants yet';

  @override
  String get gardenFilterEmptyTitle => 'No plants match your filter.';

  @override
  String get gardenWellnessEmptyBody =>
      'Add your first plant to unlock garden wellness.';

  @override
  String get gardenWellnessOverallScore => 'Overall score';

  @override
  String gardenWellnessOverdueChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessStatPlants => 'Plants';

  @override
  String get gardenWellnessStatRecentCare => 'Recent care';

  @override
  String get gardenWellnessStatAtRisk => 'At risk';

  @override
  String get gardenWellnessStatPunctuality => 'On time';

  @override
  String get gardenWellnessStatWeeklyActive => 'Weekly active';

  @override
  String get gardenWellnessStatBestStreak => 'Best streak';

  @override
  String get gardenWellnessMomentumIncreasing => 'Momentum rising';

  @override
  String get gardenWellnessMomentumDecreasing => 'Momentum dipping';

  @override
  String get gardenWellnessRoomPulseTitle => 'Room pulse';

  @override
  String gardenWellnessRoomPulseSummary(int plantCount, int overdueCount) {
    return '$plantCount plants · $overdueCount overdue';
  }

  @override
  String get gardenWellnessRoomPulseStable => 'stable';

  @override
  String gardenWellnessRoomPulseAtRisk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count at risk',
      one: '1 at risk',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPrioritiesTitle => 'Today\'s priorities';

  @override
  String get gardenWellnessFocusPlantsTitle => 'Focus plants';

  @override
  String get gardenWellnessScoreLabel => 'score';

  @override
  String get gardenWellnessScoreFlourishing => 'Flourishing';

  @override
  String get gardenWellnessScoreSteady => 'Steady';

  @override
  String get gardenWellnessScoreNeedsLittleCare => 'Needs a little care';

  @override
  String get gardenWellnessScoreNeedsAttention => 'Needs attention';

  @override
  String gardenWellnessFocusReasonOverdueAndNoLog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue tasks · No recent log',
      one: '1 overdue task · No recent log',
    );
    return '$_temp0';
  }

  @override
  String gardenWellnessFocusReasonOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue tasks',
      one: '1 overdue task',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessFocusReasonNoLog => 'No recent log in 14 days';

  @override
  String get gardenWellnessFocusReasonSteady => 'Looking steady';

  @override
  String gardenWellnessPriorityAttentionTitle(String plantName) {
    return 'Check on $plantName';
  }

  @override
  String gardenWellnessPriorityAttentionBodyOverdueAndNoLog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue tasks and no recent log.',
      one: '1 overdue task and no recent log.',
    );
    return '$_temp0';
  }

  @override
  String gardenWellnessPriorityAttentionBodyOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue tasks need attention.',
      one: '1 overdue task needs attention.',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPriorityAttentionBodyNoLog =>
      'No recent log in the last 14 days.';

  @override
  String get gardenWellnessPriorityAttentionBodyCheckIn =>
      'This plant needs a quick check-in.';

  @override
  String get gardenWellnessPriorityDueTodayTitle => 'Keep today on track';

  @override
  String gardenWellnessPriorityDueTodayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks are due today.',
      one: '1 task is due today.',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPriorityRefreshHistoryTitle =>
      'Refresh care history';

  @override
  String gardenWellnessPriorityRefreshHistoryBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plants are missing a recent log.',
      one: '1 plant is missing a recent log.',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPriorityCalmTitle => 'Enjoy the calm';

  @override
  String get gardenWellnessPriorityCalmBody =>
      'No urgent issues today — your garden looks steady.';

  @override
  String get gardenWellnessRoomUnassigned => 'Unassigned';

  @override
  String get editPlantTitle => 'Edit Plant';

  @override
  String get editPlantSaveButton => 'Save changes';

  @override
  String get plantDetailMenuEdit => 'Edit plant';

  @override
  String get plantDetailMenuArchive => 'Archive plant';

  @override
  String get plantDetailMenuDelete => 'Delete plant';

  @override
  String archivePlantTitle(String plantName) {
    return 'Archive $plantName?';
  }

  @override
  String get archivePlantBody =>
      'Archived plants are hidden from your garden but keep their history.';

  @override
  String get archivePlantConfirm => 'Archive';

  @override
  String deletePlantTitle(String plantName) {
    return 'Delete $plantName?';
  }

  @override
  String get deletePlantBody =>
      'This permanently removes the plant and all its history. This cannot be undone.';

  @override
  String get deletePlantConfirm => 'Delete';

  @override
  String restorePlantTitle(String plantName) {
    return 'Restore $plantName?';
  }

  @override
  String get restorePlantBody =>
      'This will return the plant to your garden and resume its care schedule.';

  @override
  String get restorePlantConfirm => 'Restore';

  @override
  String get gardenStatusArchived => 'Archived';

  @override
  String get gardenSortTitle => 'Sort by';

  @override
  String get gardenFilterArchived => 'Archived';

  @override
  String get gardenSortCare => 'Care needs';

  @override
  String get gardenSortName => 'Name';

  @override
  String get gardenSortNewest => 'Newest added';

  @override
  String get gardenSortHealth => 'Health score';

  @override
  String get gardenSortRoom => 'Room';

  @override
  String get gardenSortSpecies => 'Species';

  @override
  String get gardenSortNeedsCare => 'Needs care';

  @override
  String get gardenFilterAll => 'All';

  @override
  String get gardenFilterHealthy => 'Healthy';

  @override
  String get gardenFilterNeedsCare => 'Needs care';

  @override
  String get gardenSearchHint => 'Search garden...';

  @override
  String archivePlantSuccess(String nickname) {
    return '$nickname archived.';
  }

  @override
  String restorePlantSuccess(String nickname) {
    return '$nickname restored.';
  }

  @override
  String deletePlantSuccess(String nickname) {
    return '$nickname deleted.';
  }

  @override
  String get commonConfirm => 'Confirm';

  @override
  String streakMilestoneTitle(int days) {
    return '$days-Day Milestone!';
  }

  @override
  String get streakMilestoneBody7 =>
      'A full week of plant care. Your garden thanks you.';

  @override
  String get streakMilestoneBody30 =>
      '30 days strong. You\'re building a real habit.';

  @override
  String get streakMilestoneBody90 =>
      '90 days! Your plants have never been happier.';

  @override
  String get streakMilestoneBody365 =>
      'A full year of care. You\'re a plant legend.';

  @override
  String get streakMilestoneDismiss => 'Keep going!';

  @override
  String timeCapsuleTitle(int days) {
    return '$days days ago today';
  }

  @override
  String timeCapsuleBody(String plant, int days) {
    return 'You took this photo of $plant $days days ago. Look how far you’ve come together.';
  }

  @override
  String get rescueResetTitle => 'Welcome back';

  @override
  String rescueResetBody(int streak, int days) {
    return 'You had a $streak-day streak going. It\'s been $days days — no guilt, just a fresh start whenever you\'re ready.';
  }

  @override
  String get rescueResetWaterNow => 'Water a plant now';

  @override
  String get rescueResetFreshStart => 'Start fresh';

  @override
  String streakSavedSnackbar(String plant, int days) {
    return 'Streak saved! $plant cared for · $days-day rhythm intact';
  }

  @override
  String get plantPulseTitle => 'Ready for a check-in';

  @override
  String plantPulseBody(String plant, int days) {
    return '$plant hasn\'t had a photo in $days days. See how it\'s grown.';
  }

  @override
  String get plantPulseCta => 'Take a photo';

  @override
  String get plantJourneyTitle => 'Your journey together';

  @override
  String plantJourneyNextMilestone(String milestone) {
    return 'Next: $milestone';
  }

  @override
  String get plantJourneyMilestoneFirstWater => 'First watering';

  @override
  String get plantJourneyMilestoneFirstPhoto => 'First photo';

  @override
  String get plantJourneyMilestone7Days => '7 days together';

  @override
  String get plantJourneyMilestoneFirstFertilize => 'First fertilize';

  @override
  String get plantJourneyMilestone10Waters => '10 waterings';

  @override
  String get plantJourneyMilestone30Days => '30 days together';

  @override
  String get plantJourneyMilestone25Waters => '25 waterings';

  @override
  String get plantJourneyMilestone100Days => '100 days together';

  @override
  String get plantJourneyMilestone365Days => '1 year together';

  @override
  String get gardenerTypeTitle => 'Your gardener type';

  @override
  String get gardenerTypeDevoted => 'The Devoted';

  @override
  String get gardenerTypeDevotedDesc =>
      '30+ days of unbroken care. Your plants adore you.';

  @override
  String get gardenerTypeConsistent => 'The Consistent';

  @override
  String get gardenerTypeConsistentDesc =>
      'Over 80% of tasks done on time. Reliable as clockwork.';

  @override
  String get gardenerTypeExplorer => 'The Explorer';

  @override
  String get gardenerTypeExplorerDesc =>
      '5+ species in your collection. A true plant explorer.';

  @override
  String get gardenerTypePhotographer => 'The Photographer';

  @override
  String get gardenerTypePhotographerDesc =>
      '10+ photos documenting growth. Every leaf tells a story.';

  @override
  String get gardenerTypeNurturer => 'The Nurturer';

  @override
  String get gardenerTypeNurturerDesc =>
      '50+ care actions. Your garden thrives on your attention.';

  @override
  String get gardenerTypeBudding => 'The Budding Gardener';

  @override
  String get gardenerTypeBuddingDesc =>
      'Every expert was once a beginner. Keep growing!';

  @override
  String get whispererTierSeedling => 'Seedling';

  @override
  String get whispererTierSprout => 'Sprout';

  @override
  String get whispererTierGardener => 'Gardener';

  @override
  String get whispererTierBotanist => 'Botanist';

  @override
  String get whispererTierWhisperer => 'Plant Whisperer';

  @override
  String whispererNextLevel(int xp) {
    return '$xp XP to next level';
  }

  @override
  String careCombo(int count) {
    return '${count}x combo!';
  }

  @override
  String careComboStreak(int count) {
    return '${count}x combo! You\'re on fire!';
  }

  @override
  String get lastCareWater => 'Watered';

  @override
  String get lastCareFertilize => 'Fertilized';

  @override
  String get lastCarePhoto => 'Photo';

  @override
  String lastCareDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get lastCareToday => 'Today';

  @override
  String get lastCareNever => '—';

  @override
  String careConfidenceOnSchedule(int days) {
    return 'Right on schedule (avg $days days)';
  }

  @override
  String get careConfidenceEarly => 'A bit early — soil might still be moist';

  @override
  String get careConfidenceLate => 'A bit late, but no worries';

  @override
  String get gardenMoodThriving => 'Thriving';

  @override
  String get gardenMoodHappy => 'Happy';

  @override
  String get gardenMoodNeedsLove => 'Needs love';

  @override
  String get gardenMoodThirsty => 'Thirsty';

  @override
  String get plantDetailLogsSparklineTitle => '14-Day Activity';

  @override
  String plantDetailLogsSparklineCount(int count) {
    return '$count actions';
  }

  @override
  String get commonToday => 'Today';

  @override
  String get calendarHeatmapTitle => '12-Week Activity';

  @override
  String get profileStatsTotalCare => 'Total Care';

  @override
  String get profileStatsWatered => 'Watered';

  @override
  String get profileStatsFertilized => 'Fertilized';

  @override
  String profileStatsActions(int count) {
    return '$count';
  }

  @override
  String get profileCareScore => 'Care Score';

  @override
  String profileCareScoreLabel(int percent) {
    return '$percent%';
  }

  @override
  String get profileCareScoreSubtitle => 'Last 30 days on-time rate';

  @override
  String get weeklyRecapTitle => 'Your Week in Review';

  @override
  String get weeklyRecapActiveDays => 'Active Days';

  @override
  String weeklyRecapSummary(int actions, int days) {
    return '$actions care actions across $days active days this week';
  }

  @override
  String get weeklyRecapDismiss => 'Nice work!';

  @override
  String weeklyRecapBestDay(String day) {
    return 'Best day: $day';
  }

  @override
  String weeklyRecapStreak(int days) {
    return 'Streak: $days days';
  }

  @override
  String get gardenAllTasksDoneTitle => 'All done for today!';

  @override
  String get gardenAllTasksDoneBody =>
      'Every plant is happy. Enjoy the rest of your day.';

  @override
  String get gardenAllDoneBody2 =>
      'Your green friends are thriving thanks to you.';

  @override
  String get gardenAllDoneBody3 => 'Consistency is the secret. You\'ve got it.';

  @override
  String get gardenAllDoneBody4 => 'Another day of great plant parenting.';

  @override
  String get gardenAllDoneBody5 =>
      'Your plants are growing stronger every day.';

  @override
  String profileLongestStreak(int days) {
    return 'Best: $days days';
  }

  @override
  String profileGardenAge(int days) {
    return 'Garden: $days days old';
  }

  @override
  String gardenNewPersonalBest(int days) {
    return 'New personal best! $days-day streak';
  }

  @override
  String gardenTomorrowPreview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'plants need',
      one: 'plant needs',
    );
    return 'Tomorrow: $count $_temp0 care';
  }

  @override
  String get gardenMotivation7DayStreak =>
      'You\'re on a roll — keep the momentum going.';

  @override
  String get gardenMotivation30DayStreak =>
      'A month of consistency. Your plants are thriving.';

  @override
  String get gardenMotivationWelcomeBack =>
      'Welcome back — your plants missed you.';

  @override
  String get gardenMotivationBigGarden =>
      'A flourishing collection. You\'ve got this.';

  @override
  String get gardenMotivationMorning =>
      'A great day to check on your green friends.';

  @override
  String get gardenMotivationEvening => 'Wind down with a quick garden check.';

  @override
  String get gardenMotivationAllDoneToday =>
      'All caught up — your plants are happy.';

  @override
  String get gardenMotivationNewPlant =>
      'Your newest plant is settling in nicely.';

  @override
  String gardenStreakFreezeUsed(int days) {
    return 'Streak freeze used! Your $days-day streak is safe.';
  }

  @override
  String gardenStreakFreezeEarned(int count) {
    return 'You earned a streak freeze! ($count available)';
  }

  @override
  String profileStreakFreezes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count freezes',
      one: '1 freeze',
    );
    return '$_temp0 available';
  }

  @override
  String gardenPlantMilestone(int count) {
    return '$count plants in your garden! Your collection is growing beautifully.';
  }

  @override
  String get streakShareTitle => 'Share Your Streak';

  @override
  String streakShareCardDays(int days) {
    return '$days-Day Streak';
  }

  @override
  String get streakShareCardSubtitle => 'Caring for my plants every day';

  @override
  String get streakShareButton => 'Share';

  @override
  String get plantLastWateredToday => 'Watered today';

  @override
  String get plantLastWateredYesterday => 'Watered yesterday';

  @override
  String plantLastWateredDaysAgo(int days) {
    return 'Watered $days days ago';
  }

  @override
  String get plantNeverWatered => 'Not yet watered';

  @override
  String plantAgeLabel(int days) {
    return '$days days in your garden';
  }

  @override
  String plantAnniversaryLabel(int years) {
    return '$years-year anniversary!';
  }

  @override
  String get careLogAddNote => 'Add note';

  @override
  String get careLogEditNote => 'Edit note';

  @override
  String get careLogNoteHint => 'How did it look? Anything to remember?';

  @override
  String get careLogNoteSaved => 'Note saved';

  @override
  String get careStatsTitle => 'Care patterns';

  @override
  String get careStatsTotalWaterings => 'Waterings';

  @override
  String get careStatsAvgInterval => 'Avg interval';

  @override
  String careStatsAvgDays(int days) {
    return '${days}d';
  }

  @override
  String get careStatsTotalActions => 'Total actions';

  @override
  String get careStatsConsistency => 'Consistency';

  @override
  String get careStatsTip =>
      'Try setting a recurring reminder to build a steady routine.';

  @override
  String get gardenForecastTitle => 'Next 7 Days';

  @override
  String gardenForecastTaskCount(int count) {
    return '$count tasks';
  }

  @override
  String gardenForecastBusyDay(String day) {
    return 'Busiest: $day';
  }

  @override
  String get gardenForecastEmpty => 'No tasks scheduled this week';

  @override
  String get gardenForecastToday => 'Today';

  @override
  String get gardenForecastTomorrow => 'Tomorrow';

  @override
  String get wellnessHeatmapTitle => 'Care Activity';

  @override
  String get wellnessHeatmapSubtitle => 'Last 12 weeks';

  @override
  String wellnessHeatmapActions(int count) {
    return '$count actions';
  }

  @override
  String gardenWeeklyTrendUp(int diff) {
    return '+$diff vs last week';
  }

  @override
  String gardenWeeklyTrendDown(int diff) {
    return '$diff vs last week';
  }

  @override
  String get gardenWeeklyTrendSame => 'Same as last week';

  @override
  String gardenWeeklyMostActiveDay(String day) {
    return 'Most active: $day';
  }

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String achievementsUnlocked(int count, int total) {
    return '$count/$total unlocked';
  }

  @override
  String get achievementFirstPlant => 'First Sprout';

  @override
  String get achievementFirstPlantDesc => 'Add your first plant';

  @override
  String get achievementFivePlants => 'Growing Collection';

  @override
  String get achievementFivePlantsDesc => 'Grow your garden to 5 plants';

  @override
  String get achievementTenPlants => 'Plant Enthusiast';

  @override
  String get achievementTenPlantsDesc => 'Reach 10 plants in your garden';

  @override
  String get achievementTwentyPlants => 'Jungle Master';

  @override
  String get achievementTwentyPlantsDesc => 'Cultivate 20 plants';

  @override
  String get achievementFirstCare => 'First Drop';

  @override
  String get achievementFirstCareDesc => 'Complete your first care task';

  @override
  String get achievementFiftyCares => 'Dedicated Carer';

  @override
  String get achievementFiftyCaresDesc => 'Complete 50 care tasks';

  @override
  String get achievementHundredCares => 'Green Thumb';

  @override
  String get achievementHundredCaresDesc => 'Complete 100 care tasks';

  @override
  String get achievementFiveHundredCares => 'Plant Whisperer';

  @override
  String get achievementFiveHundredCaresDesc => 'Complete 500 care tasks';

  @override
  String get achievementWeekStreak => 'Week Warrior';

  @override
  String get achievementWeekStreakDesc => 'Maintain a 7-day care streak';

  @override
  String get achievementMonthStreak => 'Monthly Devotion';

  @override
  String get achievementMonthStreakDesc => 'Maintain a 30-day care streak';

  @override
  String get achievementYearStreak => 'Legendary Gardener';

  @override
  String get achievementYearStreakDesc => 'Maintain a 365-day care streak';

  @override
  String get achievementFirstPhoto => 'Snapshot';

  @override
  String get achievementFirstPhotoDesc => 'Take your first plant photo';

  @override
  String get achievementTenPhotos => 'Photo Journal';

  @override
  String get achievementTenPhotosDesc => 'Capture 10 plant photos';

  @override
  String get achievementFiftyPhotos => 'Visual Storyteller';

  @override
  String get achievementFiftyPhotosDesc => 'Capture 50 plant photos';

  @override
  String get achievementThreeRooms => 'Room Explorer';

  @override
  String get achievementThreeRoomsDesc => 'Place plants in 3 different rooms';

  @override
  String get achievementFiveRooms => 'Whole Home Garden';

  @override
  String get achievementFiveRoomsDesc => 'Place plants in 5 different rooms';

  @override
  String get achievementDiverseCarer => 'Renaissance Gardener';

  @override
  String get achievementDiverseCarerDesc => 'Perform 5 different care types';

  @override
  String get tasksCompleteAll => 'Complete all';

  @override
  String tasksCompleteAllDone(int count) {
    return '$count tasks completed';
  }

  @override
  String get tasksStreakAtRiskTitle => 'Streak at risk!';

  @override
  String tasksStreakAtRiskBody(int days) {
    return 'Your $days-day streak ends tonight. Complete a task to keep it alive.';
  }

  @override
  String get plantMilestoneOneMonth => '1 month together!';

  @override
  String get plantMilestoneThreeMonths => '3 months together!';

  @override
  String get plantMilestoneSixMonths => 'Half a year of care!';

  @override
  String get plantMilestoneOneYear => '1 year anniversary!';

  @override
  String get plantMilestoneTwoYears => '2 years of growth!';

  @override
  String plantMilestoneSubtitle(String name, int days) {
    return 'You\'ve been caring for $name for $days days';
  }

  @override
  String get seasonalTipTitle => 'Seasonal Tip';

  @override
  String get seasonalTipSpringRepotTitle => 'Time to repot';

  @override
  String get seasonalTipSpringRepotBody =>
      'Spring is the best time to repot. Plants are entering their growth phase and will recover quickly from the stress.';

  @override
  String get seasonalTipSpringFertilizeTitle => 'Resume feeding';

  @override
  String get seasonalTipSpringFertilizeBody =>
      'Start fertilizing again as days get longer. Begin with half-strength and increase gradually over a few weeks.';

  @override
  String get seasonalTipSpringGrowthTitle => 'Watch for new growth';

  @override
  String get seasonalTipSpringGrowthBody =>
      'Your plants are waking up. Look for new leaves, shoots, and roots — a great time to take progress photos.';

  @override
  String get seasonalTipSpringWaterTitle => 'Increase watering';

  @override
  String get seasonalTipSpringWaterBody =>
      'As growth picks up, your plants will drink more. Check soil moisture more frequently than in winter.';

  @override
  String get seasonalTipSpringPestsTitle => 'Pest patrol';

  @override
  String get seasonalTipSpringPestsBody =>
      'Warmer weather brings pests. Inspect new growth and leaf undersides regularly for early signs of infestation.';

  @override
  String get seasonalTipSummerWaterTitle => 'Stay hydrated';

  @override
  String get seasonalTipSummerWaterBody =>
      'Heat and longer days mean faster evaporation. Water deeply and check soil more often, especially for smaller pots.';

  @override
  String get seasonalTipSummerMistTitle => 'Boost humidity';

  @override
  String get seasonalTipSummerMistBody =>
      'Air conditioning dries the air. Mist tropical plants or group them together to create a humid microclimate.';

  @override
  String get seasonalTipSummerSunburnTitle => 'Watch for sunburn';

  @override
  String get seasonalTipSummerSunburnBody =>
      'Intense midday sun can scorch leaves. Move sensitive plants back from south-facing windows or add sheer curtains.';

  @override
  String get seasonalTipSummerOutdoorTitle => 'Outdoor time';

  @override
  String get seasonalTipSummerOutdoorBody =>
      'Many houseplants love a summer vacation outdoors. Acclimate gradually and bring them in before nights get cold.';

  @override
  String get seasonalTipSummerPropagateTitle => 'Propagation season';

  @override
  String get seasonalTipSummerPropagateBody =>
      'Summer warmth and long days make this the ideal time to take cuttings. Most will root quickly in bright indirect light.';

  @override
  String get seasonalTipAutumnWaterTitle => 'Ease off watering';

  @override
  String get seasonalTipAutumnWaterBody =>
      'Growth slows as days shorten. Let soil dry out more between waterings to prevent root rot during the transition.';

  @override
  String get seasonalTipAutumnFertilizeTitle => 'Stop fertilizing';

  @override
  String get seasonalTipAutumnFertilizeBody =>
      'Most plants enter dormancy soon. Stop feeding to avoid salt buildup and let them rest naturally.';

  @override
  String get seasonalTipAutumnLightTitle => 'Chase the light';

  @override
  String get seasonalTipAutumnLightBody =>
      'As the sun angle drops, move plants closer to windows. Rotate them regularly so all sides get even light.';

  @override
  String get seasonalTipAutumnInsideTitle => 'Bring plants inside';

  @override
  String get seasonalTipAutumnInsideBody =>
      'If you moved plants outdoors for summer, bring them back before nighttime temperatures drop below 10°C (50°F).';

  @override
  String get seasonalTipAutumnCleanTitle => 'Leaf cleaning day';

  @override
  String get seasonalTipAutumnCleanBody =>
      'Dust blocks light absorption. Wipe leaves with a damp cloth to help your plants photosynthesize efficiently through winter.';

  @override
  String get seasonalTipWinterWaterTitle => 'Water sparingly';

  @override
  String get seasonalTipWinterWaterBody =>
      'Most plants need much less water in winter. Overwatering is the top killer during dormancy — when in doubt, wait.';

  @override
  String get seasonalTipWinterHumidityTitle => 'Combat dry air';

  @override
  String get seasonalTipWinterHumidityBody =>
      'Heating systems dry indoor air dramatically. Use a humidifier or pebble trays to keep tropical plants happy.';

  @override
  String get seasonalTipWinterDraftsTitle => 'Avoid cold drafts';

  @override
  String get seasonalTipWinterDraftsBody =>
      'Keep plants away from drafty windows and exterior doors. Even cold-hardy plants dislike sudden temperature swings.';

  @override
  String get seasonalTipWinterLightTitle => 'Maximize light';

  @override
  String get seasonalTipWinterLightBody =>
      'Short days mean less photosynthesis. Move plants to your brightest spots and consider a grow light for light-lovers.';

  @override
  String get seasonalTipWinterRestTitle => 'Let them rest';

  @override
  String get seasonalTipWinterRestBody =>
      'Dormancy is natural and healthy. Don\'t worry about slow growth — your plants are conserving energy for spring.';

  @override
  String get healthBreakdownTitle => 'Health Score';

  @override
  String get healthBreakdownSubtitle =>
      'Here\'s what contributes to this plant\'s health rating';

  @override
  String healthBreakdownOverall(int score) {
    return 'Overall: $score/100';
  }

  @override
  String get healthFactorOverdue => 'Task timeliness';

  @override
  String get healthFactorActivity => 'Recent care activity';

  @override
  String get healthFactorVariety => 'Care variety';

  @override
  String get healthFactorConsistency => 'Schedule consistency';

  @override
  String get coachingTitle => 'Care Coaching';

  @override
  String get coachingLateWatererTitle => 'Adjust your reminders';

  @override
  String get coachingLateWatererBody =>
      'You often water a day or two late. Try shifting your reminder time to when you\'re usually free.';

  @override
  String get coachingStreakAtRiskTitle => 'Streak at risk!';

  @override
  String get coachingStreakAtRiskBody =>
      'You haven\'t cared for any plants today. A quick water keeps your streak alive.';

  @override
  String get coachingNeglectedPlantTitle => 'A plant needs you';

  @override
  String get coachingNeglectedPlantBody =>
      'One of your plants hasn\'t received care in over 3 weeks. Check in on it.';

  @override
  String get coachingImprovingTitle => 'You\'re improving!';

  @override
  String get coachingImprovingBody =>
      'You\'ve been more active this week than last. Keep the momentum going.';

  @override
  String get coachingConsistentTitle => 'Consistency champion';

  @override
  String get coachingConsistentBody =>
      '9 out of your last 10 tasks were completed on time. Your plants are thriving.';

  @override
  String get coachingDiversifyTitle => 'Try something new';

  @override
  String get coachingDiversifyBody =>
      'You\'ve only been watering lately. Consider misting, rotating, or fertilizing for healthier plants.';

  @override
  String get plantDetailNextWateringTomorrow => 'Tomorrow';

  @override
  String get plantDetailNextWateringToday => 'Due today';

  @override
  String gardenStreakFreezeAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count streak freezes available',
      one: '1 streak freeze available',
    );
    return '$_temp0';
  }

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get plantDetailHealthScore => 'Health score';

  @override
  String get plantDetailExpandText => 'Expand text';

  @override
  String get plantDetailCollapseText => 'Collapse text';

  @override
  String get gardenWateredToday => 'Watered today';

  @override
  String get gardenWateredYesterday => 'Watered yesterday';

  @override
  String gardenWateredDaysAgo(int days) {
    return 'Watered $days days ago';
  }

  @override
  String get gardenNeverWatered => 'Not yet watered';

  @override
  String calendarHeatmapTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count care actions',
      one: '1 care action',
    );
    return '$_temp0';
  }

  @override
  String calendarHeatmapTooltipDetail(
      int waters, String fertSep, int fertilizes, String otherSep, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      waters,
      locale: localeName,
      other: '$waters waters',
      one: '1 water',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      fertilizes,
      locale: localeName,
      other: '$fertilizes fertilizes',
      one: '1 fertilize',
      zero: '',
    );
    String _temp2 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others other',
      one: '1 other',
      zero: '',
    );
    return '$_temp0$fertSep$_temp1$otherSep$_temp2';
  }

  @override
  String calendarDayCareCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count care logs',
      one: '1 care log',
    );
    return '$_temp0';
  }

  @override
  String get exportDataConfirmTitle => 'Export care data?';

  @override
  String get exportDataConfirmBody =>
      'This will create a JSON file with all your plants, care logs, and tasks.';

  @override
  String get exportDataConfirmAction => 'Export';

  @override
  String get gardenWaterAllOverdue => 'Water all overdue';

  @override
  String gardenWaterAllOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Water $count overdue plants',
      one: 'Water 1 overdue plant',
    );
    return '$_temp0';
  }

  @override
  String gardenWateredAllOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Watered $count overdue plants',
      one: 'Watered 1 overdue plant',
    );
    return '$_temp0';
  }

  @override
  String get plantOverviewNoCareStats =>
      'Water your plant a few times to see care patterns here.';

  @override
  String get plantOverviewNoAiInsights =>
      'Enable AI insights in settings to get personalized care tips.';

  @override
  String get plantOverviewNoTasksYet =>
      'No upcoming tasks yet. Care schedules will appear as they are created.';

  @override
  String get gardenHealthTrendUp => 'Improving';

  @override
  String get gardenHealthTrendDown => 'Declining';

  @override
  String get gardenHealthTrendStable => 'Stable';

  @override
  String plantCareStreakLabel(int days) {
    return '$days-day care streak';
  }

  @override
  String get tasksEmptySoonMotivation =>
      'Enjoy the calm. Your plants are thriving.';

  @override
  String get manageCareTitle => 'Manage care reminders';

  @override
  String manageCareSubtitle(int active, int disabled) {
    return '$active active · $disabled disabled';
  }

  @override
  String get manageCareSpeciesDefault => 'Species default';

  @override
  String get manageCareEnabledByYou => 'Enabled by you';

  @override
  String get manageCareDisabledByYou => 'Disabled by you';

  @override
  String get manageCareButton => 'Manage';

  @override
  String manageCareDisableConfirm(String type) {
    return 'Turn off $type reminders?';
  }

  @override
  String get manageCareEnabled => 'Enabled';

  @override
  String get manageCareDisabled => 'Disabled';

  @override
  String get growthEchoCompareTitle => 'Then & now';

  @override
  String growthEchoCompareBody(String plant, int days) {
    return '$plant has $days days of growth to compare.';
  }

  @override
  String get growthEchoCaptureTitle => 'Growth check-in';

  @override
  String growthEchoCaptureBody(int days, String plant) {
    return 'It\'s been $days days since $plant\'s last photo.';
  }

  @override
  String get commonProblemsTitle => 'Common issues';

  @override
  String commonProblemsSubtitle(String plant) {
    return 'Watch for these with your $plant';
  }

  @override
  String perfectWeekTitle(int count) {
    return 'Perfect Week $count!';
  }

  @override
  String get perfectWeekBody =>
      'Every task completed on time for 7 straight days. Your plants are thriving because of you.';

  @override
  String perfectWeekBodyRepeat(int count) {
    return '$count perfect weeks in a row. You\'re in a league of your own.';
  }

  @override
  String get perfectWeekDismiss => 'On to the next!';

  @override
  String get growthTimelineTitle => 'Growth Timeline';

  @override
  String get growthTimelineEmpty => 'Take photos to track growth over time';

  @override
  String notificationStreakProtectionTitle(int days) {
    return 'Your $days-day streak is at risk!';
  }

  @override
  String get notificationStreakProtectionBody =>
      'Complete a care task before midnight to keep it going.';

  @override
  String get careRhythmTitle => 'Your Care Rhythm';

  @override
  String careRhythmAvgInterval(int days) {
    return 'Avg ${days}d between waterings';
  }

  @override
  String get careRhythmConsistent => 'Very consistent';

  @override
  String get careRhythmImproving => 'Getting more consistent';

  @override
  String get careRhythmNoData => 'Water a few more times to see your rhythm';

  @override
  String get plantMoodThriving => 'Thriving! 🌱';

  @override
  String get plantMoodHappy => 'Feeling great';

  @override
  String get plantMoodOkay => 'Doing okay';

  @override
  String get plantMoodThirsty => 'Getting thirsty…';

  @override
  String get plantMoodNeglected => 'Missing you…';

  @override
  String get plantMoodNewHere => 'Just planted!';

  @override
  String plantAnniversaryTitle(String plant) {
    return 'Happy anniversary, $plant!';
  }

  @override
  String get plantAnniversaryBody30 =>
      'One month together. You\'re building something beautiful.';

  @override
  String get plantAnniversaryBody90 =>
      'Three months of care. Your dedication shows.';

  @override
  String get plantAnniversaryBody180 =>
      'Half a year! This plant is thriving because of you.';

  @override
  String get plantAnniversaryBody365 =>
      'A full year together. What an incredible journey.';

  @override
  String get plantAnniversaryDismiss => 'Here\'s to more!';

  @override
  String insightRhythmShift(String plant, String oldDays, String newDays) {
    return '$plant\'s watering rhythm shifted from every $oldDays to $newDays days this month';
  }

  @override
  String insightFavoriteCareDay(String percent, String day) {
    return '$percent% of your care happens on ${day}s — your garden day';
  }

  @override
  String insightActiveTime(String period, String percent) {
    return 'You\'re a $period plant parent — $percent% of care happens then';
  }

  @override
  String insightMostLovedPlant(String plant, String actions) {
    return '$plant got the most attention this month — $actions care actions';
  }

  @override
  String insightQuietThenBusy(String quietDays, String taskCount) {
    return 'Quiet $quietDays days ahead, then $taskCount tasks coming up';
  }

  @override
  String insightCareAcceleration(String thisWeek, String lastWeek) {
    return 'You\'re on a roll — $thisWeek actions this week vs $lastWeek last week';
  }

  @override
  String insightGardenGrowing(String total, String recent) {
    return 'Your garden is growing — $total plants now, $recent added recently';
  }

  @override
  String insightSeasonalActivity(
      String direction, String thisMonth, String lastMonth) {
    return 'Seasonal shift: $direction active this month ($thisMonth) vs last ($lastMonth)';
  }

  @override
  String get insightSectionTitle => 'Garden Intelligence';

  @override
  String quickCheckInTitle(String plant) {
    return 'How does $plant look?';
  }

  @override
  String get quickCheckInSubtitle =>
      'A quick check helps track your plant\'s health over time';

  @override
  String get quickCheckInThriving => 'Thriving';

  @override
  String get quickCheckInOkay => 'Okay';

  @override
  String get quickCheckInWorried => 'Worried';

  @override
  String get diversityTitle => 'Biodiversity Index';

  @override
  String get diversitySpecies => 'Species';

  @override
  String get diversityLightNeeds => 'Light needs';

  @override
  String get diversityDifficulty => 'Difficulty';

  @override
  String get diversityEnvironment => 'Environment';

  @override
  String get diversitySuggestNewSpecies =>
      'Try adding a different species to diversify';

  @override
  String get diversitySuggestDifferentLight =>
      'Consider plants with different light needs';

  @override
  String get diversitySuggestVaryDifficulty =>
      'Mix easy and challenging plants for variety';

  @override
  String get diversitySuggestOutdoor =>
      'Try an outdoor or balcony plant for environment diversity';

  @override
  String get diversitySuggestAddPlants => 'Add more plants to build diversity';

  @override
  String get momentumTitle => 'Garden Momentum';

  @override
  String momentumTrending(String direction) {
    return 'Trending $direction';
  }

  @override
  String get momentumUp => 'up';

  @override
  String get momentumDown => 'down';

  @override
  String get momentumSteady => 'steady';

  @override
  String get momentumStreak => 'Streak';

  @override
  String get momentumActivity => 'Activity';

  @override
  String get momentumGrowth => 'Growth';

  @override
  String get batchPlannerTitle => 'Watering Schedule';

  @override
  String batchPlannerEfficiency(int percent) {
    return '$percent% efficient';
  }

  @override
  String batchPlannerDays(int count) {
    return '$count watering days/week';
  }

  @override
  String batchPlannerPlants(int count) {
    return '$count plants';
  }

  @override
  String get careImpactTitle => 'Your Care Impact';

  @override
  String get careImpactWaterings => 'waterings';

  @override
  String get careImpactSaved => 'saved';

  @override
  String get careImpactTypes => 'types';

  @override
  String careImpactLongestCompanion(String name, int days) {
    return 'Longest companion: $name (${days}d)';
  }

  @override
  String careImpactAvgResponse(String hours) {
    return 'Avg response: ${hours}h';
  }

  @override
  String get gardenLegacyTitle => 'Garden Legacy';

  @override
  String get gardenLegacyTotalCare => 'Total care actions';

  @override
  String get gardenLegacyLongestSurvivor => 'Longest survivor';

  @override
  String get gardenLegacyScore => 'Legacy score';

  @override
  String roomCompatibilityTitle(String room) {
    return '$room Compatibility';
  }

  @override
  String roomCompatibilityPairings(int plants, int pairings) {
    return '$plants plants, $pairings pairings';
  }

  @override
  String get wateringEfficiencyTitle => 'Watering Efficiency';

  @override
  String wateringEfficiencyOptimal(int count, int total) {
    return '$count/$total optimal';
  }

  @override
  String get careAutopilotTitle => 'Care Autopilot';

  @override
  String careAutopilotUrgent(int count) {
    return '$count urgent';
  }

  @override
  String get roomSuggestionsTitle => 'Room Suggestions';

  @override
  String roomSuggestionsMoves(int count) {
    return '$count moves';
  }

  @override
  String get dailyFactTitle => 'Did You Know?';

  @override
  String get seasonalTransitionTitle => 'Seasonal Transition';

  @override
  String seasonalTransitionWeeks(int weeks) {
    return '${weeks}w away';
  }

  @override
  String get gardenInsightsTitle => 'Garden Insights';

  @override
  String get recommendedForYouTitle => 'Recommended for You';

  @override
  String recommendedGaps(String gaps) {
    return 'Gaps: $gaps';
  }

  @override
  String get plantMemoryFirstPhoto => 'First Photo';

  @override
  String get plantMemoryFirstCare => 'First Care';

  @override
  String get plantMemoryAnniversary => 'Anniversary';

  @override
  String get plantMemoryBusiestDay => 'Busiest Day';

  @override
  String get plantMemoryLongestGap => 'Longest Gap';

  @override
  String get plantMemoryComeback => 'Comeback';

  @override
  String careAutopilotMore(int count) {
    return '+$count more suggestions';
  }

  @override
  String wateringEfficiencyMore(int count) {
    return '+$count more';
  }

  @override
  String seasonalTransitionMore(int count) {
    return '+$count more tasks';
  }

  @override
  String get gardenProgressTitle => 'Garden Intelligence';

  @override
  String gardenProgressUnlocked(int unlocked, int total) {
    return '$unlocked/$total';
  }

  @override
  String gardenProgressMilestonePlant(String feature) {
    return 'Add 1 more plant to unlock $feature';
  }

  @override
  String gardenProgressMilestoneLogs(int count, String feature) {
    return 'Log $count more care actions for $feature';
  }

  @override
  String get transitionMoveIndoors => 'Move indoors';

  @override
  String get transitionMoveOutdoors => 'Move outdoors';

  @override
  String get transitionReduceWatering => 'Reduce watering';

  @override
  String get transitionIncreaseWatering => 'Increase watering';

  @override
  String get transitionStartFertilizing => 'Start fertilizing';

  @override
  String get transitionStopFertilizing => 'Stop fertilizing';

  @override
  String get transitionIncreaseHumidity => 'Increase humidity';

  @override
  String get transitionProtectFromFrost => 'Protect from frost';

  @override
  String get transitionProvideShadeCover => 'Provide shade';

  @override
  String get transitionResumeNormalCare => 'Resume normal care';

  @override
  String get dailyBriefingTitle => 'Daily Briefing';

  @override
  String get dailyBriefingAllCaughtUp =>
      'All caught up — your garden is thriving!';

  @override
  String get weeklyInsightTitle => 'Weekly Insight';

  @override
  String get dailyChallengeTitle => 'Daily Challenge';

  @override
  String get dailyChallengeAccept => 'Accept';

  @override
  String get communityChallengesTitle => 'Community Challenges';

  @override
  String get dailyRitualTitle => 'Daily Ritual';

  @override
  String get achievementsRecent => 'Recent';

  @override
  String get careEffectivenessTitle => 'Care Effectiveness';

  @override
  String get scheduleTuningTitle => 'Schedule Tuning';

  @override
  String get careBurnoutOverload => 'Care Overload Detected';

  @override
  String get careBurnoutStretched => 'Feeling Stretched?';

  @override
  String get careLoadTitle => 'Care Load';

  @override
  String get careLoadThisWeek => 'This Week';

  @override
  String get careCoachTitle => 'Care Coach';

  @override
  String get careConfidenceTitle => 'Care Confidence';

  @override
  String get careConsistencyTitle => 'Care Consistency';

  @override
  String get careCostsTitle => 'Care Costs';

  @override
  String get delegationPlanTitle => 'Delegation Plan';

  @override
  String get carePatternsTitle => 'Care Patterns';

  @override
  String get carePersonaTitle => 'Your Care Persona';

  @override
  String get carePersonaStrengths => 'Strengths';

  @override
  String get carePersonaGrowthAreas => 'Growth Areas';

  @override
  String get nextWateringTitle => 'Next Watering';

  @override
  String get careRoutinesTitle => 'Your Care Routines';

  @override
  String get plantAnniversariesTitle => 'Plant Anniversaries';

  @override
  String get communityBenchmarkTitle => 'Community Benchmark';

  @override
  String get emotionalBondsTitle => 'Emotional Bonds';

  @override
  String get suggestedGoalsTitle => 'Suggested Goals';

  @override
  String get gardenHarmonyTitle => 'Garden Harmony';

  @override
  String get gardenMomentumTitle => 'Garden Momentum';

  @override
  String get gardenMoodTitle => 'Garden Mood';

  @override
  String get gardenRhythmTitle => 'Garden Rhythm';

  @override
  String get gardenCardTitle => 'Garden Card';

  @override
  String get gardenStatsTitle => 'Garden Stats';

  @override
  String get growthJournalTitle => 'Growth Journal';

  @override
  String get careHabitsTitle => 'Care Habits';

  @override
  String get healthForecastTitle => 'Health Forecast';

  @override
  String get healthTimelineTitle => 'Health Timeline';

  @override
  String get plantQuizTitle => 'Plant Quiz';

  @override
  String get growthStageTitle => 'Growth Stage';

  @override
  String get memoryLaneTitle => 'Memory Lane';

  @override
  String get microSeasonsTitle => 'Micro Seasons';

  @override
  String get milestonesTitle => 'Milestones';

  @override
  String get gentleNudgesTitle => 'Gentle Nudges';

  @override
  String get timelapseReadyTitle => 'Timelapse Ready';

  @override
  String get lifeStoryTitle => 'Life Story';

  @override
  String get plantLineageTitle => 'Plant Lineage';

  @override
  String get rescuePlanTitle => 'Rescue Plan';

  @override
  String get plantStoryTitle => 'Plant Story';

  @override
  String get vitalSignsTitle => 'Vital Signs';

  @override
  String get predictedNeedsTitle => 'Predicted Needs';

  @override
  String get propagationTitle => 'Propagation';

  @override
  String get roomProfilesTitle => 'Room Profiles';

  @override
  String get seasonalTipsTitle => 'Seasonal Tips';

  @override
  String get skillLevelTitle => 'Skill Level';

  @override
  String get plantSocialGraphTitle => 'Plant Social Graph';

  @override
  String get streakBoardTitle => 'Streak Board';

  @override
  String get stressAlertsTitle => 'Stress Alerts';

  @override
  String get survivalOutlookTitle => 'Survival Outlook';

  @override
  String get gardenTimelineTitle => 'Garden Timeline';

  @override
  String get waterEfficiencyTitle => 'Water Efficiency';

  @override
  String get wateringScheduleTitle => 'Watering Schedule';

  @override
  String get scheduleOptimizerTitle => 'Schedule Optimizer';

  @override
  String get weeklyReportTitle => 'This Week';

  @override
  String get plantWhispererTitle => 'Plant Whisperer';

  @override
  String get smartGreetingMorning => 'Good morning! Your plants are waiting.';

  @override
  String get smartGreetingAfternoon =>
      'Good afternoon! Time for a garden check.';

  @override
  String get smartGreetingEvening =>
      'Good evening! Wind down with your plants.';

  @override
  String smartGreetingStreak(String days) {
    return '$days-day streak! Keep it up.';
  }

  @override
  String get smartGreetingRainy => 'Rainy day — your outdoor plants are happy.';

  @override
  String smartGreetingNewPlant(String plant) {
    return 'How\'s $plant settling in?';
  }

  @override
  String get smartGreetingProductive =>
      'Productive day! Your garden thanks you.';

  @override
  String get smartGreetingEarlyBird => 'Early bird! Plants love morning care.';

  @override
  String smartGreetingLateNight(String count) {
    return 'Late night check on your $count plants.';
  }

  @override
  String smartGreetingBigGarden(String count) {
    return '$count plants strong! Impressive.';
  }

  @override
  String get smartGreetingDefault => 'Welcome back to your garden.';

  @override
  String nextActionWaterOverdue(String plant) {
    return 'Water $plant';
  }

  @override
  String get nextActionWaterOverdueSub => 'Overdue — needs attention now';

  @override
  String nextActionWaterToday(String plant) {
    return 'Water $plant';
  }

  @override
  String get nextActionWaterTodaySub => 'Scheduled for today';

  @override
  String get nextActionTakePhoto => 'Photo time';

  @override
  String nextActionTakePhotoSub(String plant) {
    return 'Capture $plant\'s progress';
  }

  @override
  String nextActionCheckNewPlant(String plant) {
    return 'Check on $plant';
  }

  @override
  String get nextActionCheckNewPlantSub =>
      'New plant — getting to know each other';

  @override
  String nextActionFertilize(String plant) {
    return 'Fertilize $plant';
  }

  @override
  String get nextActionFertilizeSub => 'Coming up in the next few days';

  @override
  String get nextActionCelebrate => 'Celebrate your streak!';

  @override
  String get nextActionCelebrateSub => 'You\'re doing amazing';

  @override
  String get nextActionExplore => 'Explore new plants';

  @override
  String get nextActionExploreSub => 'Start your plant journey';

  @override
  String get nextActionRest => 'All caught up!';

  @override
  String get nextActionRestSub => 'Your garden is happy — enjoy the moment';

  @override
  String careRhythmStreakBadge(int count) {
    return '${count}x streak';
  }

  @override
  String get careRhythmMorningPerson => 'Morning Person';

  @override
  String get careRhythmMorningPersonDesc =>
      'You tend to care for your plants in the morning hours.';

  @override
  String get careRhythmEveningCarer => 'Evening Carer';

  @override
  String get careRhythmEveningCarerDesc =>
      'Your plants get attention during the evening wind-down.';

  @override
  String get careRhythmWeekendWarrior => 'Weekend Warrior';

  @override
  String get careRhythmWeekendWarriorDesc =>
      'Weekends are your dedicated plant care time.';

  @override
  String get careRhythmDailyDevoter => 'Daily Devoter';

  @override
  String get careRhythmDailyDevoterDesc =>
      'You check on your plants almost every single day.';

  @override
  String get careRhythmBatchCarer => 'Batch Carer';

  @override
  String get careRhythmBatchCarerDesc =>
      'You handle multiple plants in focused care sessions.';

  @override
  String careRhythmConfidence(int percent) {
    return '$percent% match';
  }

  @override
  String get quickCheckInThanks => 'Thanks for checking in!';

  @override
  String carePersonaMatch(int percent) {
    return '$percent% match';
  }

  @override
  String get carePersonaDevotee => 'Devotee';

  @override
  String get carePersonaExplorer => 'Explorer';

  @override
  String get carePersonaPerfectionist => 'Perfectionist';

  @override
  String get carePersonaNurturer => 'Nurturer';

  @override
  String get carePersonaVeteran => 'Veteran';

  @override
  String get carePersonaEarlyBird => 'Early Bird';

  @override
  String plantPersonalityThe(String trait) {
    return 'The $trait';
  }

  @override
  String get plantPersonalityDedicated => 'Dedicated care routine';

  @override
  String get plantPersonalityBalanced => 'Balanced care approach';

  @override
  String get plantPersonalityCasual => 'Casual care style';

  @override
  String get plantPersonalityMinimalist => 'Minimalist care';

  @override
  String get careRoutineNight => 'Night';

  @override
  String get careRoutineMorning => 'Morning';

  @override
  String get careRoutineAfternoon => 'Afternoon';

  @override
  String get careRoutineEvening => 'Evening';

  @override
  String careRoutinePlants(int count) {
    return '$count plants';
  }

  @override
  String careRoutineMinPerWeek(int minutes) {
    return '$minutes min/week';
  }

  @override
  String get confidenceMaster => 'Plant Master';

  @override
  String get confidenceConfident => 'Confident Carer';

  @override
  String get confidenceLearning => 'Growing Learner';

  @override
  String get confidenceNovice => 'Plant Novice';

  @override
  String get confidenceNextKeepGoing => 'Keep the streak alive';

  @override
  String get confidenceNextMaster => 'Reach Master level';

  @override
  String get confidenceNextConfident => 'Reach Confident level';

  @override
  String get confidenceNextBuild => 'Build your routine';

  @override
  String confidenceNext(String milestone) {
    return 'Next: $milestone';
  }

  @override
  String get confidenceDimConsistency => 'Consistency';

  @override
  String get confidenceDimDiversity => 'Diversity';

  @override
  String get confidenceDimHealth => 'Health';

  @override
  String get confidenceDimExperience => 'Experience';

  @override
  String get confidenceDimVariety => 'Variety';

  @override
  String get bondSoulmate => 'Soulmate';

  @override
  String get bondBestFriend => 'Best Friend';

  @override
  String get bondCompanion => 'Companion';

  @override
  String get bondNewFriend => 'New Friend';

  @override
  String get bondAcquaintance => 'Acquaintance';

  @override
  String bondSharedMoments(int count) {
    return '$count shared moments';
  }

  @override
  String get calendarThisWeek => 'This Week';

  @override
  String calendarTasks(int count) {
    return '$count tasks';
  }

  @override
  String get calendarToday => 'today';

  @override
  String get calendarTomorrow => 'tomorrow';

  @override
  String calendarDaysShort(int days) {
    return '${days}d';
  }

  @override
  String get patternBatchCarer => 'Batch Carer';

  @override
  String get patternMorningRitual => 'Morning Ritual';

  @override
  String get patternEveningRitual => 'Evening Ritual';

  @override
  String get patternWeekendWarrior => 'Weekend Warrior';

  @override
  String get patternSeasonalDip => 'Seasonal Dip';

  @override
  String get patternSeasonalSurge => 'Seasonal Surge';

  @override
  String get patternFavoriteFirst => 'Favorite First';

  @override
  String get patternNeedsLove => 'Needs Love';

  @override
  String get patternDiverseRoutine => 'Diverse Routine';

  @override
  String get patternFocusedCarer => 'Focused Carer';

  @override
  String get patternTitle => 'Your Care Patterns';

  @override
  String get seasonalAlertTitle => 'Seasonal Transition';

  @override
  String seasonalAlertComing(String season) {
    return '$season is coming';
  }

  @override
  String seasonalAlertUrgent(int count) {
    return '$count plants need prep';
  }

  @override
  String seasonalAlertDays(int days) {
    return '${days}d';
  }

  @override
  String get seasonalReportActions => 'actions';

  @override
  String get seasonalReportPlants => 'plants';

  @override
  String get seasonalReportPerWeek => '/week';

  @override
  String seasonalReportImprovement(String percent) {
    return '$percent% vs last season';
  }

  @override
  String xpLevelTitle(int level) {
    return 'Level $level';
  }

  @override
  String xpLevelProgress(int current, int next) {
    return '$current / $next to next level';
  }

  @override
  String get resetAll => 'Reset all';
}
