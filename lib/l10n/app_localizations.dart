import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'WellQ'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your Health, Our Priority'**
  String get tagline;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @loginCanceled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in canceled.'**
  String get loginCanceled;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Error signing in: {error}'**
  String loginError(String error);

  /// No description provided for @navHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get navHealth;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navCommit.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get navCommit;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light/Dark mode'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure alerts'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageValueSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingsLanguageValueSystem;

  /// No description provided for @settingsLanguageValueEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageValueEs;

  /// No description provided for @settingsLanguageValueEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageValueEn;

  /// No description provided for @devTools.
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get devTools;

  /// No description provided for @dbViewer.
  ///
  /// In en, this message translates to:
  /// **'Database Viewer'**
  String get dbViewer;

  /// No description provided for @dbViewerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage local database'**
  String get dbViewerSubtitle;

  /// No description provided for @insertTestHealthData.
  ///
  /// In en, this message translates to:
  /// **'Insert Test Health Data'**
  String get insertTestHealthData;

  /// No description provided for @insertTestHealthDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Populate Health Connect with sample data'**
  String get insertTestHealthDataSubtitle;

  /// No description provided for @clearTestData.
  ///
  /// In en, this message translates to:
  /// **'Clear Test Data'**
  String get clearTestData;

  /// No description provided for @clearTestDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all test health data'**
  String get clearTestDataSubtitle;

  /// No description provided for @forceSaveMetrics.
  ///
  /// In en, this message translates to:
  /// **'Force Save Metrics'**
  String get forceSaveMetrics;

  /// No description provided for @forceSaveMetricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save current health data to database'**
  String get forceSaveMetricsSubtitle;

  /// No description provided for @confirmClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Test Data?'**
  String get confirmClearTitle;

  /// No description provided for @confirmClearBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all test health data from Health Connect. Your habits and other app data will remain safe.'**
  String get confirmClearBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @insertingTestData.
  ///
  /// In en, this message translates to:
  /// **'Inserting test data...'**
  String get insertingTestData;

  /// No description provided for @insertOk.
  ///
  /// In en, this message translates to:
  /// **'Test data inserted successfully!'**
  String get insertOk;

  /// No description provided for @insertFail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String insertFail(String error);

  /// No description provided for @clearOk.
  ///
  /// In en, this message translates to:
  /// **'Test data cleared'**
  String get clearOk;

  /// No description provided for @clearFail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String clearFail(String error);

  /// No description provided for @checkLogs.
  ///
  /// In en, this message translates to:
  /// **'Check logs for details'**
  String get checkLogs;

  /// No description provided for @dailyCommitmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Commitments'**
  String get dailyCommitmentsTitle;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todaysProgress;

  /// No description provided for @commitmentsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} commitments completed'**
  String commitmentsCompleted(int done, int total);

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @todaysEvents.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Events'**
  String get todaysEvents;

  /// No description provided for @noEventsToday.
  ///
  /// In en, this message translates to:
  /// **'No events for today'**
  String get noEventsToday;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @aiSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Optimized Session'**
  String get aiSessionTitle;

  /// No description provided for @aiSessionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobility focus · {minutes} min'**
  String aiSessionSubtitle(int minutes);

  /// No description provided for @basedOnRecovery.
  ///
  /// In en, this message translates to:
  /// **'Based on your recovery data'**
  String get basedOnRecovery;

  /// No description provided for @healthVitals.
  ///
  /// In en, this message translates to:
  /// **'Health Vitals'**
  String get healthVitals;

  /// No description provided for @vitalsTab.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get vitalsTab;

  /// No description provided for @metricsTab.
  ///
  /// In en, this message translates to:
  /// **'Metrics'**
  String get metricsTab;

  /// No description provided for @healthMetrics.
  ///
  /// In en, this message translates to:
  /// **'Health Metrics'**
  String get healthMetrics;

  /// No description provided for @stepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsLabel;

  /// No description provided for @sleepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @weightUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get weightUnitKg;

  /// No description provided for @exerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseLabel;

  /// No description provided for @stressLabel.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get stressLabel;

  /// No description provided for @currentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentLabel;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @statusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get statusLow;

  /// No description provided for @statusModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get statusModerate;

  /// No description provided for @statusHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get statusHigh;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @statusOptimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get statusOptimal;

  /// No description provided for @statusLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get statusLight;

  /// No description provided for @usingMockData.
  ///
  /// In en, this message translates to:
  /// **'Using mock data'**
  String get usingMockData;

  /// No description provided for @updatedAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedAgo(String time);

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String timeMinutes(int m);

  /// No description provided for @timeHours.
  ///
  /// In en, this message translates to:
  /// **'{h}h'**
  String timeHours(int h);

  /// No description provided for @timeDays.
  ///
  /// In en, this message translates to:
  /// **'{d}d'**
  String timeDays(int d);

  /// No description provided for @recoveryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Recovery Optimization'**
  String get recoveryOptimization;

  /// No description provided for @recoveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recoveryLabel;

  /// No description provided for @heartRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRateLabel;

  /// No description provided for @recoveryBreadcrumb.
  ///
  /// In en, this message translates to:
  /// **'{program} • Day {day}'**
  String recoveryBreadcrumb(String program, int day);

  /// No description provided for @weeklyChange.
  ///
  /// In en, this message translates to:
  /// **'{percent} this week'**
  String weeklyChange(String percent);

  /// No description provided for @connectHealth.
  ///
  /// In en, this message translates to:
  /// **'Connect Health'**
  String get connectHealth;

  /// No description provided for @boneLabel.
  ///
  /// In en, this message translates to:
  /// **'Bone'**
  String get boneLabel;

  /// No description provided for @densityLabel.
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get densityLabel;

  /// No description provided for @muscleLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle'**
  String get muscleLabel;

  /// No description provided for @strengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strengthLabel;

  /// No description provided for @jointLabel.
  ///
  /// In en, this message translates to:
  /// **'Joint'**
  String get jointLabel;

  /// No description provided for @mobilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get mobilityLabel;

  /// No description provided for @cardioLabel.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardioLabel;

  /// No description provided for @vo2maxLabel.
  ///
  /// In en, this message translates to:
  /// **'VO2 Max'**
  String get vo2maxLabel;

  /// No description provided for @startStreak.
  ///
  /// In en, this message translates to:
  /// **'Start streak'**
  String get startStreak;

  /// No description provided for @streakActiveDays.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String streakActiveDays(int days);

  /// No description provided for @todaysHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Habits'**
  String get todaysHabitsTitle;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @habitPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get habitPending;

  /// No description provided for @habitDone.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get habitDone;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutes(int count);

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @completeAction.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeAction;

  /// No description provided for @completeEarly.
  ///
  /// In en, this message translates to:
  /// **'Complete Early'**
  String get completeEarly;

  /// No description provided for @skipToNext.
  ///
  /// In en, this message translates to:
  /// **'Skip to Next'**
  String get skipToNext;

  /// No description provided for @completeNow.
  ///
  /// In en, this message translates to:
  /// **'Complete Now'**
  String get completeNow;

  /// No description provided for @stepOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOfTotal(int step, int total);

  /// No description provided for @habitSnackStart.
  ///
  /// In en, this message translates to:
  /// **'Great start! Begin your streak!'**
  String get habitSnackStart;

  /// No description provided for @habitSnackNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New record! {days}-day streak!'**
  String habitSnackNewRecord(int days);

  /// No description provided for @habitSnackAmazing.
  ///
  /// In en, this message translates to:
  /// **'Amazing! {days}-day streak!'**
  String habitSnackAmazing(int days);

  /// No description provided for @habitSnackCompleted.
  ///
  /// In en, this message translates to:
  /// **'Habit completed! {days}-day streak!'**
  String habitSnackCompleted(int days);

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get noHabitsYet;

  /// No description provided for @addFirstHabit.
  ///
  /// In en, this message translates to:
  /// **'Add your first habit to get started'**
  String get addFirstHabit;

  /// No description provided for @habitMorningStretches.
  ///
  /// In en, this message translates to:
  /// **'Morning Stretches'**
  String get habitMorningStretches;

  /// No description provided for @habitPhysicalTherapy.
  ///
  /// In en, this message translates to:
  /// **'Physical Therapy'**
  String get habitPhysicalTherapy;

  /// No description provided for @habitEveningWalk.
  ///
  /// In en, this message translates to:
  /// **'Evening Walk'**
  String get habitEveningWalk;

  /// No description provided for @habitMeditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get habitMeditation;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @createAccountHeader.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccountHeader;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join our health community'**
  String get joinCommunity;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordHint;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
  String get orSignUpWith;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @createAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountCta;

  /// No description provided for @accountCreatedOk.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedOk;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationFailed(String error);

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String passwordMinChars(int min);

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept Terms & Conditions'**
  String get pleaseAcceptTerms;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get emailAlreadyRegistered;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get passwordTooWeak;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @registrationGenericError.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationGenericError;

  /// No description provided for @enterEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailAndPassword;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get wrongCredentials;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get userDisabled;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later'**
  String get tooManyRequests;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet'**
  String get networkError;

  /// No description provided for @signInGenericError.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in. Try again'**
  String get signInGenericError;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error. Try again'**
  String get unexpectedError;

  /// No description provided for @hiUser.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String hiUser(String name);

  /// No description provided for @myTrainingOverline.
  ///
  /// In en, this message translates to:
  /// **'My training'**
  String get myTrainingOverline;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @sessionsXofY.
  ///
  /// In en, this message translates to:
  /// **'Sessions: {done}/{total}'**
  String sessionsXofY(int done, int total);

  /// No description provided for @planSessions.
  ///
  /// In en, this message translates to:
  /// **'{count}-session plan'**
  String planSessions(int count);

  /// No description provided for @goalPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Goal: {count}/week'**
  String goalPerWeek(int count);

  /// No description provided for @nextWorkoutOverline.
  ///
  /// In en, this message translates to:
  /// **'Next workout'**
  String get nextWorkoutOverline;

  /// No description provided for @openMyWorkout.
  ///
  /// In en, this message translates to:
  /// **'Open my workout'**
  String get openMyWorkout;

  /// No description provided for @todayWorkoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today {time} • Category {category}'**
  String todayWorkoutSubtitle(String time, String category);

  /// No description provided for @seeOtherWorkouts.
  ///
  /// In en, this message translates to:
  /// **'See other workout options'**
  String get seeOtherWorkouts;

  /// No description provided for @yourRoutineOverline.
  ///
  /// In en, this message translates to:
  /// **'Your routine'**
  String get yourRoutineOverline;

  /// No description provided for @consecutiveTrainingWeeks.
  ///
  /// In en, this message translates to:
  /// **'Consecutive\ntraining weeks'**
  String get consecutiveTrainingWeeks;

  /// No description provided for @trainingCommitment.
  ///
  /// In en, this message translates to:
  /// **'Training\ncommitment'**
  String get trainingCommitment;

  /// No description provided for @treatmentCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Treatment Categories'**
  String get treatmentCategoriesTitle;

  /// No description provided for @recoveryProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery Program'**
  String get recoveryProgramTitle;

  /// No description provided for @therapeuticExercisesRehab.
  ///
  /// In en, this message translates to:
  /// **'Therapeutic exercises for rehabilitation'**
  String get therapeuticExercisesRehab;

  /// No description provided for @recoveryExercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recovery exercises'**
  String recoveryExercisesCount(int count);

  /// No description provided for @injuryLigamentTear.
  ///
  /// In en, this message translates to:
  /// **'Ligament Tear'**
  String get injuryLigamentTear;

  /// No description provided for @injuryRotatorCuff.
  ///
  /// In en, this message translates to:
  /// **'Rotator Cuff Issues'**
  String get injuryRotatorCuff;

  /// No description provided for @injuryTendinitis.
  ///
  /// In en, this message translates to:
  /// **'Tendinitis'**
  String get injuryTendinitis;

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category {letter}'**
  String categoryTitle(String letter);

  /// No description provided for @therapeuticRecoveryExercises.
  ///
  /// In en, this message translates to:
  /// **'Therapeutic recovery exercises'**
  String get therapeuticRecoveryExercises;

  /// No description provided for @tapForInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap for instructions'**
  String get tapForInstructions;

  /// No description provided for @completeSession.
  ///
  /// In en, this message translates to:
  /// **'Complete session'**
  String get completeSession;

  /// No description provided for @sessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Session completed and saved'**
  String get sessionSaved;

  /// No description provided for @exerciseInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Instructions'**
  String get exerciseInstructionsTitle;

  /// No description provided for @stepByStepInstructions.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step instructions'**
  String get stepByStepInstructions;

  /// No description provided for @safetyTips.
  ///
  /// In en, this message translates to:
  /// **'Safety tips'**
  String get safetyTips;

  /// No description provided for @backToExerciseList.
  ///
  /// In en, this message translates to:
  /// **'Back to exercise list'**
  String get backToExerciseList;

  /// No description provided for @todaysCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s check-in'**
  String get todaysCheckInTitle;

  /// No description provided for @checkInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us how you feel after the session.'**
  String get checkInSubtitle;

  /// No description provided for @painLevel.
  ///
  /// In en, this message translates to:
  /// **'Pain level'**
  String get painLevel;

  /// No description provided for @stiffness.
  ///
  /// In en, this message translates to:
  /// **'Stiffness'**
  String get stiffness;

  /// No description provided for @howDoYouFeelToday.
  ///
  /// In en, this message translates to:
  /// **'How do you feel today?'**
  String get howDoYouFeelToday;

  /// No description provided for @anyObservationsHint.
  ///
  /// In en, this message translates to:
  /// **'Any observations?'**
  String get anyObservationsHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @statusImproving.
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get statusImproving;

  /// No description provided for @statusFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get statusFlexible;

  /// No description provided for @statusStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get statusStable;

  /// No description provided for @statusStiff.
  ///
  /// In en, this message translates to:
  /// **'Stiff'**
  String get statusStiff;

  /// No description provided for @iAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeTo;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @calendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule and track your recovery activities'**
  String get calendarSubtitle;

  /// No description provided for @reminderTakeMedication.
  ///
  /// In en, this message translates to:
  /// **'Take medication'**
  String get reminderTakeMedication;

  /// No description provided for @reminderIceTherapy.
  ///
  /// In en, this message translates to:
  /// **'Ice therapy session'**
  String get reminderIceTherapy;

  /// No description provided for @reminderLogPainLevels.
  ///
  /// In en, this message translates to:
  /// **'Log pain levels'**
  String get reminderLogPainLevels;

  /// No description provided for @dueIn.
  ///
  /// In en, this message translates to:
  /// **'Due in {time}'**
  String dueIn(String time);

  /// No description provided for @healthPermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Permissions Required'**
  String get healthPermsTitle;

  /// No description provided for @healthPermsBody.
  ///
  /// In en, this message translates to:
  /// **'Please grant access to Health Connect to track your daily commitments and health metrics'**
  String get healthPermsBody;

  /// No description provided for @grantPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get grantPermissions;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboard;

  /// No description provided for @commitDrinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink {liters} liters of water'**
  String commitDrinkWater(int liters);

  /// No description provided for @commitSleepHours.
  ///
  /// In en, this message translates to:
  /// **'Sleep {hours} hours'**
  String commitSleepHours(int hours);

  /// No description provided for @commitConsumeCalories.
  ///
  /// In en, this message translates to:
  /// **'Consume {kcals} calories'**
  String commitConsumeCalories(int kcals);

  /// No description provided for @unitSteps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get unitSteps;

  /// No description provided for @commitWalkSteps.
  ///
  /// In en, this message translates to:
  /// **'Walk {count} steps'**
  String commitWalkSteps(int count);

  /// No description provided for @commitDrinkWaterLiters.
  ///
  /// In en, this message translates to:
  /// **'Drink {liters} liters of water'**
  String commitDrinkWaterLiters(int liters);

  /// No description provided for @unitStepsShort.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get unitStepsShort;

  /// No description provided for @unitLitersShort.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unitLitersShort;

  /// No description provided for @unitHours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get unitHours;

  /// No description provided for @unitKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Your longest streak: {days} days'**
  String longestStreak(int days);
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
