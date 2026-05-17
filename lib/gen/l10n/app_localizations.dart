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

  /// No description provided for @commonErrorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonErrorTryAgain;

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

  /// No description provided for @calendarWeekAheadTitle.
  ///
  /// In en, this message translates to:
  /// **'Week ahead'**
  String get calendarWeekAheadTitle;

  /// Total tasks in the upcoming week
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String calendarWeekAheadCount(int count);

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

  /// No description provided for @gardenGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get gardenGreetingMorning;

  /// No description provided for @gardenGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get gardenGreetingAfternoon;

  /// No description provided for @gardenGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get gardenGreetingEvening;

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

  /// No description provided for @gardenAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up! Your plants are happy.'**
  String get gardenAllCaughtUp;

  /// No description provided for @allDoneQuietRunway.
  ///
  /// In en, this message translates to:
  /// **'Nothing due for {days} days'**
  String allDoneQuietRunway(int days);

  /// No description provided for @allDoneTomorrowPreview.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow · {count} tasks for {plants}'**
  String allDoneTomorrowPreview(int count, String plants);

  /// No description provided for @gardenVacationBanner.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode — reminders paused'**
  String get gardenVacationBanner;

  /// No description provided for @gardenWeeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get gardenWeeklySummaryTitle;

  /// No description provided for @gardenWeeklyCareActions.
  ///
  /// In en, this message translates to:
  /// **'{count} care actions'**
  String gardenWeeklyCareActions(int count);

  /// No description provided for @gardenWeeklyWatered.
  ///
  /// In en, this message translates to:
  /// **'{count} watered'**
  String gardenWeeklyWatered(int count);

  /// No description provided for @gardenWeeklyFertilized.
  ///
  /// In en, this message translates to:
  /// **'{count} fertilized'**
  String gardenWeeklyFertilized(int count);

  /// Chip label showing the user's current care streak
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String gardenCareStreakChip(int days);

  /// Warning shown when the user's care streak will break if they don't act today
  ///
  /// In en, this message translates to:
  /// **'Your {days}-day streak ends today — care for a plant to keep it!'**
  String gardenStreakAtRisk(int days);

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

  /// No description provided for @weatherTipRainy.
  ///
  /// In en, this message translates to:
  /// **'Rainy outside — skip watering outdoor plants today'**
  String get weatherTipRainy;

  /// No description provided for @weatherTipStormy.
  ///
  /// In en, this message translates to:
  /// **'Stormy weather — bring sensitive plants indoors'**
  String get weatherTipStormy;

  /// No description provided for @weatherTipExtremeHeat.
  ///
  /// In en, this message translates to:
  /// **'Extreme heat — check soil moisture and mist leaves'**
  String get weatherTipExtremeHeat;

  /// No description provided for @weatherTipHotSunny.
  ///
  /// In en, this message translates to:
  /// **'Hot and sunny — water early morning or evening'**
  String get weatherTipHotSunny;

  /// No description provided for @weatherTipNearFreezing.
  ///
  /// In en, this message translates to:
  /// **'Near freezing — protect frost-sensitive plants'**
  String get weatherTipNearFreezing;

  /// No description provided for @weatherTipSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow expected — move outdoor pots to shelter'**
  String get weatherTipSnow;

  /// No description provided for @weatherTipCool.
  ///
  /// In en, this message translates to:
  /// **'Cool day — reduce watering frequency'**
  String get weatherTipCool;

  /// No description provided for @weatherTipLowHumidity.
  ///
  /// In en, this message translates to:
  /// **'Dry air today — mist tropical plants or group them together'**
  String get weatherTipLowHumidity;

  /// No description provided for @weatherTipHighHumidity.
  ///
  /// In en, this message translates to:
  /// **'High humidity — hold off on misting and watch for fungal issues'**
  String get weatherTipHighHumidity;

  /// No description provided for @seasonalTipSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring is here — time to fertilize and repot if needed'**
  String get seasonalTipSpring;

  /// No description provided for @seasonalTipSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer heat means more frequent watering for most plants'**
  String get seasonalTipSummer;

  /// No description provided for @seasonalTipAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn — reduce fertilizing as plants slow their growth'**
  String get seasonalTipAutumn;

  /// No description provided for @seasonalTipWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter — most plants need less water and no fertilizer'**
  String get seasonalTipWinter;

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

  /// No description provided for @gardenQuickLogCare.
  ///
  /// In en, this message translates to:
  /// **'Log care'**
  String get gardenQuickLogCare;

  /// No description provided for @gardenQuickLogDone.
  ///
  /// In en, this message translates to:
  /// **'Logged!'**
  String get gardenQuickLogDone;

  /// No description provided for @gardenViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get gardenViewDetails;

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

  /// No description provided for @profilePlantsInGarden.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 plant in your garden} other{{count} plants in your garden}}'**
  String profilePlantsInGarden(int count);

  /// No description provided for @discoverInYourGarden.
  ///
  /// In en, this message translates to:
  /// **'in your garden'**
  String get discoverInYourGarden;

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

  /// Shows how many days the user has been caring for this plant
  ///
  /// In en, this message translates to:
  /// **'Caring for {days} days'**
  String plantDetailCaringForDays(int days);

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

  /// No description provided for @discoverPlantOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Plant of the Day'**
  String get discoverPlantOfTheDay;

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

  /// No description provided for @discoverAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get discoverAddFavorite;

  /// No description provided for @discoverRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get discoverRemoveFavorite;

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

  /// No description provided for @exportDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Export care data'**
  String get exportDataTitle;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your plants and care history as a JSON file.'**
  String get exportDataSubtitle;

  /// No description provided for @exportDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Care data exported successfully.'**
  String get exportDataSuccess;

  /// No description provided for @exportDataEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data to export yet — add some plants first.'**
  String get exportDataEmpty;

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

  /// No description provided for @vacationModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode'**
  String get vacationModeTitle;

  /// No description provided for @vacationModeOff.
  ///
  /// In en, this message translates to:
  /// **'Pause all reminders while you\'re away.'**
  String get vacationModeOff;

  /// Vacation mode active subtitle
  ///
  /// In en, this message translates to:
  /// **'Active until {date}'**
  String vacationModeActiveUntil(String date);

  /// No description provided for @vacationModeEnd.
  ///
  /// In en, this message translates to:
  /// **'End vacation mode'**
  String get vacationModeEnd;

  /// No description provided for @vacationModePickDate.
  ///
  /// In en, this message translates to:
  /// **'Return date'**
  String get vacationModePickDate;

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

  /// No description provided for @notificationWaterTitle2.
  ///
  /// In en, this message translates to:
  /// **'{plant} is getting thirsty!'**
  String notificationWaterTitle2(String plant);

  /// No description provided for @notificationWaterTitle3.
  ///
  /// In en, this message translates to:
  /// **'Your {plant} needs a drink'**
  String notificationWaterTitle3(String plant);

  /// No description provided for @notificationFertilizeTitle2.
  ///
  /// In en, this message translates to:
  /// **'{plant} could use some nutrients'**
  String notificationFertilizeTitle2(String plant);

  /// No description provided for @notificationFertilizeTitle3.
  ///
  /// In en, this message translates to:
  /// **'Feeding time for {plant}'**
  String notificationFertilizeTitle3(String plant);

  /// No description provided for @notificationMistTitle2.
  ///
  /// In en, this message translates to:
  /// **'A little humidity boost for {plant}?'**
  String notificationMistTitle2(String plant);

  /// No description provided for @notificationMistTitle3.
  ///
  /// In en, this message translates to:
  /// **'Time to mist {plant}'**
  String notificationMistTitle3(String plant);

  /// No description provided for @notificationRotateTitle2.
  ///
  /// In en, this message translates to:
  /// **'Rotate {plant} for even growth'**
  String notificationRotateTitle2(String plant);

  /// No description provided for @notificationRotateTitle3.
  ///
  /// In en, this message translates to:
  /// **'{plant} needs a turn today'**
  String notificationRotateTitle3(String plant);

  /// No description provided for @notificationPruneTitle2.
  ///
  /// In en, this message translates to:
  /// **'Time to tidy up {plant}'**
  String notificationPruneTitle2(String plant);

  /// No description provided for @notificationPruneTitle3.
  ///
  /// In en, this message translates to:
  /// **'{plant} could use a trim'**
  String notificationPruneTitle3(String plant);

  /// No description provided for @notificationDailySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Good morning, plant parent!'**
  String get notificationDailySummaryTitle;

  /// No description provided for @notificationDailySummaryBody.
  ///
  /// In en, this message translates to:
  /// **'You have {count} care tasks today. Your plants are counting on you!'**
  String notificationDailySummaryBody(int count);

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

  /// No description provided for @gardenWellnessStatPunctuality.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get gardenWellnessStatPunctuality;

  /// No description provided for @gardenWellnessStatWeeklyActive.
  ///
  /// In en, this message translates to:
  /// **'Weekly active'**
  String get gardenWellnessStatWeeklyActive;

  /// No description provided for @gardenWellnessStatBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get gardenWellnessStatBestStreak;

  /// No description provided for @gardenWellnessMomentumIncreasing.
  ///
  /// In en, this message translates to:
  /// **'Momentum rising'**
  String get gardenWellnessMomentumIncreasing;

  /// No description provided for @gardenWellnessMomentumDecreasing.
  ///
  /// In en, this message translates to:
  /// **'Momentum dipping'**
  String get gardenWellnessMomentumDecreasing;

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

  /// Sort option by plant health score (lowest first)
  ///
  /// In en, this message translates to:
  /// **'Health score'**
  String get gardenSortHealth;

  /// Sort option by room
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get gardenSortRoom;

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

  /// No description provided for @streakMilestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{days}-Day Milestone!'**
  String streakMilestoneTitle(int days);

  /// No description provided for @streakMilestoneBody7.
  ///
  /// In en, this message translates to:
  /// **'A full week of plant care. Your garden thanks you.'**
  String get streakMilestoneBody7;

  /// No description provided for @streakMilestoneBody30.
  ///
  /// In en, this message translates to:
  /// **'30 days strong. You\'re building a real habit.'**
  String get streakMilestoneBody30;

  /// No description provided for @streakMilestoneBody90.
  ///
  /// In en, this message translates to:
  /// **'90 days! Your plants have never been happier.'**
  String get streakMilestoneBody90;

  /// No description provided for @streakMilestoneBody365.
  ///
  /// In en, this message translates to:
  /// **'A full year of care. You\'re a plant legend.'**
  String get streakMilestoneBody365;

  /// No description provided for @streakMilestoneDismiss.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get streakMilestoneDismiss;

  /// No description provided for @timeCapsuleTitle.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago today'**
  String timeCapsuleTitle(int days);

  /// No description provided for @timeCapsuleBody.
  ///
  /// In en, this message translates to:
  /// **'You took this photo of {plant} {days} days ago. Look how far you’ve come together.'**
  String timeCapsuleBody(String plant, int days);

  /// No description provided for @rescueResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get rescueResetTitle;

  /// No description provided for @rescueResetBody.
  ///
  /// In en, this message translates to:
  /// **'You had a {streak}-day streak going. It\'s been {days} days — no guilt, just a fresh start whenever you\'re ready.'**
  String rescueResetBody(int streak, int days);

  /// No description provided for @rescueResetWaterNow.
  ///
  /// In en, this message translates to:
  /// **'Water a plant now'**
  String get rescueResetWaterNow;

  /// No description provided for @rescueResetFreshStart.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get rescueResetFreshStart;

  /// No description provided for @streakSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Streak saved! {plant} cared for · {days}-day rhythm intact'**
  String streakSavedSnackbar(String plant, int days);

  /// No description provided for @plantPulseTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for a check-in'**
  String get plantPulseTitle;

  /// No description provided for @plantPulseBody.
  ///
  /// In en, this message translates to:
  /// **'{plant} hasn\'t had a photo in {days} days. See how it\'s grown.'**
  String plantPulseBody(String plant, int days);

  /// No description provided for @plantPulseCta.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get plantPulseCta;

  /// No description provided for @plantJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey together'**
  String get plantJourneyTitle;

  /// No description provided for @plantJourneyNextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Next: {milestone}'**
  String plantJourneyNextMilestone(String milestone);

  /// No description provided for @plantJourneyMilestoneFirstWater.
  ///
  /// In en, this message translates to:
  /// **'First watering'**
  String get plantJourneyMilestoneFirstWater;

  /// No description provided for @plantJourneyMilestoneFirstPhoto.
  ///
  /// In en, this message translates to:
  /// **'First photo'**
  String get plantJourneyMilestoneFirstPhoto;

  /// No description provided for @plantJourneyMilestone7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days together'**
  String get plantJourneyMilestone7Days;

  /// No description provided for @plantJourneyMilestoneFirstFertilize.
  ///
  /// In en, this message translates to:
  /// **'First fertilize'**
  String get plantJourneyMilestoneFirstFertilize;

  /// No description provided for @plantJourneyMilestone10Waters.
  ///
  /// In en, this message translates to:
  /// **'10 waterings'**
  String get plantJourneyMilestone10Waters;

  /// No description provided for @plantJourneyMilestone30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days together'**
  String get plantJourneyMilestone30Days;

  /// No description provided for @plantJourneyMilestone25Waters.
  ///
  /// In en, this message translates to:
  /// **'25 waterings'**
  String get plantJourneyMilestone25Waters;

  /// No description provided for @plantJourneyMilestone100Days.
  ///
  /// In en, this message translates to:
  /// **'100 days together'**
  String get plantJourneyMilestone100Days;

  /// No description provided for @plantJourneyMilestone365Days.
  ///
  /// In en, this message translates to:
  /// **'1 year together'**
  String get plantJourneyMilestone365Days;

  /// No description provided for @gardenerTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your gardener type'**
  String get gardenerTypeTitle;

  /// No description provided for @gardenerTypeDevoted.
  ///
  /// In en, this message translates to:
  /// **'The Devoted'**
  String get gardenerTypeDevoted;

  /// No description provided for @gardenerTypeDevotedDesc.
  ///
  /// In en, this message translates to:
  /// **'30+ days of unbroken care. Your plants adore you.'**
  String get gardenerTypeDevotedDesc;

  /// No description provided for @gardenerTypeConsistent.
  ///
  /// In en, this message translates to:
  /// **'The Consistent'**
  String get gardenerTypeConsistent;

  /// No description provided for @gardenerTypeConsistentDesc.
  ///
  /// In en, this message translates to:
  /// **'Over 80% of tasks done on time. Reliable as clockwork.'**
  String get gardenerTypeConsistentDesc;

  /// No description provided for @gardenerTypeExplorer.
  ///
  /// In en, this message translates to:
  /// **'The Explorer'**
  String get gardenerTypeExplorer;

  /// No description provided for @gardenerTypeExplorerDesc.
  ///
  /// In en, this message translates to:
  /// **'5+ species in your collection. A true plant explorer.'**
  String get gardenerTypeExplorerDesc;

  /// No description provided for @gardenerTypePhotographer.
  ///
  /// In en, this message translates to:
  /// **'The Photographer'**
  String get gardenerTypePhotographer;

  /// No description provided for @gardenerTypePhotographerDesc.
  ///
  /// In en, this message translates to:
  /// **'10+ photos documenting growth. Every leaf tells a story.'**
  String get gardenerTypePhotographerDesc;

  /// No description provided for @gardenerTypeNurturer.
  ///
  /// In en, this message translates to:
  /// **'The Nurturer'**
  String get gardenerTypeNurturer;

  /// No description provided for @gardenerTypeNurturerDesc.
  ///
  /// In en, this message translates to:
  /// **'50+ care actions. Your garden thrives on your attention.'**
  String get gardenerTypeNurturerDesc;

  /// No description provided for @gardenerTypeBudding.
  ///
  /// In en, this message translates to:
  /// **'The Budding Gardener'**
  String get gardenerTypeBudding;

  /// No description provided for @gardenerTypeBuddingDesc.
  ///
  /// In en, this message translates to:
  /// **'Every expert was once a beginner. Keep growing!'**
  String get gardenerTypeBuddingDesc;

  /// No description provided for @whispererTierSeedling.
  ///
  /// In en, this message translates to:
  /// **'Seedling'**
  String get whispererTierSeedling;

  /// No description provided for @whispererTierSprout.
  ///
  /// In en, this message translates to:
  /// **'Sprout'**
  String get whispererTierSprout;

  /// No description provided for @whispererTierGardener.
  ///
  /// In en, this message translates to:
  /// **'Gardener'**
  String get whispererTierGardener;

  /// No description provided for @whispererTierBotanist.
  ///
  /// In en, this message translates to:
  /// **'Botanist'**
  String get whispererTierBotanist;

  /// No description provided for @whispererTierWhisperer.
  ///
  /// In en, this message translates to:
  /// **'Plant Whisperer'**
  String get whispererTierWhisperer;

  /// No description provided for @whispererNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to next level'**
  String whispererNextLevel(int xp);

  /// No description provided for @careCombo.
  ///
  /// In en, this message translates to:
  /// **'{count}x combo!'**
  String careCombo(int count);

  /// No description provided for @careComboStreak.
  ///
  /// In en, this message translates to:
  /// **'{count}x combo! You\'re on fire!'**
  String careComboStreak(int count);

  /// No description provided for @lastCareWater.
  ///
  /// In en, this message translates to:
  /// **'Watered'**
  String get lastCareWater;

  /// No description provided for @lastCareFertilize.
  ///
  /// In en, this message translates to:
  /// **'Fertilized'**
  String get lastCareFertilize;

  /// No description provided for @lastCarePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get lastCarePhoto;

  /// No description provided for @lastCareDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String lastCareDaysAgo(int days);

  /// No description provided for @lastCareToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get lastCareToday;

  /// No description provided for @lastCareNever.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get lastCareNever;

  /// No description provided for @careConfidenceOnSchedule.
  ///
  /// In en, this message translates to:
  /// **'Right on schedule (avg {days} days)'**
  String careConfidenceOnSchedule(int days);

  /// No description provided for @careConfidenceEarly.
  ///
  /// In en, this message translates to:
  /// **'A bit early — soil might still be moist'**
  String get careConfidenceEarly;

  /// No description provided for @careConfidenceLate.
  ///
  /// In en, this message translates to:
  /// **'A bit late, but no worries'**
  String get careConfidenceLate;

  /// No description provided for @gardenMoodThriving.
  ///
  /// In en, this message translates to:
  /// **'Thriving'**
  String get gardenMoodThriving;

  /// No description provided for @gardenMoodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get gardenMoodHappy;

  /// No description provided for @gardenMoodNeedsLove.
  ///
  /// In en, this message translates to:
  /// **'Needs love'**
  String get gardenMoodNeedsLove;

  /// No description provided for @gardenMoodThirsty.
  ///
  /// In en, this message translates to:
  /// **'Thirsty'**
  String get gardenMoodThirsty;

  /// No description provided for @plantDetailLogsSparklineTitle.
  ///
  /// In en, this message translates to:
  /// **'14-Day Activity'**
  String get plantDetailLogsSparklineTitle;

  /// No description provided for @plantDetailLogsSparklineCount.
  ///
  /// In en, this message translates to:
  /// **'{count} actions'**
  String plantDetailLogsSparklineCount(int count);

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @calendarHeatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'12-Week Activity'**
  String get calendarHeatmapTitle;

  /// No description provided for @profileStatsTotalCare.
  ///
  /// In en, this message translates to:
  /// **'Total Care'**
  String get profileStatsTotalCare;

  /// No description provided for @profileStatsWatered.
  ///
  /// In en, this message translates to:
  /// **'Watered'**
  String get profileStatsWatered;

  /// No description provided for @profileStatsFertilized.
  ///
  /// In en, this message translates to:
  /// **'Fertilized'**
  String get profileStatsFertilized;

  /// No description provided for @profileStatsActions.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String profileStatsActions(int count);

  /// No description provided for @profileCareScore.
  ///
  /// In en, this message translates to:
  /// **'Care Score'**
  String get profileCareScore;

  /// No description provided for @profileCareScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String profileCareScoreLabel(int percent);

  /// No description provided for @profileCareScoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days on-time rate'**
  String get profileCareScoreSubtitle;

  /// No description provided for @weeklyRecapTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Week in Review'**
  String get weeklyRecapTitle;

  /// No description provided for @weeklyRecapActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get weeklyRecapActiveDays;

  /// No description provided for @weeklyRecapSummary.
  ///
  /// In en, this message translates to:
  /// **'{actions} care actions across {days} active days this week'**
  String weeklyRecapSummary(int actions, int days);

  /// No description provided for @weeklyRecapDismiss.
  ///
  /// In en, this message translates to:
  /// **'Nice work!'**
  String get weeklyRecapDismiss;

  /// No description provided for @weeklyRecapBestDay.
  ///
  /// In en, this message translates to:
  /// **'Best day: {day}'**
  String weeklyRecapBestDay(String day);

  /// No description provided for @weeklyRecapStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak: {days} days'**
  String weeklyRecapStreak(int days);

  /// No description provided for @gardenAllTasksDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'All done for today!'**
  String get gardenAllTasksDoneTitle;

  /// No description provided for @gardenAllTasksDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Every plant is happy. Enjoy the rest of your day.'**
  String get gardenAllTasksDoneBody;

  /// No description provided for @gardenAllDoneBody2.
  ///
  /// In en, this message translates to:
  /// **'Your green friends are thriving thanks to you.'**
  String get gardenAllDoneBody2;

  /// No description provided for @gardenAllDoneBody3.
  ///
  /// In en, this message translates to:
  /// **'Consistency is the secret. You\'ve got it.'**
  String get gardenAllDoneBody3;

  /// No description provided for @gardenAllDoneBody4.
  ///
  /// In en, this message translates to:
  /// **'Another day of great plant parenting.'**
  String get gardenAllDoneBody4;

  /// No description provided for @gardenAllDoneBody5.
  ///
  /// In en, this message translates to:
  /// **'Your plants are growing stronger every day.'**
  String get gardenAllDoneBody5;

  /// No description provided for @profileLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best: {days} days'**
  String profileLongestStreak(int days);

  /// No description provided for @profileGardenAge.
  ///
  /// In en, this message translates to:
  /// **'Garden: {days} days old'**
  String profileGardenAge(int days);

  /// No description provided for @gardenNewPersonalBest.
  ///
  /// In en, this message translates to:
  /// **'New personal best! {days}-day streak'**
  String gardenNewPersonalBest(int days);

  /// No description provided for @gardenTomorrowPreview.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow: {count} {count, plural, =1{plant needs} other{plants need}} care'**
  String gardenTomorrowPreview(int count);

  /// No description provided for @gardenMotivation7DayStreak.
  ///
  /// In en, this message translates to:
  /// **'You\'re on a roll — keep the momentum going.'**
  String get gardenMotivation7DayStreak;

  /// No description provided for @gardenMotivation30DayStreak.
  ///
  /// In en, this message translates to:
  /// **'A month of consistency. Your plants are thriving.'**
  String get gardenMotivation30DayStreak;

  /// No description provided for @gardenMotivationWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back — your plants missed you.'**
  String get gardenMotivationWelcomeBack;

  /// No description provided for @gardenMotivationBigGarden.
  ///
  /// In en, this message translates to:
  /// **'A flourishing collection. You\'ve got this.'**
  String get gardenMotivationBigGarden;

  /// No description provided for @gardenMotivationMorning.
  ///
  /// In en, this message translates to:
  /// **'A great day to check on your green friends.'**
  String get gardenMotivationMorning;

  /// No description provided for @gardenMotivationEvening.
  ///
  /// In en, this message translates to:
  /// **'Wind down with a quick garden check.'**
  String get gardenMotivationEvening;

  /// No description provided for @gardenMotivationAllDoneToday.
  ///
  /// In en, this message translates to:
  /// **'All caught up — your plants are happy.'**
  String get gardenMotivationAllDoneToday;

  /// No description provided for @gardenMotivationNewPlant.
  ///
  /// In en, this message translates to:
  /// **'Your newest plant is settling in nicely.'**
  String get gardenMotivationNewPlant;

  /// No description provided for @gardenStreakFreezeUsed.
  ///
  /// In en, this message translates to:
  /// **'Streak freeze used! Your {days}-day streak is safe.'**
  String gardenStreakFreezeUsed(int days);

  /// No description provided for @gardenStreakFreezeEarned.
  ///
  /// In en, this message translates to:
  /// **'You earned a streak freeze! ({count} available)'**
  String gardenStreakFreezeEarned(int count);

  /// No description provided for @profileStreakFreezes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 freeze} other{{count} freezes}} available'**
  String profileStreakFreezes(int count);

  /// No description provided for @gardenPlantMilestone.
  ///
  /// In en, this message translates to:
  /// **'{count} plants in your garden! Your collection is growing beautifully.'**
  String gardenPlantMilestone(int count);

  /// No description provided for @streakShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Your Streak'**
  String get streakShareTitle;

  /// No description provided for @streakShareCardDays.
  ///
  /// In en, this message translates to:
  /// **'{days}-Day Streak'**
  String streakShareCardDays(int days);

  /// No description provided for @streakShareCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Caring for my plants every day'**
  String get streakShareCardSubtitle;

  /// No description provided for @streakShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get streakShareButton;

  /// No description provided for @plantLastWateredToday.
  ///
  /// In en, this message translates to:
  /// **'Watered today'**
  String get plantLastWateredToday;

  /// No description provided for @plantLastWateredYesterday.
  ///
  /// In en, this message translates to:
  /// **'Watered yesterday'**
  String get plantLastWateredYesterday;

  /// No description provided for @plantLastWateredDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Watered {days} days ago'**
  String plantLastWateredDaysAgo(int days);

  /// No description provided for @plantNeverWatered.
  ///
  /// In en, this message translates to:
  /// **'Not yet watered'**
  String get plantNeverWatered;

  /// No description provided for @plantAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'{days} days in your garden'**
  String plantAgeLabel(int days);

  /// No description provided for @plantAnniversaryLabel.
  ///
  /// In en, this message translates to:
  /// **'{years}-year anniversary!'**
  String plantAnniversaryLabel(int years);

  /// No description provided for @careLogAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get careLogAddNote;

  /// No description provided for @careLogEditNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get careLogEditNote;

  /// No description provided for @careLogNoteHint.
  ///
  /// In en, this message translates to:
  /// **'How did it look? Anything to remember?'**
  String get careLogNoteHint;

  /// No description provided for @careLogNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get careLogNoteSaved;

  /// No description provided for @careStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Care patterns'**
  String get careStatsTitle;

  /// No description provided for @careStatsTotalWaterings.
  ///
  /// In en, this message translates to:
  /// **'Waterings'**
  String get careStatsTotalWaterings;

  /// No description provided for @careStatsAvgInterval.
  ///
  /// In en, this message translates to:
  /// **'Avg interval'**
  String get careStatsAvgInterval;

  /// No description provided for @careStatsAvgDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String careStatsAvgDays(int days);

  /// No description provided for @careStatsTotalActions.
  ///
  /// In en, this message translates to:
  /// **'Total actions'**
  String get careStatsTotalActions;

  /// No description provided for @careStatsConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get careStatsConsistency;

  /// No description provided for @careStatsTip.
  ///
  /// In en, this message translates to:
  /// **'Try setting a recurring reminder to build a steady routine.'**
  String get careStatsTip;

  /// No description provided for @gardenForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Next 7 Days'**
  String get gardenForecastTitle;

  /// No description provided for @gardenForecastTaskCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String gardenForecastTaskCount(int count);

  /// No description provided for @gardenForecastBusyDay.
  ///
  /// In en, this message translates to:
  /// **'Busiest: {day}'**
  String gardenForecastBusyDay(String day);

  /// No description provided for @gardenForecastEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks scheduled this week'**
  String get gardenForecastEmpty;

  /// No description provided for @gardenForecastToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get gardenForecastToday;

  /// No description provided for @gardenForecastTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get gardenForecastTomorrow;

  /// No description provided for @wellnessHeatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Activity'**
  String get wellnessHeatmapTitle;

  /// No description provided for @wellnessHeatmapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last 12 weeks'**
  String get wellnessHeatmapSubtitle;

  /// No description provided for @wellnessHeatmapActions.
  ///
  /// In en, this message translates to:
  /// **'{count} actions'**
  String wellnessHeatmapActions(int count);

  /// No description provided for @gardenWeeklyTrendUp.
  ///
  /// In en, this message translates to:
  /// **'+{diff} vs last week'**
  String gardenWeeklyTrendUp(int diff);

  /// No description provided for @gardenWeeklyTrendDown.
  ///
  /// In en, this message translates to:
  /// **'{diff} vs last week'**
  String gardenWeeklyTrendDown(int diff);

  /// No description provided for @gardenWeeklyTrendSame.
  ///
  /// In en, this message translates to:
  /// **'Same as last week'**
  String get gardenWeeklyTrendSame;

  /// No description provided for @gardenWeeklyMostActiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most active: {day}'**
  String gardenWeeklyMostActiveDay(String day);

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total} unlocked'**
  String achievementsUnlocked(int count, int total);

  /// No description provided for @achievementFirstPlant.
  ///
  /// In en, this message translates to:
  /// **'First Sprout'**
  String get achievementFirstPlant;

  /// No description provided for @achievementFirstPlantDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your first plant'**
  String get achievementFirstPlantDesc;

  /// No description provided for @achievementFivePlants.
  ///
  /// In en, this message translates to:
  /// **'Growing Collection'**
  String get achievementFivePlants;

  /// No description provided for @achievementFivePlantsDesc.
  ///
  /// In en, this message translates to:
  /// **'Grow your garden to 5 plants'**
  String get achievementFivePlantsDesc;

  /// No description provided for @achievementTenPlants.
  ///
  /// In en, this message translates to:
  /// **'Plant Enthusiast'**
  String get achievementTenPlants;

  /// No description provided for @achievementTenPlantsDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 10 plants in your garden'**
  String get achievementTenPlantsDesc;

  /// No description provided for @achievementTwentyPlants.
  ///
  /// In en, this message translates to:
  /// **'Jungle Master'**
  String get achievementTwentyPlants;

  /// No description provided for @achievementTwentyPlantsDesc.
  ///
  /// In en, this message translates to:
  /// **'Cultivate 20 plants'**
  String get achievementTwentyPlantsDesc;

  /// No description provided for @achievementFirstCare.
  ///
  /// In en, this message translates to:
  /// **'First Drop'**
  String get achievementFirstCare;

  /// No description provided for @achievementFirstCareDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first care task'**
  String get achievementFirstCareDesc;

  /// No description provided for @achievementFiftyCares.
  ///
  /// In en, this message translates to:
  /// **'Dedicated Carer'**
  String get achievementFiftyCares;

  /// No description provided for @achievementFiftyCaresDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 care tasks'**
  String get achievementFiftyCaresDesc;

  /// No description provided for @achievementHundredCares.
  ///
  /// In en, this message translates to:
  /// **'Green Thumb'**
  String get achievementHundredCares;

  /// No description provided for @achievementHundredCaresDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 care tasks'**
  String get achievementHundredCaresDesc;

  /// No description provided for @achievementFiveHundredCares.
  ///
  /// In en, this message translates to:
  /// **'Plant Whisperer'**
  String get achievementFiveHundredCares;

  /// No description provided for @achievementFiveHundredCaresDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 500 care tasks'**
  String get achievementFiveHundredCaresDesc;

  /// No description provided for @achievementWeekStreak.
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get achievementWeekStreak;

  /// No description provided for @achievementWeekStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 7-day care streak'**
  String get achievementWeekStreakDesc;

  /// No description provided for @achievementMonthStreak.
  ///
  /// In en, this message translates to:
  /// **'Monthly Devotion'**
  String get achievementMonthStreak;

  /// No description provided for @achievementMonthStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 30-day care streak'**
  String get achievementMonthStreakDesc;

  /// No description provided for @achievementYearStreak.
  ///
  /// In en, this message translates to:
  /// **'Legendary Gardener'**
  String get achievementYearStreak;

  /// No description provided for @achievementYearStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 365-day care streak'**
  String get achievementYearStreakDesc;

  /// No description provided for @achievementFirstPhoto.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get achievementFirstPhoto;

  /// No description provided for @achievementFirstPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Take your first plant photo'**
  String get achievementFirstPhotoDesc;

  /// No description provided for @achievementTenPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photo Journal'**
  String get achievementTenPhotos;

  /// No description provided for @achievementTenPhotosDesc.
  ///
  /// In en, this message translates to:
  /// **'Capture 10 plant photos'**
  String get achievementTenPhotosDesc;

  /// No description provided for @achievementFiftyPhotos.
  ///
  /// In en, this message translates to:
  /// **'Visual Storyteller'**
  String get achievementFiftyPhotos;

  /// No description provided for @achievementFiftyPhotosDesc.
  ///
  /// In en, this message translates to:
  /// **'Capture 50 plant photos'**
  String get achievementFiftyPhotosDesc;

  /// No description provided for @achievementThreeRooms.
  ///
  /// In en, this message translates to:
  /// **'Room Explorer'**
  String get achievementThreeRooms;

  /// No description provided for @achievementThreeRoomsDesc.
  ///
  /// In en, this message translates to:
  /// **'Place plants in 3 different rooms'**
  String get achievementThreeRoomsDesc;

  /// No description provided for @achievementFiveRooms.
  ///
  /// In en, this message translates to:
  /// **'Whole Home Garden'**
  String get achievementFiveRooms;

  /// No description provided for @achievementFiveRoomsDesc.
  ///
  /// In en, this message translates to:
  /// **'Place plants in 5 different rooms'**
  String get achievementFiveRoomsDesc;

  /// No description provided for @achievementDiverseCarer.
  ///
  /// In en, this message translates to:
  /// **'Renaissance Gardener'**
  String get achievementDiverseCarer;

  /// No description provided for @achievementDiverseCarerDesc.
  ///
  /// In en, this message translates to:
  /// **'Perform 5 different care types'**
  String get achievementDiverseCarerDesc;

  /// No description provided for @tasksCompleteAll.
  ///
  /// In en, this message translates to:
  /// **'Complete all'**
  String get tasksCompleteAll;

  /// No description provided for @tasksCompleteAllDone.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks completed'**
  String tasksCompleteAllDone(int count);

  /// No description provided for @tasksStreakAtRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak at risk!'**
  String get tasksStreakAtRiskTitle;

  /// No description provided for @tasksStreakAtRiskBody.
  ///
  /// In en, this message translates to:
  /// **'Your {days}-day streak ends tonight. Complete a task to keep it alive.'**
  String tasksStreakAtRiskBody(int days);

  /// No description provided for @plantMilestoneOneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month together!'**
  String get plantMilestoneOneMonth;

  /// No description provided for @plantMilestoneThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months together!'**
  String get plantMilestoneThreeMonths;

  /// No description provided for @plantMilestoneSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Half a year of care!'**
  String get plantMilestoneSixMonths;

  /// No description provided for @plantMilestoneOneYear.
  ///
  /// In en, this message translates to:
  /// **'1 year anniversary!'**
  String get plantMilestoneOneYear;

  /// No description provided for @plantMilestoneTwoYears.
  ///
  /// In en, this message translates to:
  /// **'2 years of growth!'**
  String get plantMilestoneTwoYears;

  /// No description provided for @plantMilestoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been caring for {name} for {days} days'**
  String plantMilestoneSubtitle(String name, int days);

  /// No description provided for @seasonalTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Tip'**
  String get seasonalTipTitle;

  /// No description provided for @seasonalTipSpringRepotTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to repot'**
  String get seasonalTipSpringRepotTitle;

  /// No description provided for @seasonalTipSpringRepotBody.
  ///
  /// In en, this message translates to:
  /// **'Spring is the best time to repot. Plants are entering their growth phase and will recover quickly from the stress.'**
  String get seasonalTipSpringRepotBody;

  /// No description provided for @seasonalTipSpringFertilizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume feeding'**
  String get seasonalTipSpringFertilizeTitle;

  /// No description provided for @seasonalTipSpringFertilizeBody.
  ///
  /// In en, this message translates to:
  /// **'Start fertilizing again as days get longer. Begin with half-strength and increase gradually over a few weeks.'**
  String get seasonalTipSpringFertilizeBody;

  /// No description provided for @seasonalTipSpringGrowthTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch for new growth'**
  String get seasonalTipSpringGrowthTitle;

  /// No description provided for @seasonalTipSpringGrowthBody.
  ///
  /// In en, this message translates to:
  /// **'Your plants are waking up. Look for new leaves, shoots, and roots — a great time to take progress photos.'**
  String get seasonalTipSpringGrowthBody;

  /// No description provided for @seasonalTipSpringWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Increase watering'**
  String get seasonalTipSpringWaterTitle;

  /// No description provided for @seasonalTipSpringWaterBody.
  ///
  /// In en, this message translates to:
  /// **'As growth picks up, your plants will drink more. Check soil moisture more frequently than in winter.'**
  String get seasonalTipSpringWaterBody;

  /// No description provided for @seasonalTipSpringPestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pest patrol'**
  String get seasonalTipSpringPestsTitle;

  /// No description provided for @seasonalTipSpringPestsBody.
  ///
  /// In en, this message translates to:
  /// **'Warmer weather brings pests. Inspect new growth and leaf undersides regularly for early signs of infestation.'**
  String get seasonalTipSpringPestsBody;

  /// No description provided for @seasonalTipSummerWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated'**
  String get seasonalTipSummerWaterTitle;

  /// No description provided for @seasonalTipSummerWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Heat and longer days mean faster evaporation. Water deeply and check soil more often, especially for smaller pots.'**
  String get seasonalTipSummerWaterBody;

  /// No description provided for @seasonalTipSummerMistTitle.
  ///
  /// In en, this message translates to:
  /// **'Boost humidity'**
  String get seasonalTipSummerMistTitle;

  /// No description provided for @seasonalTipSummerMistBody.
  ///
  /// In en, this message translates to:
  /// **'Air conditioning dries the air. Mist tropical plants or group them together to create a humid microclimate.'**
  String get seasonalTipSummerMistBody;

  /// No description provided for @seasonalTipSummerSunburnTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch for sunburn'**
  String get seasonalTipSummerSunburnTitle;

  /// No description provided for @seasonalTipSummerSunburnBody.
  ///
  /// In en, this message translates to:
  /// **'Intense midday sun can scorch leaves. Move sensitive plants back from south-facing windows or add sheer curtains.'**
  String get seasonalTipSummerSunburnBody;

  /// No description provided for @seasonalTipSummerOutdoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Outdoor time'**
  String get seasonalTipSummerOutdoorTitle;

  /// No description provided for @seasonalTipSummerOutdoorBody.
  ///
  /// In en, this message translates to:
  /// **'Many houseplants love a summer vacation outdoors. Acclimate gradually and bring them in before nights get cold.'**
  String get seasonalTipSummerOutdoorBody;

  /// No description provided for @seasonalTipSummerPropagateTitle.
  ///
  /// In en, this message translates to:
  /// **'Propagation season'**
  String get seasonalTipSummerPropagateTitle;

  /// No description provided for @seasonalTipSummerPropagateBody.
  ///
  /// In en, this message translates to:
  /// **'Summer warmth and long days make this the ideal time to take cuttings. Most will root quickly in bright indirect light.'**
  String get seasonalTipSummerPropagateBody;

  /// No description provided for @seasonalTipAutumnWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Ease off watering'**
  String get seasonalTipAutumnWaterTitle;

  /// No description provided for @seasonalTipAutumnWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Growth slows as days shorten. Let soil dry out more between waterings to prevent root rot during the transition.'**
  String get seasonalTipAutumnWaterBody;

  /// No description provided for @seasonalTipAutumnFertilizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop fertilizing'**
  String get seasonalTipAutumnFertilizeTitle;

  /// No description provided for @seasonalTipAutumnFertilizeBody.
  ///
  /// In en, this message translates to:
  /// **'Most plants enter dormancy soon. Stop feeding to avoid salt buildup and let them rest naturally.'**
  String get seasonalTipAutumnFertilizeBody;

  /// No description provided for @seasonalTipAutumnLightTitle.
  ///
  /// In en, this message translates to:
  /// **'Chase the light'**
  String get seasonalTipAutumnLightTitle;

  /// No description provided for @seasonalTipAutumnLightBody.
  ///
  /// In en, this message translates to:
  /// **'As the sun angle drops, move plants closer to windows. Rotate them regularly so all sides get even light.'**
  String get seasonalTipAutumnLightBody;

  /// No description provided for @seasonalTipAutumnInsideTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring plants inside'**
  String get seasonalTipAutumnInsideTitle;

  /// No description provided for @seasonalTipAutumnInsideBody.
  ///
  /// In en, this message translates to:
  /// **'If you moved plants outdoors for summer, bring them back before nighttime temperatures drop below 10°C (50°F).'**
  String get seasonalTipAutumnInsideBody;

  /// No description provided for @seasonalTipAutumnCleanTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaf cleaning day'**
  String get seasonalTipAutumnCleanTitle;

  /// No description provided for @seasonalTipAutumnCleanBody.
  ///
  /// In en, this message translates to:
  /// **'Dust blocks light absorption. Wipe leaves with a damp cloth to help your plants photosynthesize efficiently through winter.'**
  String get seasonalTipAutumnCleanBody;

  /// No description provided for @seasonalTipWinterWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water sparingly'**
  String get seasonalTipWinterWaterTitle;

  /// No description provided for @seasonalTipWinterWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Most plants need much less water in winter. Overwatering is the top killer during dormancy — when in doubt, wait.'**
  String get seasonalTipWinterWaterBody;

  /// No description provided for @seasonalTipWinterHumidityTitle.
  ///
  /// In en, this message translates to:
  /// **'Combat dry air'**
  String get seasonalTipWinterHumidityTitle;

  /// No description provided for @seasonalTipWinterHumidityBody.
  ///
  /// In en, this message translates to:
  /// **'Heating systems dry indoor air dramatically. Use a humidifier or pebble trays to keep tropical plants happy.'**
  String get seasonalTipWinterHumidityBody;

  /// No description provided for @seasonalTipWinterDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Avoid cold drafts'**
  String get seasonalTipWinterDraftsTitle;

  /// No description provided for @seasonalTipWinterDraftsBody.
  ///
  /// In en, this message translates to:
  /// **'Keep plants away from drafty windows and exterior doors. Even cold-hardy plants dislike sudden temperature swings.'**
  String get seasonalTipWinterDraftsBody;

  /// No description provided for @seasonalTipWinterLightTitle.
  ///
  /// In en, this message translates to:
  /// **'Maximize light'**
  String get seasonalTipWinterLightTitle;

  /// No description provided for @seasonalTipWinterLightBody.
  ///
  /// In en, this message translates to:
  /// **'Short days mean less photosynthesis. Move plants to your brightest spots and consider a grow light for light-lovers.'**
  String get seasonalTipWinterLightBody;

  /// No description provided for @seasonalTipWinterRestTitle.
  ///
  /// In en, this message translates to:
  /// **'Let them rest'**
  String get seasonalTipWinterRestTitle;

  /// No description provided for @seasonalTipWinterRestBody.
  ///
  /// In en, this message translates to:
  /// **'Dormancy is natural and healthy. Don\'t worry about slow growth — your plants are conserving energy for spring.'**
  String get seasonalTipWinterRestBody;

  /// No description provided for @healthBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get healthBreakdownTitle;

  /// No description provided for @healthBreakdownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what contributes to this plant\'s health rating'**
  String get healthBreakdownSubtitle;

  /// No description provided for @healthBreakdownOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall: {score}/100'**
  String healthBreakdownOverall(int score);

  /// No description provided for @healthFactorOverdue.
  ///
  /// In en, this message translates to:
  /// **'Task timeliness'**
  String get healthFactorOverdue;

  /// No description provided for @healthFactorActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent care activity'**
  String get healthFactorActivity;

  /// No description provided for @healthFactorVariety.
  ///
  /// In en, this message translates to:
  /// **'Care variety'**
  String get healthFactorVariety;

  /// No description provided for @healthFactorConsistency.
  ///
  /// In en, this message translates to:
  /// **'Schedule consistency'**
  String get healthFactorConsistency;

  /// No description provided for @coachingTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Coaching'**
  String get coachingTitle;

  /// No description provided for @coachingLateWatererTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust your reminders'**
  String get coachingLateWatererTitle;

  /// No description provided for @coachingLateWatererBody.
  ///
  /// In en, this message translates to:
  /// **'You often water a day or two late. Try shifting your reminder time to when you\'re usually free.'**
  String get coachingLateWatererBody;

  /// No description provided for @coachingStreakAtRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak at risk!'**
  String get coachingStreakAtRiskTitle;

  /// No description provided for @coachingStreakAtRiskBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t cared for any plants today. A quick water keeps your streak alive.'**
  String get coachingStreakAtRiskBody;

  /// No description provided for @coachingNeglectedPlantTitle.
  ///
  /// In en, this message translates to:
  /// **'A plant needs you'**
  String get coachingNeglectedPlantTitle;

  /// No description provided for @coachingNeglectedPlantBody.
  ///
  /// In en, this message translates to:
  /// **'One of your plants hasn\'t received care in over 3 weeks. Check in on it.'**
  String get coachingNeglectedPlantBody;

  /// No description provided for @coachingImprovingTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re improving!'**
  String get coachingImprovingTitle;

  /// No description provided for @coachingImprovingBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been more active this week than last. Keep the momentum going.'**
  String get coachingImprovingBody;

  /// No description provided for @coachingConsistentTitle.
  ///
  /// In en, this message translates to:
  /// **'Consistency champion'**
  String get coachingConsistentTitle;

  /// No description provided for @coachingConsistentBody.
  ///
  /// In en, this message translates to:
  /// **'9 out of your last 10 tasks were completed on time. Your plants are thriving.'**
  String get coachingConsistentBody;

  /// No description provided for @coachingDiversifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Try something new'**
  String get coachingDiversifyTitle;

  /// No description provided for @coachingDiversifyBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve only been watering lately. Consider misting, rotating, or fertilizing for healthier plants.'**
  String get coachingDiversifyBody;

  /// No description provided for @plantDetailNextWateringTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get plantDetailNextWateringTomorrow;

  /// No description provided for @plantDetailNextWateringToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get plantDetailNextWateringToday;

  /// No description provided for @gardenStreakFreezeAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 streak freeze available} other{{count} streak freezes available}}'**
  String gardenStreakFreezeAvailable(int count);

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @plantDetailHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Health score'**
  String get plantDetailHealthScore;

  /// No description provided for @plantDetailExpandText.
  ///
  /// In en, this message translates to:
  /// **'Expand text'**
  String get plantDetailExpandText;

  /// No description provided for @plantDetailCollapseText.
  ///
  /// In en, this message translates to:
  /// **'Collapse text'**
  String get plantDetailCollapseText;

  /// No description provided for @gardenWateredToday.
  ///
  /// In en, this message translates to:
  /// **'Watered today'**
  String get gardenWateredToday;

  /// No description provided for @gardenWateredYesterday.
  ///
  /// In en, this message translates to:
  /// **'Watered yesterday'**
  String get gardenWateredYesterday;

  /// No description provided for @gardenWateredDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Watered {days} days ago'**
  String gardenWateredDaysAgo(int days);

  /// No description provided for @gardenNeverWatered.
  ///
  /// In en, this message translates to:
  /// **'Not yet watered'**
  String get gardenNeverWatered;

  /// No description provided for @calendarHeatmapTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 care action} other{{count} care actions}}'**
  String calendarHeatmapTooltip(int count);

  /// No description provided for @calendarHeatmapTooltipDetail.
  ///
  /// In en, this message translates to:
  /// **'{waters, plural, =0{} =1{1 water} other{{waters} waters}}{fertSep}{fertilizes, plural, =0{} =1{1 fertilize} other{{fertilizes} fertilizes}}{otherSep}{others, plural, =0{} =1{1 other} other{{others} other}}'**
  String calendarHeatmapTooltipDetail(
      int waters, String fertSep, int fertilizes, String otherSep, int others);

  /// No description provided for @calendarDayCareCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 care log} other{{count} care logs}}'**
  String calendarDayCareCount(int count);

  /// No description provided for @exportDataConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Export care data?'**
  String get exportDataConfirmTitle;

  /// No description provided for @exportDataConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will create a JSON file with all your plants, care logs, and tasks.'**
  String get exportDataConfirmBody;

  /// No description provided for @exportDataConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportDataConfirmAction;

  /// No description provided for @gardenWaterAllOverdue.
  ///
  /// In en, this message translates to:
  /// **'Water all overdue'**
  String get gardenWaterAllOverdue;

  /// No description provided for @gardenWaterAllOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {Water 1 overdue plant} other {Water {count} overdue plants}}'**
  String gardenWaterAllOverdueCount(int count);

  /// No description provided for @gardenWateredAllOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {Watered 1 overdue plant} other {Watered {count} overdue plants}}'**
  String gardenWateredAllOverdue(int count);

  /// No description provided for @plantOverviewNoCareStats.
  ///
  /// In en, this message translates to:
  /// **'Water your plant a few times to see care patterns here.'**
  String get plantOverviewNoCareStats;

  /// No description provided for @plantOverviewNoAiInsights.
  ///
  /// In en, this message translates to:
  /// **'Enable AI insights in settings to get personalized care tips.'**
  String get plantOverviewNoAiInsights;

  /// No description provided for @plantOverviewNoTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No upcoming tasks yet. Care schedules will appear as they are created.'**
  String get plantOverviewNoTasksYet;

  /// No description provided for @gardenHealthTrendUp.
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get gardenHealthTrendUp;

  /// No description provided for @gardenHealthTrendDown.
  ///
  /// In en, this message translates to:
  /// **'Declining'**
  String get gardenHealthTrendDown;

  /// No description provided for @gardenHealthTrendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get gardenHealthTrendStable;

  /// No description provided for @plantCareStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'{days}-day care streak'**
  String plantCareStreakLabel(int days);

  /// No description provided for @tasksEmptySoonMotivation.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the calm. Your plants are thriving.'**
  String get tasksEmptySoonMotivation;

  /// No description provided for @manageCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage care reminders'**
  String get manageCareTitle;

  /// No description provided for @manageCareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {disabled} disabled'**
  String manageCareSubtitle(int active, int disabled);

  /// No description provided for @manageCareSpeciesDefault.
  ///
  /// In en, this message translates to:
  /// **'Species default'**
  String get manageCareSpeciesDefault;

  /// No description provided for @manageCareEnabledByYou.
  ///
  /// In en, this message translates to:
  /// **'Enabled by you'**
  String get manageCareEnabledByYou;

  /// No description provided for @manageCareDisabledByYou.
  ///
  /// In en, this message translates to:
  /// **'Disabled by you'**
  String get manageCareDisabledByYou;

  /// No description provided for @manageCareButton.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageCareButton;

  /// No description provided for @manageCareDisableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Turn off {type} reminders?'**
  String manageCareDisableConfirm(String type);

  /// No description provided for @manageCareEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get manageCareEnabled;

  /// No description provided for @manageCareDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get manageCareDisabled;

  /// No description provided for @growthEchoCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Then & now'**
  String get growthEchoCompareTitle;

  /// No description provided for @growthEchoCompareBody.
  ///
  /// In en, this message translates to:
  /// **'{plant} has {days} days of growth to compare.'**
  String growthEchoCompareBody(String plant, int days);

  /// No description provided for @growthEchoCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth check-in'**
  String get growthEchoCaptureTitle;

  /// No description provided for @growthEchoCaptureBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s been {days} days since {plant}\'s last photo.'**
  String growthEchoCaptureBody(int days, String plant);

  /// No description provided for @commonProblemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Common issues'**
  String get commonProblemsTitle;

  /// No description provided for @commonProblemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch for these with your {plant}'**
  String commonProblemsSubtitle(String plant);

  /// No description provided for @perfectWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect Week {count}!'**
  String perfectWeekTitle(int count);

  /// No description provided for @perfectWeekBody.
  ///
  /// In en, this message translates to:
  /// **'Every task completed on time for 7 straight days. Your plants are thriving because of you.'**
  String get perfectWeekBody;

  /// No description provided for @perfectWeekBodyRepeat.
  ///
  /// In en, this message translates to:
  /// **'{count} perfect weeks in a row. You\'re in a league of your own.'**
  String perfectWeekBodyRepeat(int count);

  /// No description provided for @perfectWeekDismiss.
  ///
  /// In en, this message translates to:
  /// **'On to the next!'**
  String get perfectWeekDismiss;

  /// No description provided for @growthTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth Timeline'**
  String get growthTimelineTitle;

  /// No description provided for @growthTimelineEmpty.
  ///
  /// In en, this message translates to:
  /// **'Take photos to track growth over time'**
  String get growthTimelineEmpty;

  /// No description provided for @notificationStreakProtectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your {days}-day streak is at risk!'**
  String notificationStreakProtectionTitle(int days);

  /// No description provided for @notificationStreakProtectionBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a care task before midnight to keep it going.'**
  String get notificationStreakProtectionBody;

  /// No description provided for @careRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Care Rhythm'**
  String get careRhythmTitle;

  /// No description provided for @careRhythmAvgInterval.
  ///
  /// In en, this message translates to:
  /// **'Avg {days}d between waterings'**
  String careRhythmAvgInterval(int days);

  /// No description provided for @careRhythmConsistent.
  ///
  /// In en, this message translates to:
  /// **'Very consistent'**
  String get careRhythmConsistent;

  /// No description provided for @careRhythmImproving.
  ///
  /// In en, this message translates to:
  /// **'Getting more consistent'**
  String get careRhythmImproving;

  /// No description provided for @careRhythmNoData.
  ///
  /// In en, this message translates to:
  /// **'Water a few more times to see your rhythm'**
  String get careRhythmNoData;

  /// No description provided for @plantMoodThriving.
  ///
  /// In en, this message translates to:
  /// **'Thriving! 🌱'**
  String get plantMoodThriving;

  /// No description provided for @plantMoodHappy.
  ///
  /// In en, this message translates to:
  /// **'Feeling great'**
  String get plantMoodHappy;

  /// No description provided for @plantMoodOkay.
  ///
  /// In en, this message translates to:
  /// **'Doing okay'**
  String get plantMoodOkay;

  /// No description provided for @plantMoodThirsty.
  ///
  /// In en, this message translates to:
  /// **'Getting thirsty…'**
  String get plantMoodThirsty;

  /// No description provided for @plantMoodNeglected.
  ///
  /// In en, this message translates to:
  /// **'Missing you…'**
  String get plantMoodNeglected;

  /// No description provided for @plantMoodNewHere.
  ///
  /// In en, this message translates to:
  /// **'Just planted!'**
  String get plantMoodNewHere;

  /// No description provided for @plantAnniversaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Happy anniversary, {plant}!'**
  String plantAnniversaryTitle(String plant);

  /// No description provided for @plantAnniversaryBody30.
  ///
  /// In en, this message translates to:
  /// **'One month together. You\'re building something beautiful.'**
  String get plantAnniversaryBody30;

  /// No description provided for @plantAnniversaryBody90.
  ///
  /// In en, this message translates to:
  /// **'Three months of care. Your dedication shows.'**
  String get plantAnniversaryBody90;

  /// No description provided for @plantAnniversaryBody180.
  ///
  /// In en, this message translates to:
  /// **'Half a year! This plant is thriving because of you.'**
  String get plantAnniversaryBody180;

  /// No description provided for @plantAnniversaryBody365.
  ///
  /// In en, this message translates to:
  /// **'A full year together. What an incredible journey.'**
  String get plantAnniversaryBody365;

  /// No description provided for @plantAnniversaryDismiss.
  ///
  /// In en, this message translates to:
  /// **'Here\'s to more!'**
  String get plantAnniversaryDismiss;

  /// No description provided for @insightRhythmShift.
  ///
  /// In en, this message translates to:
  /// **'{plant}\'s watering rhythm shifted from every {oldDays} to {newDays} days this month'**
  String insightRhythmShift(String plant, String oldDays, String newDays);

  /// No description provided for @insightFavoriteCareDay.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of your care happens on {day}s — your garden day'**
  String insightFavoriteCareDay(String percent, String day);

  /// No description provided for @insightActiveTime.
  ///
  /// In en, this message translates to:
  /// **'You\'re a {period} plant parent — {percent}% of care happens then'**
  String insightActiveTime(String period, String percent);

  /// No description provided for @insightMostLovedPlant.
  ///
  /// In en, this message translates to:
  /// **'{plant} got the most attention this month — {actions} care actions'**
  String insightMostLovedPlant(String plant, String actions);

  /// No description provided for @insightQuietThenBusy.
  ///
  /// In en, this message translates to:
  /// **'Quiet {quietDays} days ahead, then {taskCount} tasks coming up'**
  String insightQuietThenBusy(String quietDays, String taskCount);

  /// No description provided for @insightCareAcceleration.
  ///
  /// In en, this message translates to:
  /// **'You\'re on a roll — {thisWeek} actions this week vs {lastWeek} last week'**
  String insightCareAcceleration(String thisWeek, String lastWeek);

  /// No description provided for @insightGardenGrowing.
  ///
  /// In en, this message translates to:
  /// **'Your garden is growing — {total} plants now, {recent} added recently'**
  String insightGardenGrowing(String total, String recent);

  /// No description provided for @insightSeasonalActivity.
  ///
  /// In en, this message translates to:
  /// **'Seasonal shift: {direction} active this month ({thisMonth}) vs last ({lastMonth})'**
  String insightSeasonalActivity(
      String direction, String thisMonth, String lastMonth);

  /// No description provided for @insightSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Intelligence'**
  String get insightSectionTitle;

  /// No description provided for @quickCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'How does {plant} look?'**
  String quickCheckInTitle(String plant);

  /// No description provided for @quickCheckInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick check helps track your plant\'s health over time'**
  String get quickCheckInSubtitle;

  /// No description provided for @quickCheckInThriving.
  ///
  /// In en, this message translates to:
  /// **'Thriving'**
  String get quickCheckInThriving;

  /// No description provided for @quickCheckInOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get quickCheckInOkay;

  /// No description provided for @quickCheckInWorried.
  ///
  /// In en, this message translates to:
  /// **'Worried'**
  String get quickCheckInWorried;

  /// No description provided for @diversityTitle.
  ///
  /// In en, this message translates to:
  /// **'Biodiversity Index'**
  String get diversityTitle;

  /// No description provided for @diversitySpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get diversitySpecies;

  /// No description provided for @diversityLightNeeds.
  ///
  /// In en, this message translates to:
  /// **'Light needs'**
  String get diversityLightNeeds;

  /// No description provided for @diversityDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get diversityDifficulty;

  /// No description provided for @diversityEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get diversityEnvironment;

  /// No description provided for @diversitySuggestNewSpecies.
  ///
  /// In en, this message translates to:
  /// **'Try adding a different species to diversify'**
  String get diversitySuggestNewSpecies;

  /// No description provided for @diversitySuggestDifferentLight.
  ///
  /// In en, this message translates to:
  /// **'Consider plants with different light needs'**
  String get diversitySuggestDifferentLight;

  /// No description provided for @diversitySuggestVaryDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Mix easy and challenging plants for variety'**
  String get diversitySuggestVaryDifficulty;

  /// No description provided for @diversitySuggestOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Try an outdoor or balcony plant for environment diversity'**
  String get diversitySuggestOutdoor;

  /// No description provided for @diversitySuggestAddPlants.
  ///
  /// In en, this message translates to:
  /// **'Add more plants to build diversity'**
  String get diversitySuggestAddPlants;

  /// No description provided for @momentumTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Momentum'**
  String get momentumTitle;

  /// No description provided for @momentumTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending {direction}'**
  String momentumTrending(String direction);

  /// No description provided for @momentumUp.
  ///
  /// In en, this message translates to:
  /// **'up'**
  String get momentumUp;

  /// No description provided for @momentumDown.
  ///
  /// In en, this message translates to:
  /// **'down'**
  String get momentumDown;

  /// No description provided for @momentumSteady.
  ///
  /// In en, this message translates to:
  /// **'steady'**
  String get momentumSteady;

  /// No description provided for @momentumStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get momentumStreak;

  /// No description provided for @momentumActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get momentumActivity;

  /// No description provided for @momentumGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get momentumGrowth;

  /// No description provided for @batchPlannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Watering Schedule'**
  String get batchPlannerTitle;

  /// No description provided for @batchPlannerEfficiency.
  ///
  /// In en, this message translates to:
  /// **'{percent}% efficient'**
  String batchPlannerEfficiency(int percent);

  /// No description provided for @batchPlannerDays.
  ///
  /// In en, this message translates to:
  /// **'{count} watering days/week'**
  String batchPlannerDays(int count);

  /// No description provided for @batchPlannerPlants.
  ///
  /// In en, this message translates to:
  /// **'{count} plants'**
  String batchPlannerPlants(int count);

  /// No description provided for @careImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Care Impact'**
  String get careImpactTitle;

  /// No description provided for @careImpactWaterings.
  ///
  /// In en, this message translates to:
  /// **'waterings'**
  String get careImpactWaterings;

  /// No description provided for @careImpactSaved.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get careImpactSaved;

  /// No description provided for @careImpactTypes.
  ///
  /// In en, this message translates to:
  /// **'types'**
  String get careImpactTypes;

  /// No description provided for @careImpactLongestCompanion.
  ///
  /// In en, this message translates to:
  /// **'Longest companion: {name} ({days}d)'**
  String careImpactLongestCompanion(String name, int days);

  /// No description provided for @careImpactAvgResponse.
  ///
  /// In en, this message translates to:
  /// **'Avg response: {hours}h'**
  String careImpactAvgResponse(String hours);

  /// No description provided for @gardenLegacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Legacy'**
  String get gardenLegacyTitle;

  /// No description provided for @gardenLegacyTotalCare.
  ///
  /// In en, this message translates to:
  /// **'Total care actions'**
  String get gardenLegacyTotalCare;

  /// No description provided for @gardenLegacyLongestSurvivor.
  ///
  /// In en, this message translates to:
  /// **'Longest survivor'**
  String get gardenLegacyLongestSurvivor;

  /// No description provided for @gardenLegacyScore.
  ///
  /// In en, this message translates to:
  /// **'Legacy score'**
  String get gardenLegacyScore;

  /// No description provided for @roomCompatibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'{room} Compatibility'**
  String roomCompatibilityTitle(String room);

  /// No description provided for @roomCompatibilityPairings.
  ///
  /// In en, this message translates to:
  /// **'{plants} plants, {pairings} pairings'**
  String roomCompatibilityPairings(int plants, int pairings);

  /// No description provided for @wateringEfficiencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Watering Efficiency'**
  String get wateringEfficiencyTitle;

  /// No description provided for @wateringEfficiencyOptimal.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total} optimal'**
  String wateringEfficiencyOptimal(int count, int total);

  /// No description provided for @careAutopilotTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Autopilot'**
  String get careAutopilotTitle;

  /// No description provided for @careAutopilotUrgent.
  ///
  /// In en, this message translates to:
  /// **'{count} urgent'**
  String careAutopilotUrgent(int count);

  /// No description provided for @roomSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Room Suggestions'**
  String get roomSuggestionsTitle;

  /// No description provided for @roomSuggestionsMoves.
  ///
  /// In en, this message translates to:
  /// **'{count} moves'**
  String roomSuggestionsMoves(int count);

  /// No description provided for @dailyFactTitle.
  ///
  /// In en, this message translates to:
  /// **'Did You Know?'**
  String get dailyFactTitle;

  /// No description provided for @seasonalTransitionTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Transition'**
  String get seasonalTransitionTitle;

  /// No description provided for @seasonalTransitionWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks}w away'**
  String seasonalTransitionWeeks(int weeks);

  /// No description provided for @gardenInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Insights'**
  String get gardenInsightsTitle;

  /// No description provided for @recommendedForYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYouTitle;

  /// No description provided for @recommendedGaps.
  ///
  /// In en, this message translates to:
  /// **'Gaps: {gaps}'**
  String recommendedGaps(String gaps);

  /// No description provided for @plantMemoryFirstPhoto.
  ///
  /// In en, this message translates to:
  /// **'First Photo'**
  String get plantMemoryFirstPhoto;

  /// No description provided for @plantMemoryFirstCare.
  ///
  /// In en, this message translates to:
  /// **'First Care'**
  String get plantMemoryFirstCare;

  /// No description provided for @plantMemoryAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get plantMemoryAnniversary;

  /// No description provided for @plantMemoryBusiestDay.
  ///
  /// In en, this message translates to:
  /// **'Busiest Day'**
  String get plantMemoryBusiestDay;

  /// No description provided for @plantMemoryLongestGap.
  ///
  /// In en, this message translates to:
  /// **'Longest Gap'**
  String get plantMemoryLongestGap;

  /// No description provided for @plantMemoryComeback.
  ///
  /// In en, this message translates to:
  /// **'Comeback'**
  String get plantMemoryComeback;

  /// No description provided for @careAutopilotMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more suggestions'**
  String careAutopilotMore(int count);

  /// No description provided for @wateringEfficiencyMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String wateringEfficiencyMore(int count);

  /// No description provided for @seasonalTransitionMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more tasks'**
  String seasonalTransitionMore(int count);

  /// No description provided for @gardenProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Intelligence'**
  String get gardenProgressTitle;

  /// No description provided for @gardenProgressUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{unlocked}/{total}'**
  String gardenProgressUnlocked(int unlocked, int total);

  /// No description provided for @gardenProgressMilestonePlant.
  ///
  /// In en, this message translates to:
  /// **'Add 1 more plant to unlock {feature}'**
  String gardenProgressMilestonePlant(String feature);

  /// No description provided for @gardenProgressMilestoneLogs.
  ///
  /// In en, this message translates to:
  /// **'Log {count} more care actions for {feature}'**
  String gardenProgressMilestoneLogs(int count, String feature);

  /// No description provided for @transitionMoveIndoors.
  ///
  /// In en, this message translates to:
  /// **'Move indoors'**
  String get transitionMoveIndoors;

  /// No description provided for @transitionMoveOutdoors.
  ///
  /// In en, this message translates to:
  /// **'Move outdoors'**
  String get transitionMoveOutdoors;

  /// No description provided for @transitionReduceWatering.
  ///
  /// In en, this message translates to:
  /// **'Reduce watering'**
  String get transitionReduceWatering;

  /// No description provided for @transitionIncreaseWatering.
  ///
  /// In en, this message translates to:
  /// **'Increase watering'**
  String get transitionIncreaseWatering;

  /// No description provided for @transitionStartFertilizing.
  ///
  /// In en, this message translates to:
  /// **'Start fertilizing'**
  String get transitionStartFertilizing;

  /// No description provided for @transitionStopFertilizing.
  ///
  /// In en, this message translates to:
  /// **'Stop fertilizing'**
  String get transitionStopFertilizing;

  /// No description provided for @transitionIncreaseHumidity.
  ///
  /// In en, this message translates to:
  /// **'Increase humidity'**
  String get transitionIncreaseHumidity;

  /// No description provided for @transitionProtectFromFrost.
  ///
  /// In en, this message translates to:
  /// **'Protect from frost'**
  String get transitionProtectFromFrost;

  /// No description provided for @transitionProvideShadeCover.
  ///
  /// In en, this message translates to:
  /// **'Provide shade'**
  String get transitionProvideShadeCover;

  /// No description provided for @transitionResumeNormalCare.
  ///
  /// In en, this message translates to:
  /// **'Resume normal care'**
  String get transitionResumeNormalCare;

  /// No description provided for @dailyBriefingTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Briefing'**
  String get dailyBriefingTitle;

  /// No description provided for @dailyBriefingAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up — your garden is thriving!'**
  String get dailyBriefingAllCaughtUp;

  /// No description provided for @weeklyInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Insight'**
  String get weeklyInsightTitle;

  /// No description provided for @dailyChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallengeTitle;

  /// No description provided for @dailyChallengeAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get dailyChallengeAccept;

  /// No description provided for @communityChallengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Challenges'**
  String get communityChallengesTitle;

  /// No description provided for @dailyRitualTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Ritual'**
  String get dailyRitualTitle;

  /// No description provided for @achievementsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get achievementsRecent;

  /// No description provided for @careEffectivenessTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Effectiveness'**
  String get careEffectivenessTitle;

  /// No description provided for @scheduleTuningTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Tuning'**
  String get scheduleTuningTitle;

  /// No description provided for @careBurnoutOverload.
  ///
  /// In en, this message translates to:
  /// **'Care Overload Detected'**
  String get careBurnoutOverload;

  /// No description provided for @careBurnoutStretched.
  ///
  /// In en, this message translates to:
  /// **'Feeling Stretched?'**
  String get careBurnoutStretched;

  /// No description provided for @careLoadTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Load'**
  String get careLoadTitle;

  /// No description provided for @careLoadThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get careLoadThisWeek;

  /// No description provided for @careCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Coach'**
  String get careCoachTitle;

  /// No description provided for @careConfidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Confidence'**
  String get careConfidenceTitle;

  /// No description provided for @careConsistencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Consistency'**
  String get careConsistencyTitle;

  /// No description provided for @careCostsTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Costs'**
  String get careCostsTitle;

  /// No description provided for @delegationPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Delegation Plan'**
  String get delegationPlanTitle;

  /// No description provided for @carePatternsTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Patterns'**
  String get carePatternsTitle;

  /// No description provided for @carePersonaTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Care Persona'**
  String get carePersonaTitle;

  /// No description provided for @carePersonaStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get carePersonaStrengths;

  /// No description provided for @carePersonaGrowthAreas.
  ///
  /// In en, this message translates to:
  /// **'Growth Areas'**
  String get carePersonaGrowthAreas;

  /// No description provided for @nextWateringTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Watering'**
  String get nextWateringTitle;

  /// No description provided for @careRoutinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Care Routines'**
  String get careRoutinesTitle;

  /// No description provided for @plantAnniversariesTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant Anniversaries'**
  String get plantAnniversariesTitle;

  /// No description provided for @communityBenchmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Benchmark'**
  String get communityBenchmarkTitle;

  /// No description provided for @emotionalBondsTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotional Bonds'**
  String get emotionalBondsTitle;

  /// No description provided for @suggestedGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested Goals'**
  String get suggestedGoalsTitle;

  /// No description provided for @gardenHarmonyTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Harmony'**
  String get gardenHarmonyTitle;

  /// No description provided for @gardenMomentumTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Momentum'**
  String get gardenMomentumTitle;

  /// No description provided for @gardenMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Mood'**
  String get gardenMoodTitle;

  /// No description provided for @gardenRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Rhythm'**
  String get gardenRhythmTitle;

  /// No description provided for @gardenCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Card'**
  String get gardenCardTitle;

  /// No description provided for @gardenStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Stats'**
  String get gardenStatsTitle;

  /// No description provided for @growthJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth Journal'**
  String get growthJournalTitle;

  /// No description provided for @careHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Habits'**
  String get careHabitsTitle;

  /// No description provided for @healthForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Forecast'**
  String get healthForecastTitle;

  /// No description provided for @healthTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Timeline'**
  String get healthTimelineTitle;

  /// No description provided for @plantQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant Quiz'**
  String get plantQuizTitle;

  /// No description provided for @growthStageTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth Stage'**
  String get growthStageTitle;

  /// No description provided for @memoryLaneTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane'**
  String get memoryLaneTitle;

  /// No description provided for @microSeasonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Micro Seasons'**
  String get microSeasonsTitle;

  /// No description provided for @milestonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestonesTitle;

  /// No description provided for @gentleNudgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle Nudges'**
  String get gentleNudgesTitle;

  /// No description provided for @timelapseReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Timelapse Ready'**
  String get timelapseReadyTitle;

  /// No description provided for @lifeStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Life Story'**
  String get lifeStoryTitle;

  /// No description provided for @plantLineageTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant Lineage'**
  String get plantLineageTitle;

  /// No description provided for @rescuePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Rescue Plan'**
  String get rescuePlanTitle;

  /// No description provided for @plantStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant Story'**
  String get plantStoryTitle;

  /// No description provided for @vitalSignsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vital Signs'**
  String get vitalSignsTitle;

  /// No description provided for @predictedNeedsTitle.
  ///
  /// In en, this message translates to:
  /// **'Predicted Needs'**
  String get predictedNeedsTitle;

  /// No description provided for @propagationTitle.
  ///
  /// In en, this message translates to:
  /// **'Propagation'**
  String get propagationTitle;

  /// No description provided for @roomProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Room Profiles'**
  String get roomProfilesTitle;

  /// No description provided for @seasonalTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Tips'**
  String get seasonalTipsTitle;

  /// No description provided for @skillLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Skill Level'**
  String get skillLevelTitle;

  /// No description provided for @plantSocialGraphTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant Social Graph'**
  String get plantSocialGraphTitle;

  /// No description provided for @streakBoardTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak Board'**
  String get streakBoardTitle;

  /// No description provided for @stressAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stress Alerts'**
  String get stressAlertsTitle;

  /// No description provided for @survivalOutlookTitle.
  ///
  /// In en, this message translates to:
  /// **'Survival Outlook'**
  String get survivalOutlookTitle;

  /// No description provided for @gardenTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden Timeline'**
  String get gardenTimelineTitle;

  /// No description provided for @waterEfficiencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Efficiency'**
  String get waterEfficiencyTitle;

  /// No description provided for @wateringScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Watering Schedule'**
  String get wateringScheduleTitle;

  /// No description provided for @scheduleOptimizerTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Optimizer'**
  String get scheduleOptimizerTitle;

  /// No description provided for @weeklyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get weeklyReportTitle;

  /// No description provided for @plantWhispererTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant Whisperer'**
  String get plantWhispererTitle;

  /// No description provided for @smartGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning! Your plants are waiting.'**
  String get smartGreetingMorning;

  /// No description provided for @smartGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon! Time for a garden check.'**
  String get smartGreetingAfternoon;

  /// No description provided for @smartGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening! Wind down with your plants.'**
  String get smartGreetingEvening;

  /// No description provided for @smartGreetingStreak.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak! Keep it up.'**
  String smartGreetingStreak(String days);

  /// No description provided for @smartGreetingRainy.
  ///
  /// In en, this message translates to:
  /// **'Rainy day — your outdoor plants are happy.'**
  String get smartGreetingRainy;

  /// No description provided for @smartGreetingNewPlant.
  ///
  /// In en, this message translates to:
  /// **'How\'s {plant} settling in?'**
  String smartGreetingNewPlant(String plant);

  /// No description provided for @smartGreetingProductive.
  ///
  /// In en, this message translates to:
  /// **'Productive day! Your garden thanks you.'**
  String get smartGreetingProductive;

  /// No description provided for @smartGreetingEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early bird! Plants love morning care.'**
  String get smartGreetingEarlyBird;

  /// No description provided for @smartGreetingLateNight.
  ///
  /// In en, this message translates to:
  /// **'Late night check on your {count} plants.'**
  String smartGreetingLateNight(String count);

  /// No description provided for @smartGreetingBigGarden.
  ///
  /// In en, this message translates to:
  /// **'{count} plants strong! Impressive.'**
  String smartGreetingBigGarden(String count);

  /// No description provided for @smartGreetingDefault.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to your garden.'**
  String get smartGreetingDefault;

  /// No description provided for @nextActionWaterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Water {plant}'**
  String nextActionWaterOverdue(String plant);

  /// No description provided for @nextActionWaterOverdueSub.
  ///
  /// In en, this message translates to:
  /// **'Overdue — needs attention now'**
  String get nextActionWaterOverdueSub;

  /// No description provided for @nextActionWaterToday.
  ///
  /// In en, this message translates to:
  /// **'Water {plant}'**
  String nextActionWaterToday(String plant);

  /// No description provided for @nextActionWaterTodaySub.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for today'**
  String get nextActionWaterTodaySub;

  /// No description provided for @nextActionTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo time'**
  String get nextActionTakePhoto;

  /// No description provided for @nextActionTakePhotoSub.
  ///
  /// In en, this message translates to:
  /// **'Capture {plant}\'s progress'**
  String nextActionTakePhotoSub(String plant);

  /// No description provided for @nextActionCheckNewPlant.
  ///
  /// In en, this message translates to:
  /// **'Check on {plant}'**
  String nextActionCheckNewPlant(String plant);

  /// No description provided for @nextActionCheckNewPlantSub.
  ///
  /// In en, this message translates to:
  /// **'New plant — getting to know each other'**
  String get nextActionCheckNewPlantSub;

  /// No description provided for @nextActionFertilize.
  ///
  /// In en, this message translates to:
  /// **'Fertilize {plant}'**
  String nextActionFertilize(String plant);

  /// No description provided for @nextActionFertilizeSub.
  ///
  /// In en, this message translates to:
  /// **'Coming up in the next few days'**
  String get nextActionFertilizeSub;

  /// No description provided for @nextActionCelebrate.
  ///
  /// In en, this message translates to:
  /// **'Celebrate your streak!'**
  String get nextActionCelebrate;

  /// No description provided for @nextActionCelebrateSub.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing amazing'**
  String get nextActionCelebrateSub;

  /// No description provided for @nextActionExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore new plants'**
  String get nextActionExplore;

  /// No description provided for @nextActionExploreSub.
  ///
  /// In en, this message translates to:
  /// **'Start your plant journey'**
  String get nextActionExploreSub;

  /// No description provided for @nextActionRest.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get nextActionRest;

  /// No description provided for @nextActionRestSub.
  ///
  /// In en, this message translates to:
  /// **'Your garden is happy — enjoy the moment'**
  String get nextActionRestSub;

  /// No description provided for @careRhythmStreakBadge.
  ///
  /// In en, this message translates to:
  /// **'{count}x streak'**
  String careRhythmStreakBadge(int count);

  /// No description provided for @careRhythmMorningPerson.
  ///
  /// In en, this message translates to:
  /// **'Morning Person'**
  String get careRhythmMorningPerson;

  /// No description provided for @careRhythmMorningPersonDesc.
  ///
  /// In en, this message translates to:
  /// **'You tend to care for your plants in the morning hours.'**
  String get careRhythmMorningPersonDesc;

  /// No description provided for @careRhythmEveningCarer.
  ///
  /// In en, this message translates to:
  /// **'Evening Carer'**
  String get careRhythmEveningCarer;

  /// No description provided for @careRhythmEveningCarerDesc.
  ///
  /// In en, this message translates to:
  /// **'Your plants get attention during the evening wind-down.'**
  String get careRhythmEveningCarerDesc;

  /// No description provided for @careRhythmWeekendWarrior.
  ///
  /// In en, this message translates to:
  /// **'Weekend Warrior'**
  String get careRhythmWeekendWarrior;

  /// No description provided for @careRhythmWeekendWarriorDesc.
  ///
  /// In en, this message translates to:
  /// **'Weekends are your dedicated plant care time.'**
  String get careRhythmWeekendWarriorDesc;

  /// No description provided for @careRhythmDailyDevoter.
  ///
  /// In en, this message translates to:
  /// **'Daily Devoter'**
  String get careRhythmDailyDevoter;

  /// No description provided for @careRhythmDailyDevoterDesc.
  ///
  /// In en, this message translates to:
  /// **'You check on your plants almost every single day.'**
  String get careRhythmDailyDevoterDesc;

  /// No description provided for @careRhythmBatchCarer.
  ///
  /// In en, this message translates to:
  /// **'Batch Carer'**
  String get careRhythmBatchCarer;

  /// No description provided for @careRhythmBatchCarerDesc.
  ///
  /// In en, this message translates to:
  /// **'You handle multiple plants in focused care sessions.'**
  String get careRhythmBatchCarerDesc;

  /// No description provided for @careRhythmConfidence.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String careRhythmConfidence(int percent);

  /// No description provided for @quickCheckInThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for checking in!'**
  String get quickCheckInThanks;

  /// No description provided for @carePersonaMatch.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String carePersonaMatch(int percent);

  /// No description provided for @carePersonaDevotee.
  ///
  /// In en, this message translates to:
  /// **'Devotee'**
  String get carePersonaDevotee;

  /// No description provided for @carePersonaExplorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get carePersonaExplorer;

  /// No description provided for @carePersonaPerfectionist.
  ///
  /// In en, this message translates to:
  /// **'Perfectionist'**
  String get carePersonaPerfectionist;

  /// No description provided for @carePersonaNurturer.
  ///
  /// In en, this message translates to:
  /// **'Nurturer'**
  String get carePersonaNurturer;

  /// No description provided for @carePersonaVeteran.
  ///
  /// In en, this message translates to:
  /// **'Veteran'**
  String get carePersonaVeteran;

  /// No description provided for @carePersonaEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get carePersonaEarlyBird;

  /// No description provided for @plantPersonalityThe.
  ///
  /// In en, this message translates to:
  /// **'The {trait}'**
  String plantPersonalityThe(String trait);

  /// No description provided for @plantPersonalityDedicated.
  ///
  /// In en, this message translates to:
  /// **'Dedicated care routine'**
  String get plantPersonalityDedicated;

  /// No description provided for @plantPersonalityBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced care approach'**
  String get plantPersonalityBalanced;

  /// No description provided for @plantPersonalityCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual care style'**
  String get plantPersonalityCasual;

  /// No description provided for @plantPersonalityMinimalist.
  ///
  /// In en, this message translates to:
  /// **'Minimalist care'**
  String get plantPersonalityMinimalist;

  /// No description provided for @careRoutineNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get careRoutineNight;

  /// No description provided for @careRoutineMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get careRoutineMorning;

  /// No description provided for @careRoutineAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get careRoutineAfternoon;

  /// No description provided for @careRoutineEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get careRoutineEvening;

  /// No description provided for @careRoutinePlants.
  ///
  /// In en, this message translates to:
  /// **'{count} plants'**
  String careRoutinePlants(int count);

  /// No description provided for @careRoutineMinPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min/week'**
  String careRoutineMinPerWeek(int minutes);

  /// No description provided for @confidenceMaster.
  ///
  /// In en, this message translates to:
  /// **'Plant Master'**
  String get confidenceMaster;

  /// No description provided for @confidenceConfident.
  ///
  /// In en, this message translates to:
  /// **'Confident Carer'**
  String get confidenceConfident;

  /// No description provided for @confidenceLearning.
  ///
  /// In en, this message translates to:
  /// **'Growing Learner'**
  String get confidenceLearning;

  /// No description provided for @confidenceNovice.
  ///
  /// In en, this message translates to:
  /// **'Plant Novice'**
  String get confidenceNovice;

  /// No description provided for @confidenceNextKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep the streak alive'**
  String get confidenceNextKeepGoing;

  /// No description provided for @confidenceNextMaster.
  ///
  /// In en, this message translates to:
  /// **'Reach Master level'**
  String get confidenceNextMaster;

  /// No description provided for @confidenceNextConfident.
  ///
  /// In en, this message translates to:
  /// **'Reach Confident level'**
  String get confidenceNextConfident;

  /// No description provided for @confidenceNextBuild.
  ///
  /// In en, this message translates to:
  /// **'Build your routine'**
  String get confidenceNextBuild;

  /// No description provided for @confidenceNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {milestone}'**
  String confidenceNext(String milestone);

  /// No description provided for @confidenceDimConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get confidenceDimConsistency;

  /// No description provided for @confidenceDimDiversity.
  ///
  /// In en, this message translates to:
  /// **'Diversity'**
  String get confidenceDimDiversity;

  /// No description provided for @confidenceDimHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get confidenceDimHealth;

  /// No description provided for @confidenceDimExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get confidenceDimExperience;

  /// No description provided for @confidenceDimVariety.
  ///
  /// In en, this message translates to:
  /// **'Variety'**
  String get confidenceDimVariety;

  /// No description provided for @bondSoulmate.
  ///
  /// In en, this message translates to:
  /// **'Soulmate'**
  String get bondSoulmate;

  /// No description provided for @bondBestFriend.
  ///
  /// In en, this message translates to:
  /// **'Best Friend'**
  String get bondBestFriend;

  /// No description provided for @bondCompanion.
  ///
  /// In en, this message translates to:
  /// **'Companion'**
  String get bondCompanion;

  /// No description provided for @bondNewFriend.
  ///
  /// In en, this message translates to:
  /// **'New Friend'**
  String get bondNewFriend;

  /// No description provided for @bondAcquaintance.
  ///
  /// In en, this message translates to:
  /// **'Acquaintance'**
  String get bondAcquaintance;

  /// No description provided for @bondSharedMoments.
  ///
  /// In en, this message translates to:
  /// **'{count} shared moments'**
  String bondSharedMoments(int count);

  /// No description provided for @calendarThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get calendarThisWeek;

  /// No description provided for @calendarTasks.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String calendarTasks(int count);

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get calendarToday;

  /// No description provided for @calendarTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get calendarTomorrow;

  /// No description provided for @calendarDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String calendarDaysShort(int days);

  /// No description provided for @patternBatchCarer.
  ///
  /// In en, this message translates to:
  /// **'Batch Carer'**
  String get patternBatchCarer;

  /// No description provided for @patternMorningRitual.
  ///
  /// In en, this message translates to:
  /// **'Morning Ritual'**
  String get patternMorningRitual;

  /// No description provided for @patternEveningRitual.
  ///
  /// In en, this message translates to:
  /// **'Evening Ritual'**
  String get patternEveningRitual;

  /// No description provided for @patternWeekendWarrior.
  ///
  /// In en, this message translates to:
  /// **'Weekend Warrior'**
  String get patternWeekendWarrior;

  /// No description provided for @patternSeasonalDip.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Dip'**
  String get patternSeasonalDip;

  /// No description provided for @patternSeasonalSurge.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Surge'**
  String get patternSeasonalSurge;

  /// No description provided for @patternFavoriteFirst.
  ///
  /// In en, this message translates to:
  /// **'Favorite First'**
  String get patternFavoriteFirst;

  /// No description provided for @patternNeedsLove.
  ///
  /// In en, this message translates to:
  /// **'Needs Love'**
  String get patternNeedsLove;

  /// No description provided for @patternDiverseRoutine.
  ///
  /// In en, this message translates to:
  /// **'Diverse Routine'**
  String get patternDiverseRoutine;

  /// No description provided for @patternFocusedCarer.
  ///
  /// In en, this message translates to:
  /// **'Focused Carer'**
  String get patternFocusedCarer;

  /// No description provided for @patternTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Care Patterns'**
  String get patternTitle;

  /// No description provided for @seasonalAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Transition'**
  String get seasonalAlertTitle;

  /// No description provided for @seasonalAlertComing.
  ///
  /// In en, this message translates to:
  /// **'{season} is coming'**
  String seasonalAlertComing(String season);

  /// No description provided for @seasonalAlertUrgent.
  ///
  /// In en, this message translates to:
  /// **'{count} plants need prep'**
  String seasonalAlertUrgent(int count);

  /// No description provided for @seasonalAlertDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String seasonalAlertDays(int days);

  /// No description provided for @seasonalReportActions.
  ///
  /// In en, this message translates to:
  /// **'actions'**
  String get seasonalReportActions;

  /// No description provided for @seasonalReportPlants.
  ///
  /// In en, this message translates to:
  /// **'plants'**
  String get seasonalReportPlants;

  /// No description provided for @seasonalReportPerWeek.
  ///
  /// In en, this message translates to:
  /// **'/week'**
  String get seasonalReportPerWeek;

  /// No description provided for @seasonalReportImprovement.
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs last season'**
  String seasonalReportImprovement(String percent);

  /// No description provided for @xpLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String xpLevelTitle(int level);

  /// No description provided for @xpLevelProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {next} to next level'**
  String xpLevelProgress(int current, int next);

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get resetAll;
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
