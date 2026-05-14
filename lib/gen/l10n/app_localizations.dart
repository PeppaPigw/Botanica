import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Botanica'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your personal plant care companion — calm, beautiful, and thoughtful.'**
  String get appTagline;

  /// No description provided for @gardenNoScheduleYet.
  ///
  /// In en, this message translates to:
  /// **'No schedule yet'**
  String get gardenNoScheduleYet;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get commonStart;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get commonOverdue;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get commonShow;

  /// No description provided for @commonHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get commonHide;

  /// No description provided for @commonLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get commonLater;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get commonUnits;

  /// No description provided for @commonLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// No description provided for @commonAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get commonAbout;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @commonWhy.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get commonWhy;

  /// No description provided for @commonIdeal.
  ///
  /// In en, this message translates to:
  /// **'Ideal'**
  String get commonIdeal;

  /// No description provided for @commonTolerates.
  ///
  /// In en, this message translates to:
  /// **'Tolerates'**
  String get commonTolerates;

  /// No description provided for @commonSoil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get commonSoil;

  /// No description provided for @commonSoilPh.
  ///
  /// In en, this message translates to:
  /// **'Soil pH'**
  String get commonSoilPh;

  /// No description provided for @commonWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get commonWhen;

  /// No description provided for @commonHow.
  ///
  /// In en, this message translates to:
  /// **'How'**
  String get commonHow;

  /// No description provided for @commonPestsAndDiseases.
  ///
  /// In en, this message translates to:
  /// **'Pests & diseases'**
  String get commonPestsAndDiseases;

  /// No description provided for @commonPrevention.
  ///
  /// In en, this message translates to:
  /// **'Prevention'**
  String get commonPrevention;

  /// No description provided for @commonHeatwave.
  ///
  /// In en, this message translates to:
  /// **'Heatwave'**
  String get commonHeatwave;

  /// No description provided for @commonFrost.
  ///
  /// In en, this message translates to:
  /// **'Frost'**
  String get commonFrost;

  /// No description provided for @commonStorm.
  ///
  /// In en, this message translates to:
  /// **'Storm'**
  String get commonStorm;

  /// No description provided for @commonHeavyRain.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain'**
  String get commonHeavyRain;

  /// No description provided for @commonClimateHotDry.
  ///
  /// In en, this message translates to:
  /// **'Hot / Dry'**
  String get commonClimateHotDry;

  /// No description provided for @commonClimateCoolWet.
  ///
  /// In en, this message translates to:
  /// **'Cool / Wet'**
  String get commonClimateCoolWet;

  /// No description provided for @commonClimateStrategies.
  ///
  /// In en, this message translates to:
  /// **'Climate strategies'**
  String get commonClimateStrategies;

  /// No description provided for @resourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resourcesTitle;

  /// No description provided for @resourceWikipedia.
  ///
  /// In en, this message translates to:
  /// **'Wikipedia'**
  String get resourceWikipedia;

  /// No description provided for @resourceYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get resourceYouTube;

  /// No description provided for @resourceBaiduBaike.
  ///
  /// In en, this message translates to:
  /// **'Baidu Baike'**
  String get resourceBaiduBaike;

  /// No description provided for @resourceBilibili.
  ///
  /// In en, this message translates to:
  /// **'Bilibili'**
  String get resourceBilibili;

  /// No description provided for @resourceGbif.
  ///
  /// In en, this message translates to:
  /// **'GBIF'**
  String get resourceGbif;

  /// No description provided for @resourceCareGuide.
  ///
  /// In en, this message translates to:
  /// **'Care guide'**
  String get resourceCareGuide;

  /// No description provided for @resourceCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get resourceCopyLink;

  /// No description provided for @resourceLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get resourceLinkCopied;

  /// No description provided for @aiNoteCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get aiNoteCopied;

  /// No description provided for @aiNoteCopyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy note'**
  String get aiNoteCopyAction;

  /// No description provided for @stateLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load'**
  String get stateLoadFailedTitle;

  /// No description provided for @stateLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get stateLoadFailedBody;

  /// No description provided for @stateNotAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get stateNotAvailableTitle;

  /// No description provided for @stateNotAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'This content isn’t available right now.'**
  String get stateNotAvailableBody;

  /// No description provided for @navGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get navGarden;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get navDaily;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get calendarFilterAll;

  /// No description provided for @calendarFilterOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get calendarFilterOther;

  /// No description provided for @calendarSectionConsistency.
  ///
  /// In en, this message translates to:
  /// **'Month consistency'**
  String get calendarSectionConsistency;

  /// No description provided for @calendarPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPrevMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// No description provided for @calendarSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Care history'**
  String get calendarSectionHistory;

  /// No description provided for @calendarNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No care logs for this day.'**
  String get calendarNoEvents;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Calm care, beautifully organized.'**
  String get splashTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Breathe life into your space'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Track your plants, build a beautiful timeline, and cultivate calm, one leaf at a time.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Botanica learns your light'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Care that adapts to your environment—season, humidity, and temperature.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'A daily ritual of growth'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Gently discover new plants and center your mind with daily botanical inspiration.'**
  String get onboardingBody3;

  /// No description provided for @onboardingCta.
  ///
  /// In en, this message translates to:
  /// **'Enter your garden'**
  String get onboardingCta;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Grow together'**
  String get permissionsTitle;

  /// No description provided for @permissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Botanica to care for your plants seamlessly, or choose when you\'re ready.'**
  String get permissionsSubtitle;

  /// No description provided for @permNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle Reminders'**
  String get permNotificationsTitle;

  /// No description provided for @permNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'So neither of you goes thirsty.'**
  String get permNotificationsBody;

  /// No description provided for @notificationsSoftAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss watering day'**
  String get notificationsSoftAskTitle;

  /// No description provided for @notificationsSoftAskBody.
  ///
  /// In en, this message translates to:
  /// **'Botanica sends calm reminders at your preferred time, so each plant gets care before leaves start to droop.'**
  String get notificationsSoftAskBody;

  /// No description provided for @permLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Climate Insight'**
  String get permLocationTitle;

  /// No description provided for @permLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Care adapted exactly to your local weather.'**
  String get permLocationBody;

  /// No description provided for @permCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual Journal'**
  String get permCameraTitle;

  /// No description provided for @permCameraBody.
  ///
  /// In en, this message translates to:
  /// **'Capture growth and identify plants with a glance.'**
  String get permCameraBody;

  /// No description provided for @permLocationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off.'**
  String get permLocationServicesOff;

  /// No description provided for @permStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get permStatusEnabled;

  /// No description provided for @permStatusNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Not enabled'**
  String get permStatusNotEnabled;

  /// No description provided for @permStatusLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get permStatusLimited;

  /// No description provided for @permStatusProvisional.
  ///
  /// In en, this message translates to:
  /// **'Provisional'**
  String get permStatusProvisional;

  /// No description provided for @permStatusRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get permStatusRestricted;

  /// No description provided for @permStatusBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get permStatusBlocked;

  /// No description provided for @permActionEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get permActionEnable;

  /// No description provided for @permActionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permActionOpenSettings;

  /// No description provided for @permissionsEnableAll.
  ///
  /// In en, this message translates to:
  /// **'Enable all now'**
  String get permissionsEnableAll;

  /// No description provided for @permissionsNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permissionsNotNow;

  /// No description provided for @permissionsPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Botanica asks only when needed — you can change this later in Profile.'**
  String get permissionsPrivacyNote;

  /// No description provided for @gardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get gardenTitle;

  /// No description provided for @gardenTodayCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get gardenTodayCardTitle;

  /// No description provided for @gardenLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plants.'**
  String get gardenLoadError;

  /// Task count on Today card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tasks due} =1{1 task due} other{{count} tasks due}}'**
  String gardenTasksDueToday(int count);

  /// Chip label showing the user's current care streak
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String gardenCareStreakChip(int days);

  /// No description provided for @gardenWeatherChip.
  ///
  /// In en, this message translates to:
  /// **'{condition} · {temp}°{unit} · {humidity}%'**
  String gardenWeatherChip(
      String condition, int temp, String unit, int humidity);

  /// No description provided for @weatherClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherClear;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherCloudy;

  /// No description provided for @weatherFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get weatherFog;

  /// No description provided for @weatherDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get weatherDrizzle;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherSnow;

  /// No description provided for @weatherThunder.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get weatherThunder;

  /// No description provided for @weatherUnknown.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weatherUnknown;

  /// No description provided for @gardenQuickWatered.
  ///
  /// In en, this message translates to:
  /// **'Watered'**
  String get gardenQuickWatered;

  /// No description provided for @gardenQuickSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get gardenQuickSnooze;

  /// No description provided for @tasksSnoozeOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get tasksSnoozeOneHour;

  /// No description provided for @tasksSnoozeThreeHours.
  ///
  /// In en, this message translates to:
  /// **'3 hours'**
  String get tasksSnoozeThreeHours;

  /// No description provided for @tasksSnoozeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tasksSnoozeTomorrow;

  /// No description provided for @tasksSnoozeTomorrowMorning.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow morning'**
  String get tasksSnoozeTomorrowMorning;

  /// No description provided for @tasksSnoozeWeekend.
  ///
  /// In en, this message translates to:
  /// **'This weekend'**
  String get tasksSnoozeWeekend;

  /// No description provided for @tasksSnoozeCustomTime.
  ///
  /// In en, this message translates to:
  /// **'Custom time'**
  String get tasksSnoozeCustomTime;

  /// No description provided for @gardenQuickAddPlant.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get gardenQuickAddPlant;

  /// No description provided for @gardenRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get gardenRoomsTitle;

  /// No description provided for @gardenRoomsAll.
  ///
  /// In en, this message translates to:
  /// **'All rooms'**
  String get gardenRoomsAll;

  /// No description provided for @gardenToggleCardMode.
  ///
  /// In en, this message translates to:
  /// **'Toggle Card Mode'**
  String get gardenToggleCardMode;

  /// No description provided for @gardenToggleViewMode.
  ///
  /// In en, this message translates to:
  /// **'Toggle View Mode'**
  String get gardenToggleViewMode;

  /// No description provided for @gardenRoomPlantCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 plant} other{{count} plants}}'**
  String gardenRoomPlantCount(int count);

  /// No description provided for @gardenRoomsWaterAll.
  ///
  /// In en, this message translates to:
  /// **'Water all'**
  String get gardenRoomsWaterAll;

  /// No description provided for @gardenRoomsSnoozeAll.
  ///
  /// In en, this message translates to:
  /// **'Snooze all'**
  String get gardenRoomsSnoozeAll;

  /// No description provided for @gardenRoomsWateredCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {Watered 1 plant} other {Watered {count} plants}}'**
  String gardenRoomsWateredCount(int count);

  /// No description provided for @gardenRoomsSnoozedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {Snoozed 1 task} other {Snoozed {count} tasks}}'**
  String gardenRoomsSnoozedCount(int count);

  /// No description provided for @gardenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your garden'**
  String get gardenEmptyTitle;

  /// No description provided for @gardenEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first plant to unlock a tailored care plan and daily tasks.'**
  String get gardenEmptyBody;

  /// No description provided for @gardenEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Add your first plant'**
  String get gardenEmptyCta;

  /// No description provided for @gardenAddPlantFab.
  ///
  /// In en, this message translates to:
  /// **'Add Plant'**
  String get gardenAddPlantFab;

  /// No description provided for @addPlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Plant'**
  String get addPlantTitle;

  /// No description provided for @addPlantMethodScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get addPlantMethodScan;

  /// No description provided for @addPlantMethodLibrary.
  ///
  /// In en, this message translates to:
  /// **'From library'**
  String get addPlantMethodLibrary;

  /// No description provided for @addPlantMethodManual.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get addPlantMethodManual;

  /// No description provided for @addPlantScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan your plant'**
  String get addPlantScanTitle;

  /// No description provided for @addPlantScanBody.
  ///
  /// In en, this message translates to:
  /// **'Capture leaf + full plant for better results.'**
  String get addPlantScanBody;

  /// No description provided for @addPlantScanButton.
  ///
  /// In en, this message translates to:
  /// **'Scan now'**
  String get addPlantScanButton;

  /// No description provided for @addPlantLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plant'**
  String get addPlantLibraryTitle;

  /// No description provided for @addPlantManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about it'**
  String get addPlantManualTitle;

  /// No description provided for @addPlantConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm details'**
  String get addPlantConfirmTitle;

  /// No description provided for @addPlantFieldNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get addPlantFieldNickname;

  /// No description provided for @addPlantFieldRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get addPlantFieldRoom;

  /// No description provided for @addPlantDefaultRoomLivingRoom.
  ///
  /// In en, this message translates to:
  /// **'Living room'**
  String get addPlantDefaultRoomLivingRoom;

  /// No description provided for @addPlantDefaultSpeciesUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get addPlantDefaultSpeciesUnknown;

  /// No description provided for @addPlantFieldEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get addPlantFieldEnvironment;

  /// No description provided for @addPlantEnvIndoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get addPlantEnvIndoor;

  /// No description provided for @addPlantEnvBalcony.
  ///
  /// In en, this message translates to:
  /// **'Balcony'**
  String get addPlantEnvBalcony;

  /// No description provided for @addPlantEnvOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get addPlantEnvOutdoor;

  /// No description provided for @addPlantReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get addPlantReminderTime;

  /// No description provided for @addPlantReminderMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get addPlantReminderMorning;

  /// No description provided for @addPlantReminderEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get addPlantReminderEvening;

  /// No description provided for @addPlantReminderCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get addPlantReminderCustom;

  /// No description provided for @addPlantSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save to Garden'**
  String get addPlantSaveButton;

  /// No description provided for @plantDetailOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get plantDetailOverview;

  /// No description provided for @plantDetailCare.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get plantDetailCare;

  /// No description provided for @plantDetailJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get plantDetailJournal;

  /// No description provided for @plantDetailLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get plantDetailLogs;

  /// No description provided for @plantDetailLogsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No care logs yet'**
  String get plantDetailLogsEmptyTitle;

  /// No description provided for @plantDetailLogsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a watering or care task and it will appear here.'**
  String get plantDetailLogsEmptyBody;

  /// No description provided for @tasksEmptySoon.
  ///
  /// In en, this message translates to:
  /// **'Nothing due soon. You\'re all caught up!'**
  String get tasksEmptySoon;

  /// No description provided for @tasksEmptyWatch.
  ///
  /// In en, this message translates to:
  /// **'No tasks to watch. Your garden is resting.'**
  String get tasksEmptyWatch;

  /// No description provided for @plantDetailWaterNow.
  ///
  /// In en, this message translates to:
  /// **'Water now'**
  String get plantDetailWaterNow;

  /// No description provided for @plantDetailAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get plantDetailAddPhoto;

  /// No description provided for @plantDetailAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get plantDetailAddNote;

  /// No description provided for @plantDetailMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant unavailable'**
  String get plantDetailMissingTitle;

  /// No description provided for @plantDetailMissingBody.
  ///
  /// In en, this message translates to:
  /// **'This plant can’t be found. It may have been deleted.'**
  String get plantDetailMissingBody;

  /// No description provided for @plantDetailMissingCta.
  ///
  /// In en, this message translates to:
  /// **'Back to Garden'**
  String get plantDetailMissingCta;

  /// No description provided for @plantDetailNextWateringInDays.
  ///
  /// In en, this message translates to:
  /// **'Next watering in {days} days'**
  String plantDetailNextWateringInDays(int days);

  /// No description provided for @plantDetailEnvironmentImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'Environment impact'**
  String get plantDetailEnvironmentImpactTitle;

  /// No description provided for @plantDetailEnvironmentImpactBaseAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Base: {base} days · Adjusted: {adjusted} days'**
  String plantDetailEnvironmentImpactBaseAdjusted(int base, int adjusted);

  /// No description provided for @plantDetailEnvironmentStable.
  ///
  /// In en, this message translates to:
  /// **'Stable conditions — no adjustment today.'**
  String get plantDetailEnvironmentStable;

  /// No description provided for @plantDetailDrynessLow.
  ///
  /// In en, this message translates to:
  /// **'Low dryness (slower drying)'**
  String get plantDetailDrynessLow;

  /// No description provided for @plantDetailDrynessBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced dryness'**
  String get plantDetailDrynessBalanced;

  /// No description provided for @plantDetailDrynessHigh.
  ///
  /// In en, this message translates to:
  /// **'High dryness (faster drying)'**
  String get plantDetailDrynessHigh;

  /// No description provided for @plantDetailCareWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Next watering is calculated from a base interval and adjusted by humidity, temperature, and season.'**
  String get plantDetailCareWaterBody;

  /// No description provided for @plantDetailCareLightBody.
  ///
  /// In en, this message translates to:
  /// **'Bright, indirect light is a great default for most indoor plants.'**
  String get plantDetailCareLightBody;

  /// No description provided for @plantDetailCareTempTitle.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get plantDetailCareTempTitle;

  /// No description provided for @plantDetailCareTempBody.
  ///
  /// In en, this message translates to:
  /// **'Avoid sudden cold drafts. Stable warmth helps predictable growth.'**
  String get plantDetailCareTempBody;

  /// No description provided for @plantDetailJournalDesignNote.
  ///
  /// In en, this message translates to:
  /// **'Match framing overlay and compare slider are designed here; plug in camera/gallery later.'**
  String get plantDetailJournalDesignNote;

  /// No description provided for @plantDetailJournalIntro.
  ///
  /// In en, this message translates to:
  /// **'A gentle timeline for photos and notes — your plant diary.'**
  String get plantDetailJournalIntro;

  /// No description provided for @journalSectionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get journalSectionPhotos;

  /// No description provided for @diarySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diarySectionTitle;

  /// No description provided for @diaryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Add one to remember what changed.'**
  String get diaryEmptyBody;

  /// No description provided for @diaryAddEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'New diary entry'**
  String get diaryAddEntryTitle;

  /// No description provided for @diaryAddEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Write what you noticed today…'**
  String get diaryAddEntryHint;

  /// No description provided for @diaryAddEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get diaryAddEntryButton;

  /// No description provided for @diaryEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Diary entry'**
  String get diaryEntryTitle;

  /// No description provided for @diaryEntrySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to diary.'**
  String get diaryEntrySaved;

  /// No description provided for @diaryEditEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit diary entry'**
  String get diaryEditEntryTitle;

  /// No description provided for @diaryEditConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Save changes?'**
  String get diaryEditConfirmTitle;

  /// No description provided for @diaryEditConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Update this diary entry with your changes.'**
  String get diaryEditConfirmBody;

  /// No description provided for @diaryEntryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Diary entry updated.'**
  String get diaryEntryUpdated;

  /// No description provided for @diaryEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Diary entry deleted.'**
  String get diaryEntryDeleted;

  /// No description provided for @diaryEntryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete diary entry?'**
  String get diaryEntryDeleteTitle;

  /// No description provided for @diaryEntryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the diary entry from the timeline. You can undo right after deleting.'**
  String get diaryEntryDeleteBody;

  /// No description provided for @diaryPromptGrowingWell.
  ///
  /// In en, this message translates to:
  /// **'Growing well'**
  String get diaryPromptGrowingWell;

  /// No description provided for @diaryPromptNewLeaf.
  ///
  /// In en, this message translates to:
  /// **'New leaf'**
  String get diaryPromptNewLeaf;

  /// No description provided for @diaryPromptStruggling.
  ///
  /// In en, this message translates to:
  /// **'Struggling'**
  String get diaryPromptStruggling;

  /// No description provided for @diaryPromptRepotted.
  ///
  /// In en, this message translates to:
  /// **'Repotted'**
  String get diaryPromptRepotted;

  /// No description provided for @diaryPromptBlooming.
  ///
  /// In en, this message translates to:
  /// **'Blooming'**
  String get diaryPromptBlooming;

  /// No description provided for @journalEntryActions.
  ///
  /// In en, this message translates to:
  /// **'Entry actions'**
  String get journalEntryActions;

  /// No description provided for @journalShareCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Share card'**
  String get journalShareCardTitle;

  /// No description provided for @journalShareCardText.
  ///
  /// In en, this message translates to:
  /// **'Made with Botanica'**
  String get journalShareCardText;

  /// No description provided for @journalShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share — please try again.'**
  String get journalShareFailed;

  /// No description provided for @journalAddPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get journalAddPhotoTitle;

  /// No description provided for @journalAddPhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get journalAddPhotoCamera;

  /// No description provided for @journalAddPhotoCameraBody.
  ///
  /// In en, this message translates to:
  /// **'Capture a new photo with an optional ghost overlay from your last shot.'**
  String get journalAddPhotoCameraBody;

  /// No description provided for @journalAddPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get journalAddPhotoGallery;

  /// No description provided for @journalAddPhotoGalleryBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo from your library.'**
  String get journalAddPhotoGalleryBody;

  /// No description provided for @journalCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get journalCaptureTitle;

  /// No description provided for @journalCaptureTip.
  ///
  /// In en, this message translates to:
  /// **'Fill the frame and try to match your last photo for better comparisons.'**
  String get journalCaptureTip;

  /// No description provided for @journalFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get journalFlash;

  /// No description provided for @journalCameraPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to capture photos.'**
  String get journalCameraPermissionNeeded;

  /// No description provided for @journalPhotosPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Photos permission is required to pick images.'**
  String get journalPhotosPermissionNeeded;

  /// No description provided for @journalPhotoSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to journal.'**
  String get journalPhotoSaved;

  /// No description provided for @journalPhotoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted.'**
  String get journalPhotoDeleted;

  /// No description provided for @journalPhotoDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete photo?'**
  String get journalPhotoDeleteTitle;

  /// No description provided for @journalPhotoDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the photo from this plant\'s journal and local storage. You can undo right after deleting.'**
  String get journalPhotoDeleteBody;

  /// No description provided for @journalEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No photos yet. Add one to start your growth timeline.'**
  String get journalEmptyBody;

  /// No description provided for @journalPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal photo'**
  String get journalPhotoTitle;

  /// No description provided for @journalPhotoNoNote.
  ///
  /// In en, this message translates to:
  /// **'No note'**
  String get journalPhotoNoNote;

  /// No description provided for @journalAddNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get journalAddNoteTitle;

  /// No description provided for @journalAddNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional: new leaf, repotted, etc.'**
  String get journalAddNoteHint;

  /// No description provided for @journalCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get journalCompareTitle;

  /// No description provided for @journalCompareHint.
  ///
  /// In en, this message translates to:
  /// **'Drag left/right to compare.'**
  String get journalCompareHint;

  /// No description provided for @journalPhotoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo unavailable'**
  String get journalPhotoUnavailable;

  /// No description provided for @journalOverlayStrength.
  ///
  /// In en, this message translates to:
  /// **'Overlay strength'**
  String get journalOverlayStrength;

  /// No description provided for @journalPreviousPhoto.
  ///
  /// In en, this message translates to:
  /// **'Previous photo'**
  String get journalPreviousPhoto;

  /// No description provided for @journalLimitedPhotosAccess.
  ///
  /// In en, this message translates to:
  /// **'Selected Photos access is on. You can choose visible photos, or update access in iOS Settings.'**
  String get journalLimitedPhotosAccess;

  /// No description provided for @journalPhotoMeta.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String journalPhotoMeta(DateTime date);

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanTitle;

  /// No description provided for @scanTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get scanTryAgain;

  /// No description provided for @scanCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan your plant'**
  String get scanCaptureTitle;

  /// No description provided for @scanCaptureTip.
  ///
  /// In en, this message translates to:
  /// **'Capture leaf + full plant for best results.'**
  String get scanCaptureTip;

  /// No description provided for @scanCameraPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan plants.'**
  String get scanCameraPermissionNeeded;

  /// No description provided for @scanCameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access'**
  String get scanCameraPermissionTitle;

  /// No description provided for @scanCameraPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Use the camera for a quick scan, or browse the plant library without granting access.'**
  String get scanCameraPermissionBody;

  /// No description provided for @scanUseCamera.
  ///
  /// In en, this message translates to:
  /// **'Use camera'**
  String get scanUseCamera;

  /// No description provided for @scanProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'Identifying your plant…'**
  String get scanProcessingBody;

  /// No description provided for @scanChooseCandidate.
  ///
  /// In en, this message translates to:
  /// **'Choose a match'**
  String get scanChooseCandidate;

  /// No description provided for @scanRefineTitle.
  ///
  /// In en, this message translates to:
  /// **'Not sure? Refine results'**
  String get scanRefineTitle;

  /// No description provided for @scanRefineHelper.
  ///
  /// In en, this message translates to:
  /// **'Answer a quick question to narrow the list.'**
  String get scanRefineHelper;

  /// No description provided for @scanRefineFallbackNote.
  ///
  /// In en, this message translates to:
  /// **'No exact matches for these filters yet—showing closest results.'**
  String get scanRefineFallbackNote;

  /// No description provided for @scanConfidenceGuide.
  ///
  /// In en, this message translates to:
  /// **'Confidence is a guide only—compare shape and care tags before adding.'**
  String get scanConfidenceGuide;

  /// No description provided for @scanConfidenceStrongLabel.
  ///
  /// In en, this message translates to:
  /// **'High confidence'**
  String get scanConfidenceStrongLabel;

  /// No description provided for @scanConfidenceStrongBody.
  ///
  /// In en, this message translates to:
  /// **'Looks close to the captured plant.'**
  String get scanConfidenceStrongBody;

  /// No description provided for @scanConfidenceLikelyLabel.
  ///
  /// In en, this message translates to:
  /// **'Moderate confidence'**
  String get scanConfidenceLikelyLabel;

  /// No description provided for @scanConfidenceLikelyBody.
  ///
  /// In en, this message translates to:
  /// **'Compare details before adding.'**
  String get scanConfidenceLikelyBody;

  /// No description provided for @scanConfidencePossibleLabel.
  ///
  /// In en, this message translates to:
  /// **'Low confidence — try another angle'**
  String get scanConfidencePossibleLabel;

  /// No description provided for @scanConfidencePossibleBody.
  ///
  /// In en, this message translates to:
  /// **'Best guess only—capture another view if you can.'**
  String get scanConfidencePossibleBody;

  /// No description provided for @scanRefineFlowering.
  ///
  /// In en, this message translates to:
  /// **'Is it flowering?'**
  String get scanRefineFlowering;

  /// No description provided for @scanRefineIndoorOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor or outdoor?'**
  String get scanRefineIndoorOutdoor;

  /// No description provided for @scanRefineSucculent.
  ///
  /// In en, this message translates to:
  /// **'Succulent type?'**
  String get scanRefineSucculent;

  /// No description provided for @scanRefinePetSafe.
  ///
  /// In en, this message translates to:
  /// **'Pet‑safe'**
  String get scanRefinePetSafe;

  /// No description provided for @scanRefineEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy care'**
  String get scanRefineEasy;

  /// No description provided for @scanRefineLowLight.
  ///
  /// In en, this message translates to:
  /// **'Low light'**
  String get scanRefineLowLight;

  /// No description provided for @scanAddToGarden.
  ///
  /// In en, this message translates to:
  /// **'Add to Garden'**
  String get scanAddToGarden;

  /// No description provided for @scanBrowseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Browse library instead'**
  String get scanBrowseLibrary;

  /// No description provided for @scanTakingLongerTitle.
  ///
  /// In en, this message translates to:
  /// **'Taking longer than expected'**
  String get scanTakingLongerTitle;

  /// No description provided for @scanTakingLongerBody.
  ///
  /// In en, this message translates to:
  /// **'The scan did not finish in time. Try again or choose a plant manually.'**
  String get scanTakingLongerBody;

  /// No description provided for @scanNoResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not identify this plant'**
  String get scanNoResultTitle;

  /// No description provided for @scanNoResultBody.
  ///
  /// In en, this message translates to:
  /// **'Try another angle with leaf detail, or browse the library instead.'**
  String get scanNoResultBody;

  /// No description provided for @scanDeterministicNote.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: results are deterministic offline placeholders. Plug in Kindwise/Gemini later.'**
  String get scanDeterministicNote;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksTabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tasksTabToday;

  /// No description provided for @tasksTabSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get tasksTabSoon;

  /// No description provided for @tasksTabWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get tasksTabWatch;

  /// No description provided for @tasksCalendarToggle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tasksCalendarToggle;

  /// No description provided for @tasksSeasonalTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal care tips'**
  String get tasksSeasonalTipsTitle;

  /// No description provided for @tipSpringRepot.
  ///
  /// In en, this message translates to:
  /// **'Spring: Repot if roots are crowded and growth has resumed.'**
  String get tipSpringRepot;

  /// No description provided for @tipSpringFertilize.
  ///
  /// In en, this message translates to:
  /// **'Spring: Resume light fertilizing as new growth starts.'**
  String get tipSpringFertilize;

  /// No description provided for @tipSummerWaterMore.
  ///
  /// In en, this message translates to:
  /// **'Summer: Check soil more often — pots dry faster in heat.'**
  String get tipSummerWaterMore;

  /// No description provided for @tipSummerShadeOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Summer: Protect balcony/outdoor plants from harsh midday sun.'**
  String get tipSummerShadeOutdoor;

  /// No description provided for @tipAutumnReduceWater.
  ///
  /// In en, this message translates to:
  /// **'Autumn: Reduce watering as light and growth slow down.'**
  String get tipAutumnReduceWater;

  /// No description provided for @tipAutumnBringIndoor.
  ///
  /// In en, this message translates to:
  /// **'Autumn: Bring sensitive plants indoors before cold nights.'**
  String get tipAutumnBringIndoor;

  /// No description provided for @tipWinterReduceFertilize.
  ///
  /// In en, this message translates to:
  /// **'Winter: Fertilize less and water less — growth slows.'**
  String get tipWinterReduceFertilize;

  /// No description provided for @tipWinterLowLight.
  ///
  /// In en, this message translates to:
  /// **'Winter: Move closer to light or use a grow light to prevent stretching.'**
  String get tipWinterLowLight;

  /// No description provided for @tasksSnoozedUntil.
  ///
  /// In en, this message translates to:
  /// **'Snoozed until {date}'**
  String tasksSnoozedUntil(DateTime date);

  /// No description provided for @tasksSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get tasksSkipped;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// No description provided for @discoverSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search plants, guides, and tips'**
  String get discoverSearchHint;

  /// No description provided for @discoverNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get discoverNoResultsTitle;

  /// No description provided for @discoverNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, or search by scientific name.'**
  String get discoverNoResultsBody;

  /// No description provided for @discoverSectionCurated.
  ///
  /// In en, this message translates to:
  /// **'Curated plants'**
  String get discoverSectionCurated;

  /// No description provided for @discoverSectionLibrary.
  ///
  /// In en, this message translates to:
  /// **'Plant library'**
  String get discoverSectionLibrary;

  /// No description provided for @discoverSectionGuides.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get discoverSectionGuides;

  /// No description provided for @discoverFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get discoverFilters;

  /// No description provided for @discoverFilterPetSafe.
  ///
  /// In en, this message translates to:
  /// **'Pet‑safe'**
  String get discoverFilterPetSafe;

  /// No description provided for @discoverFilterDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get discoverFilterDifficulty;

  /// No description provided for @discoverFilterLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get discoverFilterLight;

  /// No description provided for @discoverTagPetSafe.
  ///
  /// In en, this message translates to:
  /// **'Pet‑safe'**
  String get discoverTagPetSafe;

  /// No description provided for @discoverTagToxic.
  ///
  /// In en, this message translates to:
  /// **'Toxic'**
  String get discoverTagToxic;

  /// No description provided for @discoverGuideWateringTitle.
  ///
  /// In en, this message translates to:
  /// **'Watering basics'**
  String get discoverGuideWateringTitle;

  /// No description provided for @discoverGuideWateringBody.
  ///
  /// In en, this message translates to:
  /// **'Learn how to read soil moisture and avoid overwatering.'**
  String get discoverGuideWateringBody;

  /// No description provided for @discoverGuideSoilTitle.
  ///
  /// In en, this message translates to:
  /// **'Soil & drainage'**
  String get discoverGuideSoilTitle;

  /// No description provided for @discoverGuideSoilBody.
  ///
  /// In en, this message translates to:
  /// **'Why airy mixes reduce root rot and help growth.'**
  String get discoverGuideSoilBody;

  /// No description provided for @discoverGuidePestTitle.
  ///
  /// In en, this message translates to:
  /// **'Pest checklist'**
  String get discoverGuidePestTitle;

  /// No description provided for @discoverGuidePestBody.
  ///
  /// In en, this message translates to:
  /// **'A quick weekly routine to catch issues early.'**
  String get discoverGuidePestBody;

  /// No description provided for @speciesDetailHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get speciesDetailHistory;

  /// No description provided for @speciesDetailHabit.
  ///
  /// In en, this message translates to:
  /// **'Growth habit'**
  String get speciesDetailHabit;

  /// No description provided for @speciesDetailCareAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'Care at a glance'**
  String get speciesDetailCareAtAGlance;

  /// No description provided for @speciesDetailWaterEvery.
  ///
  /// In en, this message translates to:
  /// **'Water every {days} days'**
  String speciesDetailWaterEvery(int days);

  /// No description provided for @speciesDetailFertilizeEvery.
  ///
  /// In en, this message translates to:
  /// **'Fertilize every {days} days'**
  String speciesDetailFertilizeEvery(int days);

  /// No description provided for @speciesDetailMistEvery.
  ///
  /// In en, this message translates to:
  /// **'Mist every {days} days'**
  String speciesDetailMistEvery(int days);

  /// No description provided for @speciesDetailDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get speciesDetailDetails;

  /// No description provided for @speciesDetailOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get speciesDetailOrigin;

  /// No description provided for @speciesDetailToxicity.
  ///
  /// In en, this message translates to:
  /// **'Toxicity'**
  String get speciesDetailToxicity;

  /// No description provided for @speciesDetailGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get speciesDetailGrowth;

  /// No description provided for @speciesDetailMatureSize.
  ///
  /// In en, this message translates to:
  /// **'Mature size'**
  String get speciesDetailMatureSize;

  /// No description provided for @speciesDetailSizeHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get speciesDetailSizeHeight;

  /// No description provided for @speciesDetailSizeSpread.
  ///
  /// In en, this message translates to:
  /// **'Spread'**
  String get speciesDetailSizeSpread;

  /// No description provided for @speciesDetailSizeVineLength.
  ///
  /// In en, this message translates to:
  /// **'Vine length'**
  String get speciesDetailSizeVineLength;

  /// No description provided for @speciesDetailRangeCm.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} cm'**
  String speciesDetailRangeCm(int min, int max);

  /// No description provided for @speciesDetailCmValue.
  ///
  /// In en, this message translates to:
  /// **'{value} cm'**
  String speciesDetailCmValue(int value);

  /// No description provided for @speciesDetailUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get speciesDetailUnknown;

  /// No description provided for @growthRateSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get growthRateSlow;

  /// No description provided for @growthRateModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get growthRateModerate;

  /// No description provided for @growthRateFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get growthRateFast;

  /// No description provided for @growthRateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get growthRateUnknown;

  /// No description provided for @growthFormUpright.
  ///
  /// In en, this message translates to:
  /// **'Upright'**
  String get growthFormUpright;

  /// No description provided for @growthFormTrailing.
  ///
  /// In en, this message translates to:
  /// **'Trailing'**
  String get growthFormTrailing;

  /// No description provided for @growthFormClimbing.
  ///
  /// In en, this message translates to:
  /// **'Climbing'**
  String get growthFormClimbing;

  /// No description provided for @growthFormRosette.
  ///
  /// In en, this message translates to:
  /// **'Rosette'**
  String get growthFormRosette;

  /// No description provided for @growthFormTreeLike.
  ///
  /// In en, this message translates to:
  /// **'Tree-like'**
  String get growthFormTreeLike;

  /// No description provided for @growthFormClumping.
  ///
  /// In en, this message translates to:
  /// **'Clumping'**
  String get growthFormClumping;

  /// No description provided for @growthFormEpiphytic.
  ///
  /// In en, this message translates to:
  /// **'Epiphytic'**
  String get growthFormEpiphytic;

  /// No description provided for @growthFormSucculent.
  ///
  /// In en, this message translates to:
  /// **'Succulent'**
  String get growthFormSucculent;

  /// No description provided for @growthFormFern.
  ///
  /// In en, this message translates to:
  /// **'Fern'**
  String get growthFormFern;

  /// No description provided for @growthFormOrchid.
  ///
  /// In en, this message translates to:
  /// **'Orchid'**
  String get growthFormOrchid;

  /// No description provided for @growthFormOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get growthFormOther;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @lightBrightDirect.
  ///
  /// In en, this message translates to:
  /// **'Bright, direct'**
  String get lightBrightDirect;

  /// No description provided for @lightBrightIndirect.
  ///
  /// In en, this message translates to:
  /// **'Bright, indirect'**
  String get lightBrightIndirect;

  /// No description provided for @lightMediumIndirect.
  ///
  /// In en, this message translates to:
  /// **'Medium, indirect'**
  String get lightMediumIndirect;

  /// No description provided for @lightLowToBrightIndirect.
  ///
  /// In en, this message translates to:
  /// **'Low to bright, indirect'**
  String get lightLowToBrightIndirect;

  /// No description provided for @lightLowToBright.
  ///
  /// In en, this message translates to:
  /// **'Low to bright'**
  String get lightLowToBright;

  /// No description provided for @dailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Flower'**
  String get dailyTitle;

  /// No description provided for @dailyReveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get dailyReveal;

  /// No description provided for @dailyRevealHintTap.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get dailyRevealHintTap;

  /// No description provided for @dailyRevealHintSlide.
  ///
  /// In en, this message translates to:
  /// **'Slide to reveal'**
  String get dailyRevealHintSlide;

  /// No description provided for @dailyRevealHintHold.
  ///
  /// In en, this message translates to:
  /// **'Hold to reveal'**
  String get dailyRevealHintHold;

  /// No description provided for @dailyRevealHintPull.
  ///
  /// In en, this message translates to:
  /// **'Pull to reveal'**
  String get dailyRevealHintPull;

  /// No description provided for @dailyRevealHintStamp.
  ///
  /// In en, this message translates to:
  /// **'Stamp to reveal'**
  String get dailyRevealHintStamp;

  /// No description provided for @dailyRevealHintFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip to reveal'**
  String get dailyRevealHintFlip;

  /// No description provided for @dailyRevealHintTrace.
  ///
  /// In en, this message translates to:
  /// **'Trace to reveal'**
  String get dailyRevealHintTrace;

  /// No description provided for @dailyInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About Daily Flower'**
  String get dailyInfoTitle;

  /// No description provided for @dailyInfoIntro.
  ///
  /// In en, this message translates to:
  /// **'Daily Flower is a calm ritual that changes once per day.'**
  String get dailyInfoIntro;

  /// No description provided for @dailyInfoModeWesternZodiac.
  ///
  /// In en, this message translates to:
  /// **'Western zodiac uses your birth date or your selected sign.'**
  String get dailyInfoModeWesternZodiac;

  /// No description provided for @dailyInfoModeTarot.
  ///
  /// In en, this message translates to:
  /// **'Tarot is chosen by drawing four cards and selecting one.'**
  String get dailyInfoModeTarot;

  /// No description provided for @dailyInfoModeAuto.
  ///
  /// In en, this message translates to:
  /// **'{mode} uses a daily draw from today’s date — personalized with your key.'**
  String dailyInfoModeAuto(String mode);

  /// No description provided for @dailyInfoModeJustFlower.
  ///
  /// In en, this message translates to:
  /// **'Just Flower is the simplest ritual. Tap to reveal a personalized bloom.'**
  String get dailyInfoModeJustFlower;

  /// No description provided for @dailyInfoHowToReveal.
  ///
  /// In en, this message translates to:
  /// **'How to reveal: {hint}'**
  String dailyInfoHowToReveal(String hint);

  /// No description provided for @dailyInfoChangeMode.
  ///
  /// In en, this message translates to:
  /// **'Change mode'**
  String get dailyInfoChangeMode;

  /// No description provided for @dailySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dailySave;

  /// No description provided for @dailyShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get dailyShare;

  /// No description provided for @dailyCareToday.
  ///
  /// In en, this message translates to:
  /// **'Care today'**
  String get dailyCareToday;

  /// No description provided for @dailyHowToAppreciate.
  ///
  /// In en, this message translates to:
  /// **'How to appreciate today'**
  String get dailyHowToAppreciate;

  /// No description provided for @dailyAiNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Botanica note'**
  String get dailyAiNoteTitle;

  /// No description provided for @plantCareAiTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s care tip'**
  String get plantCareAiTipTitle;

  /// No description provided for @dailyModeMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your Daily mode'**
  String get dailyModeMissingTitle;

  /// No description provided for @dailyModeMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a tradition (tarot, almanac, rune…) and Botanica will personalize your Daily Flower.'**
  String get dailyModeMissingBody;

  /// No description provided for @dailyModeMissingCta.
  ///
  /// In en, this message translates to:
  /// **'Choose a mode'**
  String get dailyModeMissingCta;

  /// No description provided for @dailyTarotNotDrawn.
  ///
  /// In en, this message translates to:
  /// **'Draw today'**
  String get dailyTarotNotDrawn;

  /// No description provided for @dailyTarotDrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Tarot draw'**
  String get dailyTarotDrawTitle;

  /// No description provided for @dailyTarotDrawBody.
  ///
  /// In en, this message translates to:
  /// **'Four cards are dealt. Choose one — Botanica will reveal today’s flower.'**
  String get dailyTarotDrawBody;

  /// No description provided for @dailyTarotDrawCta.
  ///
  /// In en, this message translates to:
  /// **'Deal 4 cards'**
  String get dailyTarotDrawCta;

  /// No description provided for @dailyTarotCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get dailyTarotCardLabel;

  /// No description provided for @dailyDeterministicNote.
  ///
  /// In en, this message translates to:
  /// **'Daily Flower is deterministic: same day + locale + mode + your profile yields the same card (great for sharing).'**
  String get dailyDeterministicNote;

  /// No description provided for @dailyContentUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Flower unavailable'**
  String get dailyContentUnavailableTitle;

  /// No description provided for @dailyContentUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Botanica couldn’t load today’s flower content. Please try again.'**
  String get dailyContentUnavailableBody;

  /// No description provided for @dailyProfileMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get dailyProfileMissingTitle;

  /// No description provided for @dailyProfileMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Set a personal key in Profile (like a short seed phrase or your birth date) so Daily Flower can be personalized.'**
  String get dailyProfileMissingBody;

  /// No description provided for @dailyProfileMissingBodyZodiac.
  ///
  /// In en, this message translates to:
  /// **'Set your birth date (or choose your sign) in Profile so Daily Flower can be personalized.'**
  String get dailyProfileMissingBodyZodiac;

  /// No description provided for @dailyProfileMissingCta.
  ///
  /// In en, this message translates to:
  /// **'Set up now'**
  String get dailyProfileMissingCta;

  /// No description provided for @careKeyLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get careKeyLight;

  /// No description provided for @careKeyWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get careKeyWater;

  /// No description provided for @careKeyTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get careKeyTemperature;

  /// No description provided for @careKeyPetSafety.
  ///
  /// In en, this message translates to:
  /// **'Pet safety'**
  String get careKeyPetSafety;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSectionPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get profileSectionPermissions;

  /// No description provided for @profileSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get profileSectionData;

  /// No description provided for @profileSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileSectionAbout;

  /// No description provided for @storageHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage health'**
  String get storageHealthTitle;

  /// No description provided for @storageHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review journal media and clear temporary files.'**
  String get storageHealthSubtitle;

  /// No description provided for @storageJournalPhotos.
  ///
  /// In en, this message translates to:
  /// **'Journal photos'**
  String get storageJournalPhotos;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage used'**
  String get storageUsed;

  /// No description provided for @storagePhotoFiles.
  ///
  /// In en, this message translates to:
  /// **'Photo files'**
  String get storagePhotoFiles;

  /// No description provided for @storageJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'Journal entries'**
  String get storageJournalEntries;

  /// No description provided for @storagePhotoEntries.
  ///
  /// In en, this message translates to:
  /// **'Photo entries'**
  String get storagePhotoEntries;

  /// No description provided for @storageMissingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Missing photos'**
  String get storageMissingPhotos;

  /// No description provided for @storageCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary cache'**
  String get storageCacheTitle;

  /// No description provided for @storageCacheBody.
  ///
  /// In en, this message translates to:
  /// **'Clears generated share cards and temporary files without deleting your journal photos.'**
  String get storageCacheBody;

  /// No description provided for @storageClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get storageClearCache;

  /// No description provided for @storageCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Temporary cache cleared.'**
  String get storageCacheCleared;

  /// No description provided for @storageFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String storageFileCount(int count);

  /// No description provided for @storageEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String storageEntryCount(int count);

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get profileUnits;

  /// No description provided for @profileHemisphereTitle.
  ///
  /// In en, this message translates to:
  /// **'Hemisphere'**
  String get profileHemisphereTitle;

  /// No description provided for @profileHemisphereBody.
  ///
  /// In en, this message translates to:
  /// **'Used for seasonal care adjustments (winter vs summer).'**
  String get profileHemisphereBody;

  /// No description provided for @hemisphereNorthern.
  ///
  /// In en, this message translates to:
  /// **'Northern'**
  String get hemisphereNorthern;

  /// No description provided for @hemisphereSouthern.
  ///
  /// In en, this message translates to:
  /// **'Southern'**
  String get hemisphereSouthern;

  /// No description provided for @profileBeliefMode.
  ///
  /// In en, this message translates to:
  /// **'Daily mode'**
  String get profileBeliefMode;

  /// No description provided for @profileDailyProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily personalization'**
  String get profileDailyProfileTitle;

  /// No description provided for @profileDailyProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Choose your personal key for {mode}.'**
  String profileDailyProfileBody(String mode);

  /// No description provided for @profileBirthdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Birthdate'**
  String get profileBirthdateTitle;

  /// No description provided for @profileBirthdateBody.
  ///
  /// In en, this message translates to:
  /// **'Used for zodiac and almanac personalization.'**
  String get profileBirthdateBody;

  /// No description provided for @profileDailySeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal key'**
  String get profileDailySeedTitle;

  /// No description provided for @profileDailySeedBody.
  ///
  /// In en, this message translates to:
  /// **'A short seed phrase (like your nickname) that personalizes Daily Flower without changing your mode.'**
  String get profileDailySeedBody;

  /// No description provided for @profileDailySeedHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Aster'**
  String get profileDailySeedHint;

  /// No description provided for @profileDailyProfileUseBirthdate.
  ///
  /// In en, this message translates to:
  /// **'Use birthdate'**
  String get profileDailyProfileUseBirthdate;

  /// No description provided for @profileDailyProfileNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileDailyProfileNotSet;

  /// No description provided for @profileDailyProfileKeySet.
  ///
  /// In en, this message translates to:
  /// **'Key set'**
  String get profileDailyProfileKeySet;

  /// No description provided for @profileDailyProfileNotNeeded.
  ///
  /// In en, this message translates to:
  /// **'No personal info needed.'**
  String get profileDailyProfileNotNeeded;

  /// No description provided for @profileDailyProfilePickModeFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose your Daily mode first, then set up the details here.'**
  String get profileDailyProfilePickModeFirst;

  /// No description provided for @profileDailyProfileTarotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Draw in Daily'**
  String get profileDailyProfileTarotSubtitle;

  /// No description provided for @profileDailyProfileAutoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto (today’s date)'**
  String get profileDailyProfileAutoSubtitle;

  /// No description provided for @profileDailyProfileTarotBody.
  ///
  /// In en, this message translates to:
  /// **'Tarot mode is a daily ritual. Open Daily, deal four cards, and choose one — then today’s flower is revealed.'**
  String get profileDailyProfileTarotBody;

  /// No description provided for @profileDailyProfileTarotCta.
  ///
  /// In en, this message translates to:
  /// **'Open Daily'**
  String get profileDailyProfileTarotCta;

  /// No description provided for @profileDailyProfileAutoBody.
  ///
  /// In en, this message translates to:
  /// **'{mode} uses a daily draw based on today’s date — personalized with your key.'**
  String profileDailyProfileAutoBody(String mode);

  /// No description provided for @profileDailyProfileLocalDefault.
  ///
  /// In en, this message translates to:
  /// **'Uses your language'**
  String get profileDailyProfileLocalDefault;

  /// No description provided for @profileLocalTraditionKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Culture key'**
  String get profileLocalTraditionKeyTitle;

  /// No description provided for @profileLocalTraditionKeyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. global, china, japan…'**
  String get profileLocalTraditionKeyHint;

  /// No description provided for @profilePhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get profilePhotos;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get profileLocation;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get profilePrivacy;

  /// No description provided for @profileBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get profileBackup;

  /// No description provided for @profileCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get profileCredits;

  /// No description provided for @profileDynamicColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Dynamic color'**
  String get profileDynamicColorTitle;

  /// No description provided for @profileDynamicColorBody.
  ///
  /// In en, this message translates to:
  /// **'Use device palette when available.'**
  String get profileDynamicColorBody;

  /// No description provided for @profileAiInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI insights'**
  String get profileAiInsightsTitle;

  /// No description provided for @profileAiInsightsBody.
  ///
  /// In en, this message translates to:
  /// **'Subtle on-page notes that personalize your Daily Flower ritual.'**
  String get profileAiInsightsBody;

  /// No description provided for @profileAiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'AI API key'**
  String get profileAiKeyTitle;

  /// No description provided for @profileAiKeyConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get profileAiKeyConfigured;

  /// No description provided for @profileAiKeyNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileAiKeyNotSet;

  /// No description provided for @profileAiKeyNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get profileAiKeyNotRequired;

  /// No description provided for @profileAiKeySheetBody.
  ///
  /// In en, this message translates to:
  /// **'Stored securely on this device. Used only to generate short, on-page insights in your selected language.'**
  String get profileAiKeySheetBody;

  /// No description provided for @profileAiKeyNotRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This build is configured to use an unauthenticated proxy, so no API key is needed.'**
  String get profileAiKeyNotRequiredBody;

  /// No description provided for @profileAiKeySheetHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your API key'**
  String get profileAiKeySheetHint;

  /// No description provided for @profileAiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'AI key saved.'**
  String get profileAiKeySaved;

  /// No description provided for @profileAiKeyCleared.
  ///
  /// In en, this message translates to:
  /// **'AI key removed.'**
  String get profileAiKeyCleared;

  /// No description provided for @profileLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileLanguageSystem;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @creditsOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open‑source'**
  String get creditsOpenSource;

  /// No description provided for @creditsFlutterCommunity.
  ///
  /// In en, this message translates to:
  /// **'Flutter community references'**
  String get creditsFlutterCommunity;

  /// No description provided for @creditsUiInspiration.
  ///
  /// In en, this message translates to:
  /// **'UI inspiration'**
  String get creditsUiInspiration;

  /// No description provided for @creditsPlaceholderNote.
  ///
  /// In en, this message translates to:
  /// **'Note: this project uses white placeholder PNGs for imagery — replace assets later with real photography/illustrations.'**
  String get creditsPlaceholderNote;

  /// No description provided for @unitsCelsius.
  ///
  /// In en, this message translates to:
  /// **'Celsius (°C)'**
  String get unitsCelsius;

  /// No description provided for @unitsFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'Fahrenheit (°F)'**
  String get unitsFahrenheit;

  /// No description provided for @beliefModeWesternZodiac.
  ///
  /// In en, this message translates to:
  /// **'Western zodiac'**
  String get beliefModeWesternZodiac;

  /// No description provided for @beliefModeChineseZodiac.
  ///
  /// In en, this message translates to:
  /// **'Chinese zodiac'**
  String get beliefModeChineseZodiac;

  /// No description provided for @beliefModeTarot.
  ///
  /// In en, this message translates to:
  /// **'Tarot draw'**
  String get beliefModeTarot;

  /// No description provided for @beliefModeLocalTraditions.
  ///
  /// In en, this message translates to:
  /// **'Local traditions'**
  String get beliefModeLocalTraditions;

  /// No description provided for @beliefModeJustFlower.
  ///
  /// In en, this message translates to:
  /// **'Just give me a flower'**
  String get beliefModeJustFlower;

  /// No description provided for @beliefModeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get beliefModeNotSet;

  /// No description provided for @beliefModeAlmanac.
  ///
  /// In en, this message translates to:
  /// **'Almanac'**
  String get beliefModeAlmanac;

  /// No description provided for @beliefModeOmikuji.
  ///
  /// In en, this message translates to:
  /// **'Japan Omikuji'**
  String get beliefModeOmikuji;

  /// No description provided for @beliefModeRunes.
  ///
  /// In en, this message translates to:
  /// **'Nordic runes'**
  String get beliefModeRunes;

  /// No description provided for @beliefModeOgham.
  ///
  /// In en, this message translates to:
  /// **'Celtic ogham'**
  String get beliefModeOgham;

  /// No description provided for @zodiacAries.
  ///
  /// In en, this message translates to:
  /// **'Aries'**
  String get zodiacAries;

  /// No description provided for @zodiacTaurus.
  ///
  /// In en, this message translates to:
  /// **'Taurus'**
  String get zodiacTaurus;

  /// No description provided for @zodiacGemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get zodiacGemini;

  /// No description provided for @zodiacCancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get zodiacCancer;

  /// No description provided for @zodiacLeo.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get zodiacLeo;

  /// No description provided for @zodiacVirgo.
  ///
  /// In en, this message translates to:
  /// **'Virgo'**
  String get zodiacVirgo;

  /// No description provided for @zodiacLibra.
  ///
  /// In en, this message translates to:
  /// **'Libra'**
  String get zodiacLibra;

  /// No description provided for @zodiacScorpio.
  ///
  /// In en, this message translates to:
  /// **'Scorpio'**
  String get zodiacScorpio;

  /// No description provided for @zodiacSagittarius.
  ///
  /// In en, this message translates to:
  /// **'Sagittarius'**
  String get zodiacSagittarius;

  /// No description provided for @zodiacCapricorn.
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get zodiacCapricorn;

  /// No description provided for @zodiacAquarius.
  ///
  /// In en, this message translates to:
  /// **'Aquarius'**
  String get zodiacAquarius;

  /// No description provided for @zodiacPisces.
  ///
  /// In en, this message translates to:
  /// **'Pisces'**
  String get zodiacPisces;

  /// No description provided for @chineseZodiacRat.
  ///
  /// In en, this message translates to:
  /// **'Rat'**
  String get chineseZodiacRat;

  /// No description provided for @chineseZodiacOx.
  ///
  /// In en, this message translates to:
  /// **'Ox'**
  String get chineseZodiacOx;

  /// No description provided for @chineseZodiacTiger.
  ///
  /// In en, this message translates to:
  /// **'Tiger'**
  String get chineseZodiacTiger;

  /// No description provided for @chineseZodiacRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get chineseZodiacRabbit;

  /// No description provided for @chineseZodiacDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon'**
  String get chineseZodiacDragon;

  /// No description provided for @chineseZodiacSnake.
  ///
  /// In en, this message translates to:
  /// **'Snake'**
  String get chineseZodiacSnake;

  /// No description provided for @chineseZodiacHorse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get chineseZodiacHorse;

  /// No description provided for @chineseZodiacGoat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get chineseZodiacGoat;

  /// No description provided for @chineseZodiacMonkey.
  ///
  /// In en, this message translates to:
  /// **'Monkey'**
  String get chineseZodiacMonkey;

  /// No description provided for @chineseZodiacRooster.
  ///
  /// In en, this message translates to:
  /// **'Rooster'**
  String get chineseZodiacRooster;

  /// No description provided for @chineseZodiacDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get chineseZodiacDog;

  /// No description provided for @chineseZodiacPig.
  ///
  /// In en, this message translates to:
  /// **'Pig'**
  String get chineseZodiacPig;

  /// No description provided for @tarotTheFool.
  ///
  /// In en, this message translates to:
  /// **'The Fool'**
  String get tarotTheFool;

  /// No description provided for @tarotTheMagician.
  ///
  /// In en, this message translates to:
  /// **'The Magician'**
  String get tarotTheMagician;

  /// No description provided for @tarotTheHighPriestess.
  ///
  /// In en, this message translates to:
  /// **'The High Priestess'**
  String get tarotTheHighPriestess;

  /// No description provided for @tarotTheEmpress.
  ///
  /// In en, this message translates to:
  /// **'The Empress'**
  String get tarotTheEmpress;

  /// No description provided for @tarotTheEmperor.
  ///
  /// In en, this message translates to:
  /// **'The Emperor'**
  String get tarotTheEmperor;

  /// No description provided for @tarotTheHierophant.
  ///
  /// In en, this message translates to:
  /// **'The Hierophant'**
  String get tarotTheHierophant;

  /// No description provided for @tarotTheLovers.
  ///
  /// In en, this message translates to:
  /// **'The Lovers'**
  String get tarotTheLovers;

  /// No description provided for @tarotTheChariot.
  ///
  /// In en, this message translates to:
  /// **'The Chariot'**
  String get tarotTheChariot;

  /// No description provided for @tarotStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get tarotStrength;

  /// No description provided for @tarotTheHermit.
  ///
  /// In en, this message translates to:
  /// **'The Hermit'**
  String get tarotTheHermit;

  /// No description provided for @tarotWheelOfFortune.
  ///
  /// In en, this message translates to:
  /// **'Wheel of Fortune'**
  String get tarotWheelOfFortune;

  /// No description provided for @tarotJustice.
  ///
  /// In en, this message translates to:
  /// **'Justice'**
  String get tarotJustice;

  /// No description provided for @tarotTheHangedMan.
  ///
  /// In en, this message translates to:
  /// **'The Hanged Man'**
  String get tarotTheHangedMan;

  /// No description provided for @tarotDeath.
  ///
  /// In en, this message translates to:
  /// **'Death'**
  String get tarotDeath;

  /// No description provided for @tarotTemperance.
  ///
  /// In en, this message translates to:
  /// **'Temperance'**
  String get tarotTemperance;

  /// No description provided for @tarotTheDevil.
  ///
  /// In en, this message translates to:
  /// **'The Devil'**
  String get tarotTheDevil;

  /// No description provided for @tarotTheTower.
  ///
  /// In en, this message translates to:
  /// **'The Tower'**
  String get tarotTheTower;

  /// No description provided for @tarotTheStar.
  ///
  /// In en, this message translates to:
  /// **'The Star'**
  String get tarotTheStar;

  /// No description provided for @tarotTheMoon.
  ///
  /// In en, this message translates to:
  /// **'The Moon'**
  String get tarotTheMoon;

  /// No description provided for @tarotTheSun.
  ///
  /// In en, this message translates to:
  /// **'The Sun'**
  String get tarotTheSun;

  /// No description provided for @tarotJudgement.
  ///
  /// In en, this message translates to:
  /// **'Judgement'**
  String get tarotJudgement;

  /// No description provided for @tarotTheWorld.
  ///
  /// In en, this message translates to:
  /// **'The World'**
  String get tarotTheWorld;

  /// No description provided for @omikujiDaikichi.
  ///
  /// In en, this message translates to:
  /// **'Great blessing (Daikichi)'**
  String get omikujiDaikichi;

  /// No description provided for @omikujiChukichi.
  ///
  /// In en, this message translates to:
  /// **'Middle blessing (Chūkichi)'**
  String get omikujiChukichi;

  /// No description provided for @omikujiShokichi.
  ///
  /// In en, this message translates to:
  /// **'Small blessing (Shōkichi)'**
  String get omikujiShokichi;

  /// No description provided for @omikujiKichi.
  ///
  /// In en, this message translates to:
  /// **'Blessing (Kichi)'**
  String get omikujiKichi;

  /// No description provided for @omikujiHankichi.
  ///
  /// In en, this message translates to:
  /// **'Half blessing (Hankichi)'**
  String get omikujiHankichi;

  /// No description provided for @omikujiSuekichi.
  ///
  /// In en, this message translates to:
  /// **'Future blessing (Suekichi)'**
  String get omikujiSuekichi;

  /// No description provided for @omikujiKyo.
  ///
  /// In en, this message translates to:
  /// **'Curse (Kyō)'**
  String get omikujiKyo;

  /// No description provided for @omikujiDaikyo.
  ///
  /// In en, this message translates to:
  /// **'Great curse (Daikyō)'**
  String get omikujiDaikyo;

  /// No description provided for @taskTypeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get taskTypeWater;

  /// No description provided for @taskTypeFertilize.
  ///
  /// In en, this message translates to:
  /// **'Fertilize'**
  String get taskTypeFertilize;

  /// No description provided for @taskTypeMist.
  ///
  /// In en, this message translates to:
  /// **'Mist'**
  String get taskTypeMist;

  /// No description provided for @taskTypeRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get taskTypeRotate;

  /// No description provided for @taskTypePrune.
  ///
  /// In en, this message translates to:
  /// **'Prune'**
  String get taskTypePrune;

  /// No description provided for @taskTypeRepot.
  ///
  /// In en, this message translates to:
  /// **'Repot'**
  String get taskTypeRepot;

  /// No description provided for @taskTypeCheckPests.
  ///
  /// In en, this message translates to:
  /// **'Check pests'**
  String get taskTypeCheckPests;

  /// No description provided for @taskTypeWipeLeaves.
  ///
  /// In en, this message translates to:
  /// **'Wipe leaves'**
  String get taskTypeWipeLeaves;

  /// No description provided for @taskTypeSunlightAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Sunlight adjustment'**
  String get taskTypeSunlightAdjustment;

  /// No description provided for @notificationsTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'{plant} · {task}'**
  String notificationsTaskTitle(String plant, String task);

  /// No description provided for @notificationsTaskBodyRoom.
  ///
  /// In en, this message translates to:
  /// **'In {room}'**
  String notificationsTaskBodyRoom(String room);

  /// No description provided for @notificationsTaskBodyNoRoom.
  ///
  /// In en, this message translates to:
  /// **'Open Botanica to mark it done.'**
  String get notificationsTaskBodyNoRoom;

  /// No description provided for @notificationWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to water {plant}'**
  String notificationWaterTitle(String plant);

  /// No description provided for @notificationFertilizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertilize {plant} today'**
  String notificationFertilizeTitle(String plant);

  /// No description provided for @notificationMistTitle.
  ///
  /// In en, this message translates to:
  /// **'{plant} would love some misting'**
  String notificationMistTitle(String plant);

  /// No description provided for @notificationRotateTitle.
  ///
  /// In en, this message translates to:
  /// **'Give {plant} a quarter turn'**
  String notificationRotateTitle(String plant);

  /// No description provided for @notificationPruneTitle.
  ///
  /// In en, this message translates to:
  /// **'{plant} is ready for pruning'**
  String notificationPruneTitle(String plant);

  /// No description provided for @reasonHumidityLow.
  ///
  /// In en, this message translates to:
  /// **'Low humidity → soil dries faster'**
  String get reasonHumidityLow;

  /// No description provided for @reasonHumidityHigh.
  ///
  /// In en, this message translates to:
  /// **'High humidity → soil stays moist longer'**
  String get reasonHumidityHigh;

  /// No description provided for @reasonHot.
  ///
  /// In en, this message translates to:
  /// **'Warm temperature → higher evaporation'**
  String get reasonHot;

  /// No description provided for @reasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring season → active growth'**
  String get reasonSpring;

  /// No description provided for @reasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer heat → more frequent watering'**
  String get reasonSummer;

  /// No description provided for @reasonAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn season → easing into dormancy'**
  String get reasonAutumn;

  /// No description provided for @reasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter season → slower growth'**
  String get reasonWinter;

  /// No description provided for @reasonOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor mode → forecast weighted more'**
  String get reasonOutdoor;

  /// No description provided for @reasonIndoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor mode → stable conditions assumed'**
  String get reasonIndoor;

  /// No description provided for @envLightLow.
  ///
  /// In en, this message translates to:
  /// **'Low Light'**
  String get envLightLow;

  /// No description provided for @envLightMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Light'**
  String get envLightMedium;

  /// No description provided for @envLightHigh.
  ///
  /// In en, this message translates to:
  /// **'High Light'**
  String get envLightHigh;

  /// No description provided for @envLabelTemp.
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get envLabelTemp;

  /// No description provided for @envLabelHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get envLabelHumidity;

  /// No description provided for @envLabelLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get envLabelLight;

  /// No description provided for @gardenWellnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Wellness'**
  String get gardenWellnessTitle;

  /// No description provided for @gardenWellnessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See score, focus plants, and care load'**
  String get gardenWellnessSubtitle;

  /// No description provided for @gardenWellnessEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No plants yet'**
  String get gardenWellnessEmptyTitle;

  /// No description provided for @gardenFilterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No plants match your filter.'**
  String get gardenFilterEmptyTitle;

  /// No description provided for @gardenWellnessEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first plant to unlock garden wellness.'**
  String get gardenWellnessEmptyBody;

  /// No description provided for @gardenWellnessOverallScore.
  ///
  /// In en, this message translates to:
  /// **'Overall score'**
  String get gardenWellnessOverallScore;

  /// No description provided for @gardenWellnessOverdueChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue} other{{count} overdue}}'**
  String gardenWellnessOverdueChip(int count);

  /// No description provided for @gardenWellnessStatPlants.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get gardenWellnessStatPlants;

  /// No description provided for @gardenWellnessStatRecentCare.
  ///
  /// In en, this message translates to:
  /// **'Recent care'**
  String get gardenWellnessStatRecentCare;

  /// No description provided for @gardenWellnessStatAtRisk.
  ///
  /// In en, this message translates to:
  /// **'At risk'**
  String get gardenWellnessStatAtRisk;

  /// No description provided for @gardenWellnessRoomPulseTitle.
  ///
  /// In en, this message translates to:
  /// **'Room pulse'**
  String get gardenWellnessRoomPulseTitle;

  /// No description provided for @gardenWellnessRoomPulseSummary.
  ///
  /// In en, this message translates to:
  /// **'{plantCount} plants · {overdueCount} overdue'**
  String gardenWellnessRoomPulseSummary(int plantCount, int overdueCount);

  /// No description provided for @gardenWellnessRoomPulseStable.
  ///
  /// In en, this message translates to:
  /// **'stable'**
  String get gardenWellnessRoomPulseStable;

  /// No description provided for @gardenWellnessRoomPulseAtRisk.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 at risk} other{{count} at risk}}'**
  String gardenWellnessRoomPulseAtRisk(int count);

  /// No description provided for @gardenWellnessPrioritiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s priorities'**
  String get gardenWellnessPrioritiesTitle;

  /// No description provided for @gardenWellnessFocusPlantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus plants'**
  String get gardenWellnessFocusPlantsTitle;

  /// No description provided for @gardenWellnessScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'score'**
  String get gardenWellnessScoreLabel;

  /// No description provided for @gardenWellnessScoreFlourishing.
  ///
  /// In en, this message translates to:
  /// **'Flourishing'**
  String get gardenWellnessScoreFlourishing;

  /// No description provided for @gardenWellnessScoreSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get gardenWellnessScoreSteady;

  /// No description provided for @gardenWellnessScoreNeedsLittleCare.
  ///
  /// In en, this message translates to:
  /// **'Needs a little care'**
  String get gardenWellnessScoreNeedsLittleCare;

  /// No description provided for @gardenWellnessScoreNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get gardenWellnessScoreNeedsAttention;

  /// No description provided for @gardenWellnessFocusReasonOverdueAndNoLog.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue task · No recent log} other{{count} overdue tasks · No recent log}}'**
  String gardenWellnessFocusReasonOverdueAndNoLog(int count);

  /// No description provided for @gardenWellnessFocusReasonOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue task} other{{count} overdue tasks}}'**
  String gardenWellnessFocusReasonOverdue(int count);

  /// No description provided for @gardenWellnessFocusReasonNoLog.
  ///
  /// In en, this message translates to:
  /// **'No recent log in 14 days'**
  String get gardenWellnessFocusReasonNoLog;

  /// No description provided for @gardenWellnessFocusReasonSteady.
  ///
  /// In en, this message translates to:
  /// **'Looking steady'**
  String get gardenWellnessFocusReasonSteady;

  /// No description provided for @gardenWellnessPriorityAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Check on {plantName}'**
  String gardenWellnessPriorityAttentionTitle(String plantName);

  /// No description provided for @gardenWellnessPriorityAttentionBodyOverdueAndNoLog.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue task and no recent log.} other{{count} overdue tasks and no recent log.}}'**
  String gardenWellnessPriorityAttentionBodyOverdueAndNoLog(int count);

  /// No description provided for @gardenWellnessPriorityAttentionBodyOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue task needs attention.} other{{count} overdue tasks need attention.}}'**
  String gardenWellnessPriorityAttentionBodyOverdue(int count);

  /// No description provided for @gardenWellnessPriorityAttentionBodyNoLog.
  ///
  /// In en, this message translates to:
  /// **'No recent log in the last 14 days.'**
  String get gardenWellnessPriorityAttentionBodyNoLog;

  /// No description provided for @gardenWellnessPriorityAttentionBodyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'This plant needs a quick check-in.'**
  String get gardenWellnessPriorityAttentionBodyCheckIn;

  /// No description provided for @gardenWellnessPriorityDueTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep today on track'**
  String get gardenWellnessPriorityDueTodayTitle;

  /// No description provided for @gardenWellnessPriorityDueTodayBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task is due today.} other{{count} tasks are due today.}}'**
  String gardenWellnessPriorityDueTodayBody(int count);

  /// No description provided for @gardenWellnessPriorityRefreshHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh care history'**
  String get gardenWellnessPriorityRefreshHistoryTitle;

  /// No description provided for @gardenWellnessPriorityRefreshHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 plant is missing a recent log.} other{{count} plants are missing a recent log.}}'**
  String gardenWellnessPriorityRefreshHistoryBody(int count);

  /// No description provided for @gardenWellnessPriorityCalmTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the calm'**
  String get gardenWellnessPriorityCalmTitle;

  /// No description provided for @gardenWellnessPriorityCalmBody.
  ///
  /// In en, this message translates to:
  /// **'No urgent issues today — your garden looks steady.'**
  String get gardenWellnessPriorityCalmBody;

  /// No description provided for @gardenWellnessRoomUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get gardenWellnessRoomUnassigned;

  /// No description provided for @editPlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Plant'**
  String get editPlantTitle;

  /// No description provided for @editPlantSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editPlantSaveButton;

  /// No description provided for @plantDetailMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit plant'**
  String get plantDetailMenuEdit;

  /// No description provided for @plantDetailMenuArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive plant'**
  String get plantDetailMenuArchive;

  /// No description provided for @plantDetailMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete plant'**
  String get plantDetailMenuDelete;

  /// No description provided for @archivePlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive {plantName}?'**
  String archivePlantTitle(String plantName);

  /// No description provided for @archivePlantBody.
  ///
  /// In en, this message translates to:
  /// **'Archived plants are hidden from your garden but keep their history.'**
  String get archivePlantBody;

  /// No description provided for @archivePlantConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archivePlantConfirm;

  /// No description provided for @deletePlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {plantName}?'**
  String deletePlantTitle(String plantName);

  /// No description provided for @deletePlantBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the plant and all its history. This cannot be undone.'**
  String get deletePlantBody;

  /// No description provided for @deletePlantConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePlantConfirm;

  /// No description provided for @restorePlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore {plantName}?'**
  String restorePlantTitle(String plantName);

  /// No description provided for @restorePlantBody.
  ///
  /// In en, this message translates to:
  /// **'This will return the plant to your garden and resume its care schedule.'**
  String get restorePlantBody;

  /// No description provided for @restorePlantConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restorePlantConfirm;

  /// No description provided for @gardenStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get gardenStatusArchived;

  /// No description provided for @gardenSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get gardenSortTitle;

  /// Filter option for archived plants
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get gardenFilterArchived;

  /// No description provided for @gardenSortCare.
  ///
  /// In en, this message translates to:
  /// **'Care needs'**
  String get gardenSortCare;

  /// Sort option by name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get gardenSortName;

  /// Sort option by newest
  ///
  /// In en, this message translates to:
  /// **'Newest added'**
  String get gardenSortNewest;

  /// Sort option by species
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get gardenSortSpecies;

  /// Sort option by needing care
  ///
  /// In en, this message translates to:
  /// **'Needs care'**
  String get gardenSortNeedsCare;

  /// Filter option for all plants
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get gardenFilterAll;

  /// Filter option for healthy plants
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get gardenFilterHealthy;

  /// Filter option for plants needing care
  ///
  /// In en, this message translates to:
  /// **'Needs care'**
  String get gardenFilterNeedsCare;

  /// Hint text for garden search
  ///
  /// In en, this message translates to:
  /// **'Search garden...'**
  String get gardenSearchHint;

  /// No description provided for @archivePlantSuccess.
  ///
  /// In en, this message translates to:
  /// **'{nickname} archived.'**
  String archivePlantSuccess(String nickname);

  /// No description provided for @restorePlantSuccess.
  ///
  /// In en, this message translates to:
  /// **'{nickname} restored.'**
  String restorePlantSuccess(String nickname);

  /// No description provided for @deletePlantSuccess.
  ///
  /// In en, this message translates to:
  /// **'{nickname} deleted.'**
  String deletePlantSuccess(String nickname);

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
